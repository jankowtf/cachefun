
# Keep as reference -------------------------------------------------------

caf_create <- function(
  fun = NULL,
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
      if (.verbose) message(shiny::isolate(object.size(dat_reactive())))
      # rm(data, envir = reactv)
      reactv$data <<- NULL
      if (.verbose) message(shiny::isolate(object.size(dat_reactive())))
      return(invisible(NULL))
    }

    # Transfer settings -----
    reactv$.verbose <<- .verbose

    if (shiny::isolate(is.null(reactv$data)) | refresh) {
      fun_res <- fun(...)
      # fun_res <- rlang::eval_tidy(fun())
      reactv$data <<- fun_res
    }

    # Relay cache-handling to shiny -----
    shiny::isolate(dat_reactive())
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
