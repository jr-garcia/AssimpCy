import sys
import zipfile
from os import environ as env, mkdir, path
from subprocess import CalledProcessError, check_call

platform = sys.platform
includes = []

if platform == 'win32':
    archString = '' if (maxsize > 2 ** 32) else ' (x86)'
    base = 'C:\\Program Files{}\\Assimp'.format(archString)
    includePath = base + '\\include'
    includes.extend([includePath])
elif platform == 'darwin':
    pass
else:
    includes.extend(['/usr/include/assimp', '/usr/local/include/assimp'])

for iPath in includes:
    if path.exists(iPath):
        exit(0)

print('compiled assimp not found. Starting process...')

if not path.exists('downloads'):
    mkdir('downloads')

localCMake = env.get('LOCAL_CMAKE', None)

if localCMake is not None:
    print('Cmake not found. Downloading...')
    try:
        check_call("wget --no-check-certificate https://cmake.org/files/v3.10/cmake-3.10.2-Linux-x86_64.sh".split())
    except CalledProcessError as err:
        raise RuntimeError(str(err))
    print('cmake not found. Installing...')
    try:
        check_call("bash ./cmake-3.10.2-Linux-x86_64.sh --skip-license".format('.').split())
    except CalledProcessError as err:
        raise RuntimeError(str(err))

try:
    import pypandoc
except ImportError:
    print('Pandoc missing. Installing...')
    import installPandoc

PYTHON = env.get("PYTHON", sys.executable)

dest = path.join('downloads', 'assimp.zip')

if not path.exists(dest):
    print('assimp zip not found. Downloading...')
    try:
        check_call("{} -m pip install requests -f downloads --cache-dir downloads".format(PYTHON).split())
    except CalledProcessError as err:
        raise RuntimeError(str(err))

    from requests import get

    with open(dest, "wb") as file:
        response = get('https://github.com/assimp/assimp/archive/v4.1.0.zip')
        file.write(response.content)

if not path.exists('assimp_unzipped'):
    print('unpacked assimp not found. Unpacking...')
    zip_ref = zipfile.ZipFile(dest, 'r')
    zip_ref.extractall('assimp_unzipped')
    zip_ref.close()

print('calling build script...')

if platform == 'win32':
    pass
else:
    try:
        if localCMake is not None:
            local = ' --local'
        else:
            local = ''
        check_call('bash ci_scripts/buildAssimp.sh{}'.format(local).split())
    except CalledProcessError as err:
        raise RuntimeError(str(err))
