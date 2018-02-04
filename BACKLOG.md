# cachefun 0.1.0

* Carefully think about default setting of `refresh`. 

  Really depends on the most frequent use case: avoid unnecessary re-executions of long-running functions (probably mostly linked to data I/O and data wrangling) or avoid confusion through forgetting to refresh cached results.
  
  It's probably best to go with `refresh = TRUE` here.
  
* Is context information via `.verbose` really that relevant? 

  Adds clarity, but hurts performance and I don't like the current implementation of `.verbose` in the  `shiny::reactive`.
  
* Find out what's best practice regarding setting defaults arg values in inner function returned by `cafun_create`

* Understand **where** the cached information is actually stored and how it can be purged (to allow explicit purges/removals like via `rm`)
