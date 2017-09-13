#!/usr/bin/env python3
"""runs the synmark benchmark"""

import os
import os.path as path
import json
import re
import subprocess
import sys

from .. import config

# Benchmark duration in seconds
DURATION_SECONDS = 10

def run(test, args=None):
    """test gputest"""
    conf = config.get_config_for_module('gputest')
    assert len(conf.executables) == 1
    executable_path = path.join(conf.benchmark_path, conf.executables[0])

    test_name_remap = {
        'furmark' : 'fur',
        'gimark' : 'gi',
        'piano' : 'pixmark_piano',
        'plot3d' : 'plot3d',
        'tessmark' : 'tessmark',
        'triangle' : 'triangle',
        'volplosion' : 'pixmark_volplosion',
    }

    cmd = [
        executable_path,
        '/test={}'.format(test_name_remap[test]),
        '/width={}'.format(args.width),
        '/height={}'.format(args.height),
        '/benchmark',
        '/benchmark_duration_ms={}'.format(DURATION_SECONDS * 1000),
        '/print_score',
        '/no_scorebox',
    ]
    if args.fullscreen:
        cmd.append("/fullscreen")

    env = os.environ.copy()
    env["vblank_mode"] = "0"
    with subprocess.Popen(cmd, env=env,
                          stderr=subprocess.PIPE,
                          stdout=subprocess.PIPE,
                          cwd=path.dirname(executable_path)) as proc:
        out, err = proc.communicate()
        if proc.returncode != 0:
            raise RuntimeError(err)

    # The benchmark gives us both FPS and "points".  It appears that
    # "points" are actually just the number of frames rendered.  Divide by
    # the test duration and you get a more accurate FPS number.
    m = re.search(r'Score:\s*(?P<frames>\d+)\s*points', out.decode('utf-8'))
    fps = float(m.group('frames')) / DURATION_SECONDS
    print(fps)
