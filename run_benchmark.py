#!/usr/bin/env python3

"""Runs all benchmarks"""

import argparse
import os.path as path
import sys
import sixonix

parser = argparse.ArgumentParser(parents=[sixonix.run_argparse])
parser.add_argument('benchmark', help="benchmark to run")
args = parser.parse_args(sys.argv[1:])

BENCH = args.benchmark
if BENCH not in sixonix.BENCHMARKS:
    print("ERROR: unknown benchmark.  Choose one of:")
    for test in sixonix.BENCHMARKS:
        print("    " + test)
    sys.exit(-1)

sixonix.run(BENCH, args)
