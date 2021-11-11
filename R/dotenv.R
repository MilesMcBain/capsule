with_.env_if_available <- function(expr) {
  if (!file.exists(".env") || getOption("capsule_ignore_dotenv", FALSE)) {
    force(expr)
  } else {
    message("{capsule} found a .env file. Setting environment for duration of this operation.")
    old_env <- Sys.getenv()
    dotenv::load_dot_env()
    new_env <- Sys.getenv()
    new_vars <- setdiff(names(new_env), names(old_env))
    unset_list <- as.list(setNames(
      rep("", length(new_vars)),
      new_vars
    ))
    on.exit(do.call(
      Sys.setenv,
      c(as.list(old_env), unset_list)
    ))
    force(expr)
  }
}
