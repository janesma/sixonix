#!/usr/bin/env python3

"""Installs all the benchmarks"""

import sixonix

def install_benchmarks(args):
    for name, module in sixonix.SUITES.items():
        module.install()

def register_cmd(subparsers):
    parser = subparsers.add_parser('install',
        help='download and install benchmark binaries')
    parser.set_defaults(func=install_benchmarks)
