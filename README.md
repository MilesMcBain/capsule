
# capsule

  [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

# Overview

A `capsule` is a stable project-specific R package library that you consciously
choose to execute code within. Think of it as representing 'production', while
your normal interactive R session represents 'development'.

You develop interactively in a dynamic package environment. You run code for
real in a well-defined static capsule. Periodically you'll want to have
your development environment reflected in the capsule as new stuff is
integrated.

When sharing with others, a capsule is the fallback that ensures your code can
always be run, no matter what issues appear in your collaborator's development
environment.

# Usage

There are 3 functions you need to know about to use `capsule`: `capsule::create()`, `capsule::run()`, `capsule::recreate()`.

## `create()` a capsule for my pipeline

```r
> capsule::create("./packages.R")
Finding R package dependencies ... Done!
* Discovering package dependencies ... Done!
* Copying packages into the cache ... [132/132] Done!
The following package(s) will be updated in the lockfile:

# CRAN ===============================
- anytime          [* -> 0.3.6]
- askpass          [* -> 1.1]
...TRUNCATED...
- BH               [* -> 1.69.0-1]
- spatial          [* -> 7.3-11]
- survival         [* -> 2.44-1.1]

# GitHub =============================
- geojsonsf        [* -> SymbolixAU/geojsonsf]
- h3jsr            [* -> obrl-soil/h3jsr]
- jsonify          [* -> SymbolixAU/jsonify]
- qfes             [* -> milesmcbain/qfes]
- renv             [* -> rstudio/renv]

* Lockfile written to 'c:/repos/capsule/renv.lock'.
```

You supply a vector of file paths to extract dependencies from. The default is
`"./packages.R"`. These dependencies are copied from your regular (dev) library
to your local capsule.

Notice how this is easier when you keep your library calls all in one place? :wink:

You'll notice some things created in your project folder. Assuming you have the
project under version control... you definitely want to commit the `./renv.lock`
file. This will allow someone else to `run()` code in the capsule context.

## `run()` code in the capsule

Render a document in the capsule:

```r
capsule::run(rmarkdown::render("doc/analysis.Rmd"))
```

Run your `drake` plan in the capsule:

```r
capsule::run(drake::r_make())
```

Source and run a file in the capsule:

```r
capsule::run_callr(function() source("./main.R"))
```

Why `run_callr` vs `run`? Use `run` for things that _already create their own R
processes_, use `run_callr()` for things that don't to avoid
contamination with your dev global environment. You could always use `run_callr()` if in doubt.

So what about code that you've just been handed? It has a `renv.lock` but no
local library? How do you build the library to run the code? You don't! `run()`
and `run_callr()` will check to see if a local library exists and build it if
required.

## `recreate()` the capsule

You've done some development work, updated a few dependencies, and the output
has tested successfully. You can make the capsule reflect the project dependencies
installed in your dev environment using `recreate()`.

## Other Useful Stuff

### Debugging in the capsule with a REPL

Try `capsule::repl()` to attach a REPL for a new R process in the context of the
capsule. This is handy for interactive work like debugging. The tradeoff here is
that depending what editor you use strange behaviour may be induced by the outer
REPL being overtaken. In ESS I loose my autocompletions.

### Helpers

* `capsule::delete()` - remove the local library and lockfile.
* `capsule::delete_local_lib()` - remove the local library.
* `capsule::delete_lockfile()` - remove the lockfile.
* `capsule::reproduce_lib()` - build the local library from the lockfile. 

### It's an `renv` in the end

A capsule is an `renv`. The full power of `renv` can always be used to
manipulate the lockfile and library if you wish.
