#!/usr/bin/python3

import os
import os.path as path
import glob
import json
import shutil
import subprocess
import sys
import tempfile

SIXONIX_DIR = path.abspath(path.join(path.dirname(sys.argv[0]), ".."))
CONF = path.join(SIXONIX_DIR, "conf.d", "windows.json")
BENCH_DIR = path.join(SIXONIX_DIR, "windows", "benchmarks")

def run(test):
    """test gfxbench"""
    assert path.exists(CONF)
    conf = json.load(open(CONF))
    executable_path = path.join(BENCH_DIR, conf["gfxbench"]["executable"])
    base_dir = path.abspath(executable_path + "/../..")
    results_dir = base_dir + "/results"
    tests = {"manhattan" : "gl_manhattan31",
             "manhattan_o" : "gl_manhattan31_off",
             "car_chase" : "gl_4",
             "trex" : "gl_trex",
             "trex_o" : "gl_trex_off",
             "fill" : " gl_fill2",
             "fill_o" : " gl_fill2_off",
             "tess" : "gl_tess",
             "tess_o" : "gl_tess_off"
    }

    for old_result in glob.glob(results_dir + "/*_*"):
        shutil.rmtree(old_result)

    cmd = [executable_path,
           # "-w", "1920",
           # "-h", "1080",
           "--ei", "-fullscreen=1",
           "--ei", "-offscreen_width=1920",
           "--ei", "-offscreen_height=1080",
           "-b", base_dir,
           "-t", tests[test],
           "--ei", "-play_time=30000",
           "--gfx", "glfw"]
    proc = subprocess.Popen(cmd, stderr=open(os.devnull, "w"), stdout=open(os.devnull, "w"))
    proc.communicate()

    result = glob.glob(results_dir + "/*/*.json")
    assert len(result) == 1
    score = json.load(open(result[0]))
    print(score["results"][0]["gfx_result"]["fps"])

    for old_result in glob.glob(results_dir + "/*_*"):
        shutil.rmtree(old_result)

run(sys.argv[1])
