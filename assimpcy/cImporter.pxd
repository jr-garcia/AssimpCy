from cScene cimport aiScene
from cPropertyStore cimport aiPropertyStore

cdef extern from "cimport.h" nogil:
    const aiScene *aiImportFile(const char *pFile, unsigned int pFlags) except +
    const aiScene *aiImportFileFromMemoryWithProperties(const char* pBuffer,
                                                        unsigned int pLength,
                                                        unsigned int pFlags,
                                                        const char* pHint,
                                                        const aiPropertyStore* pProps) except +
    void aiReleaseImport(const aiScene* pScene)
    const char* aiGetErrorString()

