import collections
import logging
import os
import random

from ml.io import file


logger = logging.getLogger('cross_validation')


def GetValidationRowIndices(data_reader, prob):
    """Get validation row indcies.

    Class proportion is considered and reservoir sampling is used.

    Args:
        data_reader: Function that returns generator which yields x, y from
          input data.
        prob: Probability of choosing a row as validation data.

    Returns:
        Row indices to use as validation data.
    """
    # Get the number of records for each label.
    label_cnt = collections.defaultdict(int)
    logger.info('Reading data...')
    for _, y in data_reader():
        label_cnt[y] += 1
    logger.info('Class distribution: %s' % str(label_cnt))
    logger.info('Sampling validation rows...')
    # Get the number of samples to pick.
    select_cnt = {}
    for y, cnt in label_cnt.iteritems():
        select_cnt[y] = cnt * prob
    # Reservoir sampling.
    validation_data = collections.defaultdict(list)
    for i, x_y in enumerate(data_reader()):
        _, y = x_y
        if len(validation_data[y]) < select_cnt[y]:
            validation_data[y].append(i)
        else:
            r = random.randint(0, i)
            if r < select_cnt[y]:
                validation_data[y][r] = i
    return sum(validation_data.values(), [])
