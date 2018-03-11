import sys
import bz2
from os import environ as env, mkdir, path, chdir
from subprocess import CalledProcessError, check_call, check_output

try:
    res = check_output('cmake --version'.split())
    if '3.0' in str(res):
        exit(0)
except OSError as err:
    pass

cmakeSrc = 'downloads/cmake-3.9.6.tar.gz'
if not path.exists(cmakeSrc):
    print('Cmake 3 not found. Downloading...')
    try:
        check_call("wget --no-check-certificate https://cmake.org/files/v3.9/cmake-3.9.6.tar.gz -O {}".format(cmakeSrc).split())
    except CalledProcessError as err:
        raise RuntimeError(str(err))

unpackedPath = 'cmake-3.9.6'
if not path.exists(unpackedPath):
    print('unpacked cmake not found. Unpacking...')
    try:
        check_call('tar -zxvf {}'.format(cmakeSrc).split())
    except CalledProcessError as err:
        raise RuntimeError(str(err))

print('calling build script...')

try:
    chdir(unpackedPath)
    check_call('bash ./bootstrap && make && make install'.split())
except CalledProcessError as err:
    raise RuntimeError(str(err))
