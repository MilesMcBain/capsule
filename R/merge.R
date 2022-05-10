get_lockfile_repos_df <- function(lockfile_path = "./renv.lock") {
  lockfile_json <- jsonlite::fromJSON(
    lockfile_path
  )
  repos_df <- lockfile_json$R$Repositories
  colnames(repos_df) <- c("name", "url")
  repos_df$source <- "user"
  repos_df$position <- seq(nrow(repos_df))
  repos_df
}

get_local_repos_df <- function() {
  repos <- options("repos")$repos
  data.frame(
    name = names(repos),
    url = repos,
    source = "lockfile",
    position = seq_along(repos)
  )
}

merge_local_lockfile_repositories <- function(lockfile_path = "./renv.lock") {
  repositories <- rbind(
    get_local_repos_df(),
    get_lockfile_repos_df(lockfile_path)
  )

  repositories$is_rspm <- is_rpm_url(respositories$url)
  respositories$is_cran <- is_cran_url(respositories$url)

  user_has_cran <- nrow(repositories[
    repositories$source == "user" &
      repositories$is_cran == TRUE,
  ]) > 1

  user_has_rspm <- nrow(repositories[
    repositories$source == "user" &
      repositories$is_rspm == TRUE,
  ]) > 1

  if (user_has_cran) {
    respositories <-
      repositories[
        !(
          respositories$source == "lockfile" &
            repsositories$is_cran == TRUE),
      ]
  }

  if (user_has_rspm) {
    respositories <-
      repositories[
        !(
          respositories$source == "lockfile" &
            repsositories$is_rspm == TRUE),
      ]
  }
}

normalise_url <- function(url) {
  gsub("/$", "", url)
}
