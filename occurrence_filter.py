import collections
import itertools

import parallel


def is_low_selective_(csr_matrix, indices_to_process, result_queue, adtl_args):
  num_classes_feature_can_appear = adtl_args['num_classes_feature_can_appear']
  label = adtl_args['label']
  old_feature_no = -1
  low_selective_features = set()
  labels_feature_appear = set()
  for i, j in indices_to_process:
    if i in low_selective_features:
      continue
    if i != old_feature_no:
      old_feature_no = i
      labels_feature_appear = set()
    labels_feature_appear.add(label[j])
    if len(labels_feature_appear) > num_classes_feature_can_appear:
      low_selective_features.add(i)
  result_queue.put(low_selective_features)


def get_low_selective_features(csr_matrix, label, num_classes_feature_can_appear):
  transposed = csr_matrix.transpose().tocsr()
  results = parallel.rowwise(
      transposed,
      is_low_selective_,
      min(8, transposed.shape[0]),
      { 'num_classes_feature_can_appear': num_classes_feature_can_appear, 
        'label': label })
  superset = set()
  for r in results:
    superset = superset.union(r)
  return superset


def erase_features(csr_matrix, features_to_erase):
  non_zero_indices = csr_matrix.nonzero()
  data = csr_matrix.data
  idx = 0
  for i, j in itertools.izip(non_zero_indices[0], non_zero_indices[1]):
    if j in features_to_erase:
      data[idx] = 0
    idx += 1
  csr_matrix.data[:] = data


def erase_low_val(csr_matrix, min_value, max_value):
  pass
