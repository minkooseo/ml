#!/usr/bin/env python
import itertools
import math
import unittest

from scipy import *
from scipy.sparse import *

import normalize

class NormalizeTest(unittest.TestCase):
  def setUp(self):
    pass

  def tearDown(self):
    pass

  def testComputeRowSum_NumRowsWithMultipleOfParallelism(self):
    m1 = csr_matrix([[1.0, 2.0, 0.0],
                     [0.0, 0.0, 3.0],
                     [4.0, 0.0, 5.0],
                     [6.0, 7.0, 8.0]])
    # Process 1 process row 0, 1.
    # Process 2 process row 2, 3.
    row_sum_dict = normalize.compute_row_sum_parallel(m1, 2)
    self.assertEqual(row_sum_dict, {0: 3.0, 1: 3.0, 2: 9.0, 3: 21.0})

  def testComputeRowSum_NumRowsWithRemainder(self):
    m1 = csr_matrix([[1.0, 2.0, 0.0],
                     [0.0, 0.0, 3.0],
                     [4.0, 0.0, 5.0]])
    # Process 1 process row 0, 1.
    # Process 2 process row 2.
    row_sum_dict = normalize.compute_row_sum_parallel(m1, 2)
    self.assertEqual(row_sum_dict, {0: 3.0, 1: 3.0, 2: 9.0})

  def testComputeRowSum_UsingSumMethod(self):
    m1 = csr_matrix([[1.0, 2.0, 0.0],
                     [0.0, 0.0, 3.0],
                     [4.0, 0.0, 5.0]])
    row_sum_dict = normalize.compute_row_sum(m1)
    self.assertEqual(row_sum_dict, {0: 3.0, 1: 3.0, 2: 9.0})

  def testNormalizeByDocLength(self):
    row_sum_dict = {0: 3.0, 1: 3.0, 2: 9.0, 3: 21.0}
    m1 = csr_matrix([[1.0, 2.0, 0.0],
                     [0.0, 0.0, 3.0],
                     [4.0, 0.0, 5.0],
                     [6.0, 7.0, 8.0]])
    normalize.normalize_by_doc_length(m1, row_sum_dict)
    m2 = csr_matrix([[1.0/3.0, 2.0/3.0, 0.0/3.0],
                     [0.0/3.0, 0.0/3.0, 3.0/3.0],
                     [4.0/9.0, 0.0/9.0, 5.0/9.0],
                     [6.0/21.0, 7.0/21.0, 8.0/21.0]])
    self.assertEqualCsrMatrix(m1, m2)

  def assertEqualCsrMatrix(self, m1, m2):
    self.assertEqual(len(m1.nonzero()[0]), len(m2.nonzero()[0]))
    self.assertEqual(len(m1.nonzero()[1]), len(m2.nonzero()[1]))
    non_zero_indices = m1.nonzero()
    idx = 0
    for i, j in itertools.izip(non_zero_indices[0], non_zero_indices[1]):
      self.assertEqual(m1.data[idx], m2.data[idx])
      idx += 1

  def testGetDf(self):
    self.assertEquals({0:2, 1:1, 2:2}, 
        normalize.get_df(
            csr_matrix([[1.0, 2.0, 0.0],
                        [0.0, 0.0, 3.0],
                        [4.0, 0.0, 5.0]])))

  def testNormalizeByIdf(self):
    feature_to_numdocs = {0:2, 1:1, 2:2}
    m1 = csr_matrix([[1.0, 2.0, 0.0],
                     [0.0, 0.0, 3.0],
                     [4.0, 0.0, 5.0]])
    normalize.normalize_by_idf(m1, feature_to_numdocs)
    n_f0 = math.log(3.0 / 2);
    n_f1 = math.log(3.0 / 1);
    n_f2 = math.log(3.0 / 2);
    m2 = csr_matrix([[1.0 * n_f0, 2.0 * n_f1, 0.0 * n_f2],
                     [0.0 * n_f0, 0.0 * n_f1, 3.0 * n_f2],
                     [4.0 * n_f0, 0.0 * n_f1, 5.0 * n_f2]])
    self.assertEqualCsrMatrix(m1, m2)


if __name__ == '__main__':
  unittest.main()
