# cachefun

The goal of `cachefun` is to make caching fun ;-)

It let's you define "cache-aware functions"" (`cafun`s) or, put differently, functions that have an internal/built-in cache.

Whether or not you want to cache to be updated upon every execuction of the function or not is completely up to you (see `refresh` argument of `cafun_create`):
* When setting `refresh = TRUE` the *cafun* would behave just as any regular R function 
* When setting `refresh = FALSE` you would explicitly request the cached result of the previous execution.

The main use case I had in mind when developping this package was offering effortless iternal caching for functions that take a long time to run (e.g. loading data, tidying data).

## Examples

### Introduction 

```{r}
# Define a regular function that you'd like to make "cache-aware"
fun <- function() Sys.time()

# Turn this function into a cache-aware function
cafun <- cafun_create(fun = fun)

str(cafun)
# Note that default value for arg 'refresh = TRUE' >> by default, the inner
# function is always execudted (no internal cache used)  which implies that you
# need to explicitly state whenever you would like to use the internal cache

cafun() # Inner function executed, result is cached
cafun() # Inner function executed, result is cached
cafun(refresh = FALSE) # Inner function NOT executed, internal cache returned
cafun(refresh = FALSE) # Inner function NOT executed, internal cache returned
cafun() # Inner function executed, result is cached
cafun(refresh = FALSE) # Inner function NOT executed, internal cache returned
```

### Change the default value of args 

```{r}
cafun <- cafun_create(fun = fun, .refresh = FALSE)

str(cafun)
# Note that default value for arg 'refresh = TRUE' >> you reversed the
# pre-configured default setting

cafun() # Inner is INITIALLY function executed, result is cached
cafun() # Inner function NOT executed, internal cache returned
cafun(refresh = TRUE) # Explicit refresh request:
                      # Inner function executed, result is cached
cafun() # Inner function NOT executed, internal cache returned
```

### Inner function with argumeents 

```{r}
fun <- function(x) Sys.time() + x

cafun <- cafun_create(fun = fun)

cafun(x = 3600) # Inner function executed, result is cached
cafun(x = 3600 * 5, refresh = FALSE) # Inner function NOT executed, internal cache returned
cafun(x = 3600 * 5) # Inner function executed, result is cached
```

### Reset internal cache 

```{r}
fun <- function(x) rnorm(x)

cafun <- cafun_create(fun = fun)

res <- cafun(x = 1000)

# Resetting the internal cache in verbose mode (messages for prior and new
# object size in cache)
cafun_reset_cache(cafun = cafun, .verbose = TRUE)
```
