from .run import run
from .. import install as _install

BENCHMARKS = [
    "heaven",
    "valley",
]

def install():
    _install.install_benchmarks_for_module("unigine")
