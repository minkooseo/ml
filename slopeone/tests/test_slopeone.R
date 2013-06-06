source('../slopeone.R')

context('slopeone')

test_that('empty rating', {
  model <- build_slopeone(data.frame())
  expect_equal(NROW(model), 0)
})

test_that('duplicate item ratins', {
  model <- build_slopeone(
    data.frame(user_id=c('u1', 'u1', 'u1'),
               item_id=c('i1', 'i2', 'i1'),
               rating=c(3, 4, 4)))
  expected_model <- data.frame(
    item_id1=c('i1', 'i2'),
    item_id2=c('i2', 'i1'),
    b=c(.5, -.5),
    support=c(1, 1),
    stringsAsFactors=FALSE)
  expect_equal(as.data.frame(model), expected_model)
})

test_that('multiple users', {
  model <- build_slopeone(
    data.frame(user_id=c('u1', 'u1', 'u1', 'u2', 'u2'),
               item_id=c('i1', 'i2', 'i3', 'i1', 'i2'),
               rating=c(3, 4, 5, 4, 5)))
  expected_model <- data.frame(
    item_id1=c('i1', 'i1', 'i2', 'i2', 'i3', 'i3'),
    item_id2=c('i2', 'i3', 'i1', 'i3', 'i1', 'i2'),
    b=c(1, 2, -1, 1, -2, -1),
    support=c(2, 1, 2, 1, 1, 1),
    stringsAsFactors=FALSE)
  expect_equal(as.data.frame(model), expected_model)
})

test_that('predict_slopeone_for_user', {
  model <- data.table(data.frame(
    item_id1=c('i1', 'i1', 'i2', 'i2', 'i3', 'i3'),
    item_id2=c('i2', 'i3', 'i1', 'i3', 'i1', 'i2'),
    b=c(1, 2, -1, 1, -2, -1),
    support=c(2, 1, 2, 1, 1, 1),
    stringsAsFactors=FALSE))
  setkey(model, item_id1, item_id2)
  expect_equal(
      predict_slopeone_for_user(model, 'i2',
                                data.table(item_id=c('i1'), rating=c(4))),
      5)
  expect_equal(
      predict_slopeone_for_user(model, 'i3',
                                data.table(item_id=c('i1'), rating=c(4))),
      6)
  expect_equal(
      predict_slopeone_for_user(model, 'i2',
                                data.table(item_id=c('i1', 'i3'),
                                           rating=c(4, 2))),
      3)  # mean(5, 1)
  expect_equal(
      predict_slopeone_for_user(model, 'i999',
                                data.table(item_id=c('i1', 'i3'),
                                           rating=c(4, 2))),
      NaN)
  expect_warning(
    (first_rating <- predict_slopeone_for_user(model, 'i3',
                              data.table(item_id=c('i3', 'i3'),
                                         rating=c(4, 2)))),
    c('i3  is already rated by user, but there are multiple ratings.'))
  # First rating take precedence
  expect_equal(first_rating, 4)
})


test_that('predict_slopeone', {
  model <- data.table(data.frame(
    item_id1=c('i1', 'i1', 'i2', 'i2', 'i3', 'i3'),
    item_id2=c('i2', 'i3', 'i1', 'i3', 'i1', 'i2'),
    b=c(1, 2, -1, 1, -2, -1),
    support=c(2, 1, 2, 1, 1, 1),
    stringsAsFactors=FALSE))
  setkey(model, item_id1, item_id2)
  ratings <- data.table(user_id=c('u1'), item_id=c('i1'), rating=c(4))
  expected_ratings <- ratings
  expected_ratings$predicted_rating <- c(NaN)
  expect_that(
    predict_slopeone(model, ratings),
    is_equivalent_to(expected_ratings))
  
  ratings <- data.table(user_id=c('u1', 'u1'), item_id=c('i1', 'i2'),
                        rating=c(3, 4))
  expected_ratings <- ratings
  expected_ratings$predicted_rating <- c(
    3,  # 4 - 1
    4)  # 3 + 1
  expect_that(
    predict_slopeone(model, ratings),
    is_equivalent_to(expected_ratings))
  
  ratings <- data.table(user_id=c('u1', 'u2', 'u2', 'u2', 'u2'), 
                        item_id=c('i1', 'i2', 'i3', 'i3', 'i999'),
                        rating=c(  3,    4,    5,    1,   2))
  expected_ratings <- ratings
  expected_ratings$predicted_rating <- c(
    NaN,  # Single rating.
    2,  # ((5-1) + (1-1)) / 2
    1,  # i3 is already rated.
    5,  # i3 is already rated.
    NaN)  # Previously unknown item.
  expect_that(
    predict_slopeone(model, ratings),
    is_equivalent_to(expected_ratings))
})
