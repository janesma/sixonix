#!/usr/bin/env python3
"""runs the xonotic benchmark"""

import os
import os.path as path
import re
import subprocess

from .. import config

def run(test, args, env):
    """test xonotic"""
    conf = config.get_config_for_module('xonotic')
    executable_path = path.join(conf.benchmark_path, conf.executables[0])

    base_dir = path.join(executable_path, '..')
    if conf.platform == 'windows':
        # on windows, the base directory is one level higher.
        base_dir = path.join(base_dir, '..')
    base_dir = path.abspath(base_dir)

    cmd = [
        executable_path,
        '-nohome',
        '-benchmark', 'demos/the-big-keybench.dem',
        '+r_glsl', '1',
        '+exec', 'effects-{}.cfg'.format(test),
        '+vid_width', str(args.width),
        '+vid_height', str(args.height),
        '+vid_fullscreen', str(int(args.fullscreen)),
    ]

    with subprocess.Popen(cmd, env=env,
                          stderr=open(os.devnull, 'w'),
                          stdout=subprocess.PIPE,
                          cwd=base_dir) as proc:
        out, err = proc.communicate()
        if proc.returncode != 0:
            raise RuntimeError(err)

    m = re.search(r'(?P<fps>\d+(\.\d+)?)\s+fps', out.decode('utf-8'))
    return float(m.group('fps'))
