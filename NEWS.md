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
