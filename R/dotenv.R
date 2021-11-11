with_.env_if_available <- function(expr) {
  if (!file.exists(".env") || getOption("capsule_ignore_dotenv", FALSE)) {
    force(expr)
  } else {
    message("{capsule} found a .env file. Setting environment for duration of this operation.")
    old_env <- Sys.getenv()
    on.exit(do.call(Sys.setenv, old_env))
    dotenv::load_dot_env()
    force(expr)
  }
}
