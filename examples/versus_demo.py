from timeit import Timer
from os import path as pt

from assimpcy import aiImportFile, aiPostProcessSteps as pp
from pyassimp import postprocess as pp2, release, load

home = pt.dirname(__file__)
model_path = pt.join(home, 'models', 'cilly', 'cilly.x')

scene = None


def doImport():
    global scene
    flags1 = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_Triangulate | pp.aiProcess_CalcTangentSpace | \
             pp.aiProcess_OptimizeGraph | pp.aiProcess_OptimizeMeshes | \
             pp.aiProcess_FixInfacingNormals | pp.aiProcess_GenUVCoords | \
             pp.aiProcess_LimitBoneWeights | pp.aiProcess_SortByPType | pp.aiProcess_RemoveRedundantMaterials
    scene = aiImportFile(model_path, flags1)


def doImportPy():
    global scene
    flags2 = pp2.aiProcess_JoinIdenticalVertices | pp2.aiProcess_Triangulate | pp2.aiProcess_CalcTangentSpace | \
         pp2.aiProcess_OptimizeGraph | pp2.aiProcess_OptimizeMeshes | \
         pp2.aiProcess_FixInfacingNormals | pp2.aiProcess_GenUVCoords | \
         pp2.aiProcess_LimitBoneWeights | pp2.aiProcess_SortByPType | pp2.aiProcess_RemoveRedundantMaterials
    scene = load(pt.join(home, model_path), processing=flags2)


def main():
    print('Reading \'{}\'...'.format(model_path))
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
