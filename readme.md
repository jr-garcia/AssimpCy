# AssimpCy 
[![Build Status](https://travis-ci.org/jr-garcia/AssimpCy.svg?branch=master)](https://travis-ci.org/jr-garcia/AssimpCy)
[![PyPI version](https://badge.fury.io/py/AssimpCy.svg)](https://badge.fury.io/py/AssimpCy)
https://readthedocs.org/projects/pip/badge/
             
Faster (than PyAssimp) Python bindings for [Assimp](http://assimp.sourceforge.net/), Cython-based, BSD3 license.

It uses the same naming as the original library, so examples from the official docs can be used directly (minus C sintaxis, of course).
    
---

#### Example usage:

```python
from assimpcy import aiImportFile, aiPostProcessSteps as pp 
flags = pp.aiProcess_JoinIdenticalVertices  
scene = aiImportFile('mymodel.3ds', flags)
print('Vertex {} = {}'.format(v, scene.mMeshes[0].mVertices[0]))
```

Matrices, quaternions and vectors are returned as Numpy arrays.

It has been tested with:
* Python 2.7
* Python 3.4 +

---

#### Requirements:

* Assimp >= 3.1.1
* Numpy >= 1.9.2

---

#### Installation:

The easiest way is:

```sh
pip install assimpcy
```

If that does not work for you, please check [Isntallation](http://assimpcy.readthedocs.io/en/latest/installation) for instructions. 

#### Missing:

* Cameras
* Lights
* Export functionality

Those might be added in the future.

And what about the name? Well, [cyassimp](https://github.com/menpo/cyassimp) was already taken :smirk:.