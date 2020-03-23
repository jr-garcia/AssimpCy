# -*- coding: utf-8 -*-
from setuptools import Extension, setup, command
from sys import platform, maxsize, version_info
from numpy import get_include
from distutils.sysconfig import get_config_vars
from glob import glob
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
    from subprocess import check_output, CalledProcessError
    directory = os.path.dirname(__file__)
    init_path = os.path.join(directory, 'readme.md')
    pyver = version_info.major
    try:
        rst = check_output('pandoc {} -f markdown -t rst'.format(init_path).split())
        if pyver == 3:
            rst = rst.decode()
        return rst
    except CalledProcessError:
        raise
    except OSError:
        from warnings import warn
        warn('error converting Readme to rst. Trying online Pandoc')
        try:
            from ipandoc import convert
            with open(init_path) as doc:
                markdowntext = doc.read()
            rst = convert(text=markdowntext, fromformat="markdown", toformat="rst")
            if pyver == 3:
                rst = rst.decode()
            return rst
        except Exception as err:
            warn('online Pandoc failed: ' + str(err))
            with open(init_path) as descFile:
                all = descFile.read()
            return all


(opt,) = get_config_vars('OPT')
if opt:
    os.environ['OPT'] = " ".join(flag for flag in opt.split() if flag != '-Wstrict-prototypes')

includes = [get_include()]
libs = []
extraCompile = []
extraLink = []

if platform == 'win32':
    rldirs = []
    archString = '' if (maxsize > 2 ** 32) else ' (x86)'
    base = 'C:\\Program Files{}\\Assimp'.format(archString)
    includePath = base + '\\include'
    libPath = base + '\\lib'
    includes.extend([includePath, includePath + "\\assimp"])
    libs.append(libPath)
    extraCompile.extend(['/EHsc', '/openmp'])
    extraLink = []
elif platform == 'darwin':
    rldirs = []
    # look for suitable llvm compiler, default compiler does not compile nore support openmp
    local_clang = sorted(glob('/usr/local/bin/clang++*')) 
    port_clang = sorted(glob('/opt/local/bin/clang++*'))
    brew_clang = sorted(glob('/usr/local/Cellar/llvm/*/bin/clang++*'))
    clang = local_clang + port_clang + brew_clang
    if 'CC' not in os.environ and 'CXX' not in os.environ and clang:
        print('Using compiler', clang[-1])
        os.environ["CC"] = os.environ["CXX"] = clang[-1]
        if 'Cellar' in clang[-1]:
            includes.extend(glob('/usr/local/opt/llvm/include"'))
            includes.extend(glob('/usr/local/opt/llvm*/include/c++/v1"'))

            lib_path = sorted(glob('/usr/local/Cellar/llvm/*/lib'))[-1]
            os.environ['LDFLAGS']="-L%s -Wl,-rpath,%s" % (lib_path, lib_path)
            extraLink.append('-stdlib=libc++')
        elif 'opt' in clang[-1]:
            libs.append('/opt/local/lib')
            includes.extend(glob('/opt/local/libexec/llvm*/include/c++/v1'))
        else:
            includes.extend(glob('/usr/local/opt/llvm/include"'))
            includes.extend(glob('/usr/local/opt/llvm*/include/c++/v1"'))
            libs.append('/usr/local/lib')

    # macports and homebrew locations
    local_assimp_head = sorted(glob('/usr/local/include/assimp'))
    port_assimp_head = sorted(glob('/opt/local/include/assimp'))
    brew_assimp_head = sorted(glob('/usr/local/Cellar/assimp/*/include/assimp'))
    assimp_head = local_assimp_head + port_assimp_head + brew_assimp_head
    if assimp_head:
        includes.append(assimp_head[-1])
        assimp_lib = ''
        if 'Cellar' in assimp_head[-1]:
            assimp_lib = sorted(glob('/usr/local/Cellar/assimp/*/lib'))[-1]
        elif 'opt' in assimp_head[-1]:
            assimp_lib = '/opt/local/lib'
            includes.append('/opt/local/include/')
        else:
            assimp_lib = '/usr/local/lib'
            includes.append('/usr/local/include/')
        
        libs.append(assimp_lib)
        includes.extend(['/usr/include/', '/usr/local/include/'])
        print('Using assimp headers:', assimp_head[-1])
        print('Using assimp lib:', assimp_lib)

    extraCompile.append('-fopenmp')
    extraLink.append('-fopenmp')
else:
    includes.extend(['/usr/include/assimp', '/usr/local/include/assimp'])
    libs.extend(['/usr/lib/', '/usr/local/lib'])
    rldirs = ["$ORIGIN"]
    extraCompile.extend(["-w", "-O3", '-fopenmp', '-std=c++0x'])
    extraLink = ['-fopenmp', '-lgomp']

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
        Extension('assimpcy.all', [os.path.join(os.path.curdir, "assimpcy", "all.pyx")],
                  libraries=["assimp"],
                  include_dirs=includes,
                  library_dirs=libs,
                  runtime_library_dirs=rldirs,
                  extra_compile_args=extraCompile,
                  extra_link_args=extraLink,
                  language="c++")
    ],
    requires=['numpy']
)
