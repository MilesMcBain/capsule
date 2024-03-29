% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compare.R
\name{compare_local_to_lockfile}
\alias{compare_local_to_lockfile}
\alias{compare_capsule_to_lockfile}
\title{compare the local R library with the lockfile}
\usage{
compare_local_to_lockfile(lockfile_path = "./renv.lock")

compare_capsule_to_lockfile(lockfile_path = "./renv.lock")
}
\arguments{
\item{lockfile_path}{a length one character vector path of the lockfile for}
}
\value{
a summary dataframe of version differences
}
\description{
Get a summary dataframe comparing package versions in the lockfile with
versions in the local R library (.libPaths()) or capsule library (./renv).
}
\section{Functions}{
\itemize{
\item \code{compare_capsule_to_lockfile}: compares the renv libray to the lockfile
}}

\seealso{
Other comparisons: 
\code{\link{any_local_behind_lockfile}()},
\code{\link{get_local_behind_lockfile}()}

Other comparisons: 
\code{\link{any_local_behind_lockfile}()},
\code{\link{get_local_behind_lockfile}()}
}
\concept{comparisons}
