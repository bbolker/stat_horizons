ALL: lecture_1.html lecture_2.html lecture_3.html

%.html: %.rmd ./glmm.bib
	Rscript -e "rmarkdown::render('$<')"

timecomp.rds: timecomp.R
	R CMD BATCH --vanilla timecomp.R

pix/nbr_graph.png: ctv_network.R
	R CMD BATCH --vanilla ctv_network.R

lecture2_clean: lecture2.rmd ./glmm.bib
