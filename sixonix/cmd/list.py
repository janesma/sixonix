#!/usr/bin/env python3

"""Lists all available benchmarks"""

import sixonix

def list_benchmarks(args):
    for test in sixonix.BENCHMARKS:
        print(test)

def register_cmd(subparsers):
    parser = subparsers.add_parser('list', help='list available benchmarks')
    parser.set_defaults(func=list_benchmarks)

