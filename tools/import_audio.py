#!/usr/bin/env python3
"""Builds the game's sounds and music (assets/audio/*.ogg) from the sound
libraries kept next to the repo (../Assets by default): picks, trims, levels and
converts each one to Ogg Vorbis.

    python3 tools/import_audio.py [--assets ../Assets] [--only hit,boom]

Each entry of SOUNDS is a game sound: one recipe makes name.ogg, several
make name_1.ogg, name_2.ogg ... for the game to pick from at random. A
recipe is a source (a glob under the assets folder, or under the repo when
it starts with "res:"; the first match is used) and what to do with it:

    start, end   seconds to keep of the source
    length       at most this long (faded out at the end)
    fade         the fade-out at the end, in seconds (default 0.03)
    gain         dB, after the loudest peak is brought to -1 dBFS

Each entry of MUSIC is a track made of Ovani's three layers (Intensity 1,
Intensity 2 and Main: the same piece, sparse to full) as name_1.ogg,
name_2.ogg and name_3.ogg, each looped seamlessly: the reverb tail past the
loop point is folded back over the start. The game plays the layers
together and moves between them with how hot the game is (Audio.music_heat).
Needs ffmpeg.
"""

import argparse
import glob
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
OUT = os.path.join(REPO, "assets", "audio")

CASUAL = "Sounds/Casual & Mobile Sound FX Pack Vol. 1/**"
RETRO = "Sounds/Retro Gaming Sound FX Pack/Retro/8 bit/**"
ELECTRONIC = "Sounds/Electronic Music Pack Vol. 5/Electronic Vol 5 Music Pack"
GOTHIC = "Sounds/Gothic Fantasy Sound FX Pack Vol. 1/**"
FILMCOW = "Sounds/FilmCow Designed SFX"

SOUNDS = {
    # --- the ship ------------------------------------------------------------
    "engine": {"src": f"{RETRO}/Motor Loop.wav", "fade": 0.0},
    "fire": [{"src": f"{RETRO}/Range Attack 00{n}.wav", "length": 0.18, "gain": -5.0} for n in (1, 2, 3, 4)],
    "hit": [{"src": f"{RETRO}/Block Wood 00{n}.wav", "length": 0.12, "gain": -5.0} for n in (1, 2, 3, 4)],
    "charge": {"src": f"{RETRO}/Charge-Up.wav", "length": 0.8, "gain": -3.0},
    "charged": {"src": f"{RETRO}/Glow Short.wav", "length": 0.3, "gain": -3.0},
    "smask": [{"src": f"{RETRO}/Dash 00{n}.wav", "length": 0.5} for n in (1, 2, 3)],
    "smask_hit": [{"src": f"{RETRO}/Critical Hit 00{n}.wav", "length": 0.35} for n in (1, 2, 3)],
    "wall_smask": {"src": f"{RETRO}/Boom Long 002.wav", "length": 0.9, "fade": 0.3},
    "wall": [{"src": f"{RETRO}/Big Footsteps 00{n}.wav", "length": 0.25} for n in (1, 2, 3)],
    "bump": {"src": f"{CASUAL}/Plonk.wav", "length": 0.25},
    "hurt": [{"src": f"{RETRO}/Melee Attack Punch 00{n}.wav", "length": 0.5} for n in (1, 2, 3)],
    "safe_over": {"src": f"{RETRO}/Force Field End.wav", "length": 0.3, "fade": 0.1, "gain": -4.0},
    "death": {"src": f"{RETRO}/Massive Boom.wav", "length": 2.5, "fade": 0.8},
    # --- what's out there -------------------------------------------------------
    "boom": [{"src": f"{RETRO}/Boom Short 00{n}.wav", "length": 0.5} for n in (1, 2, 3, 4, 5)],
    "boom_big": [{"src": f"{RETRO}/Boom Long 00{n}.wav", "length": 1.2, "fade": 0.4} for n in (1, 3, 4)],
    "clank": [{"src": f"{RETRO}/Blocking Armor 00{n}.wav", "length": 0.2, "gain": -3.0} for n in (1, 2, 3, 4)],
    "crack": {"src": f"{CASUAL}/Huge Splang.wav", "length": 0.6, "gain": -2.0},
    "shot": [{"src": f"{RETRO}/Magic Attack 00{n}.wav", "length": 0.3, "gain": -3.0} for n in (1, 2, 3)],
    "hop": [{"src": f"{RETRO}/Jump 00{n}.wav", "length": 0.2, "gain": -4.0} for n in (1, 2)],
    "spawn": {"src": f"{RETRO}/Portal Warp In.wav", "length": 0.6, "gain": -3.0},
    "bumper": {"src": f"{CASUAL}/Bouncy Select.wav", "length": 0.3},
    "reply": {"src": f"{CASUAL}/Text Sprawl Sci-Fi.wav", "length": 0.7},
    "horn": {"src": f"{FILMCOW}/space horn 7.wav", "length": 1.4, "fade": 0.4, "gain": -2.0},
    "bell": {"src": f"{GOTHIC}/Mystic Bell 001.wav", "length": 3.0, "fade": 1.0},
    # --- what you get -----------------------------------------------------------
    "coin": {"src": f"{CASUAL}/Plink.wav", "length": 0.2, "gain": -3.0},
    "coffee": {"src": f"{CASUAL}/Power Up Grab A.wav", "length": 0.8},
    "perk": {"src": f"{CASUAL}/Power Up Grab C.wav", "length": 0.9},
    "zero": {"src": f"{CASUAL}/Achievement.wav", "length": 2.0, "fade": 0.5},
    "hour": {"src": f"{RETRO}/Engines ready.wav", "length": 1.5, "fade": 0.4, "gain": -3.0},
    "warning": {"src": f"{RETRO}/Danger Ahead 001.wav", "length": 1.8, "fade": 0.4, "gain": -2.0},
    # --- the menus ---------------------------------------------------------------
    "tick": {"src": f"{CASUAL}/Quick Click.wav", "length": 0.1},
    "accept": {"src": f"{CASUAL}/Yes Button.wav", "length": 0.3},
}

MUSIC = {
    "title": f"{ELECTRONIC}/Apollo*",
    "dusk": f"{ELECTRONIC}/Festival*",
    "night": f"{ELECTRONIC}/Solar Complex*",
    "late": f"{ELECTRONIC}/Quanta*",
    "boss": f"{ELECTRONIC}/Double-dip*",
    "final": f"{ELECTRONIC}/Golden Gates*",
    "ending": f"{ELECTRONIC}/Stardust*",
}


def find(assets: str, pattern: str) -> str:
    if pattern.startswith("res:"):
        path = os.path.join(REPO, pattern[4:])
        if not os.path.isfile(path):
            raise SystemExit(f"Not found: {path}")
        return path
    matches = sorted(glob.glob(os.path.join(assets, pattern), recursive=True))
    matches = [m for m in matches if "__MACOSX" not in m]
    if not matches:
        raise SystemExit(f"Not found: {pattern}")
    return matches[0]


def peak_db(path: str, filters: str) -> float:
    result = subprocess.run(["ffmpeg", "-hide_banner", "-i", path, "-af", filters + ",volumedetect", "-f", "null", "-"],
        capture_output=True, text=True)
    match = re.search(r"max_volume: (-?[\d.]+) dB", result.stderr)
    return float(match.group(1)) if match else 0.0


def make_sound(assets: str, recipe: dict, out: str) -> None:
    src = find(assets, recipe["src"])
    filters = ["aformat=channel_layouts=mono"]
    start, end = recipe.get("start"), recipe.get("end")
    if start is not None or end is not None:
        filters.append(f"atrim=start={start or 0}" + (f":end={end}" if end is not None else "") + ",asetpts=PTS-STARTPTS")
    # Trims the silence a library leaves in front of a hit, so it lands on the frame.
    filters.append("silenceremove=start_periods=1:start_threshold=-50dB")
    length = recipe.get("length")
    fade = recipe.get("fade", 0.03)
    if length:
        filters.append(f"atrim=end={length},afade=t=out:st={max(length - fade, 0)}:d={fade}")
    chain = ",".join(filters)
    gain = -1.0 - peak_db(src, chain) + recipe.get("gain", 0.0)
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", src, "-af", f"{chain},volume={gain:.2f}dB",
        "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4", out], check=True)


def make_music(assets: str, folder_glob: str, name: str) -> None:
    folder = find(assets, folder_glob)
    tail = float(re.search(r"RT ([\d.]+)", folder).group(1))
    for i, layer in enumerate(["Intensity 1", "Intensity 2", "Main"]):
        src = glob.glob(os.path.join(glob.escape(folder), f"* {layer}.wav"))[0]
        duration = float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", src],
            capture_output=True, text=True).stdout)
        loop = duration - tail
        graph = (f"[0]atrim=0:{loop},asetpts=PTS-STARTPTS[body];"
            f"[0]atrim={loop},asetpts=PTS-STARTPTS[tail];"
            "[body][tail]amix=inputs=2:duration=first:normalize=0[out]")
        out = os.path.join(OUT, f"music_{name}_{i + 1}.ogg")
        subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", src, "-filter_complex", graph, "-map", "[out]",
            "-ar", "44100", "-c:a", "libvorbis", "-q:a", "3", out], check=True)
        print(f"  {os.path.basename(out)} ({loop:.1f} s)")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--assets", default=os.path.join(REPO, "..", "Assets"))
    parser.add_argument("--only", default="", help="comma-separated names to make (sounds or music)")
    args = parser.parse_args()
    only = set(filter(None, args.only.split(",")))
    os.makedirs(OUT, exist_ok=True)
    for name, recipes in SOUNDS.items():
        if only and name not in only:
            continue
        if isinstance(recipes, dict):
            make_sound(args.assets, recipes, os.path.join(OUT, f"{name}.ogg"))
        else:
            for i, recipe in enumerate(recipes):
                make_sound(args.assets, recipe, os.path.join(OUT, f"{name}_{i + 1}.ogg"))
        print(name)
    for name, folder in MUSIC.items():
        if only and name not in only:
            continue
        print(f"music {name}")
        make_music(args.assets, folder, name)


if __name__ == "__main__":
    sys.exit(main())
