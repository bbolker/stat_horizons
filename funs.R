## function for plotting Sigma, ZVZ' side by side
library(cowplot)
simfun <- function(ng, nvar, nrep, form, pars) {
  dd <- expand.grid(r = seq(nrep),
                    v = factor(seq(nvar[1])),
                    v2 = factor(seq(nvar[2])),
                    g = factor(seq(ng[1])),
                    g2 = factor(seq(ng[2]))
                    )
  dd$y <- simulate(form[-2],
                   newdata = dd,
                   newparams = pars,
                   family = gaussian)[[1]]
  lmer(form, data = dd)
}

ifun <- function(x, sub = "", ...) {
  image(x, useAbs=FALSE, useRaster = TRUE, xlab = "",
        sub = sub,
        ylab = "")
}

## add group names?
plotfun <- function(fit) {
  L2 <-getME(fit, "Lambdat")
  S1 <- crossprod(L2)
  Z <- getME(fit, "Z")
  S2 <- Z %*% S1 %*% t(Z)
  S3 <- S2 + Matrix::Diagonal(nrow(S2), sigma(fit)^2)
  cowplot::plot_grid(ifun(S1, sub = expression("random effects" ~~ Sigma)), ifun(S3, sub = expression("observation" ~~ Sigma)))
}        
