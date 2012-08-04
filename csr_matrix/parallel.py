import itertools
import math
import multiprocessing

from scipy import sparse
import numpy

def rowwise(csr_matrix, func, parallelism, adtl_args):
  print "Running rowwise for (%d, %d) matrix..." % (csr_matrix.shape[0],
                                                    csr_matrix.shape[1])
  NUM_ROWS_PER_PROCESS = max(int(csr_matrix.shape[0] / parallelism), 1)
  print "- Will launch a process per %d rows." % NUM_ROWS_PER_PROCESS
  result_queue = multiprocessing.Queue()
  non_zero_indices = csr_matrix.nonzero()
  processes = []
  num_rows = 0
  old_row_no = -1
  indices_to_process = []

  for row_no, col_no in itertools.izip(non_zero_indices[0],
                                       non_zero_indices[1]):
    if old_row_no != row_no:
      num_rows += 1
      old_row_no = row_no
    if num_rows >= NUM_ROWS_PER_PROCESS:
      processes.append(
          multiprocessing.Process(target=func,
                                  args=(csr_matrix,
                                        indices_to_process,
                                        result_queue,
                                        adtl_args)))
      print "- Added process:", len(processes)
      indices_to_process = []
      num_rows = 0
    indices_to_process.append((row_no, col_no))

  processes.append(
      multiprocessing.Process(target=func,
                              args=(csr_matrix,
                                    indices_to_process,
                                    result_queue,
                                    adtl_args)))
  print "- Added process:", len(processes)

  print "- Forking processes..."
  [p.start() for p in processes]
  print "- Joining processes..."
  return [result_queue.get() for p in processes]
