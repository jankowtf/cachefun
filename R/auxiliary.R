
# Aux ---------------------------------------------------------------------

get_env_to_assign_to <- function(
  use_env = c("temp", "global", "package")
) {
  # nsName <- "temp"
  # (ns <- asNamespace(nsName)) # <environment: namespace:stats>
  # Keep as reference

  # as.environment( "package:dlaker")
  # Keep as reference

  # getPackageName(2)
  # Get name that corresponds to second entry on the search list
  # Keep as reference

  use_env <- match.arg(use_env)

  switch(use_env,
    "temp" = as.environment("._dlaker_temp"),
    "global" = .GlobalEnv,
    # "package" = as.environment(search()[2])

    # TODO-20180131-2:
    # This seems VERY fragile/dangerous and probably only
    # makes sense in context where the datacon generics/methods should be part
    # of a PACKAGE that the developer is building. Not sure what the best
    # option would be in use cases where a developer would work in a PROJECT
    # setting (i.e. only applying packages to solve actual tasks)

    "package" = as.environment(sprintf("package:%s", devtools::as.package(".")))
    # TODO-20180131-2-SOLVED:
    # This seems to be much more robust regarding the package's namespace
    # environment position on the search path
  )
}
