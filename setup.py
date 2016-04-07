from setuptools import Extension, setup, command
from Cython.Distutils import build_ext
from Cython.Build import cythonize
from sys import platform
from numpy import get_include

from distutils.sysconfig import get_config_vars
import os

(opt,) = get_config_vars('OPT')
if opt:
    os.environ['OPT'] = " ".join(flag for flag in opt.split() if flag != '-Wstrict-prototypes')

incl = [get_include()]
extrac = []

if platform == 'win32':
    rldirs = []
    extrac.append('/EHsc')
elif platform == 'darwin':
    rldirs = []
else:
    incl.extend(['/usr/include/assimp', '/usr/local/include/assimp'])
    rldirs = ["$ORIGIN"]
    extrac.extend(["-w", "-O3"])

setup(
    name="assimpcy",
    packages=["assimpcy"],
    ext_modules=cythonize([
        Extension('*', ["assimpcy/*.pyx"],
                  libraries=["assimp"],
                  include_dirs=incl,
                  runtime_library_dirs=rldirs,
                  extra_compile_args=extrac,
                  language="c++")
    ]),
    cmdclass={'build_ext': build_ext},
)
