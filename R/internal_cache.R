# Internal cache factory --------------------------------------------------

# cafun_create <- function(
#   fun = NULL,
#   .refresh = TRUE,
#   .verbose = FALSE
#
# ) {
#   reactv <- shiny::reactiveValues()
#   dat_reactive <- shiny::reactive({
#     if(reactv$.verbose) message('Caching result...')
#     reactv$data
#   })
#
#   cafun <- function(
#     fun,
#     refresh = TRUE,
#     reset = FALSE,
#     .verbose = FALSE,
#     ...
#   ) {
#     # Reset -----
#     if (reset) {
#       if (.verbose) message(shiny::isolate(object.size(dat_reactive())))
#       # rm(data, envir = reactv)
#       reactv$data <<- NULL
#       if (.verbose) message(shiny::isolate(object.size(dat_reactive())))
#       return(invisible(NULL))
#     }
#
#     # Transfer settings -----
#     reactv$.verbose <<- .verbose
#
#     if (shiny::isolate(is.null(reactv$data)) | refresh) {
#       fun_res <- fun(...)
#       # fun_res <- rlang::eval_tidy(fun())
#       reactv$data <<- fun_res
#     }
#
#     # Relay cache-handling to shiny -----
#     shiny::isolate(dat_reactive())
#   }
#
#   # Transfer default values -----
#
#   # TODO-20180204-1:
#   # This seems too inolved >> find better solution
#
#   .formals <- formals(cafun)
#   if (!is.null(fun)) .formals$fun <- fun
#   .formals$refresh <- .refresh
#   .formals$.verbose <- .verbose
#   formals(cafun) <- .formals
#
#   cafun
# }

#' Create cache-aware function
#' @importFrom shiny reactiveValues
#' @importFrom shiny reactive
#' @importFrom shiny isolate
#' @example inst/examples/ex-cafun_main.R
#' @export
cafun_create <- function(
  fun = NULL,
  observes = list(),
  .refresh = TRUE,
  .verbose = FALSE
) {
  reactv <- shiny::reactiveValues()

  dat_reactive <- shiny::reactive({
    if(reactv$.verbose) message('Caching result...')
    reactv$data
  })

  cafun <- function(
    fun,
    refresh = TRUE,
    reset = FALSE,
    .verbose = FALSE,
    ...
  ) {
    # Reset -----
    if (reset) {
      if (.verbose) message(object.size(dat_reactive()))
      reactv$data <<- NULL
      if (.verbose) message(object.size(dat_reactive()))
      return(invisible(NULL))
    }

    # Transfer settings -----
    reactv$.verbose <<- .verbose

    # if (shiny::isolate(is.null(reactv$data)) | refresh) {

    # NOTE:
    # Isolate not needed anymore if 'options(shiny.suppressMissingContextError = TRUE)'
    # which is handled via the package's '.onLoad' function.
    # Keep as reference, though.

    if (is.null(reactv$data) | refresh) {
      # browser()
      # fun_res <- fun(..., observes = observes)
      fun_formals <- formals(fun)
      fun_res <- if (!"observes" %in% names(fun_formals)) {
        fun(...)
      } else {
        fun(..., observes = observes)
      }
      # fun_res <- rlang::eval_tidy(fun())
      reactv$data <<- fun_res
    }

    # Relay cache-handling to shiny -----
    dat_reactive()
  }

  # Transfer default values -----

  # TODO-20180204-1:
  # This seems too inolved >> find better solution

  .formals <- formals(cafun)
  if (!is.null(fun)) .formals$fun <- fun
  .formals$refresh <- .refresh
  .formals$.verbose <- .verbose
  formals(cafun) <- .formals

  cafun
}

# Reset cache -------------------------------------------------------------

#' Reset internal cache of cache-aware function
#' @example inst/examples/ex-cafun_main.R
#' @export
cafun_reset_cache <- function(cafun, .verbose = FALSE) {
  cafun(reset = TRUE, .verbose = .verbose)
}
