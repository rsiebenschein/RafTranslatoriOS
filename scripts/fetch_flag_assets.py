#!/usr/bin/env python3
"""
Fetches the flag SVGs referenced by DialectSeeder.swift (via each SeedDialect's
`assetCode`) and writes them straight into an Xcode asset catalog as SVG
imagesets, so SwiftUI can render them with a plain `Image("flag-<code>")` /
`Image("round-<code>")` - no third-party SVG library needed (Xcode rasterizes
"preserves-vector-representation" SVG imagesets itself).

This mirrors the Android app's scripts/fetch_flag_assets.py, adapted for the
iOS asset-catalog model instead of Android's file:///android_asset/ + Coil
SvgDecoder pipeline: same sources, same licensing, same canton/placeholder
handling, different packaging.

Sources:
  - flat (rectangular):
      lipis/flag-icons (MIT)      -> https://raw.githubusercontent.com/lipis/flag-icons/main/flags/4x3/{code}.svg
      ylerjen/swiss-flags cantons -> https://raw.githubusercontent.com/ylerjen/swiss-flags/master/cantons/{code}.svg
  - round (used for compact contexts):
      HatScripts/circle-flags (MIT) -> https://hatscripts.github.io/circle-flags/flags/{code}.svg
      Swiss cantons: no per-canton round source exists. Canton crests are
      irregular shields with a transparent surround already, so - matching the
      Android script's approach - this just re-declares the flat SVG's
      width/height from its own viewBox instead of leaving them ambiguous;
      it does not force a circular crop.

A handful of German/Italian regional dialect flags have no verified
free-license source yet and get a labeled placeholder instead of a guess.

Usage:
    python3 scripts/fetch_flag_assets.py
"""

import os
import re
import sys
import urllib.request
import urllib.error

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS_DIR = os.path.join(REPO_ROOT, "RafTranslator/Resources/Assets.xcassets")
SEEDER_PATH = os.path.join(REPO_ROOT, "RafTranslator/Data/Persistence/DialectSeeder.swift")
CANTON_REGISTRY_PATH = os.path.join(REPO_ROOT, "RafTranslator/Data/Persistence/SwissCantonRegistry.swift")

LIPIS_FLAT_URL = "https://raw.githubusercontent.com/lipis/flag-icons/main/flags/4x3/{code}.svg"
CIRCLE_FLAGS_ROUND_URL = "https://hatscripts.github.io/circle-flags/flags/{code}.svg"
SWISS_CANTON_FLAT_URL = "https://raw.githubusercontent.com/ylerjen/swiss-flags/master/cantons/{canton}.svg"

# assetCode -> label shown on the placeholder, real source not yet verified
PLACEHOLDER_ASSET_CODES = {
    "de-bavaria": "Bavaria",
    "de-swabia": "Baden-Württemberg",
    "de-saxony": "Saxony",
    "de-cologne": "NRW / Cologne",
    "it-sicily": "Sicily",
}

# Non-German-speaking cantons are seeded under other assetCodes (e.g. plain "ch"),
# so the swiss-german-cantons loop in DialectSeeder.swift never emits these.
NON_GERMAN_CANTON_CODES = {"ge", "vd", "ne", "ju", "ti"}


def extract_asset_codes() -> set:
    """Pull every `assetCode: "..."` literal plus the programmatically-generated
    Swiss canton codes out of DialectSeeder.swift."""
    content = open(SEEDER_PATH, encoding="utf-8").read()
    literal_codes = re.findall(r'assetCode:\s*"([^"\\]+)"', content)
    codes = set(literal_codes)

    registry = open(CANTON_REGISTRY_PATH, encoding="utf-8").read()
    all_cantons = re.findall(r'code:\s*"([A-Z]{2})"', registry)
    codes.update(
        f"ch-{c.lower()}" for c in all_cantons if c.lower() not in NON_GERMAN_CANTON_CODES
    )
    return codes


def fetch(url: str):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "RafTranslator-asset-fetch"})
        with urllib.request.urlopen(req, timeout=15) as resp:
            return resp.read()
    except urllib.error.HTTPError as e:
        if e.code != 404:
            print(f"  ! HTTP {e.code} for {url}")
        return None
    except Exception as e:
        print(f"  ! error fetching {url}: {e}")
        return None


def normalize_intrinsic_size(flat_svg_bytes: bytes) -> bytes:
    """Pin width/height to the SVG's own viewBox aspect ratio so a decoder has an
    unambiguous intrinsic size, without forcing any crop or shape (see module docstring)."""
    svg = flat_svg_bytes.decode("utf-8", errors="ignore")
    svg = re.sub(r"<\?xml[^>]*\?>", "", svg).strip()

    view_box_match = re.search(r'viewBox\s*=\s*"([^"]+)"', svg)
    w, h = (512.0, 512.0)
    if view_box_match:
        parts = view_box_match.group(1).split()
        if len(parts) == 4:
            w, h = float(parts[2]), float(parts[3])

    scale = 600.0 / max(w, h)
    px_w, px_h = round(w * scale), round(h * scale)

    def normalize_root_tag(match: re.Match) -> str:
        tag = match.group(0)
        tag = re.sub(r'\s*width="[^"]*"', "", tag)
        tag = re.sub(r'\s*height="[^"]*"', "", tag)
        tag = re.sub(r'\s*preserveAspectRatio="[^"]*"', "", tag)
        return tag[:-1] + f' width="{px_w}" height="{px_h}">'

    svg = re.sub(r"^<svg\b[^>]*>", normalize_root_tag, svg, count=1)
    return svg.encode("utf-8")


def placeholder_svg(label: str) -> bytes:
    svg = (
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">'
        '<rect width="512" height="512" fill="#c9b896"/>'
        '<circle cx="256" cy="256" r="240" fill="none" stroke="#5a4a2f" stroke-width="8" stroke-dasharray="16 14"/>'
        f'<text x="256" y="266" font-size="46" font-family="sans-serif" fill="#5a4a2f" '
        f'text-anchor="middle">{label}</text>'
        "</svg>"
    )
    return svg.encode("utf-8")


def write_catalog_root():
    os.makedirs(ASSETS_DIR, exist_ok=True)
    write_json(os.path.join(ASSETS_DIR, "Contents.json"), '{\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n')


def write_json(path: str, content: str):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def write_imageset(name: str, svg_bytes: bytes):
    imageset_dir = os.path.join(ASSETS_DIR, f"{name}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)
    with open(os.path.join(imageset_dir, f"{name}.svg"), "wb") as f:
        f.write(svg_bytes)
    contents = (
        '{\n'
        '  "images" : [\n'
        '    {\n'
        f'      "filename" : "{name}.svg",\n'
        '      "idiom" : "universal"\n'
        '    }\n'
        '  ],\n'
        '  "info" : {\n'
        '    "author" : "xcode",\n'
        '    "version" : 1\n'
        '  },\n'
        '  "properties" : {\n'
        '    "preserves-vector-representation" : true\n'
        '  }\n'
        '}\n'
    )
    write_json(os.path.join(imageset_dir, "Contents.json"), contents)


def main():
    write_catalog_root()
    codes = sorted(extract_asset_codes())
    print(f"Found {len(codes)} asset codes referenced in DialectSeeder.swift\n")

    ok, missing = [], []

    for code in codes:
        if code in PLACEHOLDER_ASSET_CODES:
            label = PLACEHOLDER_ASSET_CODES[code]
            print(f"[placeholder] {code} ({label}) - no verified free-license source yet")
            placeholder = placeholder_svg(label)
            write_imageset(f"flag-{code}", placeholder)
            write_imageset(f"round-{code}", placeholder)
            missing.append(code)
            continue

        if code.startswith("ch-") and code[3:] not in NON_GERMAN_CANTON_CODES and len(code) == 5:
            canton = code[3:]
            data = fetch(SWISS_CANTON_FLAT_URL.format(canton=canton))
            if data:
                write_imageset(f"flag-{code}", data)
                write_imageset(f"round-{code}", normalize_intrinsic_size(data))
                print(f"[canton]  {code} <- ylerjen/swiss-flags")
                ok.append(code)
            else:
                print(f"[MISSING] {code} - could not fetch from ylerjen/swiss-flags")
                missing.append(code)
            continue

        flat_data = fetch(LIPIS_FLAT_URL.format(code=code))
        round_data = fetch(CIRCLE_FLAGS_ROUND_URL.format(code=code))

        if flat_data:
            write_imageset(f"flag-{code}", flat_data)
        if round_data:
            write_imageset(f"round-{code}", round_data)

        if flat_data and round_data:
            print(f"[ok]      {code}")
            ok.append(code)
        elif flat_data or round_data:
            print(f"[partial] {code} - flat={'yes' if flat_data else 'NO'} round={'yes' if round_data else 'NO'}")
            ok.append(code)
        else:
            print(f"[MISSING] {code} - not found in lipis/flag-icons or circle-flags")
            missing.append(code)

    print(f"\n{len(ok)} ok, {len(missing)} missing/placeholder out of {len(codes)}")
    if missing:
        print("Missing/placeholder codes:", ", ".join(missing))
    return 0


if __name__ == "__main__":
    sys.exit(main())
