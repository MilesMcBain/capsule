# Version 0.4.1

  * remove `capshot` dependency on `renv:::renv_alias`.
  * When looking for the sitaution where packages with the same version have different SHAs, only real shas are considered. Not the fake version SHAs inserted by `{pak}` et. al.
