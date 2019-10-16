delete_local_lib <- function() {

  unlink("./renv",
         recursive = TRUE)

}

delete_lockfile <- function() {

  unlink("./renv.lock")

}

delete <- function() {

  delete_local_lib()
  delete_lockfile()

}
