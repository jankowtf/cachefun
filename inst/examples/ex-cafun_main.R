
# Introduction ------------------------------------------------------------

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

# Change the default value of args ----------------------------------------

cafun <- cafun_create(fun = fun, .refresh = FALSE)

str(cafun)
# Note that default value for arg 'refresh = TRUE' >> you reversed the
# pre-configured default setting

cafun() # Inner is INITIALLY function executed, result is cached
cafun() # Inner function NOT executed, internal cache returned
cafun(refresh = TRUE) # Explicit refresh request:
                      # Inner function executed, result is cached
cafun() # Inner function NOT executed, internal cache returned

# Inner function with argumeents ------------------------------------------

fun <- function(x) Sys.time() + x

cafun <- cafun_create(fun = fun)

cafun(x = 3600) # Inner function executed, result is cached
cafun(x = 3600 * 5, refresh = FALSE) # Inner function NOT executed, internal cache returned
cafun(x = 3600 * 5) # Inner function executed, result is cached

# Reset internal cache ----------------------------------------------------

fun <- function(x) rnorm(x)

cafun <- cafun_create(fun = fun)

res <- cafun(x = 1000)

# Resetting the internal cache in verbose mode (messages for prior and new
# object size in cache)
cafun_reset_cache(cafun = cafun, .verbose = TRUE)
