from subprocess import call, check_output
import sys
import os

isPython3 = sys.version_info.major == 3

# https://stackoverflow.com/a/3357357
command = 'git log --format=%B -n 1'.split()
out = check_output(command)

if b'build wheels' not in out.lower() or not isPython3:
    exit(0)

path = os.path.abspath(sys.argv[1])
call('pip install cibuildwheel==0.7.0'.split())
call('cibuildwheel --output-dir {}'.format(sys.argv[1]).split())

call('pip install dropbox'.split())
from dropboxUpload import uploadAll

uploadAll(path)
