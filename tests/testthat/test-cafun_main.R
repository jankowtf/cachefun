library(testthat)
context("Test cache-aware functions")

test_that("20180204-1: cache-aware function: initial", {
  fun <- function(x) sprintf("hello %s!", x)
  expect_is(fun_with_cache <- cafun_create(fun = fun), "function")

  x_1 <-  "world"
  x_2 <-  "WORLD"

  expectation <- "hello world!"
  expect_identical(fun_with_cache(x = x_1), expectation)
  expect_identical(fun_with_cache(x = x_2, refresh = FALSE), expectation)

  expectation <- "hello WORLD!"
  expect_identical(fun_with_cache(x = x_2), expectation)
  expect_identical(fun_with_cache(x = x_1, refresh = FALSE), expectation)
})

test_that("20180204-2: cache-aware function: verbose", {
  fun <- function() "hello world!"
  expect_is(fun_with_cache <- cafun_create(fun = fun), "function")

  expectation <- "hello world!"
  expect_message(
    expect_identical(fun_with_cache(fun = fun, .verbose = TRUE), expectation),
    "Caching result"
  )
})

test_that("20180204-3: cache-aware function: reset cache", {
  # Inner function with argumeents
  fun <- function(x) rnorm(x)

  cafun <- cafun_create(fun = fun)

  res <- cafun(x = 3600)

  cafun_reset_cache(cafun = cafun, .verbose = TRUE)
})
