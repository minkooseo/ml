#!/usr/bin/env python
import csv
import cPickle
import itertools

import EMC_IO
import normalize
import occurrence_filter
import partition
import csr_dump

from scipy import sparse
import numpy

NUM_CLASSES_FEATURE_CAN_APPEAR = 3
RATIO_FEATURE_APPEAR_IN_EACH_LABEL = 0.05
TRAIN_DATA_RATIO = 0.7
ROW_SUM_DICT_FILENAME = "row_sum_dict.data"
PARALLELISM = 8

print
print "Reading train and label data..."
train = EMC_IO.EMC_ReadData('train_data.csv')
print "train:", train.shape
label = EMC_IO.EMC_ReadLabels("train_labels.csv")
print "label:", label.shape

#print "Split train and validation..."
#training_rows, validation_rows = partition.split_rows(train, TRAIN_DATA_RATIO)
#print len(training_rows), "rows will be used as train."
#print len(validation_rows), "rows will be used as validation."
#
## Store training rows and validation rows as seprate CSV files.
#print "Splitting matrix..."
#training_matrix, validation_matrix = partition.split_matrix(
#    train, training_rows, validation_rows)
#csr_dump.dump_csr_matrix(training_matrix, 'split_train.csv')
#csr_dump.dump_csr_matrix(validation_matrix, 'split_validation.csv')

print "Occurrence filtering..."
low_selective_features = occurrence_filter.get_low_selective_features(
    train, label, NUM_CLASSES_FEATURE_CAN_APPEAR)
cPickle.dump(low_selective_features, open("low_selective_features.data", "w"))
#low_selective_features = cPickle.load(open("low_selective_features.data"))
print len(low_selective_features), "features occurs in too many classes."

# Let's be careful.
del label
del train

def process(input_fname, output_fname):
  print "Reading %s..." % input_fname
  csr_matrix = EMC_IO.EMC_ReadData(input_fname)
  print "dimension:", csr_matrix.shape

  print "Erasing features from", len(csr_matrix.nonzero()[0]), "non-zero entries."
  occurrence_filter.erase_features(csr_matrix, low_selective_features)
  print "Now we have", len(csr_matrix.nonzero()[0]), "non-zero entries."
  print "dimension:", csr_matrix.shape

  print
  print "Normaling document length..."
  normalize.normalize_by_doc_length(csr_matrix, normalize.compute_row_sum(csr_matrix))

  print "Writing resulting data..."
  csr_dump.dump_csr_matrix(csr_matrix, output_fname)

process('train_data.csv', 'a1_train.csv')
process('test_data.csv', 'a1_test.csv')

print "Done!"
