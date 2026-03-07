#!/usr/bin/env python3
"""
patch_ytlite.py - Fix playbackRate crashes in YTLite .deb or .dylib

The official YTLite dylib calls [YTSingleVideoController playbackRate] and
[YTSingleVideoController setPlaybackRate:] directly. In newer YouTube versions
(e.g. 21.07+), these selectors no longer exist on YTSingleVideoController,
causing unrecognized selector crashes.

Two fix strategies:
  1. Companion dylib (deb mode) — injects YTLPlaybackRateFix.dylib which adds
     the missing methods via ObjC runtime. Speed overlay fully works.
  2. Binary patches (dylib mode / fallback) — replaces getter calls with
     rate=1.0 and NOPs setter calls. Prevents crash, speed buttons are no-ops.

Usage:
  python3 patch_ytlite.py YTLite.deb                    # patch deb (full fix)
  python3 patch_ytlite.py YTLite.deb -o fixed.deb       # patch deb -> fixed.deb
  python3 patch_ytlite.py YTLite.dylib                  # patch dylib (crash fix only)
"""

import argparse
import os
import plistlib
import shutil
import struct
import subprocess
import sys
import tempfile

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# ARM64 instruction encodings (little-endian)
FCMP_S0_ZERO  = bytes([0x08, 0x20, 0x20, 0x1E])  # fcmp s0, #0.0
SCVTF_S0_WZR  = bytes([0xE0, 0x03, 0x22, 0x1E])  # scvtf s0, wzr (= 0.0)
FMOV_S0_1     = bytes([0x00, 0x10, 0x2E, 0x1E])  # fmov s0, #1.0
FMOV_S1_NEG25 = bytes([0x01, 0x10, 0x3A, 0x1E])  # fmov s1, #-0.25
FMOV_S1_POS25 = bytes([0x01, 0x10, 0x2A, 0x1E])  # fmov s1, #0.25
NOP           = bytes([0x1F, 0x20, 0x03, 0xD5])  # nop


def run(cmd, **kwargs):
    return subprocess.run(cmd, capture_output=True, text=True, **kwargs)


def is_bl(instr_bytes):
    return len(instr_bytes) == 4 and 0x94 <= instr_bytes[3] <= 0x97


def bl_target(pc, instr_bytes):
    val = struct.unpack('<I', instr_bytes)[0]
    imm26 = val & 0x3FFFFFF
    if imm26 & 0x2000000:
        imm26 -= 0x4000000
    return pc + imm26 * 4


def find_func_offset(dylib, func="_addEndTime", arch="arm64"):
    for cmd in [["nm", "-arch", arch, dylib], ["nm", dylib]]:
        r = run(cmd)
        for line in r.stdout.splitlines():
            parts = line.split()
            if len(parts) >= 3 and parts[2] == func:
                return int(parts[0], 16)
    return None


def get_section_info(dylib, sectname, arch="arm64"):
    for cmd in [["otool", "-arch", arch, "-l", dylib], ["otool", "-l", dylib]]:
        r = run(cmd)
        in_sect = False
        addr = size = offset = None
        for line in r.stdout.splitlines():
            l = line.strip()
            if f"sectname {sectname}" in l:
                in_sect = True
            elif in_sect:
                if l.startswith("addr "):
                    addr = int(l.split()[-1], 16)
                elif l.startswith("size "):
                    size = int(l.split()[-1], 16)
                elif l.startswith("offset "):
                    offset = int(l.split()[-1])
                elif l.startswith("sectname"):
                    break
        if addr is not None:
            return addr, size, offset
    return None, None, None


def is_fat(path):
    return "universal" in run(["file", path]).stdout.lower()


def get_archs(path):
    r = run(["lipo", "-archs", path])
    return r.stdout.strip().split() if r.returncode == 0 else []


# ── Binary patching (fallback for dylib-only mode) ──

def patch_slice_binary(dylib, arch="arm64"):
    """Apply binary patches to a single-arch dylib. Fallback when companion isn't available."""
    sect_addr, _, sect_offset = get_section_info(dylib, "__text", arch)
    if sect_addr is None:
        print(f"    __text section not found")
        return False

    stubs_addr, stubs_size, _ = get_section_info(dylib, "__objc_stubs", arch)
    patched = False

    # Patch 1: addEndTime getter — bl <playbackRate>; fcmp s0, #0.0
    func_va = find_func_offset(dylib, arch=arch)
    getter_stub = None

    if func_va is not None:
        file_off = func_va - sect_addr + sect_offset
        print(f"    _addEndTime at VA 0x{func_va:x}")
        with open(dylib, "r+b") as f:
            f.seek(file_off)
            func_bytes = f.read(512)
            idx = func_bytes.find(FCMP_S0_ZERO)
            if idx >= 4:
                bl_bytes = func_bytes[idx - 4 : idx]
                if bl_bytes == SCVTF_S0_WZR:
                    print(f"    [1/3] addEndTime getter: already patched")
                    patched = True
                elif is_bl(bl_bytes):
                    getter_stub = bl_target(func_va + idx - 4, bl_bytes)
                    f.seek(file_off + idx - 4)
                    f.write(SCVTF_S0_WZR)
                    print(f"    [1/3] addEndTime getter: patched")
                    patched = True

    # Patch 2 & 3: Speed overlay getter + setter
    with open(dylib, "rb") as f:
        data = f.read()

    setter_stub = None
    getter_patches = []
    setter_patches = []

    for marker, label in [(FMOV_S1_NEG25, "decrease"), (FMOV_S1_POS25, "increase")]:
        pos = 0
        while True:
            idx = data.find(marker, pos)
            if idx < 4 or idx == -1:
                break
            pos = idx + 4
            bl_bytes = data[idx - 4 : idx]
            if not is_bl(bl_bytes):
                continue
            bl_va = (idx - 4 - sect_offset) + sect_addr
            target = bl_target(bl_va, bl_bytes)
            if stubs_addr and not (stubs_addr <= target < stubs_addr + stubs_size):
                continue
            if getter_stub is None:
                getter_stub = target
            elif getter_stub != target:
                continue
            getter_patches.append((idx - 4, label))
            for scan in range(idx, min(idx + 160, len(data) - 4), 4):
                candidate = data[scan : scan + 4]
                if is_bl(candidate):
                    cand_va = (scan - sect_offset) + sect_addr
                    cand_target = bl_target(cand_va, candidate)
                    if stubs_addr and stubs_addr <= cand_target < stubs_addr + stubs_size:
                        if cand_target != getter_stub:
                            if setter_stub is None:
                                setter_stub = cand_target
                            if cand_target == setter_stub:
                                setter_patches.append((scan, f"{label} setter"))
                            break

    pos = 0
    while True:
        idx = data.find(FMOV_S0_1, pos)
        if idx == -1 or idx + 8 > len(data):
            break
        pos = idx + 4
        bl_bytes = data[idx + 4 : idx + 8]
        if not is_bl(bl_bytes):
            continue
        bl_va = (idx + 4 - sect_offset) + sect_addr
        target = bl_target(bl_va, bl_bytes)
        if stubs_addr and not (stubs_addr <= target < stubs_addr + stubs_size):
            continue
        if setter_stub is None:
            setter_stub = target
        if target == setter_stub:
            setter_patches.append((idx + 4, "reset setter"))

    with open(dylib, "r+b") as f:
        seen = set()
        for off, label in getter_patches:
            if off not in seen:
                seen.add(off)
                f.seek(off)
                if f.read(4) != FMOV_S0_1:
                    f.seek(off)
                    f.write(FMOV_S0_1)
                    print(f"    [2/3] speed {label} getter at 0x{off:x}: patched")
                    patched = True

        for off, label in setter_patches:
            if off not in seen:
                seen.add(off)
                f.seek(off)
                if f.read(4) != NOP:
                    f.seek(off)
                    f.write(NOP)
                    print(f"    [3/3] speed {label} at 0x{off:x}: patched")
                    patched = True

    return patched


def patch_dylib_binary(dylib_path):
    """Binary-patch a dylib (thin or fat)."""
    patched_any = False
    if is_fat(dylib_path):
        archs = get_archs(dylib_path)
        print(f"  fat binary: {', '.join(archs)}")
        with tempfile.TemporaryDirectory() as tmp:
            slices = {}
            for arch in archs:
                thin = os.path.join(tmp, f"{arch}.dylib")
                run(["lipo", dylib_path, "-thin", arch, "-output", thin])
                slices[arch] = thin
                if arch in ("arm64", "arm64e"):
                    print(f"  [{arch}]")
                    if patch_slice_binary(thin, arch):
                        patched_any = True
                else:
                    print(f"  [{arch}] skipped (32-bit)")
            cmd = ["lipo", "-create"]
            for arch, path in slices.items():
                cmd += ["-arch", arch, path]
            cmd += ["-output", dylib_path]
            run(cmd)
    else:
        file_info = run(["file", dylib_path]).stdout
        arch = "arm64e" if "arm64e" in file_info else "arm64"
        print(f"  thin binary: {arch}")
        print(f"  [{arch}]")
        if patch_slice_binary(dylib_path, arch):
            patched_any = True
    return patched_any


# ── Companion dylib (full fix for deb mode) ──

def compile_companion(output_path):
    """Compile YTLPlaybackRateFix.dylib from source."""
    source = os.path.join(SCRIPT_DIR, "YTLPlaybackRateFix.m")
    if not os.path.exists(source):
        return False

    print(f"[*] compiling companion dylib from {os.path.basename(source)}")
    r = run([
        "xcrun", "--sdk", "iphoneos", "clang",
        "-arch", "arm64", "-arch", "arm64e",
        "-dynamiclib",
        "-framework", "Foundation", "-framework", "UIKit",
        "-fobjc-arc",
        "-install_name", "@rpath/YTLPlaybackRateFix.dylib",
        "-miphoneos-version-min=13.0",
        "-o", output_path,
        source,
    ])
    if r.returncode != 0:
        print(f"[!] compilation failed: {r.stderr.strip()}")
        return False

    # codesign with ad-hoc
    run(["ldid", "-S", output_path])
    print(f"[*] compiled {os.path.basename(output_path)} ({os.path.getsize(output_path)} bytes)")
    return True


def inject_companion(extract_dir, companion_dylib):
    """Add companion dylib + filter plist into the extracted deb."""
    # Find the DynamicLibraries directory
    ms_dir = None
    for root, dirs, files in os.walk(extract_dir):
        if os.path.basename(root) == "DynamicLibraries":
            ms_dir = root
            break

    if not ms_dir:
        ms_dir = os.path.join(extract_dir, "Library", "MobileSubstrate", "DynamicLibraries")
        os.makedirs(ms_dir, exist_ok=True)

    # Copy dylib
    dst_dylib = os.path.join(ms_dir, "YTLPlaybackRateFix.dylib")
    shutil.copy2(companion_dylib, dst_dylib)

    # Create filter plist (same filter as YTLite — target YouTube)
    plist_data = {
        "Filter": {
            "Bundles": ["com.google.ios.youtube"]
        }
    }
    dst_plist = os.path.join(ms_dir, "YTLPlaybackRateFix.plist")
    with open(dst_plist, "wb") as f:
        plistlib.dump(plist_data, f)

    print(f"[*] injected companion: {os.path.relpath(dst_dylib, extract_dir)}")


# ── Main entry points ──

def patch_deb(input_deb, output_deb):
    """Extract deb, inject companion dylib, repack."""
    with tempfile.TemporaryDirectory() as tmp:
        extract = os.path.join(tmp, "deb")
        os.makedirs(extract)

        print(f"[*] extracting {input_deb}")
        r = run(["dpkg-deb", "-R", input_deb, extract])
        if r.returncode != 0:
            print(f"[!] dpkg-deb failed: {r.stderr}")
            sys.exit(1)

        # Find dylib
        dylib = None
        for root, _, files in os.walk(extract):
            for f in files:
                if f == "YTLite.dylib":
                    dylib = os.path.join(root, f)
                    break
        if not dylib:
            print("[!] YTLite.dylib not found in deb")
            sys.exit(1)

        print(f"[*] found {os.path.relpath(dylib, extract)}")

        # Try companion dylib approach (full fix)
        companion = os.path.join(tmp, "YTLPlaybackRateFix.dylib")
        if compile_companion(companion):
            inject_companion(extract, companion)
            print(f"[*] companion injected — speed overlay will work")
        else:
            # Fallback to binary patches
            print(f"[!] companion compilation failed, falling back to binary patches")
            print(f"[!] speed overlay buttons will prevent crash but won't change speed")
            if not patch_dylib_binary(dylib):
                print("[!] binary patch also failed")
                sys.exit(1)

        print(f"[*] repacking -> {output_deb}")
        r = run(["dpkg-deb", "-b", extract, output_deb])
        if r.returncode != 0:
            print(f"[!] dpkg-deb repack failed: {r.stderr}")
            sys.exit(1)

    print(f"[+] done: {output_deb}")


def main():
    parser = argparse.ArgumentParser(
        description="Patch YTLite to fix playbackRate crash on newer YouTube"
    )
    parser.add_argument("input", help=".deb or .dylib to patch")
    parser.add_argument("-o", "--output", help="output path (deb only; dylibs are patched in-place)")
    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"[!] not found: {args.input}")
        sys.exit(1)

    if args.input.endswith(".deb"):
        output = args.output or args.input.replace(".deb", "_patched.deb")
        patch_deb(args.input, output)
    elif args.input.endswith(".dylib"):
        print(f"[*] patching {args.input} in-place (binary patch mode)")
        print(f"[*] note: speed overlay buttons will not change speed (use deb mode for full fix)")
        if not patch_dylib_binary(args.input):
            print("[!] patch failed")
            sys.exit(1)
        print("[+] done")
    else:
        print("[!] expected .deb or .dylib file")
        sys.exit(1)


if __name__ == "__main__":
    main()
