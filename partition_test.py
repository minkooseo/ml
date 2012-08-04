#!/usr/bin/env python
import unittest

from scipy import *
from scipy.sparse import *

import csr_test_util
import EMC_IO
import partition

class PartitionTest(unittest.TestCase):
  def setUp(self):
    pass

  def tearDown(self):
    pass

  def testSplitMatrix(self):
    m = csr_matrix([[1.0, 2.0, 0.0],
                    [0.0, 0.0, 3.0],
                    [4.0, 0.0, 5.0]])
    t, v = partition.split_matrix(m, [0, 1], [2])
    csr_test_util.assertEqualCsrMatrix(
        m.todense(), 
        csr_matrix([[1.0, 2.0, 0.0],
                    [0.0, 0.0, 3.0]]).todense())
    csr_test_util.assertEqualCsrMatrix(
        v.todense(), 
        csr_matrix([[4.0, 0.0, 5.0]]).todense())

    t, v = partition.split_matrix(m, [0, 2], [1])
    csr_test_util.assertEqualCsrMatrix(
        m.todense(), 
        csr_matrix([[1.0, 2.0, 0.0],
                    [4.0, 0.0, 5.0]]).todense())
    csr_test_util.assertEqualCsrMatrix(
        v.todense(), 
        csr_matrix([[0.0, 0.0, 3.0]]).todense())


if __name__ == '__main__':
  unittest.main()
