Installation
------------

Lets say you already tried::

    pip install assimpcy

And that failed or you want to make changes to the code or
recompile the extension with a different version of the Assimp library, so you will compile from the sources.

You will need:
  * Cmake 3
  * Microsoft Visual Studio 2017+ for Windows or Gcc for Linux and Mac (Clang might work too).

#. Download AssimpCy from:

   https://github.com/jr-garcia/AssimpCy

   And extract the zip package (or clone the repository with Git).

#. Download Assimp from the official page (minimum version 5.0.1):

   http://www.assimp.org/

#. Compile Assimp with the next options for cmake::

    -DBUILD_SHARED_LIBS=OFF -DASSIMP_INCLUDE_INSTALL_DIR=assimpcy_folder/files/include -DASSIMP_LIB_INSTALL_DIR=assimpcy_folder/files/lib

   Replace ``assimpcy_folder`` with the path where AssimpCy was extracted / cloned.

   Compile and install Assimp with::

        make
        make install


   You should end up with Assimp headers in ``assimpcy_folder/files/include`` and static versions of 3 libraries in ``assimpcy_folder/files/lib``::

        libassimp, libIrrXML, libzlibstatic


#. Install `Cython <https://cython.org/>`_ and `Numpy <http://www.numpy.org/>`_ with::

    pip install cython==0.29.24 numpy==1.21.4

  .. note::
    The versions specified are the ones used to build the wheels stored at Pypi.

    You are free to try older or newer versions of the packages listed above,
    if available.

#. Build AssimpCy by executing, from its folder::

      python setup.py build_ext

   If setup.py can't find the headers, specify them manually::

      python setup.py build_ext -I'path/to/assimp/headers' -L'path/to/library/'

   .. attention::
       If you get an error saying::

           Cannot open include file: 'types.h':

       It means that setup.py is not finding the Assimp headers. Make sure that there is a folder called
       ``include`` in the AssimpCy files folder or in a path that your compiler can find.

#. Finally, to install the package, run::

      python setup.py install


Check `basic_demo.py <https://github.com/jr-garcia/AssimpCy/blob/master/examples/basic_demo.py>`_  in AssimpCy folder for a simple example or read :doc:`/usage`.