
* references: https://stackoverflow.com/questions/38260799/references-page-truncated-in-rmarkdown-ioslides-presentation?rq=3
* table of contents https://github.com/ShKlinkenberg/TOC-for-IOslides-in-Rmarkdown

* Hodges old/new [@hodges_richly_2016]
* Julia timing comparison ????

* QR code
* set up workstation in HH 
   * laptop as 'presenter notes'

## lecture 1: to add

* REML
* formula table spacing
* 2D shrinkage plots (based on sleepstudy etc.?)
* mention conditional modes/BLUPs

## lecture 2: workflow

* try out Kliegl methods

* identify maximal model
* specify other modeling decisions (response distribution, link function, etc.)
* specify model selection strategy

* exploratory (grouping-aware) data analysis

* model fits
* model selection (if necessary)

* diagnostics

* computationally intensive inference
    * likelihood profiles
    * (parametric) bootstrapping

* easy inference
   * effects plots (with partial residuals)
   * prediction plots
   * contrasts, coefficient estimates, etc. (coef plots)

* fitting. compare glmmTMB, lme4 (gamm4), buildmer ...
* diagnostics
* model comparison, inference
* save model list
* env variable to re-fit models or not (i.e. whether to evaluate fitting chunks)
* record fitting times? (batch-run file rather than doing it within rmarkdown?)

(works with master lme4, not currently with flexSigma ...)

## lecture 3: frontiers

* image for Wald <-> bootstrap spectrum?
* check Satt/KR glmmTMB vs lme4
* predictive simulation example
* allFit example?

* other platforms (INLA, brms/rstanarm/etc.)
   * feature table?
* integration methods (GLMM details)
* speed: MixedModels.jl vs glmmTMB vs lme4 on big (crossed) problems?
* conditional distributions, zero-inflation, censoring, etc etc
* dealing with singular fits
* structured covariances (splines etc etc etc)
* inference details:
* causal inference? (DAGs etc; Mundlak)

## stuff from mixed_details.md

   
* lecture 3
   * random slopes etc
   * singular fits
   * model simplification
   * inference

## stuff from glmm_details.md

   * integration methods
   * zero-inflation
