from os import path, mkdir, chdir
import sys
import zipfile
from os import environ as env
from subprocess import check_output

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

print('compiled assimp not found. Building...')

import installPandoc

if not path.exists('downloads'):
    mkdir('downloads')

PYTHON = env.get("PYTHON", sys.executable)

dest = path.join('downloads', 'assimp.zip')

if not path.exists(dest):
    print('assimp zip not found. Downloading...')
    check_output("{} -m pip install requests -f downloads --cache-dir downloads".format(PYTHON).split())
    from requests import get

    with open(dest, "wb") as file:
        response = get('https://github.com/assimp/assimp/archive/v4.1.0.zip')
        file.write(response.content)

if not path.exists('assimp_unzipped'):
    print('unpacked assimp not found. Unpacking...')
    zip_ref = zipfile.ZipFile(dest, 'r')
    zip_ref.extractall('assimp_unzipped')
    zip_ref.close()

if platform == 'win32':
    pass
else:
    check_output('bash buildAssimp.sh'.split())
