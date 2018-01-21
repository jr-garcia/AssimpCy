It uses the same naming as the original library, so examples from the official docs can be used directly (minus C
sintaxis, of course).

_Example usage:_

    from assimpcy import aiImportFile, aiPostProcessSteps as pp
    flags = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_Triangulate
    scene = aiImportFile('model.x', flags)
    print('\tHas {} meshes, {} textures, {} materials, {} animations.'.format(scene.mNumMeshes, scene.mNumTextures,
    scene.mNumMaterials, scene.mNumAnimations))
    
    # Check mesh.Has* before extracting corresponding mesh.m* (Vertices, Normals, etc)
    if scene.HasMeshes and scene.mMeshes[0].HasPositions:
        v = scene.mMeshes[0].mNumVertices / 2
        print('Vertex {} = {}'.format(v, scene.mMeshes[0].mVertices[v]))

Matrices, quaternions and vectors are returned as Numpy arrays.