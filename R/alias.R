# Code in this file taken from {renv} with MIT-style license:

# Copyright 2021 RStudio, PBC

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# aliases used primarily for nicer / normalized text output
`_renv_aliases` <- list(
  bioconductor = "Bioconductor",
  bitbucket    = "Bitbucket",
  cellar       = "Cellar",
  cran         = "CRAN",
  git2r        = "Git",
  github       = "GitHub",
  gitlab       = "GitLab",
  local        = "Local",
  repository   = "Repository",
  standard     = "Repository",
  url          = "URL",
  xgit         = "Git"
)

renv_alias <- function(text) {
  `_renv_aliases`[[text]] %||% text
}
