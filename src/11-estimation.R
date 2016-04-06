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
args <- commandArgs(trailingOnly = TRUE) # args <- c("adhoc6", "ML", 1, 1000)
collection.name <- args[1]
estimator.name <- args[2]
batch.number <- as.integer(args[3])
batch.total <- as.integer(args[4])

collection.path <- file.path("data", paste0(collection.name, ".csv"))
simulation.path <- file.path("scratch/01-simulation", collection.name)
estimator.path <- file.path("src/estimators", paste0("estimator.", estimator.name, ".R"))

if(!file.exists(collection.path) | !file.exists(simulation.path) | !file.exists(estimator.path) |
   is.na(batch.number) | is.na(batch.total)) {
  stop("usage: Rscript src/11-estimation.R <collection> <estimator> <batch> <n_batches>\n")
}

tasks <- expand.grid(n_t = .N_t, trial = 1:.N_TRIALS)
from.to <- batch.start.and.end(nrow(tasks), batch.total, batch.number)
if(any(is.na(from.to)))
  q() # nothing to run
tasks <- tasks[from.to,]

# Prepare output directory
output.path <- file.path("scratch/11-estimation", estimator.name, collection.name)
dir.create(file.path(output.path, "tau"), showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(output.path, "tauAP"), showWarnings = FALSE, recursive = TRUE)

# EXECUTION ############################################################################################################

source("src/correlation.R")
source(estimator.path)

estimator.precompute <- get(paste0("precompute.", estimator.name))
estimator.tau <- get(paste0("Etau.", estimator.name))
estimator.tauAP <- get(paste0("EtauAP.", estimator.name))

X <- as.matrix(read.csv(collection.path))
X <- dropWorstSystems(X)
X.mu <- colMeans(X)

# Output basic info and initialize structures and directories ==========================================================
cat(output.path, ": trials = [", range(from.to), "]\n")
flush.console()

# Create structures to hold results
res.tau <- res.tauAP <- data.frame(n_t = tasks$n_t, trial = tasks$trial, actual = NA, E = NA)

# Initialize progress bar and run trials in batch ======================================================================
pb <- txtProgressBar(min = 1, max = nrow(tasks), style = 3)
setTxtProgressBar(pb, 0)
for(trial.i in 1:nrow(res.tau)) {
  trial <- res.tau$trial[trial.i]
  n_t <- res.tau$n_t[trial.i]

  # Read simulated matrix and subset n_t topics
  Y <- as.matrix(read.csv(file.path(simulation.path, paste0(trial,".csv"))))
  set.seed(trial * n_t)
  Y <- Y[sample(1:nrow(Y), n_t), ]
  Y.mu <- colMeans(Y)

  # Compute actual correlations
  res.tau$actual[trial.i] <- tau(X.mu, Y.mu)
  res.tauAP$actual[trial.i] <- tauAP(X.mu, Y.mu)

  # Estimate correlations
  pre <- estimator.precompute(Y)
  res.tau$E[trial.i] <- estimator.tau(Y, pre)
  res.tauAP$E[trial.i] <- estimator.tauAP(Y, pre)

  setTxtProgressBar(pb, trial.i)
}
close(pb)

# Write results to disk ================================================================================================

write.csv(file = file.path(output.path, "tau", paste0(batch.number,".csv")), row.names = FALSE, round(res.tau, 6))
write.csv(file = file.path(output.path, "tauAP", paste0(batch.number,".csv")), row.names = FALSE, round(res.tauAP, 6))
