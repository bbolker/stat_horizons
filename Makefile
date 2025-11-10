ALL: docs/lecture_1.html docs/lecture_2.html docs/lecture_3.html docs/lecture_2.pdf docs/index.html

.SECONDARY:

Rcb = R CMD BATCH --vanilla

docs/lecture_2.pdf: lecture_2.rmd ./glmm.bib
	Rscript -e "rmarkdown::render('lecture_2.rmd', output_format = 'pdf_document')"
	mv lecture_2.pdf docs

docs/%.pdf: docs/%.html
	chromium --headless --print-to-pdf=$@ $<

docs/%.html: %.rmd ./glmm.bib
	mkdir -p docs
	Rscript -e "rmarkdown::render('$<')"; mv $(basename $<).html docs

%.html: %.rmd
	Rscript -e "rmarkdown::render('$<')"

%.pdf: %.html
	chromium --headless --print-to-pdf=docs/$@ $<

fix_lme4:
	cd ~/R/pkgs/lme4; git checkout master; R CMD INSTALL .


timecomp.rds: timecomp.R
	R CMD BATCH --vanilla timecomp.R

pix/nbr_graph.png: ctv_network.R
	R CMD BATCH --vanilla ctv_network.R

outputs/mod_list.rds: lecture2_batch.R
	$(Rcb) lecture2_batch.R

lecture2_clean: lecture2.rmd ./glmm.bib
	rm outputs/mod_list.rds outputs/buildmer.rds
	R CMD BATCH --vanilla lecture2_batch.R


