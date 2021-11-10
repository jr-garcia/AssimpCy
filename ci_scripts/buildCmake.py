import sys
from os import path, chdir
from subprocess import CalledProcessError, check_call, check_output

base_folder = path.dirname(__file__)


def check_version():
    try:
        res = check_output('cmake --version'.split())
        ver = str(res.decode()).strip('\n').split()[2]
        if '3.' in ver:
            return True, ver
    except OSError as err:
        return False, str(err)


res, ver = check_version()
cmake_str = '\nRequired minimum Cmake 3 {} ({})'

if res:
    print(cmake_str.format('found', ver))
    exit(0)
else:
    print(cmake_str.format('not found', ver))

sys.stdout.flush()

cmakeSrc = path.join(base_folder, 'cmake-3.16.3.tar.gz')
print('\nDownloading Cmake 3.10 archive...')
sys.stdout.flush()
try:
    check_call("wget -nv --no-check-certificate https://cmake.org/files/v3.16/cmake-3.16.3.tar.gz -O {}".format(cmakeSrc).split())
except CalledProcessError as err:
    raise RuntimeError(str(err))

unpackedPath = path.join(base_folder, 'cmake-3.16.3')
print('\nUnpacking archive...')
sys.stdout.flush()
try:
    check_output('tar -zxvf {}'.format(cmakeSrc).split())
except CalledProcessError as err:
    raise RuntimeError(str(err.output[-200:]))

print('\nCalling build script...')
sys.stdout.flush()
chdir(unpackedPath)
try:
    print('\t-Bootstrapping...')
    sys.stdout.flush()
    check_output('bash ./bootstrap'.split())
except CalledProcessError as err:
    raise RuntimeError(str(err.output[-200:]))
try:
    print('\t-Making...')
    sys.stdout.flush()
    check_output('make --quiet'.split())
except CalledProcessError as err:
    raise RuntimeError(str(err.output[-200:]))
try:
    print('\t-Installing...')
    sys.stdout.flush()
    check_output('make install'.split())
except CalledProcessError as err:
    raise RuntimeError(str(err.output[-200:]))

try:
    print('\t-Installing...')
    sys.stdout.flush()
    check_output('make install'.split())
except CalledProcessError as err:
    raise RuntimeError(str(err.output[-200:]))
chdir('..')
