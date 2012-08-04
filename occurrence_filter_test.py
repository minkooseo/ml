#!/usr/bin/env python
import unittest

from scipy import *
from scipy.sparse import *

import csr_test_util
import occurrence_filter

class OccurrenceFilterTest(unittest.TestCase):
  def setUp(self):
    pass

  def tearDown(self):
    pass

  def testGetLowSelectiveFeatures(self):
    m = self.GetTableForTest()
    self.assertEquals(
        set([0, 1, 2]), occurrence_filter.get_low_selective_features(m, [1, 1, 1], 0))
    self.assertEquals(
        set([]), occurrence_filter.get_low_selective_features(m, [1, 1, 1], 1))
    self.assertEquals(
        set([0, 1, 2]), occurrence_filter.get_low_selective_features(m, [1, 2, 3], 0))
    self.assertEquals(
        set([0, 2]), occurrence_filter.get_low_selective_features(m, [1, 2, 3], 1))
    self.assertEquals(
        set([2]), occurrence_filter.get_low_selective_features(m, [1, 2, 3], 2))
    self.assertEquals(
        set([0, 1, 2]), occurrence_filter.get_low_selective_features(m, [1, 2, 2], 0))
    self.assertEquals(
        set([0, 2]), occurrence_filter.get_low_selective_features(m, [1, 2, 2], 1))
    self.assertEquals(
        set([]), occurrence_filter.get_low_selective_features(m, [1, 2, 2], 2))

  def GetTableForTest(self):
    return csr_matrix([[1.0, 2.0, 7.0],
                       [0.0, 0.0, 3.0],
                       [4.0, 0.0, 5.0]])

  def testEraseFeatures(self):
    m = self.GetTableForTest()
    occurrence_filter.erase_features(m, [])
    csr_test_util.assertEqualCsrMatrix(m, self.GetTableForTest())

    m = self.GetTableForTest()
    occurrence_filter.erase_features(m, [0])
    csr_test_util.assertEqualCsrMatrix(m,
        csr_matrix([[2.0, 7.0],
                    [0.0, 3.0],
                    [0.0, 5.0]]))

    m = self.GetTableForTest()
    occurrence_filter.erase_features(m, [0, 2])
    csr_test_util.assertEqualCsrMatrix(m,
        csr_matrix([[2.0],
                    [0.0],
                    [0.0]]))

    m = self.GetTableForTest()
    occurrence_filter.erase_features(m, [1])
    csr_test_util.assertEqualCsrMatrix(m,
        csr_matrix([[1.0, 7.0],
                    [0.0, 3.0],
                    [4.0, 5.0]]))
    print m.nonzero()
    self.assertEquals(5, len(m.nonzero()[0]))
    self.assertEquals(5, len(m.nonzero()[1]))

if __name__ == '__main__':
  unittest.main()
