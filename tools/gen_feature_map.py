#!/usr/bin/env python3
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCES = ["YTLite.x", "YTNativeShare.x"]


def selector(signature):
    signature = re.sub(r"^\s*\([^)]*\)", "", signature, count=1)
    signature = re.sub(r"\([^()]*(\([^()]*\)[^()]*)*\)", "", signature)
    parts = re.findall(r"(\w+)\s*:", signature)
    if parts:
        return "".join(p + ":" for p in parts)
    m = re.match(r"\s*(\w+)", signature)
    return m.group(1) if m else None


def build_map():
    gates = {}
    for name in SOURCES:
        current = sel = None
        new = False
        for line in (ROOT / name).read_text().splitlines():
            s = line.strip()
            m = re.match(r"%hook (\w+)", s)
            if m:
                current, sel = m.group(1), None
                continue
            if s.startswith("%end"):
                current = sel = None
                continue
            if s.startswith("%new"):
                new = True
                continue
            if current and re.match(r"^[-+]\s*\(", s):
                sel = None if new else s[0] + selector(s[1:].split("{")[0])
                new = False
            if current and sel:
                for key in re.findall(r'ytlBool\(@"(\w+)"\)', line):
                    gates.setdefault(key, set()).add((current, sel))
    return gates


def render(gates):
    lines = ["static NSDictionary <NSString *, NSArray <NSString *> *> *YTLFeatureGates(void) {",
             "    return @{"]
    for key in sorted(gates):
        entries = ", ".join('@"%s %s"' % (cls, sel) for cls, sel in sorted(gates[key]))
        lines.append('        @"%s": @[%s],' % (key, entries))
    lines += ["    };", "}", ""]
    return "\n".join(lines)


if __name__ == "__main__":
    out = ROOT / "YTLFeatureMap.h"
    content = render(build_map())
    if "--check" in sys.argv:
        sys.exit(0 if out.exists() and out.read_text() == content else "YTLFeatureMap.h is out of date, run tools/gen_feature_map.py")
    if not out.exists() or out.read_text() != content:
        out.write_text(content)
