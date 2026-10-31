#!/usr/bin/env python3
"""Merges the overlapping shapes inside a font's letters, so an outline drawn round
one follows only its real edge. Unbounded is built from overlapping shapes, and without
this every stroked letter shows lines through it. Needs fonttools and skia-pathops.

    python3 tools/merge_font.py assets/fonts/Unbounded-Black.ttf
"""
import sys

from fontTools.ttLib import TTFont
from fontTools.ttLib.removeOverlaps import removeOverlaps

path = sys.argv[1]
font = TTFont(path)
removeOverlaps(font)
font.save(path)
print("merged", path)
