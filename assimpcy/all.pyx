# cython: c_string_type=bytes
# cython: c_string_encoding=utf8

cimport cImporter, cScene, cMesh, cTypes, cMaterial, cAnim, cPostprocess
cimport cPropertyStore, cConfig, cComponent
import numpy as np
cimport numpy as np
cimport cython

from cython.parallel cimport prange

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

cdef int AI_MAX_NUMBER_OF_TEXTURECOORDS = cMesh._AI_MAX_NUMBER_OF_TEXTURECOORDS
cdef int AI_MAX_NUMBER_OF_COLOR_SETS = cMesh._AI_MAX_NUMBER_OF_COLOR_SETS

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
    cdef int i, j = 0, k
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
    k = AI_MAX_NUMBER_OF_COLOR_SETS
    for i in range(k):
        val = mesh.HasVertexColors(i)
        if val:
            hasanycolor = val
        rMesh.HasVertexColors.append(val)

    rMesh.HasTextureCoords = []
    k = AI_MAX_NUMBER_OF_TEXTURECOORDS
    for i in range(k):
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

    for i in range(k):
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

    cdef NUMPYINT_t [:,:] facememview
    if rMesh.HasFaces:
        rMesh.mFaces = np.empty((rMesh.mNumFaces, mesh.mFaces.mNumIndices), dtype=NUMPYINT)
        facememview = rMesh.mFaces
        with nogil:
            for i in prange(<int>(mesh.mNumFaces), schedule='static'):
                for j in range(mesh.mFaces.mNumIndices):
                    facememview[i][j] = mesh.mFaces[i].mIndices[j]

    if hasanycoord:
        for j in range(k):
            if rMesh.HasTextureCoords[j]:
                # tempnd = np.empty((mesh.mNumVertices, rMesh.mNumUVComponents[j]), dtype=NUMPYFLOAT)
                tempnd = np.empty((mesh.mNumVertices, 3), dtype=NUMPYFLOAT)
                with nogil:
                    memcpy(<void*>tempnd.data, <void*>&mesh.mTextureCoords[j][0], mesh.mNumVertices *
                                                   3 * sizeof(NUMPYFLOAT_t))
                rMesh.mTextureCoords[j] = tempnd[:,:rMesh.mNumUVComponents[j]]

    if hasanycolor:
        k = AI_MAX_NUMBER_OF_COLOR_SETS
        for j in range(k):
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
    cdef unsigned int i = 0, j
    rNode.mParent = parent
    rNode.mNumMeshes = node.mNumMeshes
    rNode.mName = str(node.mName.data)
    rNode.mNumChildren = node.mNumChildren
    rNode.mTransformation = np.empty((4, 4), dtype=NUMPYFLOAT)
    with nogil:
        memcpy(<void*>rNode.mTransformation.data, <void*>&node.mTransformation, sizeof(NUMPYFLOAT_t) * 16)

    j = rNode.mNumChildren
    for i in range(j):
        rNode.mChildren.append(buildNode(node.mChildren[i], rNode))

    j = rNode.mNumMeshes
    for i in range(j):
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
            elif ptype == cMaterial.aiPTI_String:
                pvalS = new cTypes.aiString()
                res =  cMaterial.aiGetMaterialString(mat, prop.mKey.data, -1, 0, pvalS)
            else:
                continue

        if res == cTypes.aiReturn_FAILURE:
            continue
        elif res == cTypes.aiReturn_OUTOFMEMORY:
            raise MemoryError('Out of memory.')

        sname = str(prop.mKey.data.decode())
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
            propval = str(pvalS.data.decode())

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
    cdef int i = 0, j
    cdef cAnim.aiVectorKey vkey
    cdef cAnim.aiQuatKey rkey
    cdef aiNodeAnim node = aiNodeAnim()
    node.mNodeName = str(channel.mNodeName.data)
    j = channel.mNumPositionKeys
    for i in range(j):
        vkey = channel.mPositionKeys[i]
        node.mPositionKeys.append(buildKey(&vkey))

    j = channel.mNumRotationKeys
    for i in range(j):
        rkey = channel.mRotationKeys[i]
        node.mRotationKeys.append(buildKey(&rkey))

    j = channel.mNumScalingKeys
    for i in range(j):
        vkey = channel.mScalingKeys[i]
        node.mScalingKeys.append(buildKey(&vkey))

    return node

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef aiKey buildKey(anykey* key):
    cdef aiKey pykey = aiKey()
    cdef int kl
    if anykey  == cAnim.aiVectorKey:
        kl = 3
    else:
        kl = 4
    pykey.mValue = np.empty((kl), dtype=NUMPYFLOAT)
    with nogil:
        pykey.mTime = key.mTime
        memcpy(<void*>pykey.mValue.data, <void*>&key.mValue, kl * sizeof(NUMPYFLOAT_t))
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
    cdef int i = 0, j
    nAnim.mName = str(anim.mName.data)
    nAnim.mDuration = anim.mDuration
    nAnim.mTicksPerSecond = anim.mTicksPerSecond
    j = anim.mNumChannels
    for i in range(j):
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
    cdef unsigned int i, j
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

    j = scene.mNumMeshes
    for i in range(j):
        scene.mMeshes.append(buildMesh(cs.mMeshes[i]))

    j = scene.mNumMaterials
    for i in range(j):
        scene.mMaterials.append(buildMaterial(cs.mMaterials[i]))

    j = scene.mNumAnimations
    for i in range(j):
        scene.mAnimations.append(buildAnimation(cs.mAnimations[i]))

    return scene


# -----------------------------------------------------

def aiImportFile(str path, unsigned int flags=0):
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
    bpath = path.encode()
    cdef const char* cpath = bpath
    with nogil:
        csc = cImporter.aiImportFile(cpath, flags)
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
        # cpath = NULL
        # del cpath  # << Error (Deletion of non-Python, non-C++ object)
        raise AssimpError(cImporter.aiGetErrorString())


cdef class aiPropertyStore:
    cdef cPropertyStore.aiPropertyStore* _props

    def __cinit__(self):
        self._props = cPropertyStore.aiCreatePropertyStore()

    def __dealloc__(self):
        if self._props is not NULL:
            cPropertyStore.aiReleasePropertyStore(self._props)
            self._props = NULL

    def SetImportPropertyInteger(self, str name, int value):
        bname = name.encode()
        cdef const char* cname = bname
        cPropertyStore.aiSetImportPropertyInteger(self._props, cname, value)

    def SetImportPropertyFloat(self, str name, float value):
        bname = name.encode()
        cdef const char* cname = bname
        cPropertyStore.aiSetImportPropertyFloat(self._props, cname, value)


def aiImportFileFromMemoryWithProperties(buf, unsigned int length, unsigned int flags, str hint, aiPropertyStore properties):
    """
    Usage:
        scene = aiImportFileFromMemoryWithProperties(buffer, flags, hint, properties)
    There is no need to use 'aiReleaseImport' after.

    :param buf: A bytes-like object containing the model
    :type path: bytes-like object
    :param length: number of bytes to read from buf
    :type length: int
    :param flags: Any "or'ed" combination of aiPostrocessStep flags.
    :type flags: int
    :param hint: A string defining which importer to use, or empty string for autodetection
    :param properties: Import properties
    :type properties: aiPropertyStore
    :rtype: aiScene
    """
    cdef const cScene.aiScene* csc
    cdef const char* cbuf = buf
    cdef const cPropertyStore.aiPropertyStore* props = properties._props
    bhint = hint.encode()
    cdef const char* chint = bhint

    with nogil:
        csc = cImporter.aiImportFileFromMemoryWithProperties(cbuf, length, flags, chint, props)
    if csc:
        try:
            return buildScene(csc)
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
     warn(RuntimeWarning('Releasing the scene in \'AssimpCy\' is not needed.'))

class AssimpError(Exception):
    pass


cdef cppclass dataStorageF nogil:
    NUMPYFLOAT_t data[16]
    int validLenght
    dataStorageF():
        validLenght = 0

cdef cppclass dataStorageI nogil:
    NUMPYINT_t data[16]
    int validLenght
    dataStorageI():
        validLenght = 0

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef np.ndarray asNumpyArray(i_f* ds):
    cdef int i
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
            for i in prange(ds.validLenght):
                iarr_view[i] = dsiarr_view[i]
        return retI
    else:
        retF = np.empty([ds.validLenght], dtype=NUMPYFLOAT)
        dsfarr_view = ds.data
        farr_view = retF
        with nogil:
            for i in prange(ds.validLenght):
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


class aiComponent:
    aiComponent_NORMALS = cComponent.aiComponent_NORMALS
    aiComponent_TANGENTS_AND_BITANGENTS = cComponent.aiComponent_TANGENTS_AND_BITANGENTS
    aiComponent_COLORS = cComponent.aiComponent_COLORS
    aiComponent_TEXCOORDS = cComponent.aiComponent_TEXCOORDS
    aiComponent_BONEWEIGHTS = cComponent.aiComponent_BONEWEIGHTS
    aiComponent_ANIMATIONS = cComponent.aiComponent_ANIMATIONS
    aiComponent_TEXTURES = cComponent.aiComponent_TEXTURES
    aiComponent_LIGHTS = cComponent.aiComponent_LIGHTS
    aiComponent_CAMERAS = cComponent.aiComponent_CAMERAS
    aiComponent_MESHES = cComponent.aiComponent_MESHES
    aiComponent_MATERIALS = cComponent.aiComponent_MATERIALS

    @staticmethod
    def aiComponent_COLORSn(n):
        return 1 << (n + 20)

    @staticmethod
    def aiComponent_TEXCOORDSn(n):
        return 1 << (n + 25)

AI_CONFIG_GLOB_MEASURE_TIME = cConfig.AI_CONFIG_GLOB_MEASURE_TIME.decode()
AI_CONFIG_IMPORT_NO_SKELETON_MESHES = cConfig.AI_CONFIG_IMPORT_NO_SKELETON_MESHES.decode()
AI_CONFIG_PP_SBBC_MAX_BONES = cConfig.AI_CONFIG_PP_SBBC_MAX_BONES.decode()
AI_CONFIG_PP_CT_MAX_SMOOTHING_ANGLE = cConfig.AI_CONFIG_PP_CT_MAX_SMOOTHING_ANGLE.decode()
AI_CONFIG_PP_CT_TEXTURE_CHANNEL_INDEX = cConfig.AI_CONFIG_PP_CT_TEXTURE_CHANNEL_INDEX.decode()
AI_CONFIG_PP_GSN_MAX_SMOOTHING_ANGLE = cConfig.AI_CONFIG_PP_GSN_MAX_SMOOTHING_ANGLE.decode()
AI_CONFIG_IMPORT_MDL_COLORMAP = cConfig.AI_CONFIG_IMPORT_MDL_COLORMAP.decode()
AI_CONFIG_PP_RRM_EXCLUDE_LIST = cConfig.AI_CONFIG_PP_RRM_EXCLUDE_LIST.decode()
AI_CONFIG_PP_PTV_KEEP_HIERARCHY = cConfig.AI_CONFIG_PP_PTV_KEEP_HIERARCHY.decode()
AI_CONFIG_PP_PTV_NORMALIZE = cConfig.AI_CONFIG_PP_PTV_NORMALIZE.decode()
AI_CONFIG_PP_PTV_ADD_ROOT_TRANSFORMATION = cConfig.AI_CONFIG_PP_PTV_ADD_ROOT_TRANSFORMATION.decode()
AI_CONFIG_PP_PTV_ROOT_TRANSFORMATION = cConfig.AI_CONFIG_PP_PTV_ROOT_TRANSFORMATION.decode()
AI_CONFIG_PP_FD_REMOVE = cConfig.AI_CONFIG_PP_FD_REMOVE.decode()
AI_CONFIG_PP_OG_EXCLUDE_LIST = cConfig.AI_CONFIG_PP_OG_EXCLUDE_LIST.decode()
AI_CONFIG_PP_SLM_TRIANGLE_LIMIT = cConfig.AI_CONFIG_PP_SLM_TRIANGLE_LIMIT.decode()
AI_CONFIG_PP_SLM_VERTEX_LIMIT = cConfig.AI_CONFIG_PP_SLM_VERTEX_LIMIT.decode()
AI_CONFIG_PP_LBW_MAX_WEIGHTS = cConfig.AI_CONFIG_PP_LBW_MAX_WEIGHTS.decode()
AI_CONFIG_PP_DB_THRESHOLD = cConfig.AI_CONFIG_PP_DB_THRESHOLD.decode()
AI_CONFIG_PP_DB_ALL_OR_NONE = cConfig.AI_CONFIG_PP_DB_ALL_OR_NONE.decode()
AI_CONFIG_PP_ICL_PTCACHE_SIZE = cConfig.AI_CONFIG_PP_ICL_PTCACHE_SIZE.decode()
AI_CONFIG_PP_RVC_FLAGS = cConfig.AI_CONFIG_PP_RVC_FLAGS.decode()
AI_CONFIG_PP_SBP_REMOVE = cConfig.AI_CONFIG_PP_SBP_REMOVE.decode()
AI_CONFIG_PP_FID_ANIM_ACCURACY = cConfig.AI_CONFIG_PP_FID_ANIM_ACCURACY.decode()
AI_CONFIG_PP_TUV_EVALUATE = cConfig.AI_CONFIG_PP_TUV_EVALUATE.decode()
AI_CONFIG_FAVOUR_SPEED = cConfig.AI_CONFIG_FAVOUR_SPEED.decode()
AI_CONFIG_IMPORT_FBX_READ_ALL_GEOMETRY_LAYERS = cConfig.AI_CONFIG_IMPORT_FBX_READ_ALL_GEOMETRY_LAYERS.decode()
AI_CONFIG_IMPORT_FBX_READ_ALL_MATERIALS = cConfig.AI_CONFIG_IMPORT_FBX_READ_ALL_MATERIALS.decode()
AI_CONFIG_IMPORT_FBX_READ_MATERIALS = cConfig.AI_CONFIG_IMPORT_FBX_READ_MATERIALS.decode()
AI_CONFIG_IMPORT_FBX_READ_CAMERAS = cConfig.AI_CONFIG_IMPORT_FBX_READ_CAMERAS.decode()
AI_CONFIG_IMPORT_FBX_READ_LIGHTS = cConfig.AI_CONFIG_IMPORT_FBX_READ_LIGHTS.decode()
AI_CONFIG_IMPORT_FBX_READ_ANIMATIONS = cConfig.AI_CONFIG_IMPORT_FBX_READ_ANIMATIONS.decode()
AI_CONFIG_IMPORT_FBX_STRICT_MODE = cConfig.AI_CONFIG_IMPORT_FBX_STRICT_MODE.decode()
AI_CONFIG_IMPORT_FBX_PRESERVE_PIVOTS = cConfig.AI_CONFIG_IMPORT_FBX_PRESERVE_PIVOTS.decode()
AI_CONFIG_IMPORT_FBX_OPTIMIZE_EMPTY_ANIMATION_CURVES = cConfig.AI_CONFIG_IMPORT_FBX_OPTIMIZE_EMPTY_ANIMATION_CURVES.decode()
AI_CONFIG_IMPORT_GLOBAL_KEYFRAME = cConfig.AI_CONFIG_IMPORT_GLOBAL_KEYFRAME.decode()
AI_CONFIG_IMPORT_MD3_KEYFRAME = cConfig.AI_CONFIG_IMPORT_MD3_KEYFRAME.decode()
AI_CONFIG_IMPORT_MD2_KEYFRAME = cConfig.AI_CONFIG_IMPORT_MD2_KEYFRAME.decode()
AI_CONFIG_IMPORT_MDL_KEYFRAME = cConfig.AI_CONFIG_IMPORT_MDL_KEYFRAME.decode()
AI_CONFIG_IMPORT_MDC_KEYFRAME = cConfig.AI_CONFIG_IMPORT_MDC_KEYFRAME.decode()
AI_CONFIG_IMPORT_SMD_KEYFRAME = cConfig.AI_CONFIG_IMPORT_SMD_KEYFRAME.decode()
AI_CONFIG_IMPORT_UNREAL_KEYFRAME = cConfig.AI_CONFIG_IMPORT_UNREAL_KEYFRAME.decode()
AI_CONFIG_IMPORT_AC_SEPARATE_BFCULL = cConfig.AI_CONFIG_IMPORT_AC_SEPARATE_BFCULL.decode()
AI_CONFIG_IMPORT_AC_EVAL_SUBDIVISION = cConfig.AI_CONFIG_IMPORT_AC_EVAL_SUBDIVISION.decode()
AI_CONFIG_IMPORT_UNREAL_HANDLE_FLAGS = cConfig.AI_CONFIG_IMPORT_UNREAL_HANDLE_FLAGS.decode()
AI_CONFIG_IMPORT_TER_MAKE_UVS = cConfig.AI_CONFIG_IMPORT_TER_MAKE_UVS.decode()
AI_CONFIG_IMPORT_ASE_RECONSTRUCT_NORMALS = cConfig.AI_CONFIG_IMPORT_ASE_RECONSTRUCT_NORMALS.decode()
AI_CONFIG_IMPORT_MD3_HANDLE_MULTIPART = cConfig.AI_CONFIG_IMPORT_MD3_HANDLE_MULTIPART.decode()
AI_CONFIG_IMPORT_MD3_SKIN_NAME = cConfig.AI_CONFIG_IMPORT_MD3_SKIN_NAME.decode()
AI_CONFIG_IMPORT_MD3_SHADER_SRC = cConfig.AI_CONFIG_IMPORT_MD3_SHADER_SRC.decode()
AI_CONFIG_IMPORT_LWO_ONE_LAYER_ONLY = cConfig.AI_CONFIG_IMPORT_LWO_ONE_LAYER_ONLY.decode()
AI_CONFIG_IMPORT_MD5_NO_ANIM_AUTOLOAD = cConfig.AI_CONFIG_IMPORT_MD5_NO_ANIM_AUTOLOAD.decode()
AI_CONFIG_IMPORT_LWS_ANIM_START = cConfig.AI_CONFIG_IMPORT_LWS_ANIM_START.decode()
AI_CONFIG_IMPORT_LWS_ANIM_END = cConfig.AI_CONFIG_IMPORT_LWS_ANIM_END.decode()
AI_CONFIG_IMPORT_IRR_ANIM_FPS = cConfig.AI_CONFIG_IMPORT_IRR_ANIM_FPS.decode()
AI_CONFIG_IMPORT_OGRE_MATERIAL_FILE = cConfig.AI_CONFIG_IMPORT_OGRE_MATERIAL_FILE.decode()
AI_CONFIG_IMPORT_OGRE_TEXTURETYPE_FROM_FILENAME = cConfig.AI_CONFIG_IMPORT_OGRE_TEXTURETYPE_FROM_FILENAME.decode()
AI_CONFIG_ANDROID_JNI_ASSIMP_MANAGER_SUPPORT = cConfig.AI_CONFIG_ANDROID_JNI_ASSIMP_MANAGER_SUPPORT.decode()
AI_CONFIG_IMPORT_IFC_SKIP_SPACE_REPRESENTATIONS = cConfig.AI_CONFIG_IMPORT_IFC_SKIP_SPACE_REPRESENTATIONS.decode()
AI_CONFIG_IMPORT_IFC_CUSTOM_TRIANGULATION = cConfig.AI_CONFIG_IMPORT_IFC_CUSTOM_TRIANGULATION.decode()
AI_CONFIG_IMPORT_COLLADA_IGNORE_UP_DIRECTION = cConfig.AI_CONFIG_IMPORT_COLLADA_IGNORE_UP_DIRECTION.decode()
AI_CONFIG_EXPORT_XFILE_64BIT = cConfig.AI_CONFIG_EXPORT_XFILE_64BIT.decode()
