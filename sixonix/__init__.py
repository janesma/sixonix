import os
import os.path
import importlib
import functools
import argparse
import sys

SIXONIX_PATH = os.path.join(os.path.dirname(__file__))
BENCHMARKS_PATH = os.path.join(SIXONIX_PATH, "..", "benchmarks")

SUITES = {}
BENCHMARKS = []

from . import install as _install

for name in os.listdir(os.path.dirname(__file__)):
    if name in ('__init__.py', '__main__.py'):
        continue

    try:
        mod = importlib.import_module(".".join([__package__, name]))
        if not "run" in dir(mod):
            continue

        SUITES[name] = mod
        BENCHMARKS += [".".join([name, test]) for test in mod.BENCHMARKS]

        # Install an "install" hook in the module
        mod.install = functools.partial(_install.install_benchmarks_for_module,
                                        name)

    except ImportError:
        continue

BENCHMARKS.sort()

run_argparse = argparse.ArgumentParser(description='sixoxix runner',
                                       add_help=False)
run_argparse.add_argument('--fullscreen', action='store_true',
                          help='run fullscreen')
run_argparse.add_argument('--width', type=int, default=1920,
                          help='screen/window width (default: %(default)s)')
run_argparse.add_argument('--height', type=int, default=1080,
                          help='screen/window width (default: %(default)s)')

def run(test, args, env = os.environ, install = True):
    suite = test.split(".")[0]
    test = test.split(".")[1]
    if install:
        SUITES[suite].install(quiet = True)

    env = env.copy()
    env["vblank_mode"] = "0"

    return SUITES[suite].run(test, args, env)

def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    for name in os.listdir(os.path.join(os.path.dirname(__file__), 'cmd')):
        base_name, ext = os.path.splitext(name)
        if ext != '.py':
            continue

        mod_path = ".".join([__package__, 'cmd', base_name])
        mod = importlib.import_module(mod_path)
        mod.register_cmd(subparsers)

    args = parser.parse_args(sys.argv[1:])
    if 'func' not in args:
        parser.print_help()
        exit(1)
    args.func(args)
