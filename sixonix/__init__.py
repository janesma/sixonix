import os
import os.path
import importlib
import functools

SIXONIX_PATH = os.path.join(os.path.dirname(__file__))
BENCHMARKS_PATH = os.path.join(SIXONIX_PATH, "..", "benchmarks")

SUITES = {}
BENCHMARKS = []

from . import install as _install

for name in os.listdir(os.path.dirname(__file__)):
    try:
        mod = importlib.import_module(".".join([__package__, name]))
        if not "run" in dir(mod):
            continue

        SUITES[name] = mod
        BENCHMARKS += [".".join([name, test]) for test in mod.BENCHMARKS]

        # Install an "install" hook in the module
        mod.install = functools.partial(_install.install_benchmarks_for_module,
                                        name)

    except ModuleNotFoundError:
        continue

BENCHMARKS.sort()

def run(test, args, env = os.environ, install = True):
    suite = test.split(".")[0]
    test = test.split(".")[1]
    if install:
        SUITES[suite].install()

    env = env.copy()
    env["vblank_mode"] = "0"

    return SUITES[suite].run(test, args, env)
