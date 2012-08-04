import csv
import itertools

from scipy import *
from scipy.sparse import *

def dump_csr_matrix(csr_matrix, fname):
  non_zero_indices = csr_matrix.nonzero()
  data = []
  indices = []
  indptr = []
  old_row = -1
  index = 0
  for i, j in itertools.izip(non_zero_indices[0], non_zero_indices[1]):
    data.append(csr_matrix.data[index])
    indices.append(j)
    if old_row != i:
      old_row = i
      indptr.append(index)
    index += 1
  indptr.append(len(indices))
  writer = csv.writer(open(fname, "w"))
  writer.writerow((csr_matrix.shape[0], csr_matrix.shape[1]))
  writer.writerow(data)
  writer.writerow(indices)
  writer.writerow(indptr)
