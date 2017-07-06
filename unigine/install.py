#!/usr/bin/python

import os
import sys
import json
from urllib import urlretrieve
import subprocess
import zipfile

def install():
    """install unigine"""
    conf_file = os.path.join(SIXONIX_DIR, "unigine", "conf.json")
    platform = "linux"
    if "win" in sys.platform:
        platform = "windows"
    bench_dir = os.path.join(SIXONIX_DIR, "benchmarks", "unigine", platform)
    if not os.path.exists(bench_dir):
        os.makedirs(bench_dir)
    conf = json.load(open(conf_file))
    if os.path.exists(bench_dir + "/" + conf[platform]["executable"]):
        return
    if platform == "windows":
        file_name = os.path.split(conf["windows"]["package"])[-1]
        local_file = bench_dir + "/" + file_name
        urlretrieve(conf["windows"]["package"], local_file)
        zipf = zipfile.ZipFile(local_file)
        os.chdir(bench_dir)
        zipf.extractall()
        return

    # else multiple downloads for linux
    for installer in conf["linux"]["package"]:
        file_name = os.path.split(installer)[-1]
        local_file = bench_dir + "/" + file_name
        if not os.path.exists(local_file):
            urlretrieve(installer, local_file)
        os.chdir(bench_dir)
        proc = subprocess.Popen(["bash", local_file])

if __name__ == "__main__":
    SIXONIX_DIR = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), ".."))
    install()
else:
    SIXONIX_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
