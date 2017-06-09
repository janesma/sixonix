#!/usr/bin/python

import os
import os.path as path
import glob
import json
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

SIXONIX_DIR = path.abspath(path.join(path.dirname(sys.argv[0]), ".."))
CONF = path.join(SIXONIX_DIR, "conf.d", "windows.json")
BENCH_DIR = path.join(SIXONIX_DIR, "windows", "benchmarks")

bench = sys.argv[1].lower()
assert path.exists(CONF)
conf = json.load(open(CONF))
if bench not in conf["tests"]:
    print "ERROR: unknown benchmark.  Choose one of: " + " ".join(conf["tests"].keys())

suite = conf["tests"][bench]["suite"]
installer = path.join(SIXONIX_DIR, conf[suite]["installer"])
executable = path.join(SIXONIX_DIR, "windows/benchmarks", conf[suite]["executable"])
runner = path.join(SIXONIX_DIR, conf[suite]["runner"])

if not path.exists(executable):
    print "WARN: installation not found: " + executable
    proc = subprocess.Popen([sys.executable, installer],
                            stderr=open(os.devnull, "w"),
                            stdout=open(os.devnull, "w"))
    proc.communicate()

proc = subprocess.Popen([sys.executable, runner, bench])
proc.communicate()
