#!/usr/bin/env python3
"""MIG-0.4 exact-byte, read-only asset inventory and SHA-256 qualification."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
animations = root / "assets/characters/kush-krusher/animations"
manifests = sorted(animations.glob("kk_anim_*/*.json"))
errors = []
verified = set()
assert len(manifests) == 15, f"Expected 15 manifests; found {len(manifests)}"

for path in manifests:
    data = json.loads(path.read_text(encoding="utf-8"))
    frames = data.get("frames", [])
    if data.get("characterId", data.get("character_id")) != "kush_krusher":
        errors.append(f"{path}: identity")
    if data.get("frameCount", data.get("frame_count")) != 10 or len(frames) != 10:
        errors.append(f"{path}: frame count")
    if data.get("frameWidth", data.get("frame_width")) != 1024 or data.get("frameHeight", data.get("frame_height")) != 1024:
        errors.append(f"{path}: dimensions")
    fps = data.get("fps")
    if fps != 10 and not (fps is None and data.get("playbackTimingStatus") == "NOT_SPECIFIED_OR_VERIFIED"):
        errors.append(f"{path}: timing")
    for index, frame in enumerate(frames, 1):
        name = frame.get("filename", frame.get("file"))
        expected = f"kush_krusher_anim_{path.parent.name[8:]}_frame_{index:02d}.png"
        if name != expected or frame.get("index", frame.get("frame_number", index)) != index:
            errors.append(f"{path}: frame order/name {index}")
            continue
        image = path.parent / name
        if not image.is_file():
            errors.append(f"{image}: missing")
            continue
        actual = image.read_bytes()
        if hashlib.sha256(actual).hexdigest() != frame.get("sha256"):
            errors.append(f"{image}: SHA-256 mismatch")
        if actual[:8] != b"\x89PNG\r\n\x1a\n":
            errors.append(f"{image}: invalid PNG signature")
        verified.add(image.resolve())

actual_pngs = {p.resolve() for p in animations.glob("kk_anim_*/*.png")}
if actual_pngs != verified or len(verified) != 150:
    errors.append(f"Expected exactly 150 manifest-referenced PNGs, got {len(verified)} referenced and {len(actual_pngs)} actual")

report = {
    "step": "MIG-0.4",
    "manifests": len(manifests),
    "verifiedPngs": len(verified),
    "actualPngs": len(actual_pngs),
    "sha256ChecksPassed": not errors,
    "errors": errors
}
print(json.dumps(report, indent=2))
if errors:
    raise SystemExit(1)
