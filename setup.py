# -*- coding: utf-8 -*-
from setuptools import Extension, setup
from sys import platform, maxsize
from numpy import get_include
from Cython.Build import cythonize
from distutils.sysconfig import get_config_vars
from glob import glob
import os

base_folder = os.path.dirname(__file__)


def getVersion():
    init_path = os.path.join(base_folder, 'assimpcy', '__init__.py')
    with open(init_path) as verFile:
        lines = verFile.readlines()
    for line in lines:
        if line.startswith('__version__'):
            return line.split('=')[1].strip(' \'\n\r\t-')


def getLongDescription():
    desc_path = os.path.join(base_folder, 'docs', '_pypi_desc.rst')
    try:
        with open(desc_path) as doc:
            rst = doc.read()
        return rst
    except Exception as err:
        from warnings import warn
        warn('Rst description failed: ' + str(err))
        return 'Fast Python bindings for Assimp.'


def get_extra_requirements():
    req_path = os.path.join(base_folder, 'docs', 'requirements.txt')
    try:
        with open(req_path) as req:
            cont = req.read()
        return cont.split()
    except Exception:
        return []


(opt,) = get_config_vars('OPT')
if opt:
    os.environ['OPT'] = " ".join(flag for flag in opt.split() if flag != '-Wstrict-prototypes')

local_includes_path = os.path.join(base_folder, 'files', 'include')
local_libs_path = os.path.join(base_folder, 'files', 'lib')
include_paths = [get_include(), local_includes_path, os.path.join(local_includes_path, 'assimp')]
lib_paths = [local_libs_path]
runtime_lib_paths = []
libraries = ['assimp', 'IrrXML', 'zlibstatic']
extraCompile = []
extraLink = []

if platform == 'win32':
    archString = '' if (maxsize > 2 ** 32) else ' (x86)'
    base = 'C:\\Program Files{}\\Assimp'.format(archString)
    system_include_path = base + '\\include'
    libPath = base + '\\lib'
    include_paths.extend([system_include_path, system_include_path + "\\assimp"])
    lib_paths.append(libPath)
    extraCompile.extend(['/d2FH4-', '/EHsc', '/openmp'])
elif platform == 'darwin':
    extraLink.append('-stdlib=libc++')
    extraCompile.append('-stdlib=libc++')
    # look for suitable llvm compiler, default compiler does not compile nore support openmp
    local_clang = sorted(glob('/usr/local/bin/clang++*')) 
    port_clang = sorted(glob('/opt/local/bin/clang++*'))
    brew_clang = sorted(glob('/usr/local/Cellar/llvm/*/bin/clang++*'))
    clang = local_clang + port_clang + brew_clang
    if 'CC' not in os.environ and 'CXX' not in os.environ and clang:
        print('Using compiler', clang[-1])
        os.environ["CC"] = os.environ["CXX"] = clang[-1]
        if 'Cellar' in clang[-1]:
            include_paths.extend(glob('/usr/local/opt/llvm/include'))
            include_paths.extend(glob('/usr/local/opt/llvm*/include/c++/v1'))

            lib_path = sorted(glob('/usr/local/Cellar/llvm/*/lib'))[-1]
            os.environ['LDFLAGS'] = "-L%s -Wl,-rpath,%s" % (lib_path, lib_path)
        elif 'opt' in clang[-1]:
            lib_paths.append('/opt/local/lib')
            include_paths.extend(glob('/opt/local/libexec/llvm*/include/c++/v1'))
        else:
            include_paths.extend(glob('/usr/local/opt/llvm/include'))
            include_paths.extend(glob('/usr/local/opt/llvm*/include/c++/v1'))
            lib_paths.extend(glob('/usr/local/opt/llvm/lib'))
            lib_paths.append('/usr/local/lib')

    # macports and homebrew locations
    local_assimp_head = sorted(glob('/usr/local/include/assimp'))
    port_assimp_head = sorted(glob('/opt/local/include/assimp'))
    brew_assimp_head = sorted(glob('/usr/local/Cellar/assimp/*/include'))
    assimp_head = local_assimp_head + port_assimp_head + brew_assimp_head
    if assimp_head:
        include_paths.append(assimp_head[-1])
        assimp_lib = ''
        if 'Cellar' in assimp_head[-1]:
            assimp_lib = sorted(glob('/usr/local/Cellar/assimp/*/lib'))[-1]
            include_paths.append(assimp_head[-1] + '/assimp')
        elif 'opt' in assimp_head[-1]:
            assimp_lib = '/opt/local/lib'
            include_paths.append('/opt/local/include/')
        else:
            assimp_lib = '/usr/local/lib'
            include_paths.append('/usr/local/include/')
        
        lib_paths.append(assimp_lib)
        include_paths.extend(['/usr/include/', '/usr/local/include/'])
        print('Using assimp headers:', assimp_head[-1])
        print('Using assimp lib:', assimp_lib)

    extraCompile.append('-fopenmp')
    extraLink.append('-fopenmp')
else:
    include_paths.extend(['/usr/include', '/usr/local/include',
                         '/usr/include/assimp', '/usr/local/include/assimp'])
    lib_paths.extend(['/usr/lib', '/usr/local/lib'])
    runtime_lib_paths.append("$ORIGIN")
    extraCompile.extend(["-w", "-O3", '-fopenmp', '-std=c++11', '-pedantic'])
    extraLink = ['-fopenmp', '-lgomp']

setup(
    name="AssimpCy",
    author='Javier R. García',
    version=getVersion(),
    description='Fast Python bindings for Assimp.',
    long_description=getLongDescription(),
    long_description_content_type='text/x-rst',
    url='https://github.com/jr-garcia/AssimpCy',
    license='BSD3',
    classifiers=[
            'Development Status :: 5 - Production/Stable',
            'Intended Audience :: Developers',
            'License :: OSI Approved :: BSD License',
            'Programming Language :: Cython',
            'Programming Language :: Python :: 3.7',
            'Programming Language :: Python :: 3.8',
            'Programming Language :: Python :: 3.9',
            'Programming Language :: Python :: 3.10',
            'Programming Language :: Python :: Implementation :: CPython',
            'Programming Language :: Python :: Implementation :: PyPy',
            'Topic :: Games/Entertainment',
            'Topic :: Multimedia :: Graphics :: 3D Modeling',
            'Topic :: Multimedia :: Graphics :: 3D Rendering',
            'Topic :: Software Development :: Libraries'],
    keywords='3d,model,geometry,assimp,games,cython',
    install_requires=['numpy'],
    extras_require={
            'docs': get_extra_requirements()
        },
    packages=["assimpcy"],
    ext_modules=cythonize([
        Extension('assimpcy.all', [os.path.join(os.path.curdir, "assimpcy", "all.pyx")],
                  libraries=libraries,
                  include_dirs=include_paths,
                  library_dirs=lib_paths,
                  runtime_library_dirs=runtime_lib_paths,
                  extra_compile_args=extraCompile,
                  extra_link_args=extraLink,
                  language="c++")
    ]),
    requires=['numpy']
)
