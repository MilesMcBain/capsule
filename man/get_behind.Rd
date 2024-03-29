% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compare.R
\name{get_local_behind_lockfile}
\alias{get_local_behind_lockfile}
\alias{get_capsule_behind_lockfile}
\title{get packckes behind lockfile}
\usage{
get_local_behind_lockfile(
  lockfile_path = "./renv.lock",
  dep_source_paths = NULL
)

get_capsule_behind_lockfile(
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
a summary dataframe of package version differences.
}
\description{
return information on packages in your main R library (\code{.libPaths()}) or capsule library (\code{./renv}) that are behind the
lockfile versions (at \code{lockfile_path}).
}
\details{
if \code{dep_source_paths} is supplied only dependencies declared in these files are returned.

Information is returned about packages that are behind in your development
environment, so you can update them to the capsule versions if you wish.

A warning is thrown in the case that pacakges have the same version but
different remote SHA. E.g. A package in one library is from GitHub and in
the other library is from CRAN. Or Both packages are from GitHub, have the
same version but different SHAs.
}
\section{Functions}{
\itemize{
\item \code{get_capsule_behind_lockfile}: get packages in the renv library that are behind the lockfile
}}

\examples{
\dontrun{
get_local_behind_capsule(
  dep_source_paths = "./packages.R",
  lockfile_path = "./renv.lock"
)
}
}
\seealso{
Other comparisons: 
\code{\link{any_local_behind_lockfile}()},
\code{\link{compare_local_to_lockfile}()}

Other comparisons: 
\code{\link{any_local_behind_lockfile}()},
\code{\link{compare_local_to_lockfile}()}
}
\concept{comparisons}
