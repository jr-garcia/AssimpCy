import sys
import zipfile
from os import environ as env, mkdir, path
from subprocess import CalledProcessError, check_output

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
        res = check_output("wget --no-check-certificate https://cmake.org/files/v3.10/cmake-3.10.2-Linux-x86_64.sh".split())
        print(res)
    except CalledProcessError as err:
        raise RuntimeError(str(err.output))
    print('cmake not found. Installing...')
    try:
        res = check_output("bash ./cmake-3.10.2-Linux-x86_64.sh --skip-license --prefix='./'".split())
        print(res)
    except CalledProcessError as err:
        raise RuntimeError(str(err.output))

try:
    import pypandoc
except ImportError:
    import installPandoc

PYTHON = env.get("PYTHON", sys.executable)

dest = path.join('downloads', 'assimp.zip')

if not path.exists(dest):
    print('assimp zip not found. Downloading...')
    try:
        res = check_output("{} -m pip install requests -f downloads --cache-dir downloads".format(PYTHON).split())
        print(res)
    except CalledProcessError as err:
        raise RuntimeError(str(err.output))

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
        if localCMake:
            local=' --local'
        else:
            local = ''
        res = check_output('bash ci_scripts/buildAssimp.sh{}'.format(local).split())
        print(res)
    except CalledProcessError as err:
        raise RuntimeError(str(err.output))
