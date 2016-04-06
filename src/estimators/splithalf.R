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

source("src/correlation.R")

splithalf.precompute <- function(X, replacement, points = 20, maxObs = 2000, maxTrials = 100)
{
  maxx <- nrow(X)
  # Compute sizes of topic subsets. By default, run at 20 points between 2 and n_t/2
  at <- unique(round(seq(1, floor(maxx / 2), length.out = points +1)))[-1]
  # If that results in only one point, also compute at subset size of 1 (that should result in sizes 1 and 2)
  if(length(at) == 1)
    at <- c(1, at)
  # By default, run at most 2000 times, and at most 200 trials per subset size.
  trials <- min(maxTrials, floor(maxObs / length(at)))

  # Split-half
  observations <- matrix(0, ncol = 3, nrow = length(at)*trials) # x tau tauAP
  for(i in seq_along(at)) {
    y <- replicate(trials, {
      x <- at[i] # subset size
      if(replacement) {
        x1 <- sample(1:maxx, x, replace = TRUE) # topic ID for subset 1
        x2 <- sample(1:maxx, x, replace = TRUE) # topic ID for subset 2
      } else {
        x1 <- sample(1:maxx, x) # topic ID for subset 1
        x2 <- sample((1:maxx)[-x1], x) # topic ID for subset 2
      }
      mu <- colMeans(X[x1,, drop = FALSE]) # drop=FALSE to avoid turning matrix into vector for subset size of 1
      mu.hat <- colMeans(X[x2,, drop = FALSE])

      res <- c(tau(mu, mu.hat), tauAP(mu, mu.hat))
      return(res)
    })
    observations[(i-1)*trials + 1:trials,] <- cbind(at[i], t(y))
  }
  observations <- observations[complete.cases(observations),]
  return(observations)
}

splithalf.extrapolate <- function(X, observations, index = 1)
  # index = 2 for tau, or 2 for tauAP
{
  x <- observations[,1]
  y <- 1- (observations[,index+1]+1)/2
  m <- lm(ly ~ x, data = list(ly = log(y), x = x), subset = !is.infinite(ly))

  p <- predict(m, newdata = list(x = nrow(X)))
  E <- 1 - 2 * pmax(0, pmin(1, exp(p))) # Since we fitted upside down, reverse and go back to [-1,1]

  return(E)
}
