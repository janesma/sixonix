#!/usr/bin/python3

import os
import sys
import json
from urllib.request import urlretrieve
import zipfile

SIXONIX_DIR = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), ".."))
CONF = os.path.join(SIXONIX_DIR, "conf.d", "windows.json")
BENCH_DIR = os.path.join(SIXONIX_DIR, "windows", "benchmarks")

def install():
    """install gfxbench"""
    if not os.path.exists(BENCH_DIR):
        os.makedirs(BENCH_DIR)
    conf = json.load(open(CONF))
    if os.path.exists(BENCH_DIR + "/" + conf["gfxbench"]["executable"]):
        return
    file_name = os.path.split(conf["gfxbench"]["package"])[-1]
    local_file = BENCH_DIR + "/" + file_name
    urlretrieve(conf["gfxbench"]["package"], local_file)
    zipf = zipfile.ZipFile(local_file)
    os.chdir(BENCH_DIR)
    zipf.extractall()

install()
