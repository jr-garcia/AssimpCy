from __future__ import print_function
import dropbox
from dropbox.exceptions import ApiError
import dropbox.files
from dropbox.files import SearchError
import os
from sys import argv, stdout


def getVersion():
    dir = os.path.dirname(__file__)
    init_path = os.path.join(dir, os.path.pardir, 'assimpcy', '__init__.py')
    with open(init_path) as verFile:
        lines = verFile.readlines()
        for l in lines:
            if l.startswith('__version__'):
                return l.split('=')[1].strip(' \'\n\r\t-')


BASEPATH = '/assimpcy/v' + str(getVersion())
drop = None


# def createFolder(drop, root, searchFolder):
#     try:
#         res = drop.files_search(root, searchFolder)
#         if len(res.matches) < 1:
#             err = ApiError('path not found', None, '', '')
#             err.error = '\'{}\' folder missing'.format(searchFolder)
#             raise err
#     except ApiError as err:
#         if isinstance(err.error, SearchError) or 'folder missing' in str(err.error):
#             drop.files_create_folder(root + '/' + searchFolder)
#         else:
#             raise
        

def _uploadFile(filePath, destination):
    fileName = os.path.basename(filePath)
    rootPath = '/'.join((BASEPATH, destination, fileName))
    print('Uploading file \'{}\' | {} KB...'.format(fileName, round((os.stat(filePath).st_size / 1024.0)), 2), end='')
    stdout.flush()
    with open(filePath, 'rb') as f:
        drop.files_upload(f.read(), rootPath, dropbox.files.WriteMode('overwrite'))
    print(' Done.')


def uploadAll(path):
    global drop
    token = os.environ.get('DROPBOX_TOKEN', None)

    if token is None:
        raise RuntimeError('dropbox token not set!')

    if drop is None:
        drop = dropbox.Dropbox(str(token))

    dest = argv[2]

    if os.path.isdir(path):
        for file in os.listdir(path):
            filePath = os.path.join(path, file)
            if os.path.isdir(filePath):
                uploadAll(filePath)
            elif os.path.isfile(filePath):
                _uploadFile(filePath, dest)
    elif os.path.isfile(path):
        _uploadFile(path, dest)
    else:
        raise RuntimeError('path {} is not valid'.format(path))


if __name__ == '__main__':
    path = os.path.abspath(argv[1])
    if not os.path.exists(path):
        from warnings import warn
        warn("File Not Found: {}".format(path))
        exit(0)
    uploadAll(path)
