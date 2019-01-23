import unittest
import numpy as np
from os import path
from assimpcy import (aiImportFile, aiImportFileFromMemoryWithProperties,
                      aiPropertyStore, aiPostProcessSteps as pp,
                      aiComponent as co, AI_CONFIG_PP_RVC_FLAGS)

VERTEX_COUNT = 318
ANIMATION_COUNT = 2
EXAMPLE_FILE_PATH = path.join(path.dirname(__file__), path.pardir, 'examples', 'models', 'cil', 'cil.x')


class SimpleTest(unittest.TestCase):
    def setUp(self):
        flags = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_Triangulate | pp.aiProcess_CalcTangentSpace | \
                pp.aiProcess_OptimizeGraph | pp.aiProcess_OptimizeMeshes | pp.aiProcess_FixInfacingNormals | \
                pp.aiProcess_GenUVCoords | pp.aiProcess_LimitBoneWeights | pp.aiProcess_SortByPType | \
                pp.aiProcess_RemoveRedundantMaterials

        self.scene = aiImportFile(EXAMPLE_FILE_PATH, flags)

    def test_vertexCount(self):
        self.assertEqual(VERTEX_COUNT, self.scene.mMeshes[0].mNumVertices)

    def test_vertex_value(self):
        scene = self.scene
        v = int(scene.mMeshes[0].mNumVertices / 2)
        value = scene.mMeshes[0].mVertices[v]
        self.assertTrue(np.all(value == np.array([0.707107, 0.707107, 0.188462], np.float32)))

    def test_animationCount(self):
        self.assertEqual(ANIMATION_COUNT, self.scene.mNumAnimations)


class ImportPropertyTest(unittest.TestCase):
    def setUp(self):
        props = aiPropertyStore()
        props.SetImportPropertyInteger(AI_CONFIG_PP_RVC_FLAGS, co.aiComponent_ANIMATIONS)
        flags = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_RemoveComponent
        with open(EXAMPLE_FILE_PATH, "rb") as f:
            data = f.read()

        self.scene = aiImportFileFromMemoryWithProperties(data, len(data),
                                                          flags, "", props)

    def test_animationCount(self):
        self.assertEqual(0, self.scene.mNumAnimations)


if __name__ == '__main__':
    unittest.main()
