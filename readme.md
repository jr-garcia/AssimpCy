# AssimpCy
Faster (than PyAssimp) Python bindings for [Assimp](http://assimp.sourceforge.net/), Cython-based, BSD3 license.

It uses the same naming as the original library, so examples from the official docs can be used directly (minus C sintaxis, of course).
    
---

#### Example usage:

```python
from assimpcy import aiImportFile, aiPostProcessSteps as pp 
flags = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_Triangulate 
scene = aiImportFile('model.x', flags)
print('\tHas {} meshes, {} textures, {} materials, {} animations.'.format(scene.mNumMeshes, scene.mNumTextures, scene.mNumMaterials, scene.mNumAnimations)) 

# Check mesh.Has* before extracting corresponding mesh.m* (Vertices, Normals, etc)
if scene.HasMeshes and scene.mMeshes[0].HasPositions:
    v = scene.mMeshes[0].mNumVertices / 2
    print('Vertex {} = {}'.format(v, scene.mMeshes[0].mVertices[v]))
```

Matrices, quaternions and vectors are returned as Numpy arrays.

It has been tested with:
* Python 2.7
* Python 3.4 +

---

#### Requirements:

* Assimp >= 3.1.1
* Numpy >= 1.9.2

To compile, the Assimp headers are also needed.

---

#### Installation:

If you have installed Assimp library in the default location for you o.s., you can run:

```sh
python setup.py build_ext
python setup.py install
```

Otherwise you'll have to pass the paths to library headers as extra arguments:

```sh
python setup.py build_ext -I'path/to/assimp/headers' -L'path/to/library/'
python setup.py install
```
Cython is only necessary to rebuild the .cpp files.
Do
```sh
python setup.py build_ext --force
``` 
in such case.

---

#### Missing:

* Cameras
* Lights
* Export functionality

Those might be added in the future.

And what about the name? Well, [cyassimp](https://github.com/menpo/cyassimp) was already taken :smirk:.