#!/usr/bin/env python
import csv
import os
import tempfile
import split_lib
import unittest


class SplitLibTest(unittest.TestCase):

    def testGroupByLabel(self):
        tf = tempfile.NamedTemporaryFile(suffix='.csv')
        writer = csv.writer(tf)
        writer.writerow(('A', 'foo'))
        writer.writerow(('B', 'foo'))
        writer.writerow(('A', 'foo'))
        writer.writerow(('A', 'foo'))
        tf.flush()
        actual = split_lib.GroupByLabel(tf.name, 0)
        expected = {'A': [0, 2, 3], 'B': [1]}
        self.assertEquals(expected.keys(), actual.keys())
        for k in expected.keys():
            self.assertListEqual(expected[k], actual[k])
        tf.close()

    def testGetChunks(self):
        self.assertListEqual(
            [[0], [1], [2], [3], [4], [5]],
            list(split_lib.GetChunks([0, 1, 2, 3, 4, 5], 6)))
        self.assertListEqual(
            [[0, 1], [2, 3], [4, 5]],
            list(split_lib.GetChunks([0, 1, 2, 3, 4, 5], 3)))
        self.assertListEqual(
            [[0, 1, 2], [3, 4, 5]],
            list(split_lib.GetChunks([0, 1, 2, 3, 4, 5], 2)))
        self.assertListEqual(
            [[0, 1, 2, 3, 4, 5]],
            list(split_lib.GetChunks([0, 1, 2, 3, 4, 5], 1)))
        self.assertListEqual(
            [[0, 1, 2], [3, 4]],
            list(split_lib.GetChunks([0, 1, 2, 3, 4], 2)))
        self.assertListEqual(
            [[0, 1], [2], [3, 4]],
            list(split_lib.GetChunks([0, 1, 2, 3, 4], 3)))
        self.assertListEqual(
            [[0], [1, 2], [3], [4]],
            list(split_lib.GetChunks([0, 1, 2, 3, 4], 4)))
        self.assertListEqual(
            [[0, 1, 2], [3, 4], [5, 6, 7]],
            list(split_lib.GetChunks([0, 1, 2, 3, 4, 5, 6, 7], 3)))

    def testSplitToN(self):
        label_to_rownum = {
            'A': [1, 2, 3, 4, 5, 6, 7],
            'B': [8, 9, 10, 11, 12, 13],
            'C': [14, 15, 16]}
        self.assertDictEqual(
            {1: 0, 2:0, 3:0, 4:0, 5:1, 6:1, 7:1,
             8: 0, 9:0, 10:0, 11:1, 12:1, 13:1,
             14:0, 15:0, 16:1},
            split_lib.SplitToN(label_to_rownum, 2, lambda x: x))
        self.assertDictEqual(
            {1: 0, 2:0, 3:1, 4:1, 5:1, 6:2, 7:2,
             8: 0, 9:0, 10:1, 11:1, 12:2, 13:2,
             14:0, 15:1, 16:2},
            split_lib.SplitToN(label_to_rownum, 3, lambda x: x))

    def testSplitToPercent(self):
        label_to_rownum = {
            'A': [1, 2, 3, 4, 5, 6, 7],
            'B': [8, 9, 10, 11, 12, 13],
            'C': [14, 15, 16]}
        self.assertDictEqual(
            {1: 0, 2:0, 3:0, 4:0, 5:1, 6:1, 7:1,
             8: 0, 9:0, 10:0, 11:1, 12:1, 13:1,
             14:0, 15:0, 16:1},
            split_lib.SplitToPercent(label_to_rownum, .5, lambda x: x))
        self.assertDictEqual(
            {1: 0, 2:0, 3:1, 4:1, 5:1, 6:1, 7:1,
             8: 0, 9:0, 10:1, 11:1, 12:1, 13:1,
             14:0, 15:1, 16:1},
            split_lib.SplitToPercent(label_to_rownum, .3, lambda x: x))

    def testGetOutputFilename(self):
        self.assertListEqual(
            ['foo-1-of-2.csv', 'foo-2-of-2.csv'],
            split_lib.GetOutputFilenames('foo.csv', 2))
        self.assertListEqual(
            ['/bar/bat/foo-1-of-3.csv',
             '/bar/bat/foo-2-of-3.csv',
             '/bar/bat/foo-3-of-3.csv'],
            split_lib.GetOutputFilenames('/bar/bat/foo.csv', 3))


if __name__ == '__main__':
    unittest.main()
