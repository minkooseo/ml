#!/usr/bin/env python
import csv
import os
import tempfile
import unittest

import file

class FileTest(unittest.TestCase):

    def testReadWriteLines(self):
        tf = tempfile.NamedTemporaryFile(suffix='.txt')
        expected = [1, 2, 3]
        file.WriteLinesToFile(tf.name, expected)
        self.assertListEqual(expected,
                             [int(x) for x in file.ReadLinesFromFile(tf.name)])
        tf.close()

    def testGetFilepathWithSuffix(self):
        self.assertEqual('/a/b/c/d-model.dat',
                         file.GetFilepathWithSuffix('/a/b/c/d.csv',
                                                    'model', 'dat'))


if __name__ == '__main__':
    unittest.main()
