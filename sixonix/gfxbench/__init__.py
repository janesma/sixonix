from .run import run
from .. import install as _install

BENCHMARKS = [
    "manhattan",
    "manhattan_o",
    "car_chase",
    "car_chase_o",
    "trex",
    "trex_o",
    "fill",
    "fill_o",
    "tess",
    "tess_o",
    "alu2",
    "alu2_o",
    "driver2",
    "driver2_o",
]

def install():
    _install.install_benchmarks_for_module("gfxbench")
