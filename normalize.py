import collections
import itertools
import math
import os
import parallel

import multiprocessing

from scipy import sparse
import numpy

def row_sum_(csr_matrix, index_tuples, result_queue, unused):
  sum_dict = collections.defaultdict(int)
  for i, j in index_tuples:
    sum_dict[i] += csr_matrix[i, j]
  result_queue.put(sum_dict)

def compute_row_sum_parallel(csr_matrix, parallelism):
  results = parallel.rowwise(csr_matrix, row_sum_, parallelism, {})
  superdict = dict()
  for r in results:
    superdict = dict(superdict.items() + r.items())
  return superdict

def compute_row_sum(csr_matrix):
  # Use csr matrix function
  sum_matrix = csr_matrix.sum(1)  # rowise sum
  row_sum_dict = {}
  for i in range(sum_matrix.shape[0]):
    row_sum_dict[i] = sum_matrix[i, 0]
  return row_sum_dict

def normalize_by_doc_length(csr_matrix, row_sum_dict):
  non_zero_indices = csr_matrix.nonzero()
  data = csr_matrix.data
  idx = 0
  for i, j in itertools.izip(non_zero_indices[0], non_zero_indices[1]):
    data[idx] = data[idx] / row_sum_dict[i]
    idx += 1
  csr_matrix.data[:] = data

def get_df(csr_matrix):
  feature_to_numdocs = collections.defaultdict(int)
  non_zero_indices = csr_matrix.nonzero()
  for i, j in itertools.izip(non_zero_indices[0], non_zero_indices[1]):
    feature_to_numdocs[j] += 1
  return feature_to_numdocs

def normalize_by_idf(csr_matrix, feature_to_numdocs):
  non_zero_indices = csr_matrix.nonzero()
  data = csr_matrix.data
  idx = 0
  num_total_docs = csr_matrix.shape[0]
  for i, j in itertools.izip(non_zero_indices[0], non_zero_indices[1]):
    data[idx] = data[idx] * math.log(float(num_total_docs) / feature_to_numdocs[j])
    idx += 1
  csr_matrix.data[:] = data
