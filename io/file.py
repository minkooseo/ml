import csv
import os

def WriteLinesToFile(filepath, lst):
    open(filepath, 'w').writelines(
        '\n'.join([str(x).encode('utf-8') for x in lst]) + '\n')


def ReadLinesFromFile(filepath):
    if os.path.exists(filepath):
        return [line.strip() for line in open(filepath).readlines()]
    return None


def GetFilepathWithSuffix(data_filepath, suffix, ext):
    """Given filepath convert it by appending suffix and changing ext.

    e.g., /a/b/foo.png will be converted to /a/b/foo-data.csv when suffix is
    data and ext is csv.
    """
    filename = ''.join(os.path.basename(data_filepath).split('.')[:-1])
    return os.path.join(
        os.path.dirname(data_filepath),
        filename + '-%s.%s' % (suffix, ext))


