from os import environ as env
import os
from subprocess import call
import sys

PYTHON = env.get("PYTHON", sys.executable)
call("{} -m pip install pypandoc -f downloads --cache-dir downloads".format(PYTHON).split())

from pypandoc.pandoc_download import download_pandoc

cudir = os.path.abspath(os.curdir)
os.chdir('downloads')
download_pandoc(version='1.19.1')
os.chdir(cudir)
