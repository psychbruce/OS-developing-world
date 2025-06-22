# About this folder (Code & Data for Figure S1)

Below are the descriptions of the files and scripts in this folder:

-  `CRAN_maintainer.xlsx` is the manually preprocessed and coded data about CRAN package maintainers used in final analysis.

-  `CRAN_pkgs_downloads.Rmd` is the main R script (R markdown) used to produce Figure S1.

   -  `downloads.RData` is the saved R data about CRAN package download counts (see code at [Line 132](CRAN_pkgs_downloads.Rmd#L132)).

-  `CRAN_pkgs.R` is the R code for scraping the CRAN package URLs and metadata.

   -  Code sections from [Line 7](CRAN_pkgs.R#L7) to [Line 73](CRAN_pkgs.R#L73) were executed repeatedly on 2023.6.12, 2023.8.11, and 2023.10.29, producing the raw datasets `data.20230612.RData`, `data.20230811.RData`, and `data.20231029.RData`, respectively.

   -  Code sections from [Line 75](CRAN_pkgs.R#L75) to [Line 98](CRAN_pkgs.R#L98) were used for merging these data to `data.RData` (unprocessed and unchecked), which was then used for manual preprocessing in `CRAN_maintainer.xlsx`.
