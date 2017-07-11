#!/usr/bin/env python3
"""runs the gfxbench benchmark"""

import os
import os.path as path
import glob
import json
import shutil
import subprocess
import sys

def run(test):
    """test gfxbench"""
    conf_file = path.join(SIXONIX_DIR, "gfxbench", "conf.json")
    assert path.exists(conf_file)
    conf = json.load(open(conf_file))
    platform = "linux"
    if "win" in sys.platform:
        platform = "windows"
    bench_dir = path.join(SIXONIX_DIR, "benchmarks", "gfxbench", platform)
    executable_path = path.join(bench_dir, conf[platform]["executable"])
    base_dir = path.abspath(executable_path + "/..")
    if platform == "windows":
        # on windows, the base directory is one level higher.
        base_dir = path.abspath(base_dir + "/..")
    results_dir = base_dir + "/results"
    tests = {"manhattan" : "gl_manhattan31",
             "manhattan_o" : "gl_manhattan31_off",
             "car_chase" : "gl_4",
             "car_chase_o" : "gl_4_off",
             "trex" : "gl_trex",
             "trex_o" : "gl_trex_off",
             "fill" : " gl_fill2",
             "fill_o" : " gl_fill2_off",
             "tess" : "gl_tess",
             "tess_o" : "gl_tess_off"}

    if os.path.exists(results_dir):
        shutil.rmtree(results_dir)

    env = os.environ.copy()
    env["vblank_mode"] = "0"
    cmd = [executable_path,
           "--ei", "-fullscreen=1",
           "--ei", "-offscreen_width=1920",
           "--ei", "-offscreen_height=1080",
           "-b", base_dir,
           "-t", tests[test],
           "--ei", "-play_time=30000",
           "--gfx", "glfw"]
    proc = subprocess.Popen(cmd,
                            stderr=open(os.devnull, "w"),
                            stdout=open(os.devnull, "w"),
                            env=env)
    proc.communicate()

    result = glob.glob(results_dir + "/*/*.json")
    assert len(result) == 1
    score = json.load(open(result[0]))
    print score["results"][0]["gfx_result"]["fps"]

    shutil.rmtree(results_dir)

if __name__ == "__main__":
    SIXONIX_DIR = path.abspath(path.join(path.dirname(sys.argv[0]), ".."))
    run(sys.argv[1].lower())
else:
    SIXONIX_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
