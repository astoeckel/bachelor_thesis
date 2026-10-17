# latexmk configuration for building the thesis
#
# Usage:  latexmk        (build astoecke_bachelor_thesis_2013.pdf)
#         latexmk -c     (remove auxiliary files)

@default_files = ('astoecke_bachelor_thesis_2013.tex');

# hyperref is loaded with the "pdftex" driver option, so use pdflatex
$pdf_mode = 1;
$pdflatex = 'pdflatex -interaction=nonstopmode -file-line-error -synctex=1 %O %S';

# Run BibTeX (natbib + plainnat) whenever bibliography.bib is present
$bibtex_use = 1;

# Additional files to remove with "latexmk -c"
$clean_ext = 'bbl synctex.gz tdo';
