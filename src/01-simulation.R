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

source("config/params.R")
source("src/common.R")

# CONFIG ###############################################################################################################

# Check command-line parameters
args <- commandArgs(trailingOnly = TRUE) # args <- c("adhoc6", 2, 100)
collection.name <- args[1]
batch.number <- as.integer(args[2])
batch.total <- as.integer(args[3])

collection.path <- file.path("data", paste0(collection.name,".csv"))

if(!file.exists(collection.path) || is.na(batch.number || is.na(batch.total))) {
  stop("usage: Rscript src/01-simulation.R <collection> <batch> <n_batches>\n")
}

# Check what trials this batch corresponds to
from.to <- batch.start.and.end(.N_TRIALS, batch.total, batch.number)
if(any(is.na(from.to)))
  q() # nothing to run

source("src/simulation.R")

# Prepare output directory
output.path <- file.path("scratch/01-simulation", collection.name)
dir.create(output.path, recursive = TRUE, showWarnings = FALSE)

# EXECUTION ############################################################################################################

# Read original collection
X <- as.matrix(read.csv(collection.path))
X <- dropWorstSystems(X)

# Configure simulation
cfg <- configure.simulation(X, normal = FALSE, homoscedastic = FALSE, uncorrelated = FALSE, random = TRUE)

# Output basic info
cat(output.path, ", trials = [", range(from.to), "]\n")
flush.console()

# Run trials
pb <- txtProgressBar(min = min(from.to), max = max(from.to), style = 3)
setTxtProgressBar(pb, 0)
for(trial in from.to) {
  set.seed(trial) # All simulations for each trial have the same seed across collections
  Y <- simulate.collection(cfg, .N_t_LARGE)

  write.csv(file = file.path(output.path, paste0(trial, ".csv")), row.names = FALSE, round(Y, 4))
  setTxtProgressBar(pb, trial)
} # trial
close(pb)
