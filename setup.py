# -*- coding: utf-8 -*-
from setuptools import Extension, setup, command
from sys import platform
from numpy import get_include
from distutils.sysconfig import get_config_vars
import os


def getVersion():
    dir = os.path.dirname(__file__)
    init_path = os.path.join(dir, 'assimpcy', '__init__.py')
    with open(init_path) as verFile:
        lines = verFile.readlines()
        for l in lines:
            if l.startswith('__version__'):
                return l.split('=')[1].strip(' \'\n\r\t-')


def getLongDescription():
    dir = os.path.dirname(__file__)
    init_path = os.path.join(dir, '_longDesc.md')
    with open(init_path) as descFile:
        all = descFile.read()
        return all


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
    name="AssimpCy",
    author='Javier R. García',
    version=getVersion(),
    description='Faster Python bindings for Assimp.',
    long_description=getLongDescription(),
    url='https://github.com/jr-garcia/AssimpCy',
    license='BSD3',
    classifiers=[
            'Development Status :: 5 - Production/Stable',
            'Intended Audience :: Developers', 
            'Topic :: Multimedia :: Graphics :: 3D Rendering',
            'License :: OSI Approved :: BSD License',
            'Programming Language :: Python :: 2.7',
            'Programming Language :: Python :: 3.4',
            'Programming Language :: Python :: 3.5',
            'Programming Language :: Python :: 3.6'],
    keywords='load 3d model geometry assimp',
    install_requires=['numpy'],
    packages=["assimpcy"],
    ext_modules=[
        Extension('assimpcy.all', ["./assimpcy/all.pyx"],
                  libraries=["assimp"],
                  include_dirs=incl,
                  runtime_library_dirs=rldirs,
                  extra_compile_args=extrac,
                  language="c++")
    ],
    requires=['numpy']
)
