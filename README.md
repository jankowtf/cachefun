# cachefun

The goal of `cachefun` is to make caching fun ;-)

It let's you define "cache-aware functions"" (`cafun`s) or, put differently, functions that have an internal/built-in cache.

Whether or not you want the cache to be updated upon every execuction of the function or not is completely up to you (see `refresh` argument of `cafun_create`):
* When setting `refresh = TRUE` the *cafun* would behave just as any regular R function 
* When setting `refresh = FALSE` you would explicitly request the cached result of the *cafun's* previous execution.

The main use case I had in mind when developping this package was offering **effortless** iternal caching for functions that take a long time to run (e.g. loading data, tidying data, etc.). I also wanted to leverage as much of reactive functionality of ``shiny`` as possible. 

## Installation

``` r
require("devtools")
devtools::install_github("rappster/cachefun")
```

## Examples

### Introduction 

``` r
library(cachefun)
# Define a regular function that you'd like to make "cache-aware"
fun <- function() Sys.time()

# Turn this function into a cache-aware function
cafun <- cafun_create(fun = fun)

str(cafun)
#> function (fun = function () 
#> Sys.time(), refresh = TRUE, reset = FALSE, .verbose = FALSE, ...)
# Note that default value for arg 'refresh = TRUE' >> by default, the inner
# function is always execudted (no internal cache used)  which implies that you
# need to explicitly state whenever you would like to use the internal cache

cafun() # Inner function executed, result is cached
#> [1] "2018-02-04 20:30:59 CET"
Sys.sleep(1)
cafun() # Inner function executed, result is cached
#> [1] "2018-02-04 20:31:00 CET"
Sys.sleep(1)
cafun(refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-04 20:31:00 CET"
cafun(refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-04 20:31:00 CET"
Sys.sleep(1)
cafun() # Inner function executed, result is cached
#> [1] "2018-02-04 20:31:02 CET"
cafun(refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-04 20:31:02 CET"
```

### Change the default value of args 

``` r
library(cachefun)
fun <- function() Sys.time()
cafun <- cafun_create(fun = fun, .refresh = FALSE)

str(cafun)
#> function (fun = function () 
#> Sys.time(), refresh = FALSE, reset = FALSE, .verbose = FALSE, ...)
# Note that default value for arg 'refresh = TRUE' >> you reversed the
# pre-configured default setting

cafun() # Inner is INITIALLY function executed, result is cached
#> [1] "2018-02-04 20:31:54 CET"
cafun() # Inner function NOT executed, internal cache returned
#> [1] "2018-02-04 20:31:54 CET"
cafun(refresh = TRUE) # Explicit refresh request:
#> [1] "2018-02-04 20:31:54 CET"
                      # Inner function executed, result is cached
cafun() # Inner function NOT executed, internal cache returned
#> [1] "2018-02-04 20:31:54 CET"
```

### Inner function with argumeents 

``` r
fun <- function(x) Sys.time() + x

cafun <- cafun_create(fun = fun)

cafun(x = 3600) # Inner function executed, result is cached
#> [1] "2018-02-04 19:42:22 CET"
cafun(x = 3600 * 5, refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-04 19:42:22 CET"
cafun(x = 3600 * 5) # Inner function executed, result is cached
#> [1] "2018-02-04 23:42:22 CET"
```

### Reset internal cache 

``` r
fun <- function(x) rnorm(x)

cafun <- cafun_create(fun = fun)

res <- cafun(x = 1000)

# Resetting the internal cache in verbose mode (messages for prior and new
# object size in cache)
cafun_reset_cache(cafun = cafun, .verbose = TRUE)
#> 8040
#> 0
```

### Observed dependencies

``` r
fun_1 <- function(x) x
cafun_1 <- cafun_create(fun = fun_1)

# Define cafun_2 that depends on cafun_1
fun_2 <- function(x, observes) {
  observes$cafun_1(refresh = FALSE) + x
}
# Note that we make the dependency explicit  by relying on the internal cache
# of cafun_1
cafun_2 <- cafun_create(fun = fun_2,
  observes = shiny::reactiveValues(cafun_1 = cafun_1))
# Dependencies to observe are supplied via 'observes' argument which is a
# shiny reactive values list

cafun_1(x = 10)
#> [1] 10
cafun_2(x = 50)
#> [1] 60

cafun_1(x = 100)
#> [1] 100
cafun_2(x = 50)
#> [1] 150
cafun_2(x = 200)
#> [1] 300
```
