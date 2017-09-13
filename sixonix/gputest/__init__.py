from .run import run
from .. import install as _install

BENCHMARKS = [
    "furmark",
#    "gimark",
    "piano",
    "volplosion",
    "plot3d",
    "tessmark",
    "triangle",
]

def install():
    _install.install_benchmarks_for_module("gputest")
