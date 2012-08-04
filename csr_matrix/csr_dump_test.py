#!/usr/bin/env python
import unittest

from scipy import *
from scipy.sparse import *

import csr_dump
import csr_test_util
import EMC_IO

class CsrDumpTest(unittest.TestCase):
  def setUp(self):
    pass

  def tearDown(self):
    pass

  def testWriteThenRead(self):
    m1 = csr_matrix([[1.0, 2.0, 0.0],
                     [0.0, 0.0, 3.0],
                     [4.0, 0.0, 5.0]])
    csr_dump.dump_csr_matrix(m1, "tmp")
    m1_loaded = EMC_IO.EMC_ReadData("tmp")
    csr_test_util.assertEqualCsrMatrix(m1.todense(), m1_loaded.todense())

if __name__ == '__main__':
  unittest.main()
