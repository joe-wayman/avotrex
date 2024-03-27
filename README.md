
# The ‘avotrex’ R package

[![CRAN
Downloads](http://cranlogs.r-pkg.org/badges/grand-total/avotrex)](https://cran.r-project.org/package=avotrex)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/avotrex)](https://cran.r-project.org/package=avotrex)
[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-yellow.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![CircleCI](https://circleci.com/gh/joe-wayman/avotrex/tree/main.svg?style=svg)](https://app.circleci.com/pipelines/github/joe-wayman/avotrex?branch=main)
[![Codecov test
coverage](https://codecov.io/gh/joe-wayman/avotrex/branch/main/graph/badge.svg)](https://app.codecov.io/gh/joe-wayman/avotrex?branch=main)

Repository for the avotrex R package.

The avotrex package provides functionality to graft extinct avian
species, present in the AvoTrex dataset, to existing BirdTree backbone
trees.

Note that the package imports and loads in the ‘ape’ R package in its
entirety, as this provides access to its full range of classes and
functions.

As this is version 1.0.0 of the package, it is possible that there are
some bugs in places. Please report any issues to us via GitHub.

## Installation

You can install the released version of avotrex from CRAN with:

And the development version from GitHub.

## Example usage

library(avotrex)

data(BirdTree_trees) \# Load in the example trees data(BirdTree_tax) \#
Load in the extant BirdTree taxonomy data(AvotrexPhylo) \# Load in the
extinct grafting database and instructions

trees \<- AvoPhylo(ctrees = Trees, avotrex = AvotrexPhylo, PER = 0.2,
tax = tax, Ntree = 1, n.cores = 1, cluster.ips = NULL)
