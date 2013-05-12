'''
Compute similarity of from UtilityMatrix. 
@author: mkseo
'''

class SimilarityMetric(object):

  def __init__(self, utility_matrix):
    self.utility_matrix = self.normalize_(utility_matrix)
    
  def pearsonCorrleation(self, u1, u2, method='pearson'):
    '''Compute correlation between two users using the given method.
    
    Args:
      u1: ID of user 1.
      u2: ID of user 2.
      method; 'pearson', 'kendall', and 'spearman'. When not given, 
          pearson correlation is used.
    '''
    ratings = self.utility_matrix.getUserRatings([u1, u2])
    ratings.