
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pivotr

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/ismailmuller/pivotr/branch/master/graph/badge.svg)](https://codecov.io/gh/ismailmuller/pivotr?branch=master)
[![Lifecycle
Status](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.com/ismailmuller/pivotr.svg?branch=master)](https://travis-ci.com/ismailmuller/pivotr)
<!-- badges: end -->

The goal of pivotr is to compute pivot tables by using the `tidyverse`
syntax.

## Installation

You can install the development version from
[GitHub](https://github.com/ismailmuller/pivotr) with:

``` r
# install.packages("devtools")
devtools::install_github("ismailmuller/pivotr")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(pivotr)

pvt(mtcars, cyl, am, N = n())
#> # A tibble: 4 x 4
#>   cyl     `0`   `1` Total
#>   <chr> <int> <int> <int>
#> 1 4         3     8    11
#> 2 6         4     3     7
#> 3 8        12     2    14
#> 4 Total    19    13    32
```
