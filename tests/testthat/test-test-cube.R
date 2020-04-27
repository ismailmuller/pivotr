context("Test that cube gives back correct dimensions")

library(testthat)

X <- data.frame(x = 1:4, y = letters[1:2], z = c(10, 100, 20, 40),
                x2 = c(letters[1:3], NA), stringsAsFactors = FALSE )

test_that("Correct dimensions and values", {
  # when no grouping variable
  expect_equal(cube(X, NULL, AVG = mean(z)), data.frame(AVG = 42.5))
  # with one grouping variable
  expect_equal(cube(X, y, AVG = mean(z)), 
               data.frame(y = c("a", "b", "Total"), AVG = c(15, 70, 42.5), stringsAsFactors = FALSE))
  # with 2 grouping variables
  expect_equal(cube(X, c(x, y), AVG = mean(z)),
               data.frame(x = c(rep(1:4, each=2), rep("Total", 3)),
                          y = c("a", "Total", "b", "Total", "a", "Total", "b", "Total", "a", "b", "Total"),
                          AVG = c(10,10,100,100, 20,20,40,40,15,70,42.5), stringsAsFactors = FALSE))
  # when a grouping variable has a NA
  expect_equal(cube(X, x2, n = length(x)),
               data.frame(x2 = c(X$x2, "Total"), n = c(1L,1L,1L,1L,4L), stringsAsFactors = FALSE ))
})

context("Test that cube gives error")
test_that("errors", {
  expect_error(cube())
  expect_error(cube("a"))
  expect_error(cube(X, NULL))
  expect_error(cube(X, zoo))
})
