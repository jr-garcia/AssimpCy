from __future__ import print_function

from timeit import Timer

from pyassimp import postprocess as pp2, release, load

from assimpcy import aiImportFile, aiPostProcessSteps as pp

from os import path as pt

home = pt.dirname(__file__)

path = 'models/cil/cil.x'

path = pt.join(home, path)

scene = None
flags1 = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_Triangulate | pp.aiProcess_CalcTangentSpace | \
         pp.aiProcess_OptimizeGraph | pp.aiProcess_OptimizeMeshes | \
         pp.aiProcess_FixInfacingNormals | pp.aiProcess_GenUVCoords | \
         pp.aiProcess_LimitBoneWeights | pp.aiProcess_SortByPType | pp.aiProcess_RemoveRedundantMaterials

flags2 = pp2.aiProcess_JoinIdenticalVertices | pp2.aiProcess_Triangulate | pp2.aiProcess_CalcTangentSpace | \
         pp2.aiProcess_OptimizeGraph | pp2.aiProcess_OptimizeMeshes | \
         pp2.aiProcess_FixInfacingNormals | pp2.aiProcess_GenUVCoords | \
         pp2.aiProcess_LimitBoneWeights | pp2.aiProcess_SortByPType | pp2.aiProcess_RemoveRedundantMaterials


def doImport():
    global path, scene
    scene = aiImportFile(path, flags1)


def doImportPy():
    global path, scene
    scene = load(pt.join(home, path), processing=flags2)


def main():
    global scene
    print('Reading \'{}\'...'.format(path))
    t = Timer(doImport)
    secs = t.timeit(1)
    print('> On AssimpCy Took {:0.4f} seconds.'.format(secs))
    print('\tHas {} meshes, {} textures, {} materials, {} animations'.format(scene.mNumMeshes,
                                                                             scene.mNumTextures,
                                                                             scene.mNumMaterials,
                                                                             scene.mNumAnimations))

    if scene.HasMeshes and scene.mMeshes[0].HasPositions:
        print('\tand {} vertices on mesh 0'.format(int(scene.mMeshes[0].mNumVertices)))
        v = int(scene.mMeshes[0].mNumVertices / 2)
        print('\tVertex {} = {}'.format(v, scene.mMeshes[0].mVertices[v]))
        print()
        # print(scene.mRootNode.mTransformation)

    t = Timer(doImportPy)
    secs = t.timeit(1)
    print('> On PyAssimp Took {:0.4f} seconds.'.format(secs))
    print('\tHas {} meshes, {} textures, {} materials, {} animations'.format(scene.mNumMeshes,
                                                                             scene.mNumTextures,
                                                                             scene.mNumMaterials,
                                                                             scene.mNumAnimations))

    if len(scene.meshes) and len(scene.meshes[0].vertices):
        print('\tand {} vertices on mesh 0'.format(len(scene.meshes[0].vertices)))
        v = int(len(scene.meshes[0].vertices) / 2)
        print('\tVertex {} = {}'.format(v, scene.meshes[0].vertices[v]))
        # print(scene.rootnode.transformation)
    release(scene)


if __name__ == '__main__':
    main()
