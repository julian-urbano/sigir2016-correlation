# Copyright (C) 2015-2016  Julián Urbano <urbano.julian@gmail.com>
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

# NOTE: this file is adapted from https://raw.githubusercontent.com/julian-urbano/irj2015-reliability/9d33236efa413232d1999cf91553a51c7b741886/src/simulation.R

library(ks) # To estimate pdfs
library(Matrix) # To improve Cholesky decomposition

# Logits ===============================================================================================================

logit <- function(p, a = .05)
  # a : parameter to smooth at 0 and 1
{
  return(log((p+a) / (1-p+a)))
}
invlogit <- function(p, a = .05)
  # a : parameter to smooth at 0 and 1
{
  ep <- exp(p)
  ep <- (ep+a*ep-a) / (1+ep)
  ep[ep > 1] <- 1
  ep[ep < 0] <- 0
  return(ep)
}

# Effect decomposition and estimation of distribution functions ========================================================

## Decompose a topic-by-system effectiveness matrix according to the model
##   x_st = mu + nu_s + nu_t + e_ts
decompose.effects <- function(X)
{
  if(is.data.frame(X))
    X <- as.matrix(X)

  mu <- mean(X) # true system mean scores
  NU_s <- colMeans(X) - mu # true system effects
  NU_t <- rowMeans(X) - mu # topic effects
  E <- X - matrix(nrow = nrow(X),
                  mu
                  + rep(NU_s, each = nrow(X))
                  + NU_t) # residuals matrix

  return(list(mu = mu, NU_s = NU_s, NU_t = NU_t, E = E))
}

## Kernel estimation of CDF with support [xmin,xmax]
estimate.cdf <- function(x, xmin = min(x), xmax = max(x))
{
  # Estimate CDF and approximate it
  cdf <- kcde(x, xmin = xmin, xmax = xmax)
  cdf <- approxfun(cdf$eval.points, cdf$estimate, yleft = 0, yright = 1)
  return(cdf)
}
## Kernel estimation of iCDF
estimate.icdf <- function(x, xmin = min(x), xmax = max(x))
{
  # Estimate CDF and approximate it
  cdf <- kcde(x, xmin = xmin, xmax = xmax)
  cdf <- approxfun(cdf$eval.points, cdf$estimate, yleft = 0, yright = 1)
  # Wrap inverse CDF
  icdf <- function(p) {
    sapply(p, function(p2) {
      # Prevent uniroot from raising error at extreme values
      p2 <- round(p2, 5)
      if(p2 <= 0) return(xmin)
      if(p2 >= 1) return(xmax)
      # Solve the CDF for the given probability
      uniroot(function(t) { cdf(t)-p2 }, interval = c(xmin, xmax))$root
    })
  }
  return(icdf)
}

# Configuration and Simulation =========================================================================================

## Analyze an existing collection and return an object to configure the simulation.
##
## The returned object contains the effect decomposition of the original data, the kernel-density estimated distribution
## functions of the residuals and topic effects, the covariance matrix and its Cholesky decompositioin. Appropriate
## transformations are applied according to the assumptions.
configure.simulation <- function(X, normal = FALSE, homoscedastic = FALSE, uncorrelated = FALSE, random = TRUE)
{
  if(is.data.frame(X))
    X <- as.matrix(X)

  # min and max effect score, to use later on when estimating distribution functions
  xmin <- -1
  xmax <- 1
  # If not Normal assumption, transform to logit and update xmin and xmax
  if(normal == FALSE) {
    X <- logit(X)
    xmin <- -2*logit(1)
    xmax <- 2*logit(1)
  }

  # Decompose effects
  dec <- decompose.effects(X)

  # If Homoscedastic assumption, standardize residuals with pooled variance
  if(homoscedastic == TRUE) {
    var_p <- mean(apply(dec$E, 2, var))
    dec$E <- apply(dec$E, 2, function(e) { e / sd(e) * sqrt(var_p)})
  }

  # Estimate CDF and iCDF of topic effects and residuals
  dec$cdf_t <- estimate.cdf(dec$NU_t, xmin = xmin, xmax = xmax)
  dec$icdf_t <- estimate.icdf(dec$NU_t, xmin = xmin, xmax = xmax)
  dec$CDF_e <- apply(dec$E, 2, function(e) estimate.cdf(e, xmin = min(xmin, min(e)), xmax = max(xmax, max(e))))
  dec$ICDF_e <- apply(dec$E, 2, function(e) estimate.icdf(e, xmin = min(xmin, min(e)), xmax = max(xmax, max(e))))

  # Append NU_t to E, and compute the covariance matrix to generate new variables with similar dependence structure
  dec$Sigma <- cov(cbind(dec$E, dec$NU_t))
  dec$Sigma <- as.matrix(nearPD(dec$Sigma)$mat) # compute the nearest positive definite matrix

  # If Uncorrelated assumption, set all off-diagonal covariances to 0
  if(uncorrelated == TRUE) {
    dec$Sigma <- diag(diag(dec$Sigma), ncol = ncol(dec$Sigma))
  }

  # Compute the Cholesky decomposition
  dec$C <- chol(dec$Sigma)

  dec$assumptions = list(normal = normal, homoscedastic = homoscedastic, uncorrelated = uncorrelated, random = random)
  return(dec)
}

## Simulate a new collection with n_t_ topics using the given configuration.
simulate.collection <- function(config, n_t_, min_n_t__ = 200, n_t__factor = 4)
  ## min_n_t__   : minimum number of topics to sample from when not assuming random sampling
  ## n_t__factor : factor of n_t_ to select a minimum of topics to sample from when not assuming random sampling
{
  n_s <- length(config$NU_s) # Number of systems

  # Generate a matrix of normal random vectors with the given covariance matrix
  # If not Random sampling assumption, generate many more random vectors, to select later on
  if(config$assumptions$random == FALSE) {
    R <- matrix(rnorm(ncol(config$Sigma) * max(min_n_t__, n_t_ * n_t__factor)), ncol = ncol(config$Sigma))
  } else {
    R <- matrix(rnorm(ncol(config$Sigma) * n_t_), ncol = ncol(config$Sigma))
  }
  R <- R %*% config$C

  # and transform their marginals to uniform with the normal CDF
  U <- matrix(0, ncol = ncol(R), nrow = nrow(R))
  for(i in 1:ncol(R))
    U[,i] <- pnorm(R[,i], sd = sqrt(config$Sigma[i,i]))

  # Use these uniforms and the estimated iCDFs to get our final random vectors
  Z <- matrix(NA, ncol = ncol(U), nrow = nrow(U))
  for(i in 1:(ncol(Z)-1)) { # skip last vector, which corresponds to NU_t
    # If Normal assumption, use normal marginal, or the estimated otherwise
    if(config$assumptions$normal == TRUE) {
      Z[,i] <- qnorm(U[,i], mean = 0, sd = sqrt(config$Sigma[i,i]))
    } else{
      Z[,i] <- config$ICDF_e[[i]](U[,i])
    }
  }
  Z[,ncol(Z)] <- config$icdf_t(U[,ncol(Z)])

  # If not Random sampling assumption, randomly select n_t_ topics without uniform sampling probability
  if(config$assumptions$random == FALSE) {
    # First sort Z by topic effect
    Z <- Z[order(Z[,ncol(Z)]),]
    # The probability of sampling each topic will be given by de pdf of a Beta distribution with random parameters
    shape1 <- runif(1, .01, 2)
    shape2 <- runif(1, 2, 8)
    if(rbinom(1, 1, .5)) {
      shape <- shape1
      shape1 <- shape2
      shape2 <- shape
    }
    P <- dbeta((0:(nrow(Z)+1)) / (nrow(Z)+2), shape1, shape2) # add one extra point at both sides to avoid infinities
    P <- P[-c(1, length(P))] # remove the two extra points here
    P <- P / sum(P) # Normalize to sum 1
    # Now randomly select n_t_ topics without replacement, using the probabilities of sampling just generated
    Z <- Z[sample(1:nrow(Z), size = n_t_, replace = FALSE, prob = P),]
  }

  # Generate simulated matrix
  Y <- matrix(nrow = n_t_,
              config$mu # Maintain the same grand average
              + rep(config$NU_s, each = n_t_) # maintain the same system effects
              + Z[,ncol(Z)]) + Z[,-ncol(Z)] # and add the new NU_t and Z
  colnames(Y) <- names(config$NU_s)

  # If not Normal assumption, transform back from logit
  if(config$assumptions$normal == FALSE) {
    Y <- invlogit(Y)
  }

  return(Y)
}
