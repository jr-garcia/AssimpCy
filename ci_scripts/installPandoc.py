import os
from subprocess import call, check_output
import sys
from shutil import copy2

platform = sys.platform


def checkAndInstall():
    try:
        check_output('pandoc -v'.split())
    except OSError:
        cudir = os.path.abspath(os.curdir)
        os.chdir(os.path.abspath(os.path.join(os.path.pardir, 'downloads')))

        def getFile():
            from requests import get
            with open(pandocFile, "wb") as file:
                response = get(source)
                file.write(response.content)

        if platform == 'win32':
            pandocFile = 'pandoc-2.1.3-windows.msi'
            source = 'https://github.com/jgm/pandoc/releases/download/2.1.3/' + pandocFile
            getFile()
            call('msiexec.exe /i "{}" /norestart'.format(pandocFile))
        else:
            pandocFile = 'pandoc-2.1.3-linux.tar.gz'
            source = 'https://github.com/jgm/pandoc/releases/download/2.1.3/' + pandocFile
            getFile()
            call("tar -xvzf {}".format(pandocFile).split())
            copy2('./pandoc-2.1.3/bin/pandoc', '/usr/local/bin')
            copy2('./pandoc-2.1.3/bin/pandoc-citeproc', '/usr/local/bin')

        os.chdir(cudir)


if __name__ == '__main__':
    checkAndInstall()
