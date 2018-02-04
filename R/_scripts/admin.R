
# Settings ----------------------------------------------------------------

library(usethis)
repeat_initial <- FALSE

# Misc --------------------------------------------------------------------

use_mit_license("Janko Thyson")
use_roxygen_md()
use_readme_md()
use_news_md()

use_revdep()
# Run checks with `revdepcheck::revdep_check(num_workers = 4)`

# Data --------------------------------------------------------------------

# x <- 1
# y <- 2
# use_data(x, y)
# use_r()

# GitHub credentials ------------------------------------------------------

if (repeat_intial) {
  # cred <- git2r::cred_ssh_key(
  #   normalizePath("~/../.ssh/id_rsa.pub", winslash = "/"),
  #   normalizePath("~/../.ssh/id_rsa", winslash = "/")
  # )
  cred <- git2r::cred_ssh_key(
    "~/.ssh/id_rsa.pub",
    "~/.ssh/id_rsa"
  )
  repo <- git2r::repository(".git")
  git2r::push(repo, credentials = cred)
}

# GitHub ------------------------------------------------------------------

# file.exists("~/../.ssh/id_rsa.pub")
# use_git()
# use_github(credentials = cred)
use_github()

# DevOps ------------------------------------------------------------------

use_travis()
use_coverage()
# covr::package_coverage()
