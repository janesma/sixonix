#!/usr/bin/python3

import os
import os.path as path
import json
import subprocess
import sys

SIXONIX_DIR = path.abspath(path.join(path.dirname(sys.argv[0]), ".."))
CONF = path.join(SIXONIX_DIR, "conf.d", "windows.json")
BENCH_DIR = path.join(SIXONIX_DIR, "windows", "benchmarks")

def run(test):
    """test gfxbench"""
    assert path.exists(CONF)
    conf = json.load(open(CONF))
    executable_path = path.join(BENCH_DIR, conf["gfxbench"]["executable"])
    os.chdir(path.dirname(executable_path))
    executable = path.split(executable_path)[-1]
    tests = {"manhattan_o" : "gl_manhattan31_off"}
    cmd = [executable, "--ei", "-fullscreen=1",
	   "--ei", "-offscreen_width=1920",
           "--ei", "-offscreen_height=1080",
	   "-b", tests[test],
           "-t", "gfxbench40",
	   "--ei", "-play_time=30000",
	   "--gfx", "glfw"]
    proc = subprocess.Popen(cmd)
    proc.communicate()

run(sys.argv[1])
