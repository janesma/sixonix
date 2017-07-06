#!/usr/bin/python
"""Runs Unigine benchmarks on windows and linux"""

import os
import time
import glob
import subprocess
import sys
import xml.etree.ElementTree as ET

def run(test):
    """test unigine"""
    platform = "linux"
    if "win" in sys.platform:
        platform = "windows"
    bench_dir = os.path.join(SIXONIX_DIR, "benchmarks", "unigine", platform)
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
    executable_path = os.path.join(bench_dir, tests[test][platform])
    bin_dir, exe = os.path.split(executable_path)
    if platform == "linux":
        exe = "./" + exe

    for old_config in glob.glob(bin_dir + "/*cfg"):
        os.unlink(old_config)

    root = ET.parse(open(SIXONIX_DIR + "/unigine/" + tests[test]["config"]))
    height_tag = root.find(".//item[@name='video_height']")
    height_tag.text = "1080"
    width_tag = root.find(".//item[@name='video_width']")
    width_tag.text = "1920"
    root.write(bin_dir + "/config.cfg")

    save_dir = os.getcwd()
    os.chdir(bin_dir)
    cmd = [exe,
           "-engine_config", "config.cfg",
           "-video_fullscreen", "1",
           "-extern_define", "PHORONIX,RELEASE"]
    if test == "valley":
        cmd += ["-video_app", "opengl",
                "-data_path", "../",
                "-video_mode", "-1",
                "-system_script", "valley/unigine.cpp"]
    proc = subprocess.Popen(cmd, stderr=open(os.devnull, "w"), stdout=subprocess.PIPE)
    (out, _) = proc.communicate()
    for aline in out.decode("ascii").splitlines():
        if "FPS" not in aline:
            continue
        print aline.split()[1]
        break

    for old_config in glob.glob(bin_dir + "/*cfg"):
        os.unlink(old_config)
    os.chdir(save_dir)

if __name__ == "__main__":
    SIXONIX_DIR = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), ".."))
    run(sys.argv[1].lower())
else:
    SIXONIX_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
