library(ggplot2); theme_set(theme_bw())
library(lme4)
zmargin <- theme(panel.spacing=unit(0,"lines"))
library(ggplot2)
library(marginaleffects)
library(emmeans)
library(effects)
library(tidyverse)
library(plotly)
library(buildmer)

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



## diagnostics


## coefficient plots etc.
