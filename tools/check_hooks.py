#!/usr/bin/env python3
import argparse
import os
import tempfile
import json
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LEGACY = set()
SOURCES = ["YTLite.x", "Settings.x", "YTNativeShare.x", "Sideloading.x", "SponsorBlock.x", "Downloads.x"]
SYSTEM_PREFIXES = ("NS", "UI", "CA", "CK", "AV", "MP", "PH", "_UI", "WK", "SK")

INTERFACE_RE = re.compile(r"^@interface (\w+)(?: \((\w*)\))?(?: : (\w+))?")
METHOD_RE = re.compile(r"^([-+])\[(\w+)(?:\(\w*\))? ([^\]]+)\];")
PROPERTY_RE = re.compile(r"^@property \(([^)]*)\)\s*(.*?)\s*(\w+);")
IVAR_RE = re.compile(r"^\s+.*?\b(_\w+);$")


def load_dump(path):
    classes = defaultdict(lambda: {"super": None, "methods": set(), "ivars": set()})
    current = None
    in_ivars = False
    with open(path, errors="ignore") as f:
        for line in f:
            line = line.rstrip("\n")
            m = INTERFACE_RE.match(line)
            if m:
                current = m.group(1)
                if m.group(3) and not m.group(2):
                    classes[current]["super"] = m.group(3)
                in_ivars = line.endswith("{")
                continue
            if line.startswith("@protocol "):
                current = "__protocol__"
                continue
            if line.startswith("@end"):
                current = None
                continue
            if current == "__protocol__":
                continue
            if current is None:
                continue
            if in_ivars:
                if line.startswith("}"):
                    in_ivars = False
                    continue
                m = IVAR_RE.match(line)
                if m:
                    classes[current]["ivars"].add(m.group(1))
                continue
            m = METHOD_RE.match(line)
            if m:
                prefix = "+" if m.group(1) == "+" else "-"
                classes[m.group(2)]["methods"].add(prefix + m.group(3).strip())
                continue
            m = PROPERTY_RE.match(line)
            if m:
                attrs, name = m.group(1).split(","), m.group(3)
                getter = next((a[1:] for a in attrs if a.startswith("G")), name)
                classes[current]["methods"].add("-" + getter)
                if "R" not in attrs:
                    setter = next((a[1:] for a in attrs if a.startswith("S")), "set%s%s:" % (name[0].upper(), name[1:]))
                    classes[current]["methods"].add("-" + setter)
                ivar = next((a[1:] for a in attrs if a.startswith("V")), None)
                if ivar:
                    classes[current]["ivars"].add(ivar)
    return classes


def selector_from_signature(sig):
    sig = re.sub(r"\([^()]*(\([^()]*\)[^()]*)*\)", "", sig)
    parts = re.findall(r"(\w+)\s*:", sig)
    if parts:
        return "".join(p + ":" for p in parts)
    m = re.match(r"\s*(\w+)", sig)
    return m.group(1) if m else None


def parse_sources():
    hooks = []
    classes = set()
    for name in SOURCES:
        path = ROOT / name
        if not path.exists():
            continue
        current = None
        is_new = False
        for lineno, line in enumerate(path.read_text(errors="ignore").splitlines(), 1):
            stripped = line.strip()
            m = re.match(r"%hook (\w+)", stripped)
            if m:
                current = m.group(1)
                if "// legacy" in stripped:
                    LEGACY.add(current)
                classes.add((current, name, lineno))
                continue
            if stripped.startswith("%end"):
                current = None
                continue
            if stripped.startswith("%new"):
                is_new = True
                continue
            if current and re.match(r"^[-+]\s*\(", stripped):
                if is_new:
                    is_new = False
                    continue
                sig = stripped[1:].split("{")[0]
                sel = selector_from_signature(re.sub(r"^\s*\([^)]*\)", "", sig, count=1))
                hooks.append((current, stripped[0] + sel, name, lineno))
            for m in re.finditer(r'%c\((\w+)\)|NSClassFromString\(@"(\w+)"\)|objc_lookUpClass\("(\w+)"\)', line):
                cls = next(g for g in m.groups() if g)
                classes.add((cls, name, lineno))
    return hooks, classes


def runtime_class(classes, cls):
    if cls in classes:
        return cls
    if cls + "Impl" in classes:
        return cls + "Impl"
    return cls


def resolve(classes, cls, sel):
    cls = runtime_class(classes, cls)
    seen = set()
    while cls and cls not in seen:
        seen.add(cls)
        info = classes.get(cls)
        if info is None:
            return "system" if cls.startswith(SYSTEM_PREFIXES) else "unknown"
        if sel in info["methods"]:
            return "ok"
        cls = info["super"]
    return "missing"


def main():
    parser = argparse.ArgumentParser(description="Checks YTLite hooks against a YouTube class-dump")
    parser.add_argument("dump", help="class-dump text of the YouTube binary, or the binary itself with --ipsw")
    parser.add_argument("--ipsw", help="path to ipsw, dumps the given binary first")
    parser.add_argument("--json", help="write the report as JSON")
    parser.add_argument("--github", action="store_true", help="emit GitHub Actions warnings")
    parser.add_argument("--source-dir", help="YTLite source directory (defaults to this repository)")
    args = parser.parse_args()

    global ROOT
    if args.source_dir:
        ROOT = Path(args.source_dir).resolve()

    dump_path = args.dump
    if args.ipsw:
        dump_path = os.path.join(tempfile.gettempdir(), "yt_classdump.txt")
        with open(dump_path, "w") as out:
            subprocess.run([args.ipsw, "class-dump", "--no-color", args.dump], stdout=out, stderr=subprocess.DEVNULL, check=True)

    classes = load_dump(dump_path)
    if len(classes) < 1000:
        sys.exit("class-dump looks empty, is the binary decrypted?")

    hooks, used_classes = parse_sources()
    report = {"missing_classes": [], "missing_methods": [], "checked": len(hooks)}

    for cls, src, line in sorted(used_classes):
        cls = runtime_class(classes, cls)
        if cls not in classes and not cls.startswith(SYSTEM_PREFIXES) and not cls.startswith(("AS", "ELM", "GPB", "MDX", "ML", "_AS", "SSO", "GCK", "GPC", "OGL", "GVR", "APM", "GUL")):
            report["missing_classes"].append({"class": cls, "file": src, "line": line})
        elif cls not in classes and cls.startswith(("AS", "ELM", "MDX", "ML", "_AS")):
            report["missing_classes"].append({"class": cls, "file": src, "line": line})

    for cls, sel, src, line in hooks:
        status = resolve(classes, cls, sel)
        if status == "missing" or (status == "unknown" and runtime_class(classes, cls) not in classes):
            report["missing_methods"].append({"class": cls, "selector": sel, "file": src, "line": line, "status": status})

    seen = set()
    report["missing_classes"] = [c for c in report["missing_classes"] if not (c["class"] in seen or seen.add(c["class"]))]

    def emit(item, msg):
        legacy = item["class"] in LEGACY
        if args.github:
            level = "notice" if legacy else "warning"
            print("::%s file=%s,line=%d::%s%s" % (level, item["file"], item["line"], msg, " (legacy hook, replaced on this version)" if legacy else ""))
        else:
            print(("[legacy] " if legacy else "") + msg)

    for c in report["missing_classes"]:
        emit(c, "class %s not found" % c["class"])
    for m in report["missing_methods"]:
        emit(m, "hooked method not found: %s[%s %s]" % (m["selector"][0], m["class"], m["selector"][1:]))

    active = [m for m in report["missing_methods"] if m["class"] not in LEGACY]
    print("checked %d hooks: %d missing (%d legacy), %d classes not found" % (report["checked"], len(report["missing_methods"]), len(report["missing_methods"]) - len(active), len(report["missing_classes"])))

    if args.json:
        Path(args.json).write_text(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
