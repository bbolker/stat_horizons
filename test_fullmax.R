## FIXME: can this be automated/not repeated?

library(lme4)
library(lmerTest)
library(buildmer)
library(glmmTMB)

odir <- "outputs"
if (!dir.exists(odir)) dir.create(odir)

fn_mod <- "mod_list.rds"
fn_buildmer <- "buildmer.rds"

checkpoint <- function() {
  fits <- ls(pattern = "^m_", envir = parent.frame())
  buildmer_fits = ls(pattern = "^m_buildmer", envir = parent.frame())
  fits <- setdiff(fits, buildmer_fits)
  mod_list <- mget(fits, envir = parent.frame())
  buildmer_list <- mget(buildmer_fits, envir = parent.frame())
  buildmer_modlist <- lapply(buildmer_list, getElement, "model")
  if (length(buildmer_fits) > 0) {
    names(buildmer_modlist) <- paste0(buildmer_fits, "_mod")
  }
  mod_list <- c(mod_list, buildmer_modlist)
  saveRDS(mod_list, file = file.path(odir, fn_mod))
  saveRDS(buildmer_list, file = file.path(odir, fn_buildmer))
}

fun_time <- function(FUN, ...) {
  t1 <- system.time(res <- FUN(...))
  attr(res, "time") <- t1
  res
}

lmer <- function(...) fun_time(lmerTest::lmer, ...)
glmmTMB <- function(...) fun_time(glmmTMB::glmmTMB, ...)


dd <- readRDS("data/ecoreg.rds")

## full model 
form <- mbirds_log ~ (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc)^2 +
  (1 + NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc | biome) +
  (1 + NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc | flor_realms) +
  (1 + NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc | biome_FR)

## reduced model
form2 <- mbirds_log ~ (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc)^2 +
  (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc || biome_FR) +
  (1 | biome) +
  (1 | flor_realms)

## ridiculous model
vars <- c("NPP_log_sc", "Feat_log_sc", "NPP_cv_sc", "Feat_cv_sc")
all_vars <- paste(vars, collapse = "+")

max_form <- sprintf("(%s)^4 + ((%s)^2 | biome) + ((%s)^2 | flor_realms) + ((%s)^2 | biome_FR)",
                    all_vars, all_vars, all_vars, all_vars)
max_form2 <- reformulate(max_form, response = "mbirds_log")

## devtools::load_all("~/Documents/R/pkgs/lme4")
## debug(lme4::lmer)
## debug(optimizeLmer)
## debug(optwrap)

## debug(lme4::lmer)
## debug(optimizeLmer)
## debug(lme4:::optwrap)
m_fullmax <- lmer(max_form2, data = dd,
                  control = lmerControl(calc.derivs = FALSE),
                  verbose = 20)

m_fullmax <- lmer(max_form2, data = dd,
                  control = lmerControl(calc.derivs = FALSE,
                                        optCtrl = list(maxeval = 10)))

m_fullmax <- lmer(max_form2, data = dd,
                  control = lmerControl(calc.derivs = TRUE,
                                        optCtrl = list(maxeval = 10)))

system.time(m_fullmax <- lmer(max_form2, data = dd, control = lmerControl(calc.derivs = FALSE)))

system.time(m_fullmax <- lmer(max_form2, data = dd, control = lmerControl(calc.derivs = TRUE)))

system.time(m_fullmax <- lmer(max_form2, data = dd))

