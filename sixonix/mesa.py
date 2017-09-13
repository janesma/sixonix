import os
import os.path
import subprocess

def _is_64bit_elf(path):
    path = os.path.realpath(path)
    if not os.path.isfile(path):
        return False

    with subprocess.Popen(['/usr/bin/file', path],
                          stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE) as proc:
        out, err = proc.communicate()
        if proc.returncode != 0:
            raise RuntimeError(err.decode('utf-8'))

        return out.decode('utf-8').find('ELF 64-bit') >= 0

def _env_prepend_path(env, key, path):
    if key in env:
        # TODO: Windows
        sep = ':'
        env[key] = sep.join([path, env[key]])
    else:
        env[key] = path

class MesaPrefix(object):
    def __init__(self, path, name=None, dri_driver=None):
        if name is not None:
            self.name = name
        else:
            self.name = os.path.basename(path)

        lib_dirs = [
            '',
            'lib',
            'lib64',
            'usr/lib',
            'usr/lib64',
        ]

        self.lib_path = None
        for lib_dir in lib_dirs:
            lib_path = os.path.join(path, lib_dir)
            if not os.path.isdir(lib_path):
                continue

            if _is_64bit_elf(os.path.join(lib_path, 'libGL.so')):
                self.lib_path = os.path.abspath(lib_path)
                break

        if self.lib_path is None:
            raise RuntimeError('Invalid mesa path: {}'.format(path))

        self.dri_path = None
        for dri_dir in ['', 'dri']:
            dri_path = os.path.join(self.lib_path, dri_dir)
            if not os.path.isdir(dri_path):
                continue

            is_dri_dir = False
            for soname in os.listdir(dri_path):
                if not soname.endswith('_dri.so'):
                    continue

                if dri_driver is not None and soname != dri_driver + '_dri.so':
                    continue

                if _is_64bit_elf(os.path.join(dri_path, soname)):
                    is_dri_dir = True
                    break

            if is_dri_dir:
                self.dri_path = os.path.abspath(dri_path)
                break

        if self.dri_path is None:
            raise RuntimeError('No dri drivers found at {}'.format(path))

        # TODO: Figure out Vulkan

    def update_env(self, env):
        _env_prepend_path(env, 'LD_LIBRARY_PATH', self.lib_path)
        env['LIBGL_DRIVERS_PATH'] = self.dri_path
        env['GBM_DRIVERS_PATH'] = self.dri_path
