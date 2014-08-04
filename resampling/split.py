#!/usr/bin/env python
# Split the given data into separate files considerating the class (or label).
#
# There are two kinds of split supported:
# - percentage: For splitting data into training and test dataset.
# - multiple files: For building separate models for each part of data.

import collections
import csv
import split_lib
import sys
from optparse import OptionParser
from collections import defaultdict

parser = OptionParser()
parser.add_option('--input', action='store', dest='input', type='string', default=None,
                  help='File containing csv.')
parser.add_option('--percent', action='store', dest='percent', type='float', default=None,
                  help='Percentage of data for the first file. Second file will contain '
                       'remaining data.')
parser.add_option('--num_files', action='store', dest='num_files', type='int', default=None,
                  help='Data will be split into num_files files. Number of '
                       'records in each file will be even.')
parser.add_option('--label_idx', action='store', dest='label_idx', type='int', default=0,
                  help='Index of label column.')
parser.add_option('--no_header', action='store_false', dest='header', default=True,
                  help='If set, all rows are treated as data. Otherwise, first line is header.')
parser.add_option('--seed', action='store', dest='seed', type='int', default=137,
                  help='Random number seed when splitting data.')
options, _ = parser.parse_args()

if options.percent is None and options.num_files is None:
    print 'Eiter --percent or --num_files should be specified.'
    sys.exit(1)

if options.input is None:
    print '--input should be specified.'
    sys.exit(1)

if options.label_idx is None:
    print '--label_idx should be specified.'
    sys.exit(1)

print 'Loading input file...'
label_to_rownum = split_lib.GroupByLabel(options.input, options.label_idx, options.header)
total_records = 0
for k in label_to_rownum.keys():
  print 'Label: %s, Number of records: %d' % (k, len(label_to_rownum[k]))
  total_records += len(label_to_rownum[k])
rownum_to_fileidx = None
num_output_files = None
print 'Splitting data...'
if options.percent:
    rownum_to_fileidx = split_lib.SplitToPercent(label_to_rownum, options.percent)
    num_output_files = 2
else:
    rownum_to_fileidx = split_lib.SplitToN(label_to_rownum, options.num_files)
    num_output_files = options.num_files

output_files = [csv.writer(open(fname, 'w'))
                for fname in split_lib.GetOutputFilenames(options.input, num_output_files)]

if options.header:
    # Copy header to all output files.
    with open(options.input) as input:
        reader = csv.reader(input)
        for elems in reader:
            for of in output_files:
                of.writerow(elems)
            break

print 'Writing output...'
fileidx_to_label_cnt = collections.defaultdict(lambda: collections.defaultdict(lambda: 0))
for rownum, elems in enumerate(csv.reader(open(options.input))):
    if options.header and rownum == 0:
        continue
    if rownum % 1000000 == 0:
        print 'Processing %d/%d' % (rownum, total_records)
    assert rownum in rownum_to_fileidx
    fileidx = rownum_to_fileidx[rownum]
    output_files[fileidx].writerow(elems)
    fileidx_to_label_cnt[fileidx][elems[options.label_idx]] += 1

print 'Stats:'
for k, v in fileidx_to_label_cnt.iteritems():
    print 'File %d' % k
    total = sum(v.values())
    for label, cnt in v.iteritems():
        print 'Label: %s, Count: %d (%.2f)' % (label, cnt, float(cnt)/total)
    print

print 'Done!'
