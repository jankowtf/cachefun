
# Introduction ------------------------------------------------------------

library(cachefun)
# Define a regular function that you'd like to make "cache-aware"
fun <- function() Sys.time()

# Turn this function into a cache-aware function
cafun <- caf_create(fun = fun)

str(cafun)
# Note that default value for arg '.refresh = TRUE' >> by default, the inner
# function is always executed (internal cache is always updated). This implies
# that the function behaves like any regular R function unless you explicitly
# tell it to return the internal cache in a particular call by setting '.refresh
# = FALSE'.

cafun() # Inner function executed, result is cached
Sys.sleep(1)
cafun() # Inner function executed, result is cached
Sys.sleep(1)
cafun(.refresh = FALSE) # Inner function NOT executed, internal cache returned
Sys.sleep(1)
cafun(.refresh = FALSE) # Inner function NOT executed, internal cache returned
Sys.sleep(1)
cafun() # Inner function executed, result is cached
Sys.sleep(1)
cafun(.refresh = FALSE) # Inner function NOT executed, internal cache returned

# Change the default value of args ----------------------------------------

library(cachefun)
fun <- function() Sys.time()
cafun <- caf_create(fun = fun, .refresh_default = FALSE)

str(cafun)
# Note that default value for arg '.refresh = FALSE' >> you reversed the
# pre-configured default settings. This implies that the function will always
# return the internal cache value unless you explicitly tell it not to by
# setting `.refresh = TRUE` in a particular call

cafun() # Inner function is INITIALLY executed (as cache is still empty),
        # result is cached
cafun() # Inner function NOT executed, internal cache returned
cafun(.refresh = TRUE) # Explicit refresh request:
                      # Inner function executed, result is cached
cafun() # Inner function NOT executed, internal cache returned

# Inner function with arguments ------------------------------------------

library(cachefun)
fun <- function(x) Sys.time() + x

cafun <- caf_create(fun = fun)

cafun(x = 3600) # Inner function executed, result is cached
cafun(x = 3600 * 5, .refresh = FALSE) # Inner function NOT executed, internal cache returned
cafun(x = 3600 * 5) # Inner function executed, result is cached

# Reset internal cache ----------------------------------------------------

library(cachefun)
fun <- function(x) rnorm(x)

cafun <- caf_create(fun = fun)

res <- cafun(x = 1000)

# Resetting the internal cache in verbose mode (messages for prior and new
# object size in cache)
caf_reset(cafun = cafun, .verbose = TRUE)

# Observed dependencies ---------------------------------------------------

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
cafun_2(x = 50)

cafun_1(x = 100)
cafun_2(x = 50)
cafun_2(x = 200)
