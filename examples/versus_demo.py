import importlib
from timeit import Timer
from contextlib import _GeneratorContextManager
from pathlib import Path
import os

CHECKED_PATHS = [os.path.join('test', p) for p in ['models', 'models-nonbsd']]
VALID_EXTENSIONS = ['.obj', '.3ds', '.off', '.lwo', '.dxf', '.ply', '.stl', '.dae', '.blend', '.md5anim', '.irrmesh',
                    '.nff', '.md5mesh', '.lws']
LIBRARY_NAMES = ['pyassimp', "impasse", 'assimpcy']


def load_scene(scene_loader, filename, meshes, materials, textures, animations, print_info=False, **flags):
    scene = scene_loader(filename, **flags)
    if type(scene) == _GeneratorContextManager:
        scene = next(scene.gen)
    if print_info:
        print(f" File: {filename}")
        print(f" -Meshes:{len(scene.__getattribute__(meshes))}")
        print(f" -Materials:{len(scene.__getattribute__(materials))}")
        print(f" -Textures:{len(scene.__getattribute__(textures))}")
        print(f" -Animations:{len(scene.__getattribute__(animations))}")


def invoke(full_path, lib_name, print_info):
    try:
        if lib_name == "assimpcy":
            from assimpcy import aiImportFile, AssimpError, aiPostProcessSteps as pp
            try:
                load_scene(aiImportFile, full_path, "mMeshes", "mMaterials", "mTextures", "mAnimations", print_info,
                           flags=pp.aiProcess_Triangulate)
                return 'ok'
            except AssimpError:
                return 'err'
        elif lib_name == "pyassimp":
            from pyassimp import load, AssimpError, postprocess as pp
            try:
                load_scene(load, full_path, "meshes", "materials", "textures", "animations", print_info,
                                   processing=pp.aiProcess_Triangulate)

                return 'ok'
            except AssimpError:
                return 'err'
        elif lib_name == "impasse":
            from impasse import errors, load
            from impasse.constants import ProcessingStep as pp
            try:
                load_scene(load, full_path, "meshes", "materials", "textures", "animations", print_info,
                           processing=pp.Triangulate)
                return 'ok'
            except errors.AssimpError:
                return 'err'
    except Exception as error:
        if print_info:
            print(f"\n {lib_name}: {error}\n in file:'{full_path}'")
        return 'unk'


def load_models(models_path, lib_name, print_info):
    results = {'ok': 0, 'err': 0, 'unk': 0}
    paths = [Path(models_path) / b for b in CHECKED_PATHS]
    for path in paths:
        path = path.resolve()  # Get the absolute path
        for root in path.rglob('*'):  # Use rglob to traverse directories
            if root.is_dir():  # Check if the current path is a directory
                continue
            full_path = str(root)
            if "/invalid" in full_path:
                continue  # Avoid OOM
            if root.suffix in VALID_EXTENSIONS:
                ret = invoke(full_path, lib_name, print_info)
                results[ret] += 1
                if not print_info:
                    if ret == 'ok':
                        print('✔', end='', flush=True)
                    else:
                        print('✖', end='', flush=True)

    ok, err, unk = (results[k] for k in ['ok', 'err', 'unk'])
    print(f'\nSuccess: {ok}, known errors: {err}, unexpected: {unk}')
    print("_" * 50)


def main(models_path, print_info, libraries_to_test):
    if not os.path.exists(models_path):
        raise FileNotFoundError("Path to models doesn't exist.")
    timings = []
    print(f'Importing all the models at "{models_path}" with:')
    for lib in libraries_to_test:
        print(f'{lib.capitalize()}, ', end='', flush=True)
        try:
            _ = importlib.import_module(lib)
            print('found:')
            t = Timer(f"load_models('{models_path}', '{lib}', {print_info})", setup='from versus_demo import '
                                                                                    'load_models')
            secs = t.timeit(1)
            timings.append((lib, secs))
        except ImportError:
            print('not found.')

    if len(timings) > 0:
        print("\nResults:")
        for lib, secs in timings:
            print(f'\t{lib.capitalize()} \t {secs:0.4f} seconds')
    else:
        print(f'Error. None of the specified libraries were found.\n'
              f'Install two or more of {LIBRARY_NAMES} and try again.')


def _parse_args():
    import argparse

    parser = argparse.ArgumentParser(description='Load 3D models with some libraries.')
    parser.add_argument('path_to_models', type=str, help='Path to Assimp directory (required)')
    parser.add_argument('--print_info', action='store_true', help='Print additional information (optional)')
    parser.add_argument('--libraries_to_test', nargs='*', type=str, help=f'List of libraries to test (optional). '
                                                                         f'One or more of {LIBRARY_NAMES}')
    parsed_args = parser.parse_args()

    return parsed_args


if __name__ == '__main__':
    _args = _parse_args()

    # Use the arguments
    _models_path = _args.path_to_models
    _print_extra_info = bool(_args.print_info)

    if _args.libraries_to_test:
        _libraries_to_test = _args.libraries_to_test
    else:
        _libraries_to_test = LIBRARY_NAMES

    main(_args.path_to_models, _print_extra_info, _libraries_to_test)
