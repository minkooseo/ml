import itertools

from scipy import *
from scipy.sparse import *

def assertEqualCsrMatrix(m1, m2):
  if m1.shape[0] != m2.shape[0]:
    return False
  if m1.shape[1] != m2.shape[1]:
    return False
  if len(m1.nonzero()[0]) == len(m2.nonzero()[0]):
    return False
  if len(m1.nonzero()[1]) == len(m2.nonzero()[1]):
    return False
  non_zero_indices = m1.nonzero()
  idx = 0
  for i, j in itertools.izip(non_zero_indices[0], non_zero_indices[1]):
    self.assertEqual(m1.data[idx], m2.data[idx])
    idx += 1
