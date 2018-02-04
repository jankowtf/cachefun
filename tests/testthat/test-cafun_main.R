library(testthat)
context("Test cache-aware functions")

test_that("20180204-1: cafun: initial", {
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

test_that("20180204-2: cafun: verbose", {
  fun <- function() "hello world!"
  expect_is(fun_with_cache <- cafun_create(fun = fun), "function")

  expectation <- "hello world!"
  expect_message(
    expect_identical(fun_with_cache(fun = fun, .verbose = TRUE), expectation),
    "Caching result"
  )
})

test_that("20180204-3: cafun: reset cache", {
  # Inner function with argumeents
  fun <- function(x) rnorm(x)

  cafun <- cafun_create(fun = fun)

  res <- cafun(x = 3600)

  cafun_reset_cache(cafun = cafun, .verbose = TRUE)
})

test_that("20180204-4: cafun: observed deps", {
  fun_1 <- function(x) x
  cafun_1 <- cafun_create(fun = fun_1)

  fun_2 <- function(x, observes) {
    observes$cafun_1(refresh = FALSE) + x
  }
  cafun_2 <- cafun_create(fun = fun_2,
    observes = shiny::reactiveValues(cafun_1 = cafun_1))

  expect_identical(cafun_1(x = 10), 10)
  expect_identical(cafun_2(x = 50), 60)
  expect_identical(cafun_1(x = 100), 100)
  expect_identical(cafun_2(x = 200), 300)
})
