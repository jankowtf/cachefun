
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

# Observed dependencies ---------------------------------------------------

# Define cafun_1 that will next be observed by cafun_2
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
cafun_2(x = 50)

cafun_1(x = 100)
cafun_2(x = 50)
cafun_2(x = 200)
