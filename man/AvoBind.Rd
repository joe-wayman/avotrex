% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AvoBind.R
\name{AvoBind}
\alias{AvoBind}
\title{AvoBind - Bind extinct species to the tree}
\usage{
AvoBind(tree, node, per, per_fixed = FALSE, sp_name)
}
\arguments{
\item{tree}{Tree object (i.e., phylogeny)}

\item{node}{Target node}

\item{per}{The fraction (0-1) of total branch length to truncate at either
end of the branch for grafting (e.g. 0.2 cuts of 20\% of the total branch
length from either end) if \code{per_fixed == FALSE}. If \code{per_fixed
== TRUE}, then the point along the branch where the grafting occurs: value
between 0-1, with a larger number meaning the grafting occurs closer to the
rootward end of the branch}

\item{per_fixed}{Logical argument: whether to graft a species on at an exact
point along a branch (TRUE), which is chosen using the \code{per} argument,
rather than random (FALSE; default)}

\item{sp_name}{Name of the grafted species}
}
\description{
Binds an extinct species at a randomly selected
point along a branch, after truncating either end.
}
