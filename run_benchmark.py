#!/usr/bin/env python3

"""Runs all benchmarks"""

import argparse
import os.path as path
import sys
import sixonix.gfxbench
import sixonix.synmark
import sixonix.unigine

SUITES = {}
for name in sixonix.gfxbench.BENCHMARKS:
    SUITES[name] = "gfxbench"
for name in sixonix.synmark.BENCHMARKS:
    SUITES[name] = "synmark"
for name in sixonix.unigine.BENCHMARKS:
    SUITES[name] = "unigine"

cmd = sys.argv[0]
parser = argparse.ArgumentParser(description="sixoxix runner")
parser.add_argument('--fullscreen', action="store_true",
                    help="run fullscreen")
parser.add_argument('--width', type=int, default=1920,
                    help="screen/window width (default: %(default)s)")
parser.add_argument('--height', type=int, default=1080,
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
    MODULE = sixonix.unigine
elif SUITES[BENCH] == "gfxbench":
    MODULE = sixonix.gfxbench
elif SUITES[BENCH] == "synmark":
    MODULE = sixonix.synmark
else:
    assert False

MODULE.install()
MODULE.run(BENCH, args)
