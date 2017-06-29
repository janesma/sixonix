#!/usr/bin/python
"""installs gfxbench binaries in the benchmarks directory"""

import os
import stat
import sys
import json
from urllib import urlretrieve
import zipfile

SIXONIX_DIR = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), ".."))

def install():
    """install gfxbench"""
    conf_file = os.path.join(SIXONIX_DIR, "gfxbench", "conf.json")
    conf = json.load(open(conf_file))
    platform = "linux"
    if "win" in sys.platform:
        platform = "windows"
    bench_dir = os.path.join(SIXONIX_DIR, "benchmarks", "gfxbench", platform)
    if not os.path.exists(bench_dir):
        os.makedirs(bench_dir)
    executable = bench_dir + "/" + conf[platform]["executable"]
    if os.path.exists(executable):
        return
    file_name = os.path.split(conf[platform]["package"])[-1]
    local_file = bench_dir + "/" + file_name
    if not os.path.exists(local_file):
        urlretrieve(conf[platform]["package"], local_file)
    zipf = zipfile.ZipFile(local_file)
    os.chdir(bench_dir)
    zipf.extractall()
    if platform == "linux":
        perms = os.stat(executable)
        os.chmod(executable, perms.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

install()
