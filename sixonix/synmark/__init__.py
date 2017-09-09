from .run import run
from .. import install as _install

def install():
    _install.install_benchmarks_for_module("synmark")
