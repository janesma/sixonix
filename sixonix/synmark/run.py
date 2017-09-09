#!/usr/bin/env python3
"""runs the synmark benchmark"""

import os
import os.path as path
import json
import subprocess
import sys

from .. import config

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
    conf = config.get_config_for_module("synmark")
    assert len(conf.executables) == 1
    executable_path = path.join(conf.benchmark_path, conf.executables[0])

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

    cmd = [executable_path]
    env = os.environ.copy()
    env["vblank_mode"] = "0"
    with subprocess.Popen(cmd, env=env,
                          stderr=subprocess.PIPE,
                          stdout=open(os.devnull, "w"),
                          cwd=path.dirname(executable_path)) as proc:
        _, err = proc.communicate()
        if proc.returncode != 0:
            raise RuntimeError(err)

    assert os.path.exists(result_path)
    with open(result_path, "r") as read_fh:
        results = read_fh.readlines()
        for line in results:
            if "FPS" not in line:
                continue
            print(line.split()[1])

    os.unlink(config_path)
    os.unlink(result_path)
