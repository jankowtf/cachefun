# Internal cache factory --------------------------------------------------

#' Create cache-aware function
#' @importFrom shiny reactiveValues
#' @importFrom shiny reactive
#' @importFrom shiny isolate
#' @example inst/examples/ex-caf_main.R
#' @export
caf_create <- function(
  fun = NULL,
  ...,
  observes = list(),
  .refresh_default = TRUE
  # .verbose_default = FALSE
) {
  reactv <- shiny::reactiveValues()

  dat_reactive <- shiny::reactive({
    # if(reactv$.verbose) message('Caching result...')
    reactv$data
  })

  caf <- function(
    ...,
    .fun,
    .refresh = TRUE,
    .reset = FALSE
    # .verbose = FALSE,
  ) {
    # Reset -----
    if (.reset) {
      # if (.verbose) message(object.size(dat_reactive()))
      reactv$data <<- NULL
      # if (.verbose) message(object.size(dat_reactive()))
      return(invisible(NULL))
    }

    # Transfer settings -----
    # reactv$.verbose <<- .verbose

    if (is.null(reactv$data) | .refresh) {
      reactv$data <<- reactive(.fun(...))
      # Note:
      # Wrapping with 'reactive' ensures that reactive relationships to
      # dependencies are picked up.
    }

    # Dispatch cache-handling to shiny -----
    if (!shiny::is.reactive(dat_reactive())) {
      dat_reactive()
    } else {
      dat_reactive()()
    }
  }

  # Embedd dependencies as default args of 'fun' -----
  dot_list <- list(...)
  .formals_fun <- formals(fun)
  for (arg in names(dot_list)) {
    .formals_fun[[arg]] <- dot_list[[arg]]
  }
  formals(fun) <- .formals_fun

  # Embedd default values of meta args as args of 'caf'

  # TODO-20180204-1:
  # This seems too inolved >> find better solution

  # TODO-20180205-1:
  # At least encapsulate it in own function

  .formals <- formals(caf)
  if (!is.null(fun)) .formals$.fun <- fun
  .formals$.refresh <- .refresh_default
  # .formals$.verbose <- .verbose_default
  formals(caf) <- .formals

  caf
}

# Reset cache -------------------------------------------------------------

#' Reset internal cache of cache-aware function
#' @example inst/examples/ex-caf_main.R
#' @export
caf_reset <- function(caf, .verbose = FALSE) {
  caf(.reset = TRUE, .verbose = .verbose)
}
