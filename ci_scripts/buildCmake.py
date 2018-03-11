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
    print('\nCmake 3 not found. Downloading...')
    sys.stdout.flush()
    try:
        check_call("wget -nv --no-check-certificate https://cmake.org/files/v3.9/cmake-3.9.6.tar.gz -O {}".format(cmakeSrc).split())
    except CalledProcessError as err:
        raise RuntimeError(str(err))

unpackedPath = 'cmake-3.9.6'
if not path.exists(unpackedPath):
    print('\nunpacked cmake not found. Unpacking...')
    sys.stdout.flush()
    try:
        check_call('tar -zxvf {}'.format(cmakeSrc).split())
    except CalledProcessError as err:
        raise RuntimeError(str(err))

print('\ncalling build script...')
sys.stdout.flush()

chdir(unpackedPath)
try:
    print('bootstrapping...')
    sys.stdout.flush()
    check_output('bash ./bootstrap'.split())
except CalledProcessError as err:
    raise RuntimeError(str(err.output[-200:]))
try:
    print('\nMaking...')
    sys.stdout.flush()
    check_call('make'.split())
except CalledProcessError as err:
    raise RuntimeError(str(err))
try:
    print('\nInstalling...')
    sys.stdout.flush()
    check_call('make install'.split())
except CalledProcessError as err:
    raise RuntimeError(str(err))