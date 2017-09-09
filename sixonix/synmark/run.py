#!/usr/bin/env python3
"""runs the synmark benchmark"""

import os
import os.path as path
import json
import subprocess
import sys

CONFIG_TEMPLATE = """\
TestsToRun = {test};
FullScreen = {fullscreen};
WindowWidth = {width};
WindowHeight = {height};
FrameWidth = 0;
FrameHeight = 0;
VSyncEnable = False;
DepthFormat = D24;
FrameBufferCount = 2;
WarmUpFrames = 3;
WarmUpTime = 10.0;
MeasureFrames = 10;
MeasureTime = 20.0;
DumpTimestamps = False;
DumpScreenshot = False;
ScreenshotFrameNumber = 0;
ValidateImage = False;
AdaptiveFlipsTargetFps = 0;
"""

def run(test, args=None):
    """test synmark"""
    conf_file = path.join(path.dirname(__file__), "conf.json")
    assert path.exists(conf_file)
    conf = json.load(open(conf_file))
    platform = "linux"
    if "win" in sys.platform:
        platform = "windows"
    bench_dir = path.join(SIXONIX_DIR, "benchmarks", "synmark", platform)
    executable_path = path.join(bench_dir, conf[platform]["executable"])
    base_dir = path.abspath(executable_path + "/..")

    config_path = path.expanduser("~/SynMark2Home/User.cfg")
    if path.exists(config_path):
        os.unlink(config_path)
    result_path = path.expanduser("~/SynMark2Home/Result.txt")
    if path.exists(result_path):
        os.unlink(result_path)
    with open(config_path, "w") as config_fp:
        config_fp.write(CONFIG_TEMPLATE.format(
            test = test,
            fullscreen = 'True' if args.fullscreen == 'true' else 'False',
            width = args.width,
            height = args.height
        ))

    os.chdir(base_dir)
    cmd = [executable_path]
    env = os.environ.copy()
    env["vblank_mode"] = "0"
    proc = subprocess.Popen(cmd, env=env,
                            stderr=open(os.devnull, "w"),
                            stdout=open(os.devnull, "w"))
    proc.communicate()
    assert os.path.exists(result_path)
    with open(result_path, "r") as read_fh:
        results = read_fh.readlines()
        for line in results:
            if "FPS" not in line:
                continue
            print(line.split()[1])

    os.unlink(config_path)
    os.unlink(result_path)

if __name__ == "__main__":
    SIXONIX_DIR = path.abspath(path.join(path.dirname(sys.argv[0]), "../.."))
    run(sys.argv[1])
else:
    SIXONIX_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
