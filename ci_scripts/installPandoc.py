import os
from subprocess import call, check_output
import sys
from shutil import copy2


def checkAndInstall():
    try:
        check_output('pandoc -v'.split())
    except OSError:
        cudir = os.path.abspath(os.curdir)
        os.chdir('downloads')

        from requests import get

        pandocFile = 'pandoc-2.1.3-linux.tar.gz'

        with open(pandocFile, "wb") as file:
            response = get('https://github.com/jgm/pandoc/releases/download/2.1.3/pandoc-2.1.3-linux.tar.gz')
            file.write(response.content)

        call("tar -xvzf {}".format(pandocFile).split())
        copy2('./pandoc-2.1.3/bin/pandoc', '/usr/local/bin')
        copy2('./pandoc-2.1.3/bin/pandoc-citeproc', '/usr/local/bin')

        os.chdir(cudir)
