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

#####

m_moritz <- lmer(form2, data = dd)

m_glmmTMB <- glmmTMB(form2, data = dd, REML = TRUE)

checkpoint()

m_full <- lmer(form, data = dd)

checkpoint()

m_fullmax <- lmer(max_form2, data = dd, control = lmerControl(calc.derivs = FALSE))

checkpoint()

m_buildmer <- buildmer(form, data = dd)

checkpoint()

m_buildmer_fix <- buildmer(form, data = dd,
                           buildmerControl =
                             buildmerControl(
                               include= ~(NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc)^2))

checkpoint()

form_diag <- as.formula(gsub("|", "||", deparse1(form), fixed = TRUE))
m_kliegl1 <- lmer(form_diag, data = dd)

form_kliegl2 <- mbirds_log ~
  (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc)^2 +
  (1 + NPP_log_sc + Feat_cv_sc || biome) +
  (1 + NPP_log_sc + Feat_log_sc + Feat_cv_sc || flor_realms) +
  (1 + NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc || biome_FR)
m_kliegl2 <- lmer(form_kliegl2, data = dd)

form_kliegl3 <- as.formula(gsub("||", "|", deparse1(form_kliegl2), fixed = TRUE))
m_kliegl3 <- lmer(form_kliegl3, data = dd)

form_kliegl4 <- mbirds_log ~
  (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc)^2 +
  rr(1 + NPP_log_sc + Feat_cv_sc | biome, d=2) +
  rr(1 + NPP_log_sc + Feat_log_sc + Feat_cv_sc | flor_realms, d=3) +
  rr(1 + NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc | biome_FR, d=4)
m_kliegl4 <- glmmTMB(form_kliegl4, dd, REML=TRUE)
