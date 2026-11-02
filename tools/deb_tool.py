#!/usr/bin/env python3
import argparse
import gzip
import io
import lzma
import os
import sys
import tarfile

AR_MAGIC = b"!<arch>\n"


def read_ar(path):
    with open(path, "rb") as f:
        data = f.read()
    if not data.startswith(AR_MAGIC):
        raise ValueError("not an ar archive")
    members, offset = [], len(AR_MAGIC)
    while offset + 60 <= len(data):
        header = data[offset:offset + 60]
        name = header[:16].decode().strip()
        size = int(header[48:58].decode().strip())
        offset += 60
        if name.startswith("#1/"):
            name_len = int(name[3:])
            name = data[offset:offset + name_len].decode().rstrip("\0")
            body = data[offset + name_len:offset + size]
        else:
            body = data[offset:offset + size]
        members.append((name.rstrip("/"), body))
        offset += size + (size % 2)
    return members


def write_ar(path, members):
    with open(path, "wb") as f:
        f.write(AR_MAGIC)
        for name, body in members:
            header = "%-16s%-12s%-6s%-6s%-8s%-10s`\n" % (name, "0", "0", "0", "100644", len(body))
            f.write(header.encode())
            f.write(body)
            if len(body) % 2:
                f.write(b"\n")


def open_tar(name, body):
    if name.endswith(".lzma"):
        body = lzma.decompress(body, format=lzma.FORMAT_ALONE)
        return tarfile.open(fileobj=io.BytesIO(body), mode="r:")
    if name.endswith(".zst"):
        import subprocess
        body = subprocess.run(["zstd", "-dc"], input=body, stdout=subprocess.PIPE, check=True).stdout
        return tarfile.open(fileobj=io.BytesIO(body), mode="r:")
    return tarfile.open(fileobj=io.BytesIO(body), mode="r:*")


def data_member(members):
    for i, (name, body) in enumerate(members):
        if name.startswith("data.tar"):
            return i, name, body
    raise ValueError("no data.tar in deb")


def control_fields(members):
    for name, body in members:
        if name.startswith("control.tar"):
            with open_tar(name, body) as tar:
                for member in tar.getmembers():
                    if os.path.basename(member.name) == "control":
                        text = tar.extractfile(member).read().decode(errors="ignore")
                        return dict(line.split(":", 1) for line in text.splitlines() if ":" in line and not line.startswith(" "))
    return {}


def inspect(path):
    members = read_ar(path)
    if not members or members[0][0] != "debian-binary":
        raise ValueError("not a deb (missing debian-binary)")
    _, name, body = data_member(members)
    with open_tar(name, body) as tar:
        files = [m.name for m in tar.getmembers()]
    fields = {k.strip(): v.strip() for k, v in control_fields(members).items()}
    return fields, files


def strip_lproj(path, keep, add_dir):
    members = read_ar(path)
    index, name, body = data_member(members)
    out = io.BytesIO()
    removed = 0
    bundle_prefix = None

    with open_tar(name, body) as src, tarfile.open(fileobj=out, mode="w:xz", format=tarfile.GNU_FORMAT) as dst:
        for member in src.getmembers():
            parts = member.name.split("/")
            lproj = next((p for p in parts if p.endswith(".lproj")), None)
            if "YTLite.bundle" in parts and bundle_prefix is None:
                bundle_prefix = "/".join(parts[:parts.index("YTLite.bundle") + 1])
            if lproj and "YTLite.bundle" in parts and lproj[:-6] not in keep:
                removed += 1
                continue
            if add_dir and lproj and "YTLite.bundle" in parts and lproj[:-6] in keep and lproj[:-6] != "en":
                if os.path.isdir(os.path.join(add_dir, lproj)):
                    continue
            dst.addfile(member, src.extractfile(member) if member.isfile() else None)

        if add_dir and bundle_prefix:
            for lang in keep:
                if lang == "en":
                    continue
                folder = os.path.join(add_dir, lang + ".lproj")
                if not os.path.isdir(folder):
                    continue
                for root, _, files in os.walk(folder):
                    rel_root = os.path.relpath(root, add_dir)
                    info = tarfile.TarInfo("%s/%s" % (bundle_prefix, rel_root))
                    info.type, info.mode = tarfile.DIRTYPE, 0o755
                    dst.addfile(info)
                    for f in sorted(files):
                        full = os.path.join(root, f)
                        info = tarfile.TarInfo("%s/%s/%s" % (bundle_prefix, rel_root, f))
                        info.size, info.mode = os.path.getsize(full), 0o644
                        with open(full, "rb") as fh:
                            dst.addfile(info, fh)

    members[index] = ("data.tar.xz", out.getvalue())
    write_ar(path, members)
    return removed


def main():
    parser = argparse.ArgumentParser(description="Small deb helper that needs no dpkg")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("validate")
    p.add_argument("deb")
    p.add_argument("--package")
    p.add_argument("--require", action="append", default=[])

    p = sub.add_parser("strip-lproj")
    p.add_argument("deb")
    p.add_argument("--keep", default="en,fr")
    p.add_argument("--add-from")

    args = parser.parse_args()

    try:
        if args.cmd == "validate":
            fields, files = inspect(args.deb)
            if args.package and fields.get("Package") != args.package:
                sys.exit("unexpected package id: %s" % fields.get("Package"))
            for needle in args.require:
                if not any(needle in f for f in files):
                    sys.exit("missing %s in %s" % (needle, os.path.basename(args.deb)))
            print("%s %s ok (%d files)" % (fields.get("Package"), fields.get("Version"), len(files)))
        else:
            keep = [k.strip() for k in args.keep.split(",") if k.strip()]
            removed = strip_lproj(args.deb, keep, args.add_from)
            print("removed %d localization files, kept %s" % (removed, ", ".join(keep)))
    except (ValueError, OSError, tarfile.TarError, lzma.LZMAError, EOFError, gzip.BadGzipFile) as error:
        sys.exit("%s: %s" % (os.path.basename(args.deb), error))


if __name__ == "__main__":
    main()
