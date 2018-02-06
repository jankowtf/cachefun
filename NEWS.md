# cachefun 0.1.0

* Initial version

# cachefun 0.1.1

* Variable default settings
* Reset of internal cache

# cachefun 0.1.2

* Decision on default value of `refresh` in `cafun_create`: it will be `TRUE`

  I think **not** wanting to cache something but instead expecting your cache-aware functions to behave just as "regular" R functions is by far the more typical use case.
  
* Example updated (`inst/examples/ex-cafun_main.R`)

* Update `README.md`
    * Added description and intro text
    * Added example from `inst/examples/ex-cafun_main.R` 

# cachefun 0.1.3

* Implemented observable dependencies (see arg `observes` in `cafun_create`)

# cachefun 0.1.4

* Major changes:
    * Renamed: `cachefun_create` to `caf_create`, `cachefun_reset_cache`  to `caf_reset`.
    * Renamed: distinguish "meta args"" of `caf_create` more explicitly from those of the actual cafuns create by it. Also, probably a good idea to follow the example of `{plyr}` to start meta args with a dot (`.refresh`, `.verbose`).
    * Meta args also aligned in `caf_refresh`.
    * Added `{shiny}` to `Imports`
* Minor changes:
    * Test updated: `test-cafun_main.R` to account for changes.
    * Test added: `test-cafun_main.R:20180205-1`
    * Corrected some minor errors in `inst/examples/ex-cachefun_main.R`.
    * Moved old code for `caf_create` to `R/_scripts/keep_as_reference`.
    * Started to assign explicit IDs to backlog items for easier referencing (see `BACKLOG.md`). The challenge here will be to keep track of the auto-increment state ;-) Think about this a bit more - especially regarding how to leverage/integrate with GitHub issue and labeling system.
    * Updated `README.md`

# cachefun 0.1.5

* Major changes:
    * Improved leveraging of `{shiny}`reactivity (made sure that cache results are automatically invalidated if cache value of dependency changes)
    * Changed argument value in `caf_create`: `observes` is a simple list now
    * Reactive context automatically added behind the scene in `caf_create` if `observes` is supplied (`fun` is wrapped by `reactive`)
    * Added test: 20180206-1 (reactive invalidation) 
* Minor changes:
    * Updated example: inst/examples/ex-cafun_main.R
    * Updated README

# cachefun 0.1.6

* Major changes:
    * Changed argument: `cafun` to `caf` in `caf_reset`
* Minar changes:
    * Changed all occurences of `cafun` to `caf` to make things more concise and consistent

# cachefun 0.1.7

* Major changes:
    * Reactive dependencies (i.e. other *caf*s) can now simply be defined as formal arguments of the inner function. Backend code for handling reactive dependencies has also been consolidated in `caf_create`
    * Three dot argument has been moved up both for `caf_create` and the *caf* created by `caf_create` in order to allow the correct handling of unnamed argument specification when calling the resulting *caf*. This should also make everything play nicely with the tidyverse approach.
* Minor changes:
    * Dropped verbose argument(s) (`.verbose` and `.verbose_default`) as I think one can do without them and they just cost compute time.
    * Modified tests in `test-caf_main.R` to reflect changes.
    * Modified examples in `ex-caf_main.R` to reflect changes.
