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

source("src/estimators/Ecorrelation.R")

# c4 factor to compute ubiased estimate of sd
c4 <- function(n, maxn = 250)
{
  if(n > maxn)
    return(1)

  return(sqrt((n-1)/2) * gamma((n-1)/2)/gamma(n/2))
}

precompute.ML <- function(X)
{
  X <- X[, order(colMeans(X), decreasing = TRUE)]
  n_s <- ncol(X)
  n_t <- nrow(X)

  Pd <- matrix(NA, ncol = n_s, nrow = n_s)

  for(i in 1:(n_s-1)) {
    for(j in (i+1):n_s) {
      D <- X[,i] - X[,j]

      mu.hat <- mean(D)
      sd.hat <- sd(D) * c4(n_t)

      Pd[i,j] <- pt(-mu.hat / sd.hat * sqrt(n_t), df = n_t - 1)
    }
  }

  return(Pd)
}

Etau.ML <- function(X, Pd)
{
  return(Etau(Pd))
}

EtauAP.ML <- function(X, Pd)
{
  return(EtauAP(Pd))
}
