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

print('\ncompiled assimp not found. Starting process...')
sys.stdout.flush()

if not path.exists('downloads'):
    mkdir('downloads')

import buildCmake

PYTHON = env.get("PYTHON", sys.executable)

dest = path.join('downloads', 'assimp.zip')

if not path.exists(dest):
    print('\nassimp zip not found. Downloading...')
    sys.stdout.flush()
    try:
        check_call("{} -m pip install requests -f downloads --cache-dir downloads".format(PYTHON).split())
    except CalledProcessError as err:
        raise RuntimeError(str(err))

    from requests import get

    with open(dest, "wb") as file:
        response = get('https://github.com/assimp/assimp/archive/v4.1.0.zip')
        file.write(response.content)

if not path.exists('assimp_unzipped'):
    print('\nunpacked assimp not found. Unpacking...')
    sys.stdout.flush()
    zip_ref = zipfile.ZipFile(dest, 'r')
    zip_ref.extractall('assimp_unzipped')
    zip_ref.close()

print('\ncalling build script...')
sys.stdout.flush()

if platform == 'win32':
    pass
else:
    try:
        check_call('bash ci_scripts/buildAssimp.sh'.split())
    except CalledProcessError as err:
        raise RuntimeError(str(err))
