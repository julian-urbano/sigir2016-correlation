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

Etau <- function(swap.estimates)
{
  n <- ncol(swap.estimates) # number of systems
  nn <- n*(n-1)/2 # number of pairs

  # No need to iterate each pair of systems
  # Simply sum the matrix's elements to get overall probability of discordance.
  E <- sum(swap.estimates, na.rm = TRUE)
  E <- 1 - 2 * E / nn

  return(E)
}

EtauAP <- function(swap.estimates)
{
  n <- ncol(swap.estimates) # number of systems

  # No need to iterate each pair of systems.
  # Simply sum the matrix's column-wise means to get overall probability of discordance.
  E <- sum((colSums(swap.estimates, na.rm = TRUE) / (1:n-1))[-1])
  E <- 1 - 2 * E / (n-1)

  return(E)
}
