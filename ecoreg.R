library(ggplot2); theme_set(theme_bw())
library(lme4)
zmargin <- theme(panel.spacing=unit(0,"lines"))
library(ggplot2)
library(tidyverse)
library(plotly)
library(buildmer)
library(broom.mixed)
library(bbmle)

library(marginaleffects)
library(emmeans)
library(effects)

## exploration

dd <- readRDS("data/ecoreg.rds")

## draw figs
gg0 <- ggplot(dd, aes(NPP_log_sc, mbirds_log, colour = biome, shape = flor_realms)) +
  geom_point() +
  geom_smooth(method = "lm", aes(group = biome_FR), alpha = 0.1)
print(gg0)

gg1 <- gg0 + facet_wrap(~biome)
gg2 <- gg0 + facet_wrap(~flor_realms)

ggplotly(gg2)

## to be continued ... ??

## full model

form <- mbirds_log ~ (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc)^2 +
  (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc | biome) +
  (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc | flor_realms) +
  (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc | biome_FR)

vars <- c("NPP_log_sc", "Feat_log_sc", "NPP_cv_sc", "Feat_cv_sc")
all_vars <- paste(vars, collapse = "+")

max_form <- sprintf("(%s)^4 + ((%s)^2 | biome) + ((%s)^2 | flor_realms) + ((%s)^2 | biome_FR)",
                    all_vars, all_vars, all_vars, all_vars)
max_form2 <- reformulate(max_form, response = "mbirds_log")
m5 <- lmer(max_form2, data = dd, control = lmerControl(calc.derivs = FALSE))


m1 <- lmer(form, data = dd)
VarCorr(m1)

m2 <- buildmer(form, data = dd)
## decides on intercepts only at each stage

m3 <- buildmer(form, data = dd,
               buildmerControl = buildmerControl(include= ~(NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc)^2))

## For birds and amphibians, the selected model included
## independent effects of the predictors at the biome/realm
## interaction level and intercept-only (mean diversity)
## variation at the biome and realm levels; for mammals,
## the (independent) predictor effects were included at the
## realm level, with mean- diversity effects at the biome and
## biome/realm levels.
form2 <- mbirds_log ~ (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc)^2 +
  (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc || biome_FR) +
  (1 | biome) +
  (1 | flor_realms)

m4 <- lmer(form2, data = dd)
mod_list <- list(full=m1, reduced = m2@model, reduced_keepfixed = m3@model, used = m4, crazy = m5)

## diagnostics
performance::check_model(m3@model)
pp1 <- DHARMa::simulateResiduals(m3@model)
pp2 <- DHARMa::simulateResiduals(m3@model, use.u = TRUE)
plot(pp2)

library(DHARMa)
plot(simulateResiduals(m4))
performance::check_model(m4)

## compare fits (coefficient plots etc.)

tt <-  mod_list |>
  purrr::map_dfr(tidy, effects = "fixed", .id = "model", conf.int = TRUE) |>
  filter(term != "(Intercept)")

ggplot(tt, aes(estimate, term, colour = model)) +
  geom_pointrange(aes(xmin = conf.low, xmax = conf.high),
                  position = position_dodge(width = 0.5)) +
  geom_vline(xintercept = 0, lty = 2)


plot(allEffects(m3@model))

## skip ????
AICtab(mod_list)
cAIC_list <- lapply(mod_list, cAIC)
cAIC_vec <- sapply(cAIC_list, \(x) x$caic)
cAIC_vec - min(cAIC_vec)

## run cAIC on full set of fitted models??
## 'full' and 'crazy' are automatically refitted with a subset ... rabbit hole ...
