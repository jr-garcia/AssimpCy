from os import chdir, environ as env
from os.path import *
from shutil import copyfile

print('Renaming file...')

BASEPATH = 'C:\\Program Files{}\\Assimp\\lib\\'.format(env.get("ARCHSTR", ''))
copyfile(BASEPATH + "assimp-vc140-mt.lib", BASEPATH + "assimp.lib")
