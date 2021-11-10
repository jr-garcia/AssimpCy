Usage
=====

Model import
^^^^^^^^^^^^
The whole work to import a model with :mod:`assimpcy` is done by :func:`aiImportFile`

The package uses the same functions and parameters names of the original library, so examples from the
official Assimp docs and other tutorials can be used with minor changes.

.. code:: python

   from assimpcy import aiImportFile, aiPostProcessSteps as pp
   flags = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_Triangulate
   scene = aiImportFile('somemodel.3ds', flags)
   print('Vertex 0 = {}'.format(scene.mMeshes[0].mVertices[0]))

Matrices, quaternions and vectors are returned as Numpy arrays.

.. note::
   There is no need to release the scene. This job is performed by :py:func:`aiImportFile`


Embedded textures
^^^^^^^^^^^^^^^^^

When a model includes the textures in the same file, they will be located in the :py:class:`scene.mTextures` list.

To use them, you can:

.. code:: python

    from assimpcy import aiImportFile, aiPostProcessSteps as pp
    flags = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_Triangulate
    scene = aiImportFile('mymodel.3ds', flags) 
    if scene.HasTextures:
        for t in scene.mTextures:
            data = t.pcData
            hint = t.achFormatHint.decode()
            if len(hint) == 3:
                # the hint indicates the texture format as an extension (e.g. png)
                from io import BytesIO
                imgfile = BytesIO(data)
                img = Image.open(imgfile)  # let Pillow figure out the image format
                w, h = img.size
                data = np.asarray(img)
                # flatten the data array
                # to send it to the graphics library
            else:
                # no hint or raw data description (e.g. argb8888)
                w, h = t.mWidth, t.mHeight
                data = np.reshape(data, (h, w, 4))  # << skip this to keep the array
                                                    # flat for use in a graphics library

            # store 'data' variable for later use
            # or save it as a file using the extension from the hint, if present,
            # or as a format compatible with the texture components


To assign each texture to the right material, check:

.. code:: python

   scene.mMaterials[material_index].properties['TEXTURE_BASE']

The ``TEXTURE_BASE`` property will contain the index of the texture in the :py:class:`scene.mTextures` list
that corresponds to that material::

   *0 equals to scene.mTextures[0]
   *1 equals to scene.mTextures[1]

And so on.

Cilly
^^^^^

`Cilly <https://github.com/jr-garcia/AssimpCy/tree/master/examples/models/cilly>`_ is a silly cylinder
that dances and dances.

.. image:: https://raw.githubusercontent.com/jr-garcia/AssimpCy/master/examples/models/cilly/cilly.png
    :alt: Cilly - 3D rigged and textured cylinder

