__author__ = 'jrg'

cimport cImporter, cScene, cMesh, cTypes, cMaterial, cAnim, cPostprocess
import numpy as np
cimport numpy as np
cimport cython

from libc.string cimport memcpy
from warnings import warn

ctypedef bint bool

NUMPYINT = np.uint32
ctypedef np.uint32_t NUMPYINT_t

NUMPYFLOAT = np.float32
ctypedef np.float32_t NUMPYFLOAT_t

ctypedef fused anykey:
    cAnim.aiVectorKey
    cAnim.aiQuatKey

ctypedef fused i_f:
    dataStorageI
    dataStorageF

AI_MAX_NUMBER_OF_TEXTURECOORDS = cMesh._AI_MAX_NUMBER_OF_TEXTURECOORDS
AI_MAX_NUMBER_OF_COLOR_SETS = cMesh._AI_MAX_NUMBER_OF_COLOR_SETS

propertyNames = {
'?mat.name': 'NAME',
'$mat.twosided': 'TWOSIDED',
'$mat.shadingm': 'SHADING_MODEL',
'$mat.wireframe': 'ENABLE_WIREFRAME',
'$mat.blend': 'BLEND_FUNC',
'$mat.opacity': 'OPACITY',
'$mat.bumpscaling': 'BUMPSCALING',
'$mat.shininess': 'SHININESS',
'$mat.reflectivity': 'REFLECTIVITY',
'$mat.shinpercent': 'SHININESS_STRENGTH',
'$mat.refracti': 'REFRACTI',
'$clr.diffuse': 'COLOR_DIFFUSE',
'$clr.ambient': 'COLOR_AMBIENT',
'$clr.specular': 'COLOR_SPECULAR',
'$clr.emissive': 'COLOR_EMISSIVE',
'$clr.transparent': 'COLOR_TRANSPARENT',
'$clr.reflective': 'COLOR_REFLECTIVE',
'?bg.global': 'GLOBAL_BACKGROUND_IMAGE',
'$tex.file': 'TEXTURE_BASE',
'$tex.mapping': 'MAPPING_BASE',
'$tex.flags': 'TEXFLAGS_BASE',
'$tex.uvwsrc': 'UVWSRC_BASE',
'$tex.mapmodev': 'MAPPINGMODE_V_BASE',
'$tex.mapaxis': 'TEXMAP_AXIS_BASE',
'$tex.blend': 'TEXBLEND_BASE',
'$tex.uvtrafo': 'UVTRANSFORM_BASE',
'$tex.op': 'TEXOP_BASE',
'$tex.mapmodeu': 'MAPPINGMODE_U_BASE'}

cdef class aiVertexWeight:
    cdef readonly unsigned int mVertexId
    cdef readonly float mWeight

    def __init__(self):
        pass


cdef class aiBone:
    cdef readonly str mName
    cdef readonly list mWeights
    cdef readonly np.ndarray mOffsetMatrix

    def __init__(self):
        self.mWeights = []

    def __str__(self):
        return self.mName


cdef class aiMesh:
    cdef readonly unsigned int mPrimitiveTypes
    cdef readonly unsigned int mNumVertices
    cdef readonly unsigned int mNumFaces
    cdef readonly np.ndarray mVertices
    cdef readonly np.ndarray mNormals
    cdef readonly np.ndarray mTangents
    cdef readonly np.ndarray mBitangents
    cdef readonly list mColors
    cdef readonly list mTextureCoords
    cdef readonly list mNumUVComponents
    cdef readonly np.ndarray mFaces
    cdef readonly unsigned int mNumBones
    cdef readonly list mBones
    cdef readonly unsigned int mMaterialIndex
    cdef readonly str mName
        #unsigned int mNumAnimMeshes
        #aiAnimMesh** mAnimMeshes
    cdef readonly bool HasPositions
    cdef readonly bool HasFaces
    cdef readonly bool HasNormals
    cdef readonly bool HasTangentsAndBitangents
    cdef readonly list HasVertexColors
    cdef readonly list HasTextureCoords
    cdef readonly unsigned int NumUVChannels
    cdef readonly unsigned int NumColorChannels
    cdef readonly bool HasBones

    def __init__(self):
        self.mNumUVComponents = [0] * AI_MAX_NUMBER_OF_TEXTURECOORDS
        self.mTextureCoords = [None] * AI_MAX_NUMBER_OF_TEXTURECOORDS
        self.mColors = [None] * AI_MAX_NUMBER_OF_COLOR_SETS
        self.mName = ''
        self.mMaterialIndex = -1
        self.mBones = []

    def __str__(self):
        return self.mName

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef aiMesh buildMesh(cMesh.aiMesh* mesh):
    cdef bint val, hasanycoord, hasanycolor = 0
    cdef unsigned int i, j = 0
    cdef aiBone bone
    cdef aiVertexWeight vertW
    cdef aiMesh rMesh = aiMesh()
    cdef np.ndarray tempnd
    rMesh.mName = str(mesh.mName.data)
    rMesh.mNumBones = mesh.mNumBones
    rMesh.mMaterialIndex = mesh.mMaterialIndex
    rMesh.mPrimitiveTypes = mesh.mPrimitiveTypes
    rMesh.mNumVertices = mesh.mNumVertices
    rMesh.HasPositions = mesh.HasPositions()
    rMesh.HasFaces = mesh.HasFaces()
    rMesh.HasNormals = mesh.HasNormals()
    rMesh.HasTangentsAndBitangents = mesh.HasTangentsAndBitangents()

    rMesh.HasVertexColors = []
    for i in range(AI_MAX_NUMBER_OF_COLOR_SETS):
        val = mesh.HasVertexColors(i)
        if val:
            hasanycolor = val
        rMesh.HasVertexColors.append(val)

    rMesh.HasTextureCoords = []
    for i in range(AI_MAX_NUMBER_OF_TEXTURECOORDS):
        val = mesh.HasTextureCoords(i)
        if val:
            hasanycoord = val
        rMesh.HasTextureCoords.append(val)

    rMesh.NumUVChannels = mesh.GetNumUVChannels()
    rMesh.NumColorChannels = mesh.GetNumColorChannels()
    rMesh.HasBones = mesh.HasBones()
    rMesh.mNumFaces = mesh.mNumFaces

    if rMesh.HasBones:
        for i in range(rMesh.mNumBones):
            bone = aiBone()
            bone.mName = str(mesh.mBones[i].mName.data)
            bone.mOffsetMatrix = np.empty((4, 4), dtype=NUMPYFLOAT)
            with nogil:
                memcpy(<void*>bone.mOffsetMatrix.data, <void*>&mesh.mBones[i].mOffsetMatrix, sizeof(NUMPYFLOAT_t) * 16)
            for j in range(mesh.mBones[i].mNumWeights):
                vertW = aiVertexWeight()
                vertW.mVertexId = mesh.mBones[i].mWeights[j].mVertexId
                vertW.mWeight = mesh.mBones[i].mWeights[j].mWeight
                bone.mWeights.append(vertW)
            rMesh.mBones.append(bone)

    for i in range(AI_MAX_NUMBER_OF_TEXTURECOORDS):
        rMesh.mNumUVComponents[i] = mesh.mNumUVComponents[i]

    if rMesh.HasPositions:
        rMesh.mVertices = np.empty((mesh.mNumVertices, 3), dtype=NUMPYFLOAT)
        with nogil:
            memcpy(<void*>rMesh.mVertices.data, <void*>&mesh.mVertices[0], mesh.mNumVertices * 3 * sizeof(NUMPYFLOAT_t))

    if rMesh.HasNormals:
        rMesh.mNormals = np.empty((mesh.mNumVertices, 3), dtype=NUMPYFLOAT)
        with nogil:
            memcpy(<void*>rMesh.mNormals.data, <void*>&mesh.mNormals[0],  mesh.mNumVertices * 3 * sizeof(NUMPYFLOAT_t))

    if rMesh.HasTangentsAndBitangents:
        rMesh.mTangents = np.empty((mesh.mNumVertices, 3), dtype=NUMPYFLOAT)
        rMesh.mBitangents = np.empty((mesh.mNumVertices, 3), dtype=NUMPYFLOAT)
        with nogil:
            memcpy(<void*>rMesh.mTangents.data, <void*>&mesh.mTangents[0], mesh.mNumVertices * 3 * sizeof(NUMPYFLOAT_t))
            memcpy(<void*>rMesh.mBitangents.data, <void*>&mesh.mBitangents[0], sizeof(NUMPYFLOAT_t) * mesh.mNumVertices * 3)

    if rMesh.HasFaces:
        rMesh.mFaces = np.empty((rMesh.mNumFaces, mesh.mFaces.mNumIndices), dtype=NUMPYINT)
        for i in range(mesh.mNumFaces):
            for j in range(mesh.mFaces.mNumIndices):
                rMesh.mFaces[i][j] = mesh.mFaces[i].mIndices[j]

    if hasanycoord:
        for j in range(AI_MAX_NUMBER_OF_TEXTURECOORDS):
            if rMesh.HasTextureCoords[j]:
                # tempnd = np.empty((mesh.mNumVertices, rMesh.mNumUVComponents[j]), dtype=NUMPYFLOAT)
                tempnd = np.empty((mesh.mNumVertices, 3), dtype=NUMPYFLOAT)
                with nogil:
                    memcpy(<void*>tempnd.data, <void*>&mesh.mTextureCoords[j][0], mesh.mNumVertices *
                                                   3 * sizeof(NUMPYFLOAT_t))
                rMesh.mTextureCoords[j] = tempnd[:,:rMesh.mNumUVComponents[j]]

    if hasanycolor:
        for j in range(AI_MAX_NUMBER_OF_COLOR_SETS):
            if rMesh.HasVertexColors[j]:
                tempnd = np.empty((mesh.mNumVertices, 4), dtype=NUMPYFLOAT)
                with nogil:
                    memcpy(<void*>tempnd.data, <void*>&mesh.mColors[j][0], mesh.mNumVertices * 4 * sizeof(NUMPYFLOAT_t))
                rMesh.mColors[j] = tempnd

    return rMesh


# -----------------------------------------------------


cdef class aiNode:
    cdef readonly list mChildren
    cdef readonly str mName
    cdef readonly int mNumChildren
    cdef readonly aiNode mParent
    cdef readonly int mNumMeshes
    cdef readonly list mMeshes
    cdef readonly np.ndarray mTransformation


    def __init__(self):
        self.mChildren = []
        self.mMeshes = []
        self.mName = ''

    def __str__(self):
        return self.mName

cdef aiNode buildNode(cScene.aiNode* node, aiNode parent):
    cdef aiNode rNode = aiNode()
    cdef unsigned int i = 0
    rNode.mParent = parent
    rNode.mNumMeshes = node.mNumMeshes
    rNode.mName = str(node.mName.data)
    rNode.mNumChildren = node.mNumChildren
    rNode.mTransformation = np.empty((4, 4), dtype=NUMPYFLOAT)
    with nogil:
        memcpy(<void*>rNode.mTransformation.data, <void*>&node.mTransformation, sizeof(NUMPYFLOAT_t) * 16)

    for i in range(rNode.mNumChildren):
        rNode.mChildren.append(buildNode(node.mChildren[i], rNode))

    for i in range(rNode.mNumMeshes):
        rNode.mMeshes.append(node.mMeshes[i])
    return rNode


# -----------------------------------------------------

cdef class aiMaterial:
    cdef readonly dict properties

    def __init__(self):
        self.properties = {}

    def __repr__(self):
        return self.properties.get('NAME', '')

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef aiMaterial buildMaterial(cMaterial.aiMaterial* mat):
    cdef cMaterial.aiMaterialProperty* prop
    cdef dataStorageF pvalF
    cdef dataStorageI pvalI
    cdef cTypes.aiString* pvalS
    cdef unsigned int pvalsize, i, j = 0
    cdef int res = 0
    cdef object propval = None
    cdef aiMaterial nMat = aiMaterial()
    cdef str sname
    cdef int ptype

    for i in range(mat.mNumProperties):
        with nogil:
            prop = mat.mProperties[i]
            ptype = prop.mType
            if ptype == cMaterial.aiPTI_Float:
                pvalsize = sizeof(dataStorageF)
                res =  cMaterial.aiGetMaterialFloatArray(mat, prop.mKey.data, -1, 0, <float*>&pvalF, &pvalsize)
            elif ptype == cMaterial.aiPTI_Integer:
                pvalsize = sizeof(dataStorageI)
                res =  cMaterial.aiGetMaterialIntegerArray(mat, prop.mKey.data, -1, 0, <int*>&pvalI, &pvalsize)
            elif cMaterial.aiPTI_String:
                pvalS = new cTypes.aiString()
                res =  cMaterial.aiGetMaterialString(mat, prop.mKey.data, -1, 0, pvalS)
            else:
                continue

        if res == cTypes.aiReturn_FAILURE:
            continue
        elif res == cTypes.aiReturn_OUTOFMEMORY:
            raise MemoryError('Out of memory.')

        sname = str(prop.mKey.data)
        if ptype == cMaterial.aiPTI_Float:
            if pvalsize == 1:
                propval = pvalF.data[0]
            else:
                pvalF.validLenght = pvalsize
                propval = asNumpyArray(&pvalF)
        elif ptype == cMaterial.aiPTI_Integer:
            if pvalsize == 1:
                propval = pvalI.data[0]
            else:
                pvalI.validLenght = pvalsize
                propval = asNumpyArray(&pvalI)
        elif ptype == cMaterial.aiPTI_String:
            propval = str(pvalS.data)

        nMat.properties[propertyNames.get(sname, sname)] = propval

    prop = NULL
    del (prop)
    pvalS = NULL
    del (pvalS)

    return nMat

# -----------------------------------------------------
cdef class aiKey:
    cdef readonly double mTime
    cdef readonly np.ndarray mValue
    def __init__(self):
        pass

    def __str__(self):
        return '{:0>5}->{}'.format(self.mTime, self.mValue)

cdef class aiNodeAnim:
    cdef readonly str mNodeName
    cdef readonly list mPositionKeys
    cdef readonly list mRotationKeys
    cdef readonly list mScalingKeys
    # cdef readonly aiAnimBehaviour mPreState
    # cdef readonly aiAnimBehaviour mPostState

    def __init__(self):
        self.mNodeName = ''
        self.mPositionKeys = []
        self.mRotationKeys = []
        self.mScalingKeys = []

    def __str__(self):
        return self.mNodeName

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef aiNodeAnim buildAnimNode(cAnim.aiNodeAnim* channel):
    cdef int i = 0
    cdef cAnim.aiVectorKey vkey
    cdef cAnim.aiQuatKey qkey
    cdef aiNodeAnim node = aiNodeAnim()
    node.mNodeName = str(channel.mNodeName.data)
    for i in range(channel.mNumPositionKeys):
        vkey = channel.mPositionKeys[i]
        node.mPositionKeys.append(buildKey(&vkey))

    for i in range(channel.mNumRotationKeys):
        rkey = channel.mRotationKeys[i]
        node.mRotationKeys.append(buildKey(&rkey))

    for i in range(channel.mNumScalingKeys):
        vkey = channel.mScalingKeys[i]
        node.mScalingKeys.append(buildKey(&vkey))

    return node

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef aiKey buildKey(anykey* key):
    cdef aiKey pykey = aiKey()
    pykey.mTime = key.mTime
    if anykey == cAnim.aiVectorKey:
        pykey.mValue = np.empty((3), dtype=NUMPYFLOAT)
        with nogil:
            memcpy(<void*>pykey.mValue.data, <void*>&key.mValue, 3 * sizeof(NUMPYFLOAT_t))
    else:
        pykey.mValue = np.empty((4), dtype=NUMPYFLOAT)
        with nogil:
            memcpy(<void*>pykey.mValue.data, <void*>&key.mValue, 4 * sizeof(NUMPYFLOAT_t))
    return pykey

cdef class aiAnimation:
    cdef readonly str mName
    cdef readonly double mDuration
    cdef readonly double mTicksPerSecond
    cdef readonly list mChannels

    def __init__(self):
        self.mName = ''
        self.mChannels = []

    def __str__(self):
        return self.mName

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef aiAnimation buildAnimation(cAnim.aiAnimation* anim):
    cdef aiAnimation nAnim = aiAnimation()
    cdef int i = 0
    nAnim.mName = str(anim.mName.data)
    nAnim.mDuration = anim.mDuration
    nAnim.mTicksPerSecond = anim.mTicksPerSecond
    for i in range(anim.mNumChannels):
        nAnim.mChannels.append(buildAnimNode(anim.mChannels[i]))
    return nAnim

# -----------------------------------------------------

cdef class aiScene:
    # self.mFlags
    cdef readonly aiNode mRootNode
    cdef readonly int mNumMeshes
    cdef readonly list mMeshes
    cdef readonly int mNumMaterials
    cdef readonly list mMaterials
    cdef readonly int mNumAnimations
    cdef readonly list mAnimations
    cdef readonly int mNumTextures
    # cdef readonly list mTextures
    cdef readonly int mNumLights
    # cdef readonly list mLights
    cdef readonly int mNumCameras
    # cdef readonly list mCameras

    cdef readonly bool HasMeshes
    cdef readonly bool HasMaterials
    cdef readonly bool HasLights
    cdef readonly bool HasTextures
    cdef readonly bool HasCameras
    cdef readonly bool HasAnimations

    def __init__(self):
        self.mMeshes = []
        self.mMaterials = []
        self.mAnimations = []

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef aiScene buildScene(const cScene.aiScene *cs):
    cdef aiScene scene = aiScene()
    cdef unsigned int i
    # scene.mFlags
    scene.mRootNode  = buildNode(cs.mRootNode, None)
    scene.mNumMeshes = cs.mNumMeshes
    scene.mNumMaterials = cs.mNumMaterials
    scene.mNumAnimations = cs.mNumAnimations
    scene.mNumTextures = cs.mNumTextures
    #scene.mTextures
    scene.mNumLights = cs.mNumLights
    #scene.mLights
    scene.mNumCameras = cs.mNumCameras
    #scene.mCameras

    scene.HasMeshes = scene.mNumMeshes
    scene.HasMaterials = scene.mNumMaterials
    scene.HasLights = scene.mNumLights
    scene.HasTextures = scene.mNumTextures
    scene.HasCameras = scene.mNumCameras
    scene.HasAnimations = scene.mNumAnimations

    for i in range(scene.mNumMeshes):
        scene.mMeshes.append(buildMesh(cs.mMeshes[i]))

    for i in range(scene.mNumMaterials):
        scene.mMaterials.append(buildMaterial(cs.mMaterials[i]))

    for i in range(scene.mNumAnimations):
        scene.mAnimations.append(buildAnimation(cs.mAnimations[i]))

    return scene


# -----------------------------------------------------

def aiImportFile(const char* path, unsigned int flags=0):
    """
    Usage:
        scene = aiImportFile(path, flags)
    There is no need to use 'aiReleaseImport' after.


    :param path: The path to the 3d model file.
    :type path: str
    :param flags: (Optional) Any "or'ed" combination of aiPostrocessStep flags.
    :type flags: int
    :rtype: aiScene
    """
    cdef const cScene.aiScene* csc
    with nogil:
        csc = cImporter.aiImportFile(path, flags)
    if csc:
        try:
            return buildScene(csc)
        # except:
        #     raise
        finally:
            with nogil:
                cImporter.aiReleaseImport(csc)
                csc = NULL
                del csc
    else:
        csc = NULL
        del csc
        raise AssimpError(cImporter.aiGetErrorString())


def aiReleaseImport(aiScene pScene):
     warn(RuntimeWarning('Releasing the scene in \'AssimpCy\' is not needed since it is handled by '
                             '\'aiImportFile\'.'))

class AssimpError(BaseException):
    pass


cdef cppclass dataStorageF nogil:
    NUMPYFLOAT_t data[16]
    unsigned int validLenght
    dataStorageF():
        validLenght = 0

cdef cppclass dataStorageI nogil:
    NUMPYINT_t data[16]
    unsigned int validLenght
    dataStorageI():
        validLenght = 0

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef np.ndarray asNumpyArray(i_f* ds):
    cdef unsigned int i
    cdef np.ndarray[NUMPYFLOAT_t, ndim=1] retF
    cdef np.ndarray[NUMPYINT_t, ndim=1] retI

    cdef NUMPYFLOAT_t[:] farr_view
    cdef NUMPYFLOAT_t[:] dsfarr_view
    cdef NUMPYINT_t[:] iarr_view
    cdef NUMPYINT_t[:] dsiarr_view

    if i_f is dataStorageI:
        retI = np.empty([ds.validLenght], dtype=NUMPYINT)
        dsiarr_view = ds.data
        iarr_view =  retI
        with nogil:
            for i in range(ds.validLenght):
                iarr_view[i] = dsiarr_view[i]
        return retI
    else:
        retF = np.empty([ds.validLenght], dtype=NUMPYFLOAT)
        dsfarr_view = ds.data
        farr_view = retF
        with nogil:
            for i in range(ds.validLenght):
                farr_view[i] = dsfarr_view[i]
        return retF


class aiPostProcessSteps:
    aiProcess_CalcTangentSpace = cPostprocess.aiProcess_CalcTangentSpace
    aiProcess_JoinIdenticalVertices = cPostprocess.aiProcess_JoinIdenticalVertices
    aiProcess_MakeLeftHanded = cPostprocess.aiProcess_MakeLeftHanded
    aiProcess_Triangulate = cPostprocess.aiProcess_Triangulate
    aiProcess_RemoveComponent = cPostprocess.aiProcess_RemoveComponent
    aiProcess_GenNormals = cPostprocess.aiProcess_GenNormals
    aiProcess_GenSmoothNormals = cPostprocess.aiProcess_GenSmoothNormals
    aiProcess_SplitLargeMeshes = cPostprocess.aiProcess_SplitLargeMeshes
    aiProcess_PreTransformVertices = cPostprocess.aiProcess_PreTransformVertices
    aiProcess_LimitBoneWeights = cPostprocess.aiProcess_LimitBoneWeights
    aiProcess_ValidateDataStructure = cPostprocess.aiProcess_ValidateDataStructure
    aiProcess_ImproveCacheLocality = cPostprocess.aiProcess_ImproveCacheLocality
    aiProcess_RemoveRedundantMaterials = cPostprocess.aiProcess_RemoveRedundantMaterials
    aiProcess_FixInfacingNormals = cPostprocess.aiProcess_FixInfacingNormals
    aiProcess_SortByPType = cPostprocess.aiProcess_SortByPType
    aiProcess_FindDegenerates = cPostprocess.aiProcess_FindDegenerates
    aiProcess_FindInvalidData = cPostprocess.aiProcess_FindInvalidData
    aiProcess_GenUVCoords = cPostprocess.aiProcess_GenUVCoords
    aiProcess_TransformUVCoords = cPostprocess.aiProcess_TransformUVCoords
    aiProcess_FindInstances = cPostprocess.aiProcess_FindInstances
    aiProcess_OptimizeMeshes = cPostprocess.aiProcess_OptimizeMeshes
    aiProcess_OptimizeGraph = cPostprocess.aiProcess_OptimizeGraph
    aiProcess_FlipUVs = cPostprocess.aiProcess_FlipUVs
    aiProcess_FlipWindingOrder = cPostprocess.aiProcess_FlipWindingOrder
    aiProcess_SplitByBoneCount = cPostprocess.aiProcess_SplitByBoneCount
    aiProcess_Debone = cPostprocess.aiProcess_Debone
