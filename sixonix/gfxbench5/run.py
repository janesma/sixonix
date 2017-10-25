#!/usr/bin/env python3
"""runs the gfxbench benchmark"""

import os
import os.path as path
import glob
import json
import shutil
import subprocess
import sys

from .. import config

def run(test, args, env):
    """test gfxbench"""
    conf = config.get_config_for_module("gfxbench5")
    assert len(conf.executables) == 1
    executable_path = path.join(conf.benchmark_path, conf.executables[0])

    base_dir = path.join(path.dirname(executable_path), '..')
    results_dir = os.path.join(base_dir, "results")
    tests = {
        "aztec_ruins_gl_high" : "gl_5_high",
        "aztec_ruins_gl_normal" : "gl_5_normal",
        "aztec_ruins_gl_high_o" : "gl_5_high_off",
        "aztec_ruins_gl_normal_o" : "gl_5_normal_off",
        "aztec_ruins_vk_high" : "gl_5_high",
        "aztec_ruins_vk_normal" : "gl_5_normal",
        "aztec_ruins_vk_high_o" : "gl_5_high_off",
        "aztec_ruins_vk_normal_o" : "gl_5_normal_off",
    }

    if os.path.exists(results_dir):
        shutil.rmtree(results_dir)

    cmd = [executable_path,
           "-b", base_dir,
           "-t", tests[test],
           "--gfx", "glfw"]
    cmd += ["--ei", "-offscreen_width=" + str(args.width),
            "--ei", "-offscreen_height=" + str(args.height)]
    if args.fullscreen:
        cmd += ["--ei", "-fullscreen=1"]
    else:
        cmd += ['-w', str(args.width), '-h', str(args.height)]
    with subprocess.Popen(cmd,
                          stderr=subprocess.PIPE,
                          stdout=open(os.devnull, "w"),
                          env=env) as proc:
        out, err = proc.communicate()
        if proc.returncode != 0:
            raise RuntimeError(err)

    result = glob.glob(results_dir + "/*/*.json")
    assert len(result) == 1
    score = json.load(open(result[0]))
    fps = float(score["results"][0]["gfx_result"]["fps"])

    shutil.rmtree(results_dir)

    return fps
