#!/usr/bin/env python3
"""runs the gfxbench benchmark"""

import os
import os.path as path
import glob
import json
import shutil
import subprocess
import sys

def run(test, args=None):
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
    width = "1920"
    height = "1080"
    fullscreen = True
    if args:
        width = args.width
        height = args.height
        fullscreen = (args.fullscreen == "true")

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
           "-b", base_dir,
           "-t", tests[test],
           "--gfx", "glfw"]
    cmd += ["--ei", "-offscreen_width=" + width,
            "--ei", "-offscreen_height=" + height]
    if fullscreen:
        cmd += ["--ei", "-fullscreen=1"]
    else:
        cmd += ['-w', width, '-h', height]
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
    run(sys.argv[1].lower())
else:
    SIXONIX_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
