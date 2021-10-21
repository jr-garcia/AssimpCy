Installation
------------

If installing with Pip fails or if you want to make changes to the code,
you'll need to compile from the sources.

* First, download, compile and install Assimp, from the official page:

  http://www.assimp.org/

  You'll need Cmake, and Microsoft Visual Studio for Windows
  or Gcc for Linux and Mac (optionally, Mingw-w64).
  On Linux, you can install Assimp from your system's repositories.

* Second, install `Cython <https://cython.org/>`_ and `Numpy <http://www.numpy.org/>`_ with::

      pip install numpy cython

* Third, download and extract the zip package from

  https://github.com/jr-garcia/AssimpCy

  or clone the repository with Git.

  If you placed the Assimp headers and libraries in the default locations, run::

      python setup.py build_ext

  If setup.py can't find the headers, specify them manually::

      python setup.py build_ext -I'path/to/assimp/headers' -L'path/to/library/'

.. attention::
    If you get an error saying:
    .. error::

        Cannot open include file: 'types.h':

    Make sure that the path to headers ends with '\\assimp'

Finally, to install the package, run::

    python setup.py install


Check ***examples/basic_demo.py*** in Assimpcy folder for a simple example or read :doc:`/usage`.
