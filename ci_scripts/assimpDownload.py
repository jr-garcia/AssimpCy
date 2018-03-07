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

print('compiled assimp not found. Building...')

if not path.exists('downloads'):
    mkdir('downloads')

try:
    import pypandoc
except ImportError:
    import installPandoc

PYTHON = env.get("PYTHON", sys.executable)

dest = path.join('downloads', 'assimp.zip')

if not path.exists(dest):
    print('assimp zip not found. Downloading...')
    try:
        check_output("{} -m pip install requests -f downloads --cache-dir downloads".format(PYTHON).split())
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

if platform == 'win32':
    pass
else:
    try:
        env['GENERATOR'] = 'Unix Makefiles'
        # import stat
        # import os
        # st = os.stat('ci_scripts/buildAssimp.sh')
        # os.chmod('ci_scripts/buildAssimp.sh', st.st_mode | stat.S_IEXEC)
        check_output('bash ci_scripts/buildAssimp.sh'.split())
    except CalledProcessError as err:
        raise RuntimeError(str(err.output))
