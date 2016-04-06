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

tau <- function(mu, mu.hat)
{
  n <- length(mu) # number of systems
  nn <- n*(n-1)/2 # number of pairs

  nd <- 0 # number of discordants
  for(i in 1:(n-1)) {
    for(j in (i+1):n) {
      s <- sign(mu[i] - mu[j])
      s.hat <- sign(mu.hat[i] - mu.hat[j])

      if(s * s.hat < 0)
        nd <- nd + 1
    }
  }
  return(1 - 2*nd/nn)
}

tauAP <- function(mu, mu.hat)
{
  n <- length(mu) # number of systems

  mu.order <- order(mu, decreasing = TRUE)
  mu.hat.order <- order(mu.hat, decreasing = TRUE)

  p <- 0
  for(i in 2:n) {
    id_i <- mu.hat.order[i]
    mu.hat.above <- mu.hat.order[1:i] # include i-th system, so we don't have to take care of the case i=1
    mu.above <- mu.order[1:which(mu.order == id_i)]
    C_i <- sum(mu.hat.above %in% mu.above) -1 # -1 to remove the i-th included above
    p <- p + C_i / (i-1)
  }
  return(2*p/(n-1) -1)
}
