from __future__ import print_function
import os
from os import environ as env
from subprocess import call, check_output
from sys import argv, executable

# https://stackoverflow.com/a/3357357
command = 'git log --format=%B -n 1 {}'.format(env.get("APPVEYOR_REPO_COMMIT", '')).split(' ')
out = check_output(command)

if b'build wheels' not in out.lower():
    exit(0)

from installPandoc import checkAndInstall
checkAndInstall()

print('Building wheels...', end='')

PYTHON = executable

call("{} -m pip install wheel -f downloads --cache-dir downloads".format(PYTHON).split())
call("{} setup.py bdist_wheel".format(PYTHON).split())

print('Done.')

from dropboxUpload import uploadAll

path = os.path.abspath(argv[1])
if not os.path.exists(path):
    from warnings import warn

    warn("File Not Found: {}".format(path))
    exit(0)

uploadAll(path)
