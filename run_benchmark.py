#!/usr/bin/env python3

"""Runs all benchmarks"""

import argparse
import os.path as path
import sys

SUITES = {"manhattan" : "gfxbench",
          "manhattan_o" : "gfxbench",
          "car_chase" : "gfxbench",
          "car_chase_o" : "gfxbench",
          "trex" : "gfxbench",
          "trex_o" : "gfxbench",
          "fill" : "gfxbench",
          "fill_o" : "gfxbench",
          "tess" : "gfxbench",
          "tess_o" : "gfxbench",
          "alu2" : "gfxbench",
          "alu2_o" : "gfxbench",
          "driver2" : "gfxbench",
          "driver2_o" : "gfxbench",
          "heaven" : "unigine",
          "valley": "unigine",
          "OglBatch0" : "synmark",
          "OglBatch1" : "synmark",
          "OglBatch2" : "synmark",
          "OglBatch3" : "synmark",
          "OglBatch4" : "synmark",
          "OglBatch5" : "synmark",
          "OglBatch6" : "synmark",
          "OglBatch7" : "synmark",
          "OglCSCloth" : "synmark",
          "OglCSDof" : "synmark",
          "OglDeferred" : "synmark",
          "OglDeferredAA" : "synmark",
          "OglDrvRes" : "synmark",
          "OglDrvShComp" : "synmark",
          "OglDrvState" : "synmark",
          "OglFillPixel" : "synmark",
          "OglFillTexMulti" : "synmark",
          "OglFillTexSingle" : "synmark",
          "OglGeomPoint" : "synmark",
          "OglGeomTriList" : "synmark",
          "OglGeomTriStrip" : "synmark",
          "OglHdrBloom" : "synmark",
          "OglMultithread" : "synmark",
          "OglPSBump2" : "synmark",
          "OglPSBump8" : "synmark",
          "OglPSPhong" : "synmark",
          "OglPSPom" : "synmark",
          "OglShMapPcf" : "synmark",
          "OglShMapVsm" : "synmark",
          "OglTerrainFlyInst" : "synmark",
          "OglTerrainFlyTess" : "synmark",
          "OglTerrainPanInst" : "synmark",
          "OglTerrainPanTess" : "synmark",
          "OglTexFilterAniso" : "synmark",
          "OglTexFilterTri" : "synmark",
          "OglTexMem128" : "synmark",
          "OglTexMem512" : "synmark",
          "OglVSDiffuse1" : "synmark",
          "OglVSDiffuse8" : "synmark",
          "OglVSInstancing" : "synmark",
          "OglVSTangent" : "synmark",
          "OglZBuffer" : "synmark"}

cmd = sys.argv[0]
parser = argparse.ArgumentParser(description="sixoxix runner")
parser.add_argument('--fullscreen', type=str, default="true",
                    choices=['true', 'false'],
                    help="windowed or fullscreen (default: %(default)s)")
parser.add_argument('--width', type=str, default="1920",
                    help="screen/window width (default: %(default)s)")
parser.add_argument('--height', type=str, default="1080",
                    help="screen/window width (default: %(default)s)")
parser.add_argument('benchmark', help="benchmark to run")
args = parser.parse_args(sys.argv[1:])

SIXONIX_DIR = path.abspath(path.join(path.dirname(cmd), ".."))

BENCH = args.benchmark
if BENCH not in SUITES:
    BENCH = BENCH.lower()
if BENCH not in SUITES:
    print("ERROR: unknown benchmark.  Choose one of: " +
          " ".join(SUITES.keys()))
    sys.exit(-1)

sys.path.append(path.join(path.dirname(path.abspath(sys.argv[0])), ".."))

MODULE = None
if SUITES[BENCH] == "unigine":
    from sixonix import unigine
    MODULE = unigine
elif SUITES[BENCH] == "gfxbench":
    from sixonix import gfxbench
    MODULE = gfxbench
elif SUITES[BENCH] == "synmark":
    from sixonix import synmark
    MODULE = synmark
else:
    assert False

MODULE.install()
MODULE.run(BENCH, args)
