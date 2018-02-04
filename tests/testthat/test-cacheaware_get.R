library(testthat)
context("Test cache-aware functions")

test_that("20180204-1: cache-aware function: initial", {
  expect_is(fun_with_cache <- cafun_create(), "function")

  fun <- function() "hello world!"
  expectation <- "hello world!"
  expect_identical(fun_with_cache(fun = fun), expectation)
  expect_identical(fun_with_cache(fun = fun), expectation)

  fun <- function() "hello WORLD!"
  expectation <- "hello WORLD!"
  expect_identical(fun_with_cache(fun = fun, refresh = TRUE), expectation)
  expect_identical(fun_with_cache(fun = fun), expectation)
})

test_that("20180204-2: cache-aware function: verbose", {
  expect_is(fun_with_cache <- cafun_create(), "function")

  fun <- function() "hello world!"
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
