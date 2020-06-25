
<!-- README.md is generated from README.Rmd. Please edit that file -->

# znktest

<!-- badges: start -->

[![R build
status](https://github.com/zkamvar/znksillysnail/workflows/R-CMD-check/badge.svg)](https://github.com/zkamvar/znksillysnail/actions)
<!-- badges: end -->

This package documents a strange behavior between {reticulate}, {knitr},
{withr}, and {testthat}.

I was testing [{dovetail}](https://github.com/carpentries/dovetail) and
noticed that there were issues in accessing `reticulate::py` in a knitr
document rendered within a test loaded in an interactive environment.
This package is an attempt at a reprex.

## The setup

I wanted to test knitting a document using relative paths, so I did the
following:

1.  set up temporary directory and populate with two folders, one for
    input, one for output. This directory would be cleaned up when it’s
    parent process (the test) finished.
2.  symlinked/copied the test rmd document into the input folder
3.  use `withr::with_dir()` to test knitting the relative path of the
    input to the relative path of the output.

The above steps are wrapped in two helper functions in
`testthat/tests/helper-funs.R`: `provision_jekyll()` and
`knit_jekyll()`.

The Rmarkdown document loaded {reticulate}, assigned a variable with a
python chunk, shows that variable in both an R chunk and inline chunk.

## The problem

This process errors when the package is loaded with devtools:

``` r
devtools::load_all()
#> Loading znksillysnail
py1 <- provision_jekyll("simple-python.Rmd")
#> Setting deferred event(s) on global environment.
#>   * Execute (and clear) with `deferred_run()`.
#>   * Clear (without executing) with `deferred_clear()`.
knit_jekyll(py1)
#> 
#> 
#> processing file: _episodes_rmd/simple-python.Rmd
#>   |                                                                                                                 |                                                                                                         |   0%  |                                                                                                                 |...............                                                                                          |  14%
#>   ordinary text without R code
#> 
#>   |                                                                                                                 |..............................                                                                           |  29%
#> label: setup (with options) 
#> List of 1
#>  $ include: logi FALSE
#> 
#>   |                                                                                                                 |.............................................                                                            |  43%
#>   ordinary text without R code
#> 
#>   |                                                                                                                 |............................................................                                             |  57%
#> label: punk (with options) 
#> List of 1
#>  $ engine: chr "python"
#> 
#>   |                                                                                                                 |...........................................................................                              |  71%
#>   ordinary text without R code
#> 
#>   |                                                                                                                 |..........................................................................................               |  86%
#> label: envir
#> <environment: 0x68ac9c0>
#>   |                                                                                                                 |.........................................................................................................| 100%
#>    inline R code fragments
#> <environment: 0x68ac9c0>
#> Quitting from lines 25-31 (_episodes_rmd/simple-python.Rmd)
#> Error in eval(parse_only(code), envir = envir): object 'py' not found
```

-----

When the test helpers a loaded without devtools, they work okay.

``` r
withr::deferred_run()
source("tests/testthat/helper-funs.R")
py1 <- provision_jekyll("simple-python.Rmd")
#> Setting deferred event(s) on global environment.
#>   * Execute (and clear) with `deferred_run()`.
#>   * Clear (without executing) with `deferred_clear()`.
py1
#> [1] "/tmp/Rtmpl1wCSv/DIR38b7156ea765"
```

``` r
cat(readLines(knit_jekyll(py1)), sep = "\n")


processing file: _episodes_rmd/simple-python.Rmd
  |                                                                                                                 |                                                                                                         |   0%  |                                                                                                                 |...............                                                                                          |  14%
  ordinary text without R code

  |                                                                                                                 |..............................                                                                           |  29%
label: setup (with options) 
List of 1
 $ include: logi FALSE

  |                                                                                                                 |.............................................                                                            |  43%
  ordinary text without R code

  |                                                                                                                 |............................................................                                             |  57%
label: punk (with options) 
List of 1
 $ engine: chr "python"

  |                                                                                                                 |...........................................................................                              |  71%
  ordinary text without R code

  |                                                                                                                 |..........................................................................................               |  86%
label: envir
<environment: 0x8a67340>
  |                                                                                                                 |.........................................................................................................| 100%
   inline R code fragments
<environment: 0x8a67340>
output file: _episodes/simple-python.md
```

```` 
---
title: test
---



## Some python code

```python
x = 'This is' + ' some text'
```


## R environment and trace back

```r
py$x
#> [1] "This is some text"
message(capture.output(environment()))
rlang::trace_back()
#>      █
#>   1. ├─rmarkdown::render("README.Rmd")
#>   2. │ └─knitr::knit(knit_input, knit_output, envir = envir, quiet = quiet)
#>   3. │   └─knitr:::process_file(text, output)
#>   4. │     ├─base::withCallingHandlers(...)
#>   5. │     ├─knitr:::process_group(group)
#>   6. │     └─knitr:::process_group.block(group)
#>   7. │       └─knitr:::call_block(x)
#>   8. │         └─knitr:::block_exec(params)
#>   9. │           ├─knitr:::in_dir(...)
#>  10. │           └─knitr:::evaluate(...)
#>  11. │             └─evaluate::evaluate(...)
#>  12. │               └─evaluate:::evaluate_call(...)
#>  13. │                 ├─evaluate:::timing_fn(...)
#>  14. │                 ├─evaluate:::handle(...)
#>  15. │                 │ └─base::try(f, silent = TRUE)
#>  16. │                 │   └─base::tryCatch(...)
#>  17. │                 │     └─base:::tryCatchList(expr, classes, parentenv, handlers)
#>  18. │                 │       └─base:::tryCatchOne(expr, names, parentenv, handlers[[1L]])
#>  19. │                 │         └─base:::doTryCatch(return(expr), name, parentenv, handler)
#>  20. │                 ├─base::withCallingHandlers(...)
#>  21. │                 ├─base::withVisible(eval(expr, envir, enclos))
#>  22. │                 └─base::eval(expr, envir, enclos)
#>  23. │                   └─base::eval(expr, envir, enclos)
#>  24. ├─base::cat(readLines(knit_jekyll(py1)), sep = "\n")
#>  25. ├─base::readLines(knit_jekyll(py1))
#>  26. └─global::knit_jekyll(py1)
#>  27.   ├─withr::with_dir(...)
#>  28.   │ └─base::force(code)
#>  29.   └─knitr::knit(...)
#>  30.     └─knitr:::process_file(text, output)
#>  31.       ├─base::withCallingHandlers(...)
#>  32.       ├─knitr:::process_group(group)
#>  33.       └─knitr:::process_group.block(group)
#>  34.         └─knitr:::call_block(x)
#>  35.           └─knitr:::block_exec(params)
#>  36.             ├─knitr:::in_dir(...)
#>  37.             └─knitr:::evaluate(...)
#>  38.               └─evaluate::evaluate(...)
#>  39.                 └─evaluate:::evaluate_call(...)
#>  40.                   ├─evaluate:::timing_fn(...)
#>  41.                   ├─evaluate:::handle(...)
#>  42.                   │ └─base::try(f, silent = TRUE)
#>  43.                   │   └─base::tryCatch(...)
#>  44.                   │     └─base:::tryCatchList(expr, classes, parentenv, handlers)
#>  45.                   │       └─base:::tryCatchOne(expr, names, parentenv, handlers[[1L]])
#>  46.                   │         └─base:::doTryCatch(return(expr), name, parentenv, handler)
#>  47.                   ├─base::withCallingHandlers(...)
#>  48.                   ├─base::withVisible(eval(expr, envir, enclos))
#>  49.                   └─base::eval(expr, envir, enclos)
#>  50.                     └─base::eval(expr, envir, enclos)
```

## Inline R code

     █ 
,   1. ├─rmarkdown::render("README.Rmd") 
,   2. │ └─knitr::knit(knit_input, knit_output, envir = envir, quiet = quiet) 
,   3. │   └─knitr:::process_file(text, output) 
,   4. │     ├─base::withCallingHandlers(...) 
,   5. │     ├─knitr:::process_group(group) 
,   6. │     └─knitr:::process_group.block(group) 
,   7. │       └─knitr:::call_block(x) 
,   8. │         └─knitr:::block_exec(params) 
,   9. │           ├─knitr:::in_dir(...) 
,  10. │           └─knitr:::evaluate(...) 
,  11. │             └─evaluate::evaluate(...) 
,  12. │               └─evaluate:::evaluate_call(...) 
,  13. │                 ├─evaluate:::timing_fn(...) 
,  14. │                 ├─evaluate:::handle(...) 
,  15. │                 │ └─base::try(f, silent = TRUE) 
,  16. │                 │   └─base::tryCatch(...) 
,  17. │                 │     └─base:::tryCatchList(expr, classes, parentenv, handlers) 
,  18. │                 │       └─base:::tryCatchOne(expr, names, parentenv, handlers[[1L]]) 
,  19. │                 │         └─base:::doTryCatch(return(expr), name, parentenv, handler) 
,  20. │                 ├─base::withCallingHandlers(...) 
,  21. │                 ├─base::withVisible(eval(expr, envir, enclos)) 
,  22. │                 └─base::eval(expr, envir, enclos) 
,  23. │                   └─base::eval(expr, envir, enclos) 
,  24. ├─base::cat(readLines(knit_jekyll(py1)), sep = "\n") 
,  25. ├─base::readLines(knit_jekyll(py1)) 
,  26. └─global::knit_jekyll(py1) 
,  27.   ├─withr::with_dir(...) 
,  28.   │ └─base::force(code) 
,  29.   └─knitr::knit(...) 
,  30.     └─knitr:::process_file(text, output) 
,  31.       ├─base::withCallingHandlers(...) 
,  32.       ├─knitr:::process_group(group) 
,  33.       └─knitr:::process_group.inline(group) 
,  34.         └─knitr:::call_inline(x) 
,  35.           ├─knitr:::in_dir(input_dir(), inline_exec(block)) 
,  36.           └─knitr:::inline_exec(block) 
,  37.             └─knitr:::hook_eval(code[i], envir) 
,  38.               ├─base::withVisible(eval(parse_only(code), envir = envir)) 
,  39.               └─base::eval(parse_only(code), envir = envir) 
,  40.                 └─base::eval(parse_only(code), envir = envir) 
 
This is some text

 
````
