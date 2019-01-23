cdef extern from "cimport.h" nogil:
    cdef struct aiPropertyStore:
        pass

    cdef aiPropertyStore* aiCreatePropertyStore() except +
    cdef void aiReleasePropertyStore(aiPropertyStore* p)
    cdef void aiSetImportPropertyInteger(aiPropertyStore* store,
                                         const char* szName, int value)
    cdef void aiSetImportPropertyFloat(aiPropertyStore *store,
                                       const char* szName, float value)
