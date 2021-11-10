import unittest
import numpy as np
from os import path
from assimpcy import aiImportFile, aiPostProcessSteps as pp

VERTEX_COUNT = 318


class SimpleTest(unittest.TestCase):
    def setUp(self):
        flags = pp.aiProcess_JoinIdenticalVertices | pp.aiProcess_Triangulate | pp.aiProcess_CalcTangentSpace | \
                pp.aiProcess_OptimizeGraph | pp.aiProcess_OptimizeMeshes | pp.aiProcess_FixInfacingNormals | \
                pp.aiProcess_GenUVCoords | pp.aiProcess_LimitBoneWeights | pp.aiProcess_SortByPType | \
                pp.aiProcess_RemoveRedundantMaterials

        self.scene = aiImportFile(path.join(path.dirname(__file__), path.pardir, 'examples', 'models', 'cilly', 'cilly.x'),
                                  flags)

    def test_vertexCount(self):
        self.assertEqual(VERTEX_COUNT, self.scene.mMeshes[0].mNumVertices)

    def test_vertex_value(self):
        scene = self.scene
        v = int(scene.mMeshes[0].mNumVertices / 2)
        value = scene.mMeshes[0].mVertices[v]
        self.assertTrue(np.all(value == np.array([0.707107, 0.707107, 0.188462], np.float32)))


if __name__ == '__main__':
    unittest.main()
