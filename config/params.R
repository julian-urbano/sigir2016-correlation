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

# Topic set sizes to estimate tau and tauAP
.N_t <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)

# Number of trials
.N_TRIALS <- 1000

# Number of topics to create per larger collection. Instead of creating '.N_TRIALS' collections of sizes 10, 20, 30, ...
# each, we create '.N_TRIALS' large collections of size '.N_t_LARGE', and them sample 10, 20, 30,... from it. It's just
# easier on the disk.
.N_t_LARGE <- 1000

