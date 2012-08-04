from scipy import *
from scipy.sparse import *

import itertools
import random

def split_rows(csr_matrix, train_data_ratio):
  NUM_ROWS = csr_matrix.shape[0]
  row_nums = range(0, NUM_ROWS)
  random.shuffle(row_nums)
  training_rows = row_nums[:int(NUM_ROWS * train_data_ratio)]
  validation_rows = row_nums[int(NUM_ROWS * train_data_ratio):]
  assert len(training_rows) != 0
  assert len(validation_rows) != 0
  return (training_rows, validation_rows)


class CsrMatrixBuilder:
  def __init__(self, no_col):
    self.row = []
    self.col = []
    self.val = []
    self.no_col = no_col
    self.prev_row_num = -1
    self.row_num = -1

  def add_data(self, csr_matrix, prev_idx, idx):
    self.row.extend(csr_matrix.nonzero[0][prev_idx:idx])
    self.col.extend(csr_matrix.nonzero[1][prev_idx:idx])
    self.val.append(csr_matrix.data[prev_idx:idx])

  def build(self):
    return csr_matrix((array(self.val), (array(self.row), array(self.col))),
      shape=(self.row_num + 1, self.no_col))


def split_matrix(csr_matrix, training_rows, validation_rows):
  non_zero_indices = csr_matrix.nonzero()
  training_builder = CsrMatrixBuilder(csr_matrix.shape[1])
  validation_builder = CsrMatrixBuilder(csr_matrix.shape[1])
  prev_row = -1
  idx = 0
  for idx in xrange(len(non_zero_indices[0])):
    row = non_zero_indices[0][idx]
    if prev_row != row:
      prev_row = row
      print "Splitting:", i, "/", csr_matrix.shape[0]
    target = None
    if row in training_rows:
      target = training_builder
    else:
      traget = validation_builder
    prev_idx = idx
    while True:
      if idx + 1 < len(non_zero_indices[0]) and non_zero_indices[0][idx + 1] == row:
        idx += 1
    target.add(csr_matrix, prev_idx, idx + 1)

  return (training_builder.build(), validation_builder.build())

