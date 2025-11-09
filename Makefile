ALL: lecture_1.html lecture_2.html lecture_3.html
Rcb = R CMD BATCH --vanilla

fix_lme4:
	cd ~/R/pkgs/lme4; git checkout master; R CMD INSTALL .

%.html: %.rmd ./glmm.bib
	Rscript -e "rmarkdown::render('$<')"

timecomp.rds: timecomp.R
	R CMD BATCH --vanilla timecomp.R

pix/nbr_graph.png: ctv_network.R
	R CMD BATCH --vanilla ctv_network.R

outputs/mod_list.rds: lecture2_batch.R
	$(Rcb) lecture2_batch.R

lecture2_clean: lecture2.rmd ./glmm.bib
	rm outputs/mod_list.rds outputs/buildmer.rds
	R CMD BATCH --vanilla lecture2_batch.R


