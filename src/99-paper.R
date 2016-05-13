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

# PLOT DEFINITIONS #####################################################################################################

my.dev.pdf <- function(num, ratio=.82, file, ...){
  width <- my.dev.width(num)
  height <- width*ratio
  pdf(file=file, width=width, height=height)
  my.dev.par(...)
}
my.dev.win <- function(num, ratio=.82, file, ...){
  width <- my.dev.width(num)
  height <- width*ratio
  dev.new(width=width, height=height)
  my.dev.par(...)
}
my.dev.width <- function(num=1){
  ret = 8;
  if(num != 1) ret = 11 / num
  return(ret)
}
# change default plot margins
my.dev.par <- function(mar=c(3.1,2.9,2,0.2), mgp=c(1.9,.7,0), ...){
  par(mar=mar, mgp=mgp, ...)
}
my.dev.abline <- function(col="darkgrey", lwd=1, lty=2, ...){
  abline(col=col, lwd=lwd, lty=lty, ...)
}
my.dev.new <- my.dev.pdf; my.dev.off <- function(...) { off <- capture.output(dev.off(...)) }
#my.dev.new <- my.dev.win; my.dev.off <- function(){}

# FIGURE 1 (Error) #####################################################################################################

for(measure.name in c("tau", "tauAP")) {
  df <- read.csv(paste0("output/estimates/", measure.name, ".csv"))
  for(collection in unique(df$collection)) {
    df2 <- df[df$collection == collection,]

    my.dev.new(file = paste0("output/paper/error-", measure.name, "-", collection, ".pdf"), num = 3)
    plot(NA, xlim = range(.N_t), ylim = c(0.02, .1), main = paste(measure.name, "-", collection),
         xlab = "topic set size", ylab = "Error", yaxs = "i", xaxt = "n")
    axis(1, .N_t, las = 3)

    lines(aggregate(I(abs(ML-actual))~n_t, df2, mean), col = "black")
    lines(aggregate(I(abs(MSQD-actual))~n_t, df2, mean), col = "red")
    lines(aggregate(I(abs(RES-actual))~n_t, df2, mean), col = "blue")
    lines(aggregate(I(abs(KD-actual))~n_t, df2, mean), col = "green")
    lines(aggregate(I(abs(SHwo-actual))~n_t, df2, mean), col = "cyan", lty = 1)
    lines(aggregate(I(abs(SHw-actual))~n_t, df2, mean), col = "cyan", lty = 2)

    if(measure.name == "tau" && collection == df$collection[1]) {
      # We have to tweak the legend to make it fit
      rect(xleft = 26, ybottom = .079, xright = 110, ytop = .1, col = "white")
      legend("topright", legend = c("ML", "MSQD", "RES", "KD", "SH(w/o)", "SH(w)"), ncol = 3, bty = "n",
             col = c("black", "red", "blue", "green", "cyan", "cyan"), lty=c(1,1,1,1,1,2), lwd = 1,
             x.intersp = .3, seg.len = 1.5, text.width = c(12,12,12,12,16,16)+.5)
      box()
    }
    my.dev.off()
  }
}

# FIGURE 2 (Bias) ######################################################################################################

for(measure.name in c("tau", "tauAP")) {
  df <- read.csv(paste0("output/estimates/", measure.name, ".csv"))
  for(collection in unique(df$collection)) {
    df2 <- df[df$collection == collection,]

    my.dev.new(file = paste0("output/paper/bias-", measure.name, "-", collection, ".pdf"), num = 3)
    plot(NA, xlim = range(.N_t), ylim = c(-.01, .08), main = paste(measure.name, "-", collection),
         xlab = "topic set size", ylab = "Bias", yaxs = "i", xaxt = "n")
    axis(1, .N_t, las = 3)
    abline(h = 0, col = "grey")

    lines(aggregate(I(ML-actual)~n_t, df2, mean), col = "black")
    lines(aggregate(I(MSQD-actual)~n_t, df2, mean), col = "red")
    lines(aggregate(I(RES-actual)~n_t, df2, mean), col = "blue")
    lines(aggregate(I(KD-actual)~n_t, df2, mean), col = "green")
    lines(aggregate(I(SHwo-actual)~n_t, df2, mean), col = "cyan", lty = 1)
    lines(aggregate(I(SHw-actual)~n_t, df2, mean), col = "cyan", lty = 2)

    if(measure.name == "tau" && collection == df$collection[1]) {
      # We have to tweak the legend to make it fit
      rect(xleft = 26, ybottom = .056, xright = 110, ytop = .1, col = "white")
      legend("topright", legend = c("ML", "MSQD", "RES", "KD", "SH(w/o)", "SH(w)"), ncol = 3, bty = "n",
             col = c("black", "red", "blue", "green", "cyan", "cyan"), lty=c(1,1,1,1,1,2), lwd = 1,
             x.intersp = .3, seg.len = 1.5, text.width = c(12,12,12,12,16,16)+.5)
      box()
    }
    my.dev.off()
  }
}
