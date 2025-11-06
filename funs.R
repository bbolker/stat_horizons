## function for plotting Sigma, ZVZ' side by side
library(cowplot)
simfun <- function(ng, nvar, nrep, form, pars) {
  dd <- expand.grid(r = seq(nrep),
                    v = factor(seq(nvar)),
                    g = factor(seq(ng))
                    )
  dd$y <- simulate(form[-2],
                   newdata = dd,
                   newparams = pars,
                   family = gaussian)[[1]]
  lmer(form, data = dd)
}

ifun <- function(x, ...) {
  image(x, useAbs=FALSE, useRaster = TRUE, sub = "", xlab = "",
        ylab = "")
}

## add group names?
plotfun <- function(fit) {
  L2 <-getME(fit, "Lambdat")
  S1 <- crossprod(L2)
  Z <- getME(fit, "Z")
  S2 <- Z %*% S1 %*% t(Z)
  S3 <- S2 + Matrix::Diagonal(nrow(S2), sigma(fit)^2)
  cowplot::plot_grid(ifun(S1), ifun(S3))
}        

fit <- simfun(10, 1, 5,
       y ~ 1 + (1|g),
       list(beta = 1, theta = 1, sigma = 1))

plotfun(fit)
  
  

