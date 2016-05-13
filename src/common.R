# Copyright (C) 2016  Julián Urbano <urbano.julian@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.

# This overrides the 'library' function so that R packages can be loaded completely silently.
# This can be very useful when checking output files looking for errors.
# If you do want to show warnings and other messages when loading packages, set .SILENT_LIBRARY <- FALSE.
.SILENT_LIBRARY <- TRUE
library <- function(package)
{
  expr <- substitute(base::library(pkg), list(pkg = substitute(package)))
  if(.SILENT_LIBRARY) {
    suppressMessages(suppressWarnings(eval(expr)))
  }else{
    eval(expr)
  }
}

# Remove the 'bottom' percent of systems from the topic-by-system matrix 'X'.
dropWorstSystems <- function(X, bottom = 0.25)
{
  sysmeans <- colMeans(X)
  return(X[,sysmeans >= quantile(sysmeans, bottom)])
}

# Given a set of 'n_t' tasks to be executed in 'n_b' batches, get the task indexes of batch 'i'.
# If no tasks are to be executed for this batch (when there are more batches than tasks), return NA.
batch.start.and.end <- function(n_t, n_b, i)
{
  t.per.b <- n_t / n_b

  starts <- unique(round((0:n_b) * t.per.b) +1)

  if(i >= length(starts))
    return(NA)
  else
    return(seq(starts[i], starts[i +1] -1))
}
