import os
import os.path
import importlib

SIXONIX_PATH = os.path.join(os.path.dirname(__file__))
BENCHMARKS_PATH = os.path.join(SIXONIX_PATH, "..", "benchmarks")

SUITES = {}
BENCHMARKS = []

for name in os.listdir(os.path.dirname(__file__)):
    try:
        mod = importlib.import_module(".".join([__package__, name]))
        if "run" in dir(mod):
            SUITES[name] = mod
            BENCHMARKS += [".".join([name, test]) for test in mod.BENCHMARKS]
    except ModuleNotFoundError:
        continue

BENCHMARKS.sort()

from . import install as _install

def run(test, args, install = True):
    suite = test.split(".")[0]
    test = test.split(".")[1]
    if install:
        SUITES[suite].install()

    return SUITES[suite].run(test, args)
