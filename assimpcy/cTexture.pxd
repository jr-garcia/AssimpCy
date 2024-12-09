from .cTypes cimport *

cdef extern from "texture.h" nogil:
    cdef cppclass aiTexture:
        unsigned int mWidth
        unsigned int mHeight
        char achFormatHint[9]
        unsigned char* pcData
        aiString mFilename
    
        aiTexture()
