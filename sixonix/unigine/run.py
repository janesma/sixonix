#!/usr/bin/python
"""Runs Unigine benchmarks on windows and linux"""

import os
import time
import glob
import subprocess
import sys
import xml.etree.ElementTree as ET

from .. import config

def run(test, args=None):
    """test unigine"""
    conf = config.get_config_for_module("unigine")
    tests = {
        "heaven" : {
            "config" : "heaven.cfg",
            "windows" : "Unigine/Heaven Benchmark 4.0/bin/Heaven.exe",
            "linux" : "Unigine_Heaven-4.0/bin/heaven_x64"
        },
        "valley" : {
            "config" : "valley.cfg",
            "windows" : "Unigine/Valley Benchmark 1.0/bin/Valley.exe",
            "linux" : "Unigine_Valley-1.0/bin/valley_x64"
        }
    }
    executable_path = os.path.join(conf.benchmark_path,
                                   tests[test][conf.platform])
    bin_dir = os.path.dirname(executable_path)

    for old_config in glob.glob(bin_dir + "/*cfg"):
        os.unlink(old_config)

    conf_path = os.path.join(os.path.dirname(__file__),
                             tests[test]["config"])
    root = ET.parse(conf_path)
    height_tag = root.find(".//item[@name='video_height']")
    height_tag.text = str(args.height)
    width_tag = root.find(".//item[@name='video_width']")
    width_tag.text = str(args.width)
    root.write(bin_dir + "/config.cfg")

    cmd = [executable_path,
           "-video_app", "opengl",
           "-data_path", "../",
           "-engine_config", "config.cfg",
           "-system_script", test + "/unigine.cpp",
           "-video_mode", "-1",
           "-video_fullscreen", "1" if args.fullscreen == "true" else "0",
           "-video_width", str(args.width),
           "-video_height", str(args.height),
           "-sound_app", "null",
           "-extern_define", "PHORONIX,RELEASE"]
    env = os.environ.copy()
    env["vblank_mode"] = "0"
    proc = subprocess.Popen(cmd,
                            stderr=open(os.devnull, "w"),
                            stdout=subprocess.PIPE,
                            env=env,
                            cwd=bin_dir)
    (out, _) = proc.communicate()
    for aline in out.decode("ascii").splitlines():
        if "FPS" not in aline:
            continue
        print(aline.split()[1])
        break

    for old_config in glob.glob(bin_dir + "/*cfg"):
        os.unlink(old_config)
