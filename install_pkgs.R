## grep library *.rmd | grep library *.rmd | sed -e 's/^[^(]*(\([^)]*\)).*/\1/' | sort | uniq
pkgs <- c("bbmle",
          "broom.mixed",
          "buildmer",
          "cAIC4",
          "colorspace",
          "DHARMa",
          "effects",
          "emmeans",
          "ggbeeswarm",
          "glmmTMB",
          "lme4",
          "lmerTest",
          "marginaleffects",
          "plotly",
          "plotrix",
          "RColorBrewer",
          "rgl",
          "scales",
          "tidyverse")

extra_pkgs <- c("knitr", "pander")

i1 <- installed.packages()
pkgs <- setdiff(pkgs, rownames(i1))
install.packages(pkgs)

