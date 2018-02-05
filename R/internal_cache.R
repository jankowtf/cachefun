# Internal cache factory --------------------------------------------------

#' Create cache-aware function
#' @importFrom shiny reactiveValues
#' @importFrom shiny reactive
#' @importFrom shiny isolate
#' @example inst/examples/ex-cafun_main.R
#' @export
caf_create <- function(
  fun = NULL,
  observes = list(),
  .refresh_default = TRUE,
  .verbose_default = FALSE
) {
  reactv <- shiny::reactiveValues()

  dat_reactive <- shiny::reactive({
    if(reactv$.verbose) message('Caching result...')
    reactv$data
  })

  cafun <- function(
    fun,
    .refresh = TRUE,
    .reset = FALSE,
    .verbose = FALSE,
    ...
  ) {
    # Reset -----
    if (.reset) {
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

    if (is.null(reactv$data) | .refresh) {
      # browser()
      # fun_res <- fun(..., observes = observes)
      fun_formals <- formals(fun)
      fun_res <- if (!"observes" %in% names(fun_formals)) {
        fun(...)
      } else {
        fun(..., observes = observes)
      }
      # fun_res <- rlang::eval_tidy(fun())
      # Keep as ref, probably will need to be done this way at some point ;-)
      reactv$data <<- fun_res
    }

    # Relay cache-handling to shiny -----
    dat_reactive()
  }

  # Transfer default values -----

  # TODO-20180204-1:
  # This seems too inolved >> find better solution

  # TODO-20180205-1:
  # At least encapsulate it in own function

  .formals <- formals(cafun)
  if (!is.null(fun)) .formals$fun <- fun
  .formals$.refresh <- .refresh_default
  .formals$.verbose <- .verbose_default
  formals(cafun) <- .formals

  cafun
}

# Reset cache -------------------------------------------------------------

#' Reset internal cache of cache-aware function
#' @example inst/examples/ex-cafun_main.R
#' @export
caf_reset <- function(cafun, .verbose = FALSE) {
  cafun(.reset = TRUE, .verbose = .verbose)
}
