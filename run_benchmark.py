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
          "valley": "unigine"}

BENCH = sys.argv[1].lower()
if BENCH not in SUITES:
    print "ERROR: unknown benchmark.  Choose one of: " + " ".join(SUITES.keys())

sys.path.append(path.join(path.dirname(path.abspath(sys.argv[0])), ".."))

MODULE = None
if SUITES[BENCH] == "unigine":
    import unigine
    MODULE = unigine
elif SUITES[BENCH] == "gfxbench":
    import gfxbench
    MODULE = gfxbench
else:
    assert False

MODULE.install()
MODULE.run(BENCH)
