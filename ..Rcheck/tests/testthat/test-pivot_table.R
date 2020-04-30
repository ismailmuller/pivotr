context("Test pivot_table")

library(testthat)

X <- data.frame(
  x = 1:4, y = letters[1:2], z = c(10, 100, 20, 40),
  x2 = c(letters[1:3], NA), stringsAsFactors = FALSE
)

context("Test that pivot_table gives error")
test_that("errors", {
  expect_error(pvt())
  expect_error(pvt("a"))
  expect_error(pvt(X, NULL))
  expect_error(pvt(X, zoo))
})

test_that("correct dimensions", {
  expect_equal(
    dim(pvt(X, rows = x2, N = dplyr::n())),
    c(5, 2)
  ) # row, calc
  expect_equal(
    dim(pvt(X, x2, y, N = dplyr::n())),
    c(5, 4)
  ) # row, col, calc
  expect_equal(
    dim(pvt(X, x2, y, N = dplyr::n(), Avg = mean(z))),
    c(5, 7)
  ) # row, col, multi calc
  expect_equal(
    dim(pvt(X, x2, y)),
    c(5, 1)
  ) # row, col
  expect_equal(
    dim(pvt(X, N = dplyr::n())),
    c(1, 1)
  ) # calc
  expect_equal(
    dim(pvt(X, cols = c(y, x2), N = dplyr::n())),
    c(1, 11)
  ) # multi cols
  expect_equal(
    dim(pvt(X, rows = c(y, x2), N = dplyr::n())),
    c(11, 3)
  ) # multi rows
})
