cdef extern from "config.h" nogil:
    cdef enum aiComponent:
        aiComponent_NORMALS
        aiComponent_TANGENTS_AND_BITANGENTS
        aiComponent_COLORS
        aiComponent_TEXCOORDS
        aiComponent_BONEWEIGHTS
        aiComponent_ANIMATIONS
        aiComponent_TEXTURES
        aiComponent_LIGHTS
        aiComponent_CAMERAS
        aiComponent_MESHES
        aiComponent_MATERIALS
