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

erf.inv <- function(p)
{
  return(qnorm((p+1)/2) / sqrt(2))
}

precompute.MSQD <- function(X)
{
  X <- X[, order(colMeans(X), decreasing = TRUE)]
  n_s <- ncol(X)
  n_t <- nrow(X)

  Pd <- matrix(NA, ncol = n_s, nrow = n_s)

  for(i in 1:(n_s-1)) {
    for(j in (i+1):n_s) {
      D <- X[,i] - X[,j]

      mu.hat <- mean(D)
      D.star <- rank(D)
      e <- erf.inv(2*D.star / (n_t+1) -1)
      sd.hat <- sqrt(2) * sum(D * e) / 2 / sum(e^2)

      Pd[i,j] <- pt(-mu.hat / sd.hat * sqrt(n_t), df = n_t - 1)
    }
  }

  return(Pd)
}

Etau.MSQD <- function(X, Pd)
{
  return(Etau(Pd))
}

EtauAP.MSQD <- function(X, Pd)
{
  return(EtauAP(Pd))
}
