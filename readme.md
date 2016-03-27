# AssimpCy
Faster and almost complete Python bindings for [Assimp](http://assimp.sourceforge.net/), Cython-based, BSD license.

It uses the same naming as the original library, so examples from the official docs can be used directly (minus C sintaxis, of course).
    
---

#### Example usage:

```python
from assimpcy import aiImportFile, aiPostProcessSteps as pp 
flags = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_Triangulate 
scene = aiImportFile('model.x', flags)
print('\tHas {} meshes, {} textures, {} materials, {} animations.'.format(scene.mNumMeshes,                                                                                 scene.mNumTextures,                                                                                  scene.mNumMaterials,                                                                                  scene.mNumAnimations)) 

# Check mesh.Has* before extracting corresponding mesh.m* (Vertices, Normals, etc)
if scene.HasMeshes and scene.mMeshes[0].HasPositions:
    v = scene.mMeshes[0].mNumVertices / 2
    print('Vertex {} = {}'.format(v, scene.mMeshes[0].mVertices[v]))
```

Matrices, quaternions and vectors are returned as numpy arrays, as usual.

It has been tested with **Python 2.7** and **Python 3.4**.

---

#### Requirements:

To compile:

* Assimp >= 3.1.1 headers and compiled shared (dynamic) library
* Cython >= 0.23
* Numpy >= 1.9.2


To run:

* Assimp >= 3.1.1 compiled shared (dynamic) library
* Numpy >= 1.9.2

---

#### Installation:

If you have installed Assimp library in the default location for you o.s., you can run:

```sh
python setup.py build
python setup.py install
```	

Otherwise you'll have to pass the paths to library headers and compiled files as extra arguments:

```sh
python setup.py build_ext -I 'path/to/assimp/headers' -L 'path/to/library/libassimp.a_or_.so'
python setup.py install
```
---

#### Missing:

* Cameras
* Lights
* Export functionality

Those might be added in the future.

#### Warning:

No checks for memory leaks have been made.

---

And what about the name? Well, [cyassimp](https://github.com/menpo/cyassimp) was already taken :smirk:.