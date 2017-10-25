import argparse
import csv
import os
import os.path
import sixonix
import sys
import itertools
import random

def write_csv(fname, table):
    with open(fname, 'w') as csvfile:
        writer = csv.writer(csvfile)
        for key in sorted(table.keys()):
            writer.writerow(list(key) + table[key])

def run_shuffled_benchmarks(args):
    suites = []
    if args.A:
        suites = sorted(sixonix.SUITES.keys())
    else:
        if args.g:
            suites.append('gfxbench')
        if args.s:
            suites.append('synmark')
        if args.G:
            suites.append('gputest')
        if args.u:
            suites.append('unigine')
    if not suites:
        suites = ['gfxbench', 'synmark', 'gputest']

    benchmarks = []
    for suite in suites:
        for benchmark in sixonix.SUITES[suite].BENCHMARKS:
            benchmarks.append('.'.join([suite, benchmark]))

    mesa_test_dir = os.path.expanduser("~/mesa-test-dir")
    mesa_prefixes = [sixonix.mesa.MesaPrefix(os.path.join(mesa_test_dir, subdir))
                     for subdir in os.listdir(mesa_test_dir)]

    test_list = list(itertools.product(mesa_prefixes, benchmarks,
                                       range(args.iterations)))
    random.shuffle(test_list)

    fps_table = {}
    for i, test in enumerate(test_list):
        mesa, benchmark, _ = test

        print("Running benchmark {} of {}: {} on mesa {}"
              .format(i, len(test_list), benchmark, mesa.name))

        env = os.environ.copy()
        mesa.update_env(env)
        fps = sixonix.run(benchmark, args, env)

        # Stash it in our FPS table
        table_key = (mesa.name, benchmark)
        fps_table.setdefault(table_key, []).append(fps)

        if args.csv:
            write_csv(args.csv, fps_table)

def register_cmd(subparsers):
    parser = subparsers.add_parser('shuffle-run',
                                   help='run shuffled benchmarks',
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

    parser.set_defaults(func=run_shuffled_benchmarks)
