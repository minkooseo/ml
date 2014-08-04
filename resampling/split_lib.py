#!/usr/bin/env python
# Split the given data into separate files considerating the class (or label).

import csv
import math
import os
import random
from collections import defaultdict

def GroupByLabel(fname, label_idx, header):
    """From input file, group row numbers by labels."""
    label_dict = defaultdict(lambda : list())
    with open(fname) as f:
        for rownum, elems in enumerate(csv.reader(f)):
            if header and rownum == 0:
                continue
            label_dict[elems[label_idx]].append(rownum)
    return label_dict


def GetChunks(lst, nchunks):
    """Split lst into the given number of chunks."""
    chunk_size = len(lst) / float(nchunks)
    start = 0.0
    while True:
        if start + chunk_size > len(lst):
            # For the last chunk, make sure that it contains all the remaining.
            yield lst[int(round(start)):]
        else:
            yield lst[int(round(start)):int(round(start + chunk_size))]
        start += chunk_size
        if start >= len(lst):
            break


def SplitToN(label_to_rownum, num_files, shuffle_func=random.shuffle):
    """Convert label to rownum map into rownum to file idx map."""
    rownum_to_fileidx = {}
    for _, rownum_list in label_to_rownum.iteritems():
        shuffle_func(rownum_list)
        for fileidx, chunk in enumerate(GetChunks(rownum_list, num_files)):
            for rownum in chunk:
                rownum_to_fileidx[rownum] = fileidx
    return rownum_to_fileidx


def SplitToPercent(label_to_rownum, percent, shuffle_func=random.shuffle):
    """Convert label to rownum map into rownum to file idx map."""
    rownum_to_fileidx = {}
    for _, rownum_list in label_to_rownum.iteritems():
        shuffle_func(rownum_list)
        for idx, rn in enumerate(rownum_list):
            # Ensure that at least one is in one side.
            if idx < max(1, round(len(rownum_list) * percent)):
                rownum_to_fileidx[rn] = 0
            else:
                rownum_to_fileidx[rn] = 1
    return rownum_to_fileidx


def GetOutputFilenames(input_filepath, num_files):
    """From the input filename, get output file name."""
    basename = os.path.basename(input_filepath)
    fname = ''.join(basename.split('.')[:-1])
    ext = basename.split('.')[-1]
    return [os.path.join(os.path.dirname(input_filepath),
                         '%s-%d-of-%d.%s' % (fname, i, num_files, ext))
            for i in xrange(1, num_files + 1)]
