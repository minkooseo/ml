import pandas as pd

class UtilityMatrix(object):
  def __init__(self):
    self.ratings_ = pd.DataFrame()
    self.row_mean_ = None
    self.col_mean_ = None
    
  def addScore(self, user_id, item_to_ratings):
    if user_id in self.ratings_.index:
      raise KeyError("Duplicate user id given: %s" % user_id)
    self.ratings_ = pd.concat(
        [self.ratings_,
         pd.DataFrame(item_to_ratings, index=[user_id])])
    
  def getUserRatings(self, user_id):
    return self.ratings_.ix[user_id]
  
  def getItemRatings(self, item_id):
    '''Get item ratings for the given item_id.
    
    Args:
     item_id: Either a single key or list of item keys.
    '''
    return self.ratings_[item_id]
  
  def normalize(self, axis=0):
    '''Normalize by removing mean.
    
    Args:
     axis: 0 for colwise normalize. 1 for rowwise.
    '''
    if axis == 0:
      self.col_mean_ = self.ratings_.mean(axis=0)
      self.ratings_ = self.ratings_ - self.col_mean_
    else:
      self.row_mean_ = self.ratings_.mean(axis=1)
      self.ratings_ = (self.ratings_.T - self.row_mean_).T
      
    # NOTE: Another normalization option is to subtract the average of column i
    # and row j from each of rating m_{i, j}. 
    # See section 9.4.5 of the book 'mining massive datasets' ver 1.3.
     
      
  def denormalize(self):
    if self.col_mean_ is not None:
      self.ratings_ = self.ratings_ + self.col_mean_
      self.col_mean_ = None
    if self.row_mean_ is not None:
      self.ratings_ = (self.ratings_.T + self.row_mean_).T
      self.row_mean_ = None
      