## Moritz et al 2023
dd <- readRDS("data/ecoreg.rds")
## View(dd)

library(ggplot2); theme_set(theme_bw())
gg0 <- ggplot(dd, aes(NPP_log_sc, mbirds_log, colour = biome, shape = flor_realms)) +
  geom_point()
gg1 <- gg0 + geom_smooth(method = "lm", aes(group = biome_FR), alpha = 0.1)
print(gg1)
## facet_wrap

library(plotly)
ggplotly(gg1)

## full model
form <- mbirds_log ~ (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc)^2 +
   (1 + NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc | biome) +
  (1 + NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc | flor_realms) +
  (1 + NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc | biome_FR)

library(lmerTest)

mod_list <- readRDS("outputs/mod_list.rds")
m_full <- lmer(form, data = dd)

VarCorr(m_full)
isSingular(m_full)

## fit a ridiculous model: all second-order interaction varying at every level (biome etc.)
## + 4-way interactions for fixed effects ((1+NPP_log_sc + ...)^2 | biome) + ( ... | biome_FR) + ...

VarCorr(mod_list$m_fullmax)


library(buildmer)
m_buildmer <- buildmer(form, data = dd, buildmerControl = buildmerControl(direction = "backward"))

## what terms should I insist stay in the model/don't get thrown away?
## include = ~ <formula with all fixed effects> (goes into buildmerControl)

## after AIC/non-singular selection (considered intercept only, diagonal model [with ||], or a full model at 
## each level (biome, FR, biome_FR) e.g (1|biome)+(1|biome_FR)+ (1 + .... | flor_realms))
form2 <- mbirds_log ~ (NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc)^2 +
  (1 | biome) +
  (1| flor_realms) +
  (1 + NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc || biome_FR) ## diagonal
m_moritz <- update(m_full, formula = form2)
VarCorr(m_moritz)

glmmTMB( ... ~ ... + rr(1 + NPP_log_sc + Feat_log_sc + NPP_cv_sc + Feat_cv_sc | biome_FR, d = 1))
## try d=1, d=2, d=3, d=4: McGillycuddy et al J Stat Software

## cs, us, rr, with different numbers of varying terms, ...
## want to use buildmer with Matuschek et al recommendations? (LRT with alpha = 0.2, not 0.05) LRTalpha()

###
library(performance)
check_model(m_moritz)
library(DHARMa)
plot(s <- simulateResiduals(m_moritz))
plotResiduals(s, form = dd$NPP_log_sc, rank = TRUE)

library(bbmle)
AICtab(mod_list)

## effects, emmeans, marginaleffects, sjPlot, ggeffects, broom.mixed

library(lattice)
cowplot::plot_grid(plotlist =dotplot(ranef(m_moritz)))

                   