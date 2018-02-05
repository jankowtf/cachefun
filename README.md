# cachefun

The goal of `cachefun` is to make caching fun ;-)

It let's you define "cache-aware functions" (`cafun`s or `caf`s) which means that the functions have an internal/built-in cache.

Whether or not you want this cache to be updated upon every execuction of the function or not is completely up to you (see `.refresh_default` argument of `caf_create`):
* When setting `.refresh_default = TRUE` the *caf* would behave just as any regular R function unless you tell it otherwise by setting `.refresh = FALSE` when calling your *caf* 
* When setting `.refresh_default = FALSE`, then it's the other way around: you would always get the value of the internal cache unless you explicitly request the cache to be updated by setting `.refresh = TRUE` when calling your *caf*.

The main use case I had in mind when developping this package was offering effortless ("built-in") **and** flexible (sometimes I don't want the cache result, sometimes I do") iternal caching for functions that take a long time to run (e.g. loading data, tidying data, etc.). 

As I'm fascinated by the concept of reactiveness, I also want/plan to leverage as much of `{shiny}`'s reactive functionality of as possible (see my efforts with observed dependencies below). 

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
cafun <- caf_create(fun = fun)

str(cafun)
#> function (fun = function () 
#> Sys.time(), .refresh = TRUE, .reset = FALSE, .verbose = FALSE, ...)
# Note that default value for arg '.refresh = TRUE' >> by default, the inner
# function is always executed (internal cache is always updated). This implies
# that the function behaves like any regular R function unless you explicitly
# tell it to return the internal cache in a particular call by setting '.refresh
# = FALSE'.

cafun() # Inner function executed, result is cached
#> [1] "2018-02-05 09:11:08 CET"
Sys.sleep(1)
cafun() # Inner function executed, result is cached
#> [1] "2018-02-05 09:11:09 CET"
Sys.sleep(1)
cafun(.refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 09:11:09 CET"
Sys.sleep(1)
cafun(.refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 09:11:09 CET"
Sys.sleep(1)
cafun() # Inner function executed, result is cached
#> [1] "2018-02-05 09:11:12 CET"
Sys.sleep(1)
cafun(.refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 09:11:12 CET"
```

### Change the default value of args 

``` r
library(cachefun)
fun <- function() Sys.time()
cafun <- caf_create(fun = fun, .refresh_default = FALSE)

str(cafun)
#> function (fun = function () 
#> Sys.time(), .refresh = FALSE, .reset = FALSE, .verbose = FALSE, ...)
# Note that default value for arg '.refresh = FALSE' >> you reversed the
# pre-configured default settings. This implies that the function will always
# return the internal cache value unless you explicitly tell it not to by
# setting `.refresh = TRUE` in a particular call

cafun() # Inner function is INITIALLY executed (as cache is still empty),
#> [1] "2018-02-05 09:11:43 CET"
        # result is cached
cafun() # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 09:11:43 CET"
cafun(.refresh = TRUE) # Explicit refresh request:
#> [1] "2018-02-05 09:11:43 CET"
                      # Inner function executed, result is cached
cafun() # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 09:11:43 CET"
```

### Inner function with argumeents 

``` r
library(cachefun)
fun <- function(x) Sys.time() + x

cafun <- caf_create(fun = fun)

cafun(x = 3600) # Inner function executed, result is cached
#> [1] "2018-02-05 10:13:44 CET"
cafun(x = 3600 * 5, .refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 10:13:44 CET"
cafun(x = 3600 * 5) # Inner function executed, result is cached
#> [1] "2018-02-05 14:13:44 CET"
```

### Reset internal cache 

``` r
library(cachefun)
fun <- function(x) rnorm(x)

cafun <- caf_create(fun = fun)

res <- cafun(x = 1000)

# Resetting the internal cache in verbose mode (messages for prior and new
# object size in cache)
caf_reset(cafun = cafun, .verbose = TRUE)
#> 8040
#> 0
```

### Observed dependencies

``` r
library(cachefun)

# Define cafun_1 that will next be observed by cafun_2
fun_1 <- function(x) x
cafun_1 <- caf_create(fun = fun_1)

# Define cafun_2 that depends on cafun_1
fun_2 <- function(x, observes) {
  observes$cafun_1(.refresh = FALSE) + x
}
# Note that we make the dependency explicit  by relying on the internal cache
# of cafun_1
cafun_2 <- caf_create(fun = fun_2,
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

