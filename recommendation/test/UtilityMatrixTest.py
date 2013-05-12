from pandas.util.testing import assert_series_equal, assert_frame_equal
import UtilityMatrix
import numpy as np
import pandas as pd
import unittest



class Test(unittest.TestCase):
  
  def setUp(self):
    #     i1  i2  i3  i4
    # u1   1   2   3 NaN
    # u2  10 NaN NaN  20
    self.utility_matrix = UtilityMatrix.UtilityMatrix()
    self.utility_matrix.addScore('u1', 
                                 {'i1': 1.0, 'i2': 2.0, 'i3': 3.0})
    self.utility_matrix.addScore('u2', 
                                 {'i1':10.0, 'i4': 20.0})

  def testUserRatings(self):
    assert_series_equal(
        pd.Series([1.0, 2.0, 3.0, np.NaN], index=['i1', 'i2', 'i3', 'i4']),
        self.utility_matrix.getUserRatings('u1'))
    assert_series_equal(
        pd.Series([10.0, np.NaN, np.NaN, 20.0], index=['i1', 'i2', 'i3', 'i4']),
        self.utility_matrix.getUserRatings('u2'))
    assert_frame_equal(
        self.utility_matrix.ratings_,
        self.utility_matrix.getUserRatings(['u1', 'u2']))
    
  def testItemRatings(self):
    assert_series_equal(pd.Series([1.0, 10.0], index=['u1', 'u2']),
                        self.utility_matrix.getItemRatings('i1'))
    assert_series_equal(pd.Series([np.NaN, 20.0], index=['u1', 'u2']),
                        self.utility_matrix.getItemRatings('i4'))
    assert_frame_equal(pd.DataFrame([[1.0, np.NaN], [10.0, 20.0]], 
                                    index=['u1', 'u2'],
                                    columns=['i1', 'i4']),
                       self.utility_matrix.getItemRatings(['i1', 'i4']))
    
  def testColumnNormalize(self):
    self.utility_matrix.normalize(axis=0)
    assert_frame_equal(
        pd.DataFrame([[-4.5,      0,      0, np.NaN],
                      [ 4.5, np.NaN, np.NaN,      0]],
                     index=['u1', 'u2'],
                     columns=['i1', 'i2', 'i3', 'i4']),
        self.utility_matrix.ratings_)
    
  def testColumnDenormalize(self):
    expected = self.utility_matrix.ratings_
    self.utility_matrix.normalize(axis=0)
    self.utility_matrix.denormalize()
    assert_frame_equal(expected, self.utility_matrix.ratings_)
  
  def testRowNormalize(self):
    self.utility_matrix.normalize(axis=1)
    assert_frame_equal(
        pd.DataFrame([[ -1.0,    0.0,    1.0, np.NaN],
                      [ -5.0, np.NaN, np.NaN,    5.0]],
                     index=['u1', 'u2'],
                     columns=['i1', 'i2', 'i3', 'i4']),
        self.utility_matrix.ratings_)    
    
  def testRowDenormalize(self):
    expected = self.utility_matrix.ratings_
    self.utility_matrix.normalize(axis=1)
    self.utility_matrix.denormalize()
    assert_frame_equal(expected, self.utility_matrix.ratings_)
        
  def testNormalizeAll(self):
    self.utility_matrix.normalize(axis=1)
    self.utility_matrix.normalize(axis=0)
    assert_frame_equal(
        pd.DataFrame([[ 2.0,      0,      0, np.NaN],
                      [-2.0, np.NaN, np.NaN,      0]],
                     index=['u1', 'u2'],
                     columns=['i1', 'i2', 'i3', 'i4']),
        self.utility_matrix.ratings_)  
    
  def testDeNormalizeAll(self):
    expected = self.utility_matrix.ratings_
    self.utility_matrix.normalize(axis=1)
    self.utility_matrix.normalize(axis=0)
    self.utility_matrix.denormalize()
    assert_frame_equal(expected, self.utility_matrix.ratings_)

if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()