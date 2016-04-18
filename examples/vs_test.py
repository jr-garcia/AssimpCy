from __future__ import print_function
import setpath

from timeit import Timer

from pyassimp import postprocess as pp2, release, load

from assimpcy import aiImportFile, aiPostProcessSteps as pp

# path = './models/cil/cil.x'
# path = './models/dragon.obj'
path = './models/shadow room/lightmapped.x'
# path = './models/sponza/sponza.3DS'

scene = None


def doImport():
    global path, scene
    flags = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_Triangulate | pp.aiProcess_CalcTangentSpace | \
            pp.aiProcess_OptimizeGraph | pp.aiProcess_OptimizeMeshes | \
            pp.aiProcess_FixInfacingNormals | pp.aiProcess_GenUVCoords | \
            pp.aiProcess_LimitBoneWeights | pp.aiProcess_SortByPType | pp.aiProcess_RemoveRedundantMaterials

    scene = aiImportFile(path, flags)


def doImportPy():
    global path, scene
    flags = pp2.aiProcess_JoinIdenticalVertices | pp2.aiProcess_Triangulate | pp2.aiProcess_CalcTangentSpace | \
            pp2.aiProcess_OptimizeGraph | pp2.aiProcess_OptimizeMeshes | \
            pp2.aiProcess_FixInfacingNormals | pp2.aiProcess_GenUVCoords | \
            pp2.aiProcess_LimitBoneWeights | pp2.aiProcess_SortByPType | pp2.aiProcess_RemoveRedundantMaterials

    scene = load(path, flags)


def main():
    global scene
    print('Reading \'{}\'...'.format(path))
    t = Timer(doImport)
    secs = t.timeit(1)
    # print('\tHas {} meshes, {} textures, {} materials, {} animations.'.format(scene.mNumMeshes,
    #                                                                           scene.mNumTextures,
    #                                                                           scene.mNumMaterials,
    #                                                                           scene.mNumAnimations))
    #
    # if scene.HasMeshes and scene.mMeshes[0].HasPositions:
    #     v = scene.mMeshes[0].mNumVertices / 2
        # print('\tVertex {} = {}'.format(v, scene.mMeshes[0].mVertices[v]))
        # print()
        # print(scene.mRootNode.mTransformation)

    print('\ton AssimpCy Took {:0.4f} seconds.'.format(secs))

    t = Timer(doImportPy)
    secs = t.timeit(1)
    # print('\tHas {} meshes, {} textures, {} materials, {} animations.'.format(scene.mNumMeshes,
    #                                                                           scene.mNumTextures,
    #                                                                           scene.mNumMaterials,
    #                                                                           scene.mNumAnimations))
    #
    # if len(scene.meshes) and len(scene.meshes[0].vertices):
    #     v = len(scene.meshes[0].vertices) / 2
    #     print('\tVertex {} = {}'.format(v, scene.meshes[0].vertices[v]))
        # print()
        # print(scene.rootnode.transformation)
    release(scene)

    print('\ton PyAssimp Took {:0.4f} seconds.'.format(secs))


if __name__ == '__main__':
    main()
