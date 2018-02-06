# cachefun

The goal of `cachefun` is to make caching fun ;-)

It let's you define "cache-aware functions" (`cafun`s or `caf`s): functions that have an internal/built-in cache.

Whether or not you want this cache to be updated upon every execuction of the function or not is completely up to you (see `.refresh_default` argument of `caf_create`):
* When setting `.refresh_default = TRUE` the *caf* would behave just as any regular R function unless you tell it otherwise by setting `.refresh = FALSE` when calling your *caf* 
* When setting `.refresh_default = FALSE`, then it's the other way around: you would always get the value of the internal cache unless you explicitly request the cache to be updated by setting `.refresh = TRUE` when calling your *caf*.

You are also able to define reactive dependencies that directly leverage the reactivity functionality of `{shiny}`. Thus, internal cache values are automatically invalidated if the cache value of one of your function's dependencies changes.

The main use case I had in mind when developping this package was offering effortless ("built-in") **and** flexible (sometimes I don't want the cache result, sometimes I do") iternal caching for functions that take a long time to run (e.g. loading data, tidying data, etc.). 

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
caf <- caf_create(fun = fun)

str(caf)
#> function (fun = function () 
#> Sys.time(), .refresh = TRUE, .reset = FALSE, .verbose = FALSE, ...)
# Note that default value for arg '.refresh = TRUE' >> by default, the inner
# function is always executed (internal cache is always updated). This implies
# that the function behaves like any regular R function unless you explicitly
# tell it to return the internal cache in a particular call by setting '.refresh
# = FALSE'.

caf() # Inner function executed, result is cached
#> [1] "2018-02-05 09:11:08 CET"
Sys.sleep(1)
caf() # Inner function executed, result is cached
#> [1] "2018-02-05 09:11:09 CET"
Sys.sleep(1)
caf(.refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 09:11:09 CET"
Sys.sleep(1)
caf(.refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 09:11:09 CET"
Sys.sleep(1)
caf() # Inner function executed, result is cached
#> [1] "2018-02-05 09:11:12 CET"
Sys.sleep(1)
caf(.refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 09:11:12 CET"
```

### Change the default value of args 

``` r
library(cachefun)
fun <- function() Sys.time()
caf <- caf_create(fun = fun, .refresh_default = FALSE)

str(caf)
#> function (fun = function () 
#> Sys.time(), .refresh = FALSE, .reset = FALSE, .verbose = FALSE, ...)
# Note that default value for arg '.refresh = FALSE' >> you reversed the
# pre-configured default settings. This implies that the function will always
# return the internal cache value unless you explicitly tell it not to by
# setting `.refresh = TRUE` in a particular call

caf() # Inner function is INITIALLY executed (as cache is still empty),
#> [1] "2018-02-05 09:11:43 CET"
        # result is cached
caf() # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 09:11:43 CET"
caf(.refresh = TRUE) # Explicit refresh request:
#> [1] "2018-02-05 09:11:43 CET"
                      # Inner function executed, result is cached
caf() # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 09:11:43 CET"
```

### Inner function with argumeents 

``` r
library(cachefun)
fun <- function(x) Sys.time() + x

caf <- caf_create(fun = fun)

caf(x = 3600) # Inner function executed, result is cached
#> [1] "2018-02-05 10:13:44 CET"
caf(x = 3600 * 5, .refresh = FALSE) # Inner function NOT executed, internal cache returned
#> [1] "2018-02-05 10:13:44 CET"
caf(x = 3600 * 5) # Inner function executed, result is cached
#> [1] "2018-02-05 14:13:44 CET"
```

### Reset internal cache 

``` r
library(cachefun)
fun <- function(x) rnorm(x)

caf <- caf_create(fun = fun)

res <- caf(x = 1000)

# Resetting the internal cache in verbose mode (messages for prior and new
# object size in cache)
caf_reset(caf = caf, .verbose = TRUE)
#> 8040
#> 0
```

### Reactive dependencies

``` r
library(cachefun)

# Define 'caf_1' that 'caf_2' will depend on
fun_1 <- function(x) x
caf_1 <- caf_create(fun = fun_1)

# Define 'caf_2' that depends on 'caf_1'
fun_2 <- function(x, observes) {
  observes$caf_1(.refresh = FALSE) + x
}
caf_2 <- caf_create(fun = fun_2, observes = list(caf_1 = caf_1))
# Note that we state the dependency by relying on the internal cache of 'caf_1'
# ('.refresh = FALSE'). Behind the scenes, 'caf_create' takes care of turning a
# dependency listed in the 'observes' ilist nto an **reactive** one (leveraging
# shiny's capabilities). This means that 'caf_2' will be re-evaluated whenever
# the cached return value of dependency 'caf_1' is updated. In shiny terms, the
# cache of 'caf_2' is autmatically invalidated when it needs to be

caf_1(x = 10)
#> [1] 10
caf_2(x = 50)
#> [1] 60

caf_1(x = 100)
#> [1] 100
caf_2(x = 50, .refresh = FALSE)
#> [1] 150
# Note that even though we explicitly requested that 'caf_2' should return the
# interanally cached value of the previous execution (60), the inner unction was
# instead evaluated. This is because the cached value of 'caf_1' has changed
# which automatically invalidates all reactive components that depend on it.
# This way you can be sure that even though you might like to use cached values,
# you still never run the risk of being out-of-sync regarding your function's
# dependencies

caf_2(x = 200)
#> [1] 300
```


