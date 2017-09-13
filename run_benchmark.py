#!/usr/bin/env python3

"""Runs all benchmarks"""

import argparse
import os.path as path
import sys
import sixonix

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
if BENCH not in sixonix.BENCHMARKS:
    print("ERROR: unknown benchmark.  Choose one of:")
    for test in sixonix.BENCHMARKS:
        print("    " + test)
    sys.exit(-1)

sys.path.append(path.join(path.dirname(path.abspath(sys.argv[0])), ".."))

sixonix.run(BENCH, args)
