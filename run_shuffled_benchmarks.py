#!/usr/bin/env python3

"""Runs all benchmarks"""

import argparse
import csv
import os
import os.path
import sys
import sixonix
import itertools
import random

parser = argparse.ArgumentParser(description='sixonix shuffled runner',
                                 parents=[sixonix.run_argparse])
parser.add_argument('-A', action='store_true', help='Run all tests')
parser.add_argument('-g', action='store_true', help='Run gfxbench tests')
parser.add_argument('-s', action='store_true', help='Run synmark tests')
parser.add_argument('-G', action='store_true', help='Run gputest tests')
parser.add_argument('-u', action='store_true', help='Run unigine tests')
parser.add_argument('-i', '--iterations', dest='iterations',
                    type=int, default=5,
                    help='Number of iterations to run each test ' +
                         '(default: %(default)s)')
parser.add_argument('--csv', '--csv', help='CSV file to store results')
args = parser.parse_args(sys.argv[1:])

SUITES = []
if args.A:
    SUITES = sorted(sixonix.SUITES.keys())
else:
    if args.g:
        SUITES.append('gfxbench')
    if args.s:
        SUITES.append('synmark')
    if args.G:
        SUITES.append('gputest')
    if args.u:
        SUITES.append('unigine')
if not SUITES:
    SUITES = ['gfxbench', 'synmark', 'gputest']

BENCHMARKS = []
for suite in SUITES:
    for benchmark in sixonix.SUITES[suite].BENCHMARKS:
        BENCHMARKS.append('.'.join([suite, benchmark]))

MESA_TEST_DIR = os.path.expanduser("~/mesa-test-dir")
MESA_PREFIXES = [sixonix.mesa.MesaPrefix(os.path.join(MESA_TEST_DIR, subdir))
                 for subdir in os.listdir(MESA_TEST_DIR)]

def write_csv(fname, table):
    with open(fname, 'w') as csvfile:
        writer = csv.writer(csvfile)
        for key in sorted(table.keys()):
            writer.writerow(list(key) + table[key])

TEST_LIST = list(itertools.product(MESA_PREFIXES, BENCHMARKS,
                                   range(args.iterations)))
random.shuffle(TEST_LIST)

FPS = {}
for i, test in enumerate(TEST_LIST):
    mesa, benchmark, _ = test

    print("Running benchmark {} of {}: {} on mesa {}"
          .format(i, len(TEST_LIST), benchmark, mesa.name))

    env = os.environ.copy()
    mesa.update_env(env)
    fps = sixonix.run(benchmark, args, env)

    # Stash it in our FPS table
    table_key = (mesa.name, benchmark)
    FPS.setdefault(table_key, []).append(fps)

    if args.csv:
        write_csv(args.csv, FPS)
