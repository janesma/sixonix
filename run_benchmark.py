#!/usr/bin/env python

"""Runs all benchmarks"""

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

BENCH = sys.argv[1]
if BENCH not in SUITES:
    BENCH = BENCH.lower()
if BENCH not in SUITES:
    print "ERROR: unknown benchmark.  Choose one of: " + " ".join(SUITES.keys())
    sys.exit(-1)

sys.path.append(path.join(path.dirname(path.abspath(sys.argv[0])), ".."))

MODULE = None
if SUITES[BENCH] == "unigine":
    import unigine
    MODULE = unigine
elif SUITES[BENCH] == "gfxbench":
    import gfxbench
    MODULE = gfxbench
elif SUITES[BENCH] == "synmark":
    import synmark
    MODULE = synmark
else:
    assert False

MODULE.install()
MODULE.run(BENCH)
