#!/usr/bin/python3

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

def run(test):
    """test unigine"""
    assert path.exists(CONF)
    conf = json.load(open(CONF))
    tests = {
        "heaven" : {
            "config" : "heaven_4.0.cfg",
            "executable" : "Unigine/Heaven Benchmark 4.0/bin/Heaven.exe"},
        "valley" : {
            "config" : "valley_1.1.cfg",
            "executable" : "Unigine/Valley Benchmark 1.0/bin/Valley.exe"
        }
    }
    executable_path = path.join(BENCH_DIR, tests[test]["executable"])
    base_dir = path.abspath(executable_path + "/../../..")
    bin_dir, exe = os.path.split(executable_path)

    for old_config in glob.glob(bin_dir + "/*cfg"):
        os.unlink(old_config)

    root = ET.parse(open(CONF + "/../" + tests[test]["config"]))
    height_tag = root.find(".//item[@name='video_height']")
    height_tag.text = "1080"
    width_tag = root.find(".//item[@name='video_width']")
    width_tag.text = "1920"
    root.write(bin_dir + "/config.cfg")
    
    save_dir = os.getcwd()
    os.chdir(bin_dir)
    cmd = [exe,
           "-engine_config", "config.cfg"]
    proc = subprocess.Popen(cmd, stderr=open(os.devnull, "w"), stdout=subprocess.PIPE)
    (out, _) = proc.communicate()
    for aline in out.decode("ascii").splitlines():
        if "FPS" not in aline:
            continue
        print(aline.split()[1])
        break

    for old_config in glob.glob(bin_dir + "/*cfg"):
        os.unlink(old_config)
    os.chdir(save_dir)

run(sys.argv[1])
