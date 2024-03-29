% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compare.R
\name{any_local_behind_lockfile}
\alias{any_local_behind_lockfile}
\title{check if any local packages are behind lockfile}
\usage{
any_local_behind_lockfile(
  lockfile_path = "./renv.lock",
  dep_source_paths = NULL
)
}
\arguments{
\item{lockfile_path}{a length one character vector path of the lockfile for}

\item{dep_source_paths}{a character vector of file paths to extract
package dependencies from. If NULL (default) the whole local library is compared.}
}
\value{
TRUE if dev packages are behind lockfile, FALSE otherwise.
}
\description{
A wrapper for \link{get_local_behind_lockfile} that returns TRUE if any
dependencies found in \code{dep_source_paths} are behind the lockfile version in
\code{lockfile_path}
}
\seealso{
Other comparisons: 
\code{\link{compare_local_to_lockfile}()},
\code{\link{get_local_behind_lockfile}()}
}
\concept{comparisons}
