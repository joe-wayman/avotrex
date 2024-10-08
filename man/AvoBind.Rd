% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AvoBind.R
\name{AvoBind}
\alias{AvoBind}
\title{AvoBind - Bind extinct species to the tree}
\usage{
AvoBind(tree, node, per, per_fixed = FALSE, sp_name,
 time_graft = FALSE, terminal = FALSE, mindist = 0.1)
}
\arguments{
\item{tree}{Tree object (i.e., phylogeny)}

\item{node}{Target node}

\item{per}{The fraction (0 to a max value of 0.5) of total
branch length to truncate at either end of the branch for
grafting (e.g. 0.2 cuts of 20\% of the total branch
length from either end) if \code{per_fixed == FALSE}. If \code{per_fixed
== TRUE}, then the point along the branch where the grafting occurs: value
between 0-1, with a larger number meaning the grafting
occurs closer to the rootward end of the branch. If
\code{time_graft = TRUE}, the specific point (in millions of
years, if BirdTree trees are used) for the grafting to
occur.}

\item{per_fixed}{Logical argument: whether to graft a species on at an exact
point (as a fraction) along a branch (TRUE), which is chosen using the
\code{per} argument, rather than random (FALSE; default). Is ignored if
\code{time_graft = TRUE}.}

\item{sp_name}{Name of the grafted species.}

\item{time_graft}{Should the grafting occur at a particular time point (in
millions of years if BirdTree trees provided) along a given branch, using
\code{avotrex:::AgeBind()}. The specific point is provided using the
\code{per} argument.}

\item{terminal}{Logical value: if \code{time_graft = TRUE}, is the species
being grafted to a terminal branch.}

\item{mindist}{If \code{time_graft = TRUE}, but the provided grafting time
point (\code{per}) is too old (i.e., older than the parent node) or too
young (i.e., younger than the child node) relative to the focal branch,
grafting will occur \code{mindist} below the parent node or above the child
node.}
}
\value{
Returns a tree of class "phylo", with the extinct species grafted on.
}
\description{
Binds an extinct species at either (1) a randomly selected point
  along a branch, after truncating either end, (2) a specific fraction along
  a branch, or (3) a specific time point along a branch.
}
\author{
Joe Wayman, Tom Matthews and Pedro Cardoso (AgeBind)
}
