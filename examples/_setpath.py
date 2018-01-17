import os
import sys
from importlib import import_module


def setAssimpPath():
    try:
        if not import_module('assimpcy'):
            raise ImportError('')
    except ImportError:
        print('AssimpCy not installed. Setting local copy.')
        assimpcy_path = os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir))
        if assimpcy_path not in sys.path:
            sys.path.append(assimpcy_path)
