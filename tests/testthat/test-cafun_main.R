library(testthat)

# Basics ------------------------------------------------------------------

context("Cache-aware functions: Basics")

test_that("20180204-1: cafun: initial", {
  fun <- function(x) sprintf("hello %s!", x)
  expect_is(cafun <- caf_create(fun = fun), "function")

  x_1 <-  "world"
  x_2 <-  "WORLD"

  expectation <- "hello world!"
  expect_identical(cafun(x = x_1), expectation)
  expect_identical(cafun(x = x_2, .refresh = FALSE), expectation)

  expectation <- "hello WORLD!"
  expect_identical(cafun(x = x_2), expectation)
  expect_identical(cafun(x = x_1, .refresh = FALSE), expectation)
})

test_that("20180205-1: cafun: different default args", {
  fun <- function(x) sprintf("hello %s!", x)
  expect_is(cafun <- caf_create(fun = fun, .refresh_default = FALSE), "function")

  x_1 <-  "world"
  x_2 <-  "WORLD"

  expectation <- "hello world!"
  expect_identical(cafun(x = x_1), expectation)
  expect_identical(cafun(x = x_2), expectation)

  expectation <- "hello WORLD!"
  expect_identical(cafun(x = x_2, .refresh = TRUE), expectation)
  expect_identical(cafun(x = x_1), expectation)
})

test_that("20180204-2: cafun: verbose", {
  fun <- function() "hello world!"
  expect_is(cafun <- caf_create(fun = fun), "function")

  expectation <- "hello world!"
  expect_message(
    expect_identical(cafun(fun = fun, .verbose = TRUE), expectation),
    "Caching result"
  )
})

# Reactivity --------------------------------------------------------------

context("Cache-aware functions: reactivity")

test_that("20180204-3: cafun: reset cache", {
  # Inner function with argumeents
  fun <- function(x) rnorm(x)

  cafun <- caf_create(fun = fun)

  res <- cafun(x = 3600)

  caf_reset(cafun = cafun, .verbose = TRUE)
})

test_that("20180204-4: reactivity: basic", {
  fun_1 <- function(x) x
  cafun_1 <- caf_create(fun = fun_1)

  fun_2 <- function(x, observes) {
    observes$cafun_1(.refresh = FALSE) + x
  }
  cafun_2 <- caf_create(fun = fun_2, observes = list(cafun_1 = cafun_1))

  expect_identical(cafun_1(x = 10), 10)
  expect_identical(cafun_2(x = 50), 60)
  expect_identical(cafun_1(x = 100), 100)
  expect_identical(cafun_2(x = 200), 300)
})

test_that("20180206-1: reactivity: invalidation", {
  fun_1 <- function(x) x
  caf_1 <- caf_create(fun = fun_1)

  # fun_2 <- function(x, observes) {
  #   reactive(observes$caf_1(.refresh = FALSE) + x)
  # }
  fun_2 <- function(x, observes) {
    observes$caf_1(.refresh = FALSE) + x
  }
  caf_2 <- caf_create(fun = fun_2, observes = list(caf_1 = caf_1))

  caf_1(x = 10)
  expect_identical(caf_2(x = 50, .refresh = FALSE), 60)
  expect_identical(caf_2(x = 50), 60)

  caf_1(x = 100)
  expect_identical(caf_2(x = 50, .refresh = FALSE), 150)
  expect_identical(caf_2(x = 200, .refresh = FALSE), 150)
  expect_identical(caf_2(x = 200), 300)
})
