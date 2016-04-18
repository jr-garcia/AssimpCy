import os, sys
from importlib import import_module

try:
    if not import_module('assimpcy'):
        raise ImportError('')
except ImportError:
    print('AssimpCy not installed. Setting local copy.')
    assimpcy_path = os.path.abspath('../assimpcy/')
    if assimpcy_path not in sys.path:
        sys.path.append(assimpcy_path)
