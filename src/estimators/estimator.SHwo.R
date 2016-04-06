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

source("src/estimators/splithalf.R")

precompute.SHwo <- function(X)
{
  return(splithalf.precompute(X, FALSE))
}

Etau.SHwo <- function(X, observations)
{
  return(splithalf.extrapolate(X, observations, 1))
}

EtauAP.SHwo <- function(X, observations)
{
  return(splithalf.extrapolate(X, observations, 2))
}
