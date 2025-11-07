library(lme4)
library(glmmTMB)
library(GLMMadaptive)
library(MASS)
library(nlme)
library(broom)
library(broom.mixed)
library(tidyverse)
L <- load("data/Banta.RData")

form <- total.fruits~1+reg+amd*nutrient + (1+amd*nutrient|gen)
m_glmer_L <- glmer(form ,data=dat.tf,family="poisson")
m_glmmTMB_L <- glmmTMB(form, data=dat.tf,family="poisson")
m_GLMMa_A7 <- mixed_model(total.fruits~1+reg+amd*nutrient,
                  random = ~1+amd*nutrient|gen, data=dat.tf,family="poisson")
m_glmmPQL <- MASS::glmmPQL(total.fruits~1+reg+amd*nutrient,
                    random = ~1+amd*nutrient|gen, data=dat.tf,family="poisson",
                    control = lmeControl(opt = "optim"))
m_glm <- glm(total.fruits~1+reg+amd*nutrient, data=dat.tf,family="poisson")

models <- ls(pattern="^m_")
mod_list <- mget(models)

tt <- purrr::map_dfr(mod_list, tidy, effect = "fixed", conf.int = TRUE, .id = "method") |>
  mutate(across(method, ~factor(., levels = c("m_glm", "m_glmmPQL", "m_glmer_L", "m_glmmTMB_L", "m_GLMMa_A7"),
                                labels = c("GLM", "PQL", "Laplace (lme4)", "Laplace (glmmTMB)", "AGHQ(7)")))) |>
  filter(term != "(Intercept)", !startsWith(term, "reg")) |>
  mutate(across(term, ~factor(., levels = c("amdclipped", "nutrient8", "amdclipped:nutrient8"),
                              labels = c("herbivory", "fertilization", "interaction"))))

saveRDS(tt, file = "outputs/banta_fits1.rds")
