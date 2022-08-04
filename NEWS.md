# Version 0.4.2

  * New `run_rscript()` can run R scripts in the capsule via `callr::rscript()` (@gadenbuie #27)
  * `run_callr()` exposes the `show` option with default to `TRUE`. 
  * `detect_depencies()` is now exported

# Version 0.4.1

  * remove `capshot` dependency on `renv:::renv_alias`.
  * When looking for the sitaution where packages with the same version have different SHAs, only real shas are considered. Not the fake version SHAs inserted by `{pak}` et. al.
