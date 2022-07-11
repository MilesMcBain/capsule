# lockfile/library comparisons work

    Code
      compare_capsule_to_lockfile("renv_cran.lock")
    Output
      data.frame [1, 11]
      name                 chr renv
      version_lock         chr 0.15.5
      repository_lock      chr CRAN
      remote_sha_lock      lgl NA
      remote_repo_lock     lgl NA
      remote_username_lock lgl NA
      version_lib          chr 0.15.5
      repository_lib       chr CRAN
      remote_sha_lib       lgl NA
      remote_repo_lib      lgl NA
      remote_username_lib  lgl NA

---

    Code
      compare_capsule_to_lockfile("renv_pak_rspm.lock")
    Output
      data.frame [1, 11]
      name                 chr renv
      version_lock         chr 0.15.5
      repository_lock      chr RSPM
      remote_sha_lock      lgl NA
      remote_repo_lock     chr https://packagemanager.rstudio.com~
      remote_username_lock lgl NA
      version_lib          chr 0.15.5
      repository_lib       chr CRAN
      remote_sha_lib       lgl NA
      remote_repo_lib      lgl NA
      remote_username_lib  lgl NA

