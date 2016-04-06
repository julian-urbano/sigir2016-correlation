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

# CONFIG ###############################################################################################################

estimation.path <- file.path("scratch/11-estimation")
output.path <- "output/estimates"
dir.create(output.path, showWarnings = FALSE, recursive = TRUE)

# EXECUTION ############################################################################################################

estimator.names <- list.files(estimation.path)
collection.names <- list.files(file.path(estimation.path, estimator.names[1]))

for(measure.name in c("tau", "tauAP")) {
  res <- as.data.frame(matrix(NA, ncol = 4+length(estimator.names), nrow = length(collection.names) * .N_t * .N_TRIALS,
                              dimnames = list(NULL, c("collection", "n_t", "trial", "actual", estimator.names))))

  # Read from each estimator
  for(estimator.i in seq_along(estimator.names)) {
    estimator.name <- estimator.names[estimator.i]

    cat(measure.name, estimator.name, "\n")
    flush.console()

    # Initialize progress bar and read estimates from each batch (collection plus trial)
    pb <- txtProgressBar(min = 1, max = nrow(res), style = 3)
    setTxtProgressBar(pb, 0)

    i <- 1
    for(collection.name in collection.names) {
      for(trial in 1:.N_TRIALS){
        df <- read.csv(file.path(estimation.path, estimator.name, collection.name, measure.name, paste0(trial, ".csv")))
        df <- data.frame(collection = collection.name, df, stringsAsFactors = FALSE)

        res[1:nrow(df) +i-1, c(1:4, estimator.i+4)] <- df

        i <- i + nrow(df)
        setTxtProgressBar(pb, i)
      }
    }
    close(pb)
  }

  # Write results to disk
  write.csv(file = file.path(output.path, paste0(measure.name, ".csv")), row.names = FALSE, res)
}
