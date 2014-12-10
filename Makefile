all: move rmd2md

move:
		cp inst/vign/enigma_vignette.md vignettes;\
		cp -r inst/vign/figure/ vignettes/figure/

rmd2md:
		cd vignettes;\
		mv enigma_vignette.md enigma_vignette.Rmd
