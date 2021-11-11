# AssimpCy 
[![PyPI - version](https://badge.fury.io/py/AssimpCy.svg)](https://pypi.org/project/AssimpCy/)
![PyPI - Python Version](https://img.shields.io/pypi/pyversions/AssimpCy.svg)
![PyPI - Satus](https://img.shields.io/pypi/status/AssimpCy.svg)
![PyPI - License](https://img.shields.io/pypi/l/AssimpCy.svg)
![PyPI - Downloads](https://img.shields.io/pypi/dm/assimpcy)

#### BUILD STATUS 

[![Linux Build Status](https://github.com/jr-garcia/assimpcy/actions/workflows/main.yaml/badge.svg)](https://github.com/jr-garcia/assimpcy/) 

[![Documentation Build Status](https://readthedocs.org/projects/assimpcy/badge/?version=latest)](http://assimpcy.readthedocs.io/en/latest/?badge=latest)

---    
        
Fast Python bindings for [Assimp](http://assimp.org/), Cython-based, BSD3 license.

It uses the same function names as the original library, so examples from c++ tutorials can be used with minor changes.

It has been tested on:

* Windows 7, 10
* Linux
* Mac
* Python 3.7 - 3.10
* Pypy
---
#### Example usage:

```python
from assimpcy import aiImportFile, aiPostProcessSteps as pp 
flags = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_Triangulate 
scene = aiImportFile('somemodel.3ds', flags)
print('Vertex 0 = {}'.format(scene.mMeshes[0].mVertices[0]))
```

Matrices, quaternions and vectors are returned as Numpy arrays.

---
#### Requirements:

* Numpy >= 1.21.3

(Assimp 5.0.1 is included in the binary wheel)

```
Open Asset Import Library (assimp)

Copyright (c) 2006-2016, assimp team
All rights reserved.
```
Please visit our [docs](https://assimpcy.readthedocs.io/en/latest/about.html#the-open-asset-import-library) to read the full license and 
to know more about your rights regarding Assimp.

---
#### Installation:

The easiest way is with Pip:

```sh
pip install assimpcy
```

If that doesn't work on your system or if you want to compile by yourself, 
please check [Installation](http://assimpcy.readthedocs.io/en/latest/install.html) for instructions. 

---
#### Missing:

* Cameras
* Lights
* Export functionality

Those might be added in the future.

---
#### Documentation

[Read The Docs](http://assimpcy.readthedocs.io/)

---
#### Bugs report and Contributioms

Please follow the guide on the [wiki](https://github.com/jr-garcia/AssimpCy/wiki/Contributons-and-Bug-reports)

---

And what about the name? Well, [cyassimp](https://github.com/menpo/cyassimp) was already taken 😞