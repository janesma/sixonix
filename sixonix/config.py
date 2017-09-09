import json
import os
import os.path
import sys

from . import SIXONIX_PATH, BENCHMARKS_PATH

def _as_str_list(list_or_str):
    if isinstance(list_or_str, str):
        return [list_or_str]
    else:
        return list_or_str

class ModuleConfig(object):
    def __init__(self, module_name):
        if "win" in sys.platform:
            self.platform = "windows"
        else:
            self.platform = "linux"

        conf_path = os.path.join(SIXONIX_PATH, module_name, "conf.json")
        with open(conf_path, 'r') as conf_file:
            self._conf = json.load(conf_file)[self.platform]

        self.packages = _as_str_list(self._conf["package"])
        self.executables = _as_str_list(self._conf["executable"])
        self.benchmark_path = os.path.abspath(os.path.join(BENCHMARKS_PATH,
                                                           module_name,
                                                           self.platform))

    def __getattr__(self, attr):
        return self._conf[attr];

_configs = {}
def get_config_for_module(module_name):
    if module_name not in _configs:
        _configs[module_name] = ModuleConfig(module_name)
    return _configs[module_name]
