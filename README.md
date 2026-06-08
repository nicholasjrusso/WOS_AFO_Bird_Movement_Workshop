# Visualizing and Analyzing Bird Movement Data in R

This workshop is prepared for the Wilson Ornithological Society/Association of Field Ornithologists Meeting in Newport, RI (7 July 2026).

In this workshop, we will:
- Visualize bird movement data
- Complete an integrated Step Selection Analysis (iSSA)

The example data and code are adapted from [Russo et al. 2024 Journal of Animal Ecology](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/1365-2656.14202https://drive.google.com/file/d/1a8e69UfHKeGuSw7tDPWVVPBPNauVWi4m/view?usp=sharing)

This workshop is adapted from an initial version that was prepared for students at Harvard University. See here for the video of the original 10/31/2025 Workshop:

## Useful Links:
[Getting started in amt](https://cran.r-project.org/web/packages/amt/vignettes/p1_getting_started.html)

[iSSA Tutorial](https://www.youtube.com/watch?v=jiY9N-TNRjs)

[RSS Paper](https://onlinelibrary.wiley.com/doi/full/10.1002/ece3.3122)

## Step 1: Load data and prepare a data frame for iSSA

`Step 1 - Data Prep.R`: R script that shows how to make a "track" object, standardize the temporal sampling rate of the track, generate random steps, and extract covariates at the end of each used and random movement step.

`white-thighed_hornbill_data.csv`: CSV containing GPS locations of five white-thighed hornbills (3 female, 2 male) tracked in the Dja Faunal Reserve of Cameroon. Explanation of column names:
    - `tag.local.identifier`: Serial number of the GPS tag (e-obs 27 g solar-powered tag)
    - `study.local.timestamp`: Timestamp recorded for each GPS location in the format MM/DD/YYYY HH:MM:SS
    - `utm.easting`: UTM Easting
    - `utm.northing`: UTM Northing
    - `utm.zone: UTM zone
    - `study.timezone`: timezone of the timestamps
    - `Sex`: sex of the individual

- `ch.tif`: Canopy Height, 10 m resolution

- `vc.tif`: Vertical Complexity Index, 10 m resolution

- `d50.tif`: Distance to gap of size >= 50 m, 10 m resolution

- `d500.tif`: Distance to gap of size >=500 m, 10 m resolution

- `swamp.tif`: Landscape classified as either swamp (1) or other habitat (0)

Figshare link containing full set of scripts and data for Russo et al. 2024 _J. Anim. Ecol.:_ https://figshare.com/articles/dataset/3D_Structure_-_Hornbill_Seed_Dispersal/25857385

## Session info for Step 1

```r
> sessionInfo()
R version 4.4.2 (2024-10-31 ucrt)
Platform: x86_64-w64-mingw32/x64
Running under: Windows 11 x64 (build 26100)

Matrix products: default

locale:
[1] LC_COLLATE=English_United States.utf8  
[2] LC_CTYPE=English_United States.utf8   
[3] LC_MONETARY=English_United States.utf8 
[4] LC_NUMERIC=C                          
[5] LC_TIME=English_United States.utf8    

time zone: America/New_York
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] amt_0.2.2.0     lubridate_1.9.3 forcats_1.0.0   stringr_1.5.2  
 [5] dplyr_1.1.4     purrr_1.0.2     readr_2.1.5     tidyr_1.3.1    
 [9] tibble_3.3.0    ggplot2_4.0.0   tidyverse_2.0.0 terra_1.8-70   

loaded via a namespace (and not attached):
 [1] utf8_1.2.6         generics_0.1.4     circular_0.5-1     class_7.3-22      
 [5] KernSmooth_2.23-24 stringi_1.8.7      lattice_0.22-6     hms_1.1.3         
 [9] magrittr_2.0.3     grid_4.4.2         timechange_0.3.0   RColorBrewer_1.1-3
[13] mvtnorm_1.3-2      Matrix_1.7-1       backports_1.5.0    e1071_1.7-16      
[17] DBI_1.2.3          survival_3.7-0     scales_1.4.0       codetools_0.2-20  
[21] Rdpack_2.6.2       cli_3.6.3          rlang_1.1.4        units_0.8-5       
[25] rbibutils_2.3      splines_4.4.2      withr_3.0.2        tools_4.4.2       
[29] tzdb_0.5.0         checkmate_2.3.2    boot_1.3-31        fitdistrplus_1.2-1
[33] vctrs_0.6.5        R6_2.6.1           proxy_0.4-27       lifecycle_1.0.4   
[37] classInt_0.4-10    MASS_7.3-61        pkgconfig_2.0.3    pillar_1.11.1     
[41] gtable_0.3.6       data.table_1.16.4  glue_1.8.0         Rcpp_1.0.13-1     
[45] sf_1.0-19          tidyselect_1.2.1   rstudioapi_0.17.1  farver_2.1.2      
[49] compiler_4.4.2     S7_0.2.0
>
```

## Step 2:  Run iSSA models and visualize results

### `Step 2 - iSSA Model Fitting and Plots.R`
This script demonstrates how to:
- Fit separate iSSA models to individuals to explore variation in movement and habitat seleciton
- Visualize and compare magnitude of selection across individuals by computing and plotting Relative Selection Strength (RSS)
- Fit a mixed effects iSSA with the `glmmtmb` R package to derive population level coefficients and random slopes for individual selection
- Compete hypotheses regarding drivers of animal movement by building off of a "core" iSSA model

### Inputs
The iSSA models in `Step 2 - iSSA Model Fitting and Plots.R` are built using the used and available steps stored in `data/hornbill.extracted.RData` that were generated in `Step 1 - Data Prep.R`

### Session Info for Step 2

```r
> sessionInfo()
R version 4.3.3 (2024-02-29)
Platform: aarch64-apple-darwin20 (64-bit)
Running under: macOS Monterey 12.5

Matrix products: default
BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib 
LAPACK: /Library/Frameworks/R.framework/Versions/4.3-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.11.0

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

time zone: America/New_York
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] glmmTMB_1.1.11  lubridate_1.9.4 forcats_1.0.0   stringr_1.5.1   dplyr_1.1.4     purrr_1.0.4     readr_2.1.5     tidyr_1.3.1     tibble_3.3.0    ggplot2_3.5.2  
[11] tidyverse_2.0.0 amt_0.2.2.0    

loaded via a namespace (and not attached):
 [1] generics_0.1.4      class_7.3-23        KernSmooth_2.23-26  stringi_1.8.7       lattice_0.22-6      lme4_1.1-37         hms_1.1.3           magrittr_2.0.3     
 [9] grid_4.3.3          timechange_0.3.0    RColorBrewer_1.1-3  Matrix_1.6-5        backports_1.5.0     e1071_1.7-16        DBI_1.2.3           survival_3.8-3     
[17] mgcv_1.9-1          scales_1.4.0        numDeriv_2016.8-1.1 reformulas_0.4.1    Rdpack_2.6.4        cli_3.6.5           crayon_1.5.3        rlang_1.1.6        
[25] units_0.8-7         rbibutils_2.3       splines_4.3.3       withr_3.0.2         tools_4.3.3         tzdb_0.5.0          checkmate_2.3.2     nloptr_2.2.1       
[33] minqa_1.2.8         boot_1.3-31         vctrs_0.6.5         R6_2.6.1            proxy_0.4-27        lifecycle_1.0.4     classInt_0.4-11     MASS_7.3-60.0.1    
[41] pkgconfig_2.0.3     pillar_1.11.0       gtable_0.3.6        glue_1.8.0          Rcpp_1.1.0          sf_1.0-21           tidyselect_1.2.1    rstudioapi_0.17.1  
[49] dichromat_2.0-0.1   farver_2.1.2        nlme_3.1-166        labeling_0.4.3      TMB_1.9.17          compiler_4.3.3     
>

```
**Relevant literature**
_Integrated Step Selection Analysis (iSSA) Methods_
1. T. Avgar, J. R. Potts, M. A. Lewis, M. S. Boyce, Integrated step selection analysis: bridging the gap between resource selection and animal movement. Methods Ecol. Evol. 7, 619–630 (2016).
2. J. Signer, J. Fieberg, T. Avgar, Animal movement tools (amt): R package for managing tracking data and conducting habitat selection analyses. Ecol. Evol. 9, 880–890 (2019).
3. J. Fieberg, J. Signer, B. Smith, T. Avgar, A ‘How to’ guide for interpreting parameters in habitat-selection analyses. J. Anim. Ecol. 90, 1027–1043 (2021).
4. T. Avgar, S. R. Lele, J. L. Keim, M. S. Boyce, Relative Selection Strength: Quantifying effect size in habitat‐ and step‐selection inference. Ecol. Evol. 7, 5322–5330 (2017). ## RSS methods
5. S. Muff, J. Signer, J. Fieberg, Accounting for individual-specific variation in habitat-selection studies: Efficient estimation of mixed-effects models using Bayesian or frequentist computation. J. Anim. Ecol. 89, 80–92 (2020). ## GLMM for multiple animals

_Hidden Markov Models/Inferring movement behavior_
1. E. Gurarie, et al., What is the animal doing? Tools for exploring behavioural structure in animal movements. J. Anim. Ecol. 85, 69–84 (2016).
2. R. Glennie, et al., Hidden Markov models: Pitfalls and opportunities in ecology. Methods Ecol. Evol. 14, 43–56 (2023).
3.  B. T. McClintock, T. Michelot, momentuHMM: R package for generalized hidden Markov models of animal movement. Methods Ecol. Evol. 9, 1518–1530 (2018).

_Dyadic movement_
1. R. Joo, M. P. Etienne, N. Bez, S. Mahévas, Metrics for describing dyadic movement: A review. Mov. Ecol. 6, 26 (2018).



