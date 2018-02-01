Installation
------------

* First, be sure to download, compile and install Assimp, from the official page:

  http://www.assimp.org/

  You'll need Cmake, and Microsoft Visual Studio for Windows or Gcc for Linux and Mac (optionally, Mingw-w64).

* Second, download the zip package from

  https://github.com/jr-garcia/AssimpCy

  If you placed the headers and libraries in the dafault locations, extract the file and run::

      python setup.py build_ext

  If setup can't find the headers or you placed them somewhere else, run::

      python setup.py build_ext -I'path/to/assimp/headers' -L'path/to/library/'

.. attention::
    If you get an error saying:
    .. error::

        Cannot open include file: 'types.h':

    Be sure that the path to headers ends with '\\assimp'

Cython is only necessary to rebuild the .cpp files, wich you can do with::

    python setup.py build_ext --force

Finally, run::

    python setup.py install

To install the package. Check ***basic_demo.py*** for a simple example or read :doc:`/usage`.
