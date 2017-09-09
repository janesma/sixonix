import os
import os.path
import stat
import subprocess
from urllib.request import urlretrieve
import zipfile

from . import config

def install_benchmarks_for_module(module_name):
    """Installs the bechmark binaries for the given module"""
    conf = config.get_config_for_module(module_name)

    # Check to see if it's already installed
    installed = True
    for executable in conf.executables:
        executable_path = os.path.join(conf.benchmark_path, executable)
        if not os.path.exists(executable_path):
            installed = False

    if installed:
        return

    os.makedirs(conf.benchmark_path, exist_ok = True)

    for package_url in conf.packages:
        package_fname = os.path.join(conf.benchmark_path,
                                     os.path.basename(package_url))
        if not os.path.exists(package_fname):
            urlretrieve(package_url, package_fname)

        if package_fname.endswith(".zip"):
            zipf = zipfile.ZipFile(package_fname)
            zipf.extractall(path = conf.benchmark_path)
        elif package_fname.endswith(".run"):
            proc = subprocess.Popen(["bash", package_fname],
                                    cwd = conf.benchmark_path)
            proc.communicate()
        else:
            assert False, "Unknown package file extension"

    if conf.platform == "linux":
        # If we're on linux, we need to make the executables executable
        for executable in conf.executables:
            executable_path = os.path.join(conf.benchmark_path, executable)
            perms = os.stat(executable_path)
            os.chmod(executable_path, perms.st_mode | stat.S_IXUSR |
                                      stat.S_IXGRP | stat.S_IXOTH)
