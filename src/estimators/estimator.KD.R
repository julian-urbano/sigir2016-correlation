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

library(ks)
source("src/estimators/Ecorrelation.R")
source("src/estimators/estimator.ML.R")

precompute.KD <- function(X, samples = 1000)
{
  X <- X[, order(colMeans(X), decreasing = TRUE)]
  n_s <- ncol(X)
  n_t <- nrow(X)

  Pd <- matrix(NA, ncol = n_s, nrow = n_s)

  for(i in 1:(n_s-1)) {
    for(j in (i+1):n_s) {
      D <- X[,i] - X[,j]

      F.hat <- NULL
      try(F.hat <- kde(D, xmin = -1, xmax = 1), silent = FALSE)

      if(is.null(F.hat)) { # couldn't fit kernel; do ML
        mu.hat <- mean(D)
        sd.hat <- sd(D) * c4(n_t)

        Pd[i,j] <- pt(-mu.hat / sd.hat * sqrt(n_t), df = n_t - 1)
      } else {
        # Instead of making several small samples, make just a big one and split it (it's faster)
        D.star <- rkde(n_t * samples, F.hat)

        p <- 0
        for(trial in 1:samples) {
          from <- (trial-1) * n_t + 1
          to <- from + n_t - 1
          mu.star <- mean(D.star[from:to])

          if(mu.star < 0)
            p <- p + 1
        }

        Pd[i,j] <- p / samples
      }
    }
  }

  return(Pd)
}

Etau.KD <- function(X, Pd)
{
  return(Etau(Pd))
}

EtauAP.KD <- function(X, Pd)
{
  return(EtauAP(Pd))
}
