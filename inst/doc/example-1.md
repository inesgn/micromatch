---
title: "Matching data from two independent surveys: labour force and living conditions"
author: "Ines Garmendia"
date: '2014-10-13'
output: rmarkdown::html_vignette
vignette: >
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteIndexEntry{micromatch package}
  %\usepackage[utf8]{inputenc}
---

<!--
%\VignetteEngine{knitr::rmarkdown}
%\VignetteIndexEntry{micromatch package: Example}
-->




About `micromatch`
==================

`micromatch` provides a set of utilities to ease the task of statistically matching microdata files from official statistics.

For a general overview, please refer to the package vignette.

About this document
===================

This documents presents the use of `micromatch` package through a real matching
example with two independent surveys from Eustat, the Basque Statistical Office.

The example: matching `ecv` and `pra`
===========================================

`micromatch` includes data from two separate surveys conducted by Eustat (The Basque Statistical Office) during the 4th quarter of 2009: 

1. the Labour Force Survey (Encuesta de Población en Relación con la Actividad, `pra`), and 
2. the Living Conditions Survey (Encuesta de Condiciones de Vida, `ecv`)

(Please refer to the package documentation for a full description of these datasets).

In the following steps, we will see how a synthetic file can be obtained starting from these two separate data frames, `ecv` and `pra`. Each step of the matching task (Fig 2) is covered by a set of functions in `micromatch`.

### Step 1: Specify the purpose of matching

First of the main elements of the matching task need to be specified:

* The list of _shared variables_ (i.e. the variables common to both files. Typically: age, sex, education level...)
* A list of _specific variables_ for the first file, A
* A list of _specific variables_ for the second file, B
* Optionally, some _stratum variables_, i.e. variables defining separate sub-groups on the population (typically sex or age)
* Possibly, some _weight variables_, i.e. variables used for estimating values for all the population)

`ecv` gives a bunch of living condition measures such as frequency of social relations, economic status, health problems, and so on. `pra` focuses on the labour market and produces a segmentation of the population in 5 categories. In this example the aim is to obtain contingency tables that cross each of the `ecv` items with the labour market segmentation provieded by `pra`.

Because `pra` has more than twice as observations than `ecv`, `pra` will act as donor and `ecv` as recipient. This means that the unique specific variable in `pra` (i.e. the labour market segmentation) will be donated (i.e. imputed) into the `ecv` file. This will produce a synthetic file with one additional variable (column) in the initial `ecv` file.

The specific variable in `pra` is the labour market segmentation (variable `labour`) with the following categories:


```r
library(micromatch)
data(pra)
levels(pra$labour)
```

```
## [1] "Occupied"                                      
## [2] "Non-working activity (seeking job)"            
## [3] "Unemployed (strict)"                           
## [4] "Non-working activity (studying, housework,...)"
## [5] "Inactive or retired"
```

Since `ecv` is a quite long questionnaire measuring many different aspects of quality and style of life, a sample of interesting items was selected for inclusion in this package:


```r
data(ecv)
str(ecv[,13:25])
```

```
## 'data.frame':	4749 obs. of  13 variables:
##  $ healthproblems: Factor w/ 2 levels "Yes","No": 2 2 2 2 2 2 1 2 2 2 ...
##  $ languages     : Factor w/ 4 levels "Spanish","Sp+Others",..: 4 4 1 2 4 2 4 1 1 1 ...
##  $ holidaydest   : Factor w/ 4 levels "Basque country",..: 3 3 3 3 4 2 2 4 2 2 ...
##  $ sparetime     : Factor w/ 3 levels "<2h","2-4h","+4h": 2 2 3 2 2 2 2 3 2 3 ...
##  $ indsocial     : Factor w/ 3 levels "Every day","At least once a month",..: 2 2 2 2 2 1 1 2 2 1 ...
##  $ famsocial     : Factor w/ 3 levels "Very frequent",..: 3 3 1 2 1 1 1 3 1 1 ...
##  $ equipment     : Factor w/ 2 levels "Scarce","Good": 2 2 2 2 2 2 2 2 2 2 ...
##  $ housemode     : Factor w/ 3 levels "Owner","Rental",..: 1 1 1 1 1 1 2 2 1 1 ...
##  $ ownvehicles   : Factor w/ 3 levels "None","1 vehicle",..: 2 3 2 3 2 2 2 2 2 2 ...
....
```

### Step 2: Select matching variables

The shared variables between `ecv` and `pra` are shown in Table 1:

Variable   | Short Name | Type
------------- | ----- | -------------
Territory  | territory | 3 categories
Age  | age | 6 categories
Sex  | sex | 2 categories
Agesex  | agesex | 12 categories (combination of age and sex)
Family size  | famsize | 3 categories
Student?  | student | TRUE, FALSE
Seeking job?  | seekjob | TRUE, FALSE
Employed?  | employed | TRUE, FALSE
Unemployed?  | unemployed | TRUE, FALSE
Inactive?  | inactive | TRUE, FALSE
Hours at work  | workhours | 4 categories
Dedication to housework  | housework | 2 categories

**Table 1: Shared variables between `ecv` and `pra`**

        * Important Note: The data frames have been pre-processed in order to provide 
        the same names for the common variables, and the same category levels for the
        categorical values. These preprocessing task will have to be tackled prior to 
        using `micromatch`.

The shared variables have been unified:


```r
# In the first data frame: pra
str(pra[,1:12])
```

```
## 'data.frame':	10865 obs. of  12 variables:
##  $ territory : Factor w/ 3 levels "Araba","Bizkaia",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ age       : Factor w/ 6 levels "(15,24]","(24,34]",..: 6 6 6 6 6 2 1 5 5 5 ...
##  $ sex       : Factor w/ 2 levels "Male","Female": 1 2 2 1 2 2 2 1 2 1 ...
##  $ agesex    : Factor w/ 12 levels "Male.(15,24]",..: 11 12 12 11 12 4 2 9 10 9 ...
##  $ famsize   : Ord.factor w/ 3 levels "1"<"2"<"3+": 2 2 1 2 2 2 2 2 2 3 ...
##  $ student   : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
##  $ seekjob   : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
##  $ employed  : logi  FALSE FALSE FALSE FALSE FALSE TRUE ...
##  $ unemployed: logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
....
```

```r
# In the second data frame: ecv
str(ecv[,1:12])
```

```
## 'data.frame':	4749 obs. of  12 variables:
##  $ territory : Factor w/ 3 levels "Araba","Bizkaia",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ age       : Factor w/ 6 levels "(15,24]","(24,34]",..: 2 2 6 4 5 2 1 3 6 5 ...
##  $ sex       : Factor w/ 2 levels "Male","Female": 1 1 1 2 2 1 2 1 2 1 ...
##  $ agesex    : Factor w/ 12 levels "Male.(15,24]",..: 3 3 11 8 10 3 2 5 12 9 ...
##  $ famsize   : Ord.factor w/ 3 levels "1"<"2"<"3+": 3 3 2 3 3 1 3 3 1 2 ...
##  $ student   : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
##  $ seekjob   : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
##  $ employed  : logi  TRUE FALSE FALSE FALSE FALSE TRUE ...
##  $ unemployed: logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
....
```

Each data frame has its weight variable, named `weights`.

For convenience, we will specify character vectors for each type of variable, as follows:


```r
# Shared variables
varshared <- c("territory", "sex", "age", "agesex",
            "famsize", "student", "seekjob", "employed",
            "unemployed", "inactive", "workhours", "housework")
# Specific variables in the 1st file
varesp_A <- "labour"
# Specific variables in the 2nd file
varesp_B <- c("healthproblems", "languages", "holidaydest","sparetime",
              "indsocial", "famsocial", "equipment", "housemode",
              "ownvehicles", "ambientalcond", "econstatus", "income","moneyend")
# Weight variables (named the same way for both files)
weights <- "weights"
```

Now we proceed to define the recipient and donor files with all the previous variables:


```r
# Create recipient and donor files
# Donor: pra
don <- donor(data = pra, matchvars = varshared, specvars = varesp_A, weights = weights)
# Receptor: ecv
rec <- receptor(data = ecv, matchvars = varshared, specvars = varesp_B, weights = weights)
```

Now we will manipulate these objets in order to we reach a final definition for the matching task. More specifically: 

* we will select an optimal subset of `varshared`, which will act as the common variables (thus we will update the character vector for `mathcvars`), and 

* we will introduce stratum (i.e. group) variables: `stratavars`.

The common variables selected for matching must meet two conditions:

1. **Coherence**: The selected variables must show the same information across the files. The coherence refers both comparable definitions (i.e. wording of items in questionnaires) and to comparable empirical (observed) distributions.

2. **Predictive value**: The selected variables must be highly related to the specific variables in each of the files.

If these two conditions are met, then statistical matching will produce results which are (at least) coherent with the original information sources. 

(Please refer to the chapter on Validation to see what other conditions must be met in order to produce high quality results from a broader point of view.)

#### Step 2-1: Compare empirical distributions

First we need to discard variables whose empirical distributions are not comparable between the files. (Note that lack of equivalence with respect to the definition of concepts i.e., wording of items in the questionnaires, is also an important criterion in this step). 

We can use the `tabulate2cat` function to tabulate a single categorical variable in both files. Using `weights` is optional, and we can choose absolute or relative cell values with the argument `cell_values`:


```r
# Tabulate "territory", using weights and with absolute cell values
tabulate2cat(data_A = ecv, data_B = pra, var_A = "territory", var_B = "territory", 
             weights_A = "weights", weights_B = "weights", cell_values = "abs")
```

```
## $`Table for data:  ecv`
## x_vector
##    Araba  Bizkaia Gipuzkoa 
##   272109  1001808   591097 
## 
## $`Table for data:  pra`
## x_vector
##    Araba  Bizkaia Gipuzkoa 
##   273167  1000723   591500
```

```r
# Proportions (i.e. cell values relative to totals)
tabulate2cat(data_A = ecv, data_B = pra, var_A = "territory", var_B = "territory", 
             weights_A = "weights", weights_B = "weights", cell_values = "rel")
```

```
## $`Table for data:  ecv`
## x_vector
##    Araba  Bizkaia Gipuzkoa 
##   0.1459   0.5372   0.3169 
## 
## $`Table for data:  pra`
## x_vector
##    Araba  Bizkaia Gipuzkoa 
##   0.1464   0.5365   0.3171
```

`plot2cat` function produces a barplot for a single categorical variable. As before, `weights` is optional, and we can choose absolute or relative cell values with the argument `cell_values`:


```r
# Plot "territory", using weights and with relative cell values (i.e. proportions)
plot2cat(data_A = ecv, data_B = pra, var_A = "territory", var_B = "territory", 
             weights_A = "weights", weights_B = "weights", cell_values = "rel")
```

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk plotExample](figure/plotExample.png) 

Finally `similarity2cat` produces disimilarity/similarity measures for empirical distributions based on `StatMatch` package. Again, `weights` is optional:


```r
# Plot "territory", using weights and with relative cell values (i.e. proportions)
similarity2cat(data_A = ecv, data_B = pra, var_A = "territory", var_B = "territory", 
             weights_A = "weights", weights_B = "weights")
```

```
## [1] "Measures for variable: territory"
```

```
##       tvd   overlap     Bhatt      Hell 
## 0.0006901 0.9993099 0.9999996 0.0006061
```

Doing this on a variable-by-variable basis can be time-consuming; for this reason, specific methods have been included in `micromatch` that handle all variables defined as `matchvars` (i.e. common variables betwen the files) at once. Here is an illustration:

**All common variables at once**

* Tables.


```r
# Tables: proportions and weights
compare_matchvars(x = rec, y = don, cell_values = "rel", weights = TRUE)
```

```
## $`Table for data:  slot(x, "data")`
## x_vector
##    Araba  Bizkaia Gipuzkoa 
##   0.1459   0.5372   0.3169 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
##    Araba  Bizkaia Gipuzkoa 
##   0.1464   0.5365   0.3171 
## 
....
```

```
## $territory
## NULL
## 
## $sex
## NULL
## 
## $age
## NULL
## 
## $agesex
....
```

* Plots. 


```r
# Plots: proportions and weights
compare_matchvars(x = rec, y = don, type = "plot", cell_values = "rel", 
                  weights = TRUE)
```

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots1.png) 

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots2.png) 

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots3.png) 

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots4.png) 

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots5.png) 

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots6.png) 

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots7.png) 

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots8.png) 

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots9.png) 

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots10.png) 

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots11.png) 

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk compareMatchvarsPlots](figure/compareMatchvarsPlots12.png) 

```
## $territory
## NULL
## 
## $sex
## NULL
## 
## $age
## NULL
## 
## $agesex
....
```

* Disimilarity measures.


```r
# Measures: weights
compare_matchvars(x = rec, y = don, type = "measures", weights = TRUE)
```

```
## [1] "Measures for variable: territory"
## [1] "Measures for variable: sex"
## [1] "Measures for variable: age"
## [1] "Measures for variable: agesex"
## [1] "Measures for variable: famsize"
## [1] "Measures for variable: student"
## [1] "Measures for variable: seekjob"
## [1] "Measures for variable: employed"
## [1] "Measures for variable: unemployed"
## [1] "Measures for variable: inactive"
....
```

```
##         territory       sex      age   agesex famsize  student seekjob
## tvd     0.0006901 6.900e-05 0.002836 0.004081 0.06577 0.007087 0.01878
## overlap 0.9993099 9.999e-01 0.997164 0.995919 0.93423 0.992913 0.98122
## Bhatt   0.9999996 1.000e+00 0.999994 0.999988 0.99518 0.999911 0.99936
## Hell    0.0006061 4.881e-05 0.002409 0.003403 0.06946 0.009434 0.02525
##         employed unemployed inactive workhours housework
## tvd     0.002644   0.007558 0.010202   0.08764   0.07521
## overlap 0.997356   0.992442 0.989798   0.91236   0.92479
## Bhatt   0.999997   0.999856 0.999947   0.99132   0.99710
## Hell    0.001870   0.012018 0.007273   0.09319   0.05390
....
```

Globally, we suspect there could be some type of incoherence in variables `famsize` (category 1 person), `unemployed` and `housework`. In any case, coherence between variables should be investigated further.

In the `ecv`-`pra` example, age and sex groups are determinant both for the labour market segmentation and for living conditions. The combined variable, `agesex`, has been created to include as a group/strata variable. 

We now remove variable `age`, `sex` and `agesex` from the common variables and include it as `stratavars` variable. `micromatch` has specific functions for easy removal (`remove`) and inclusion (`include`) of variables:


```r
rec1 <- remove(x = rec, vars = c("age", "sex", "agesex")) 
#removes variables and creates new object
rec2 <- include(x = rec1, vars = "agesex", as = "stratavars") 
#includes 'agesex' as strata
##
don1 <- remove(x = don, vars = c("age", "sex", "agesex"))
don2 <- include(don1, vars = "agesex", as = "stratavars")
```

Now we will repeat the analyses with objects `rec2` and `don2`, which include `agesex` as stratum variables. By setting option `strata` to `TRUE` in `compare_matchvars` method we get the same answers as before, by each stratum value (12 groups of age and sex, in this case):

**Results by `agesex` groups**

* Tables


```r
# Tables: proportions and weights
compare_matchvars(x = rec2, y = don2, type = "table", weights = TRUE, 
                  cell_values = "rel", strata = TRUE)
```

(Not printed)

* Plots


```r
# Plots: proportions and weights
compare_matchvars(x = rec2, y = don2, type = "plot", weights = TRUE, strata = TRUE, 
                  cell_values = "rel")
```

(Not printed)

* Measures


```r
# Measures: weights
#compare_matchvars(x = rec2, y = don2, type = "measures", weights = TRUE, strata = TRUE)
#da error, porque hay casos con 0 casos en el estrato +65
compare_matchvars(x = remove(rec2, vars=c("unemployed", "employed", "inactive", "seekjob")), 
                  y = remove(don2, vars=c("unemployed", "employed", "inactive", "seekjob")),
                  type = "measures", weights = TRUE, strata = TRUE)
```

```
## [1] "Measures for variable: territory"
## [1] "Stratum:  Male.(15,24]"
##      tvd  overlap    Bhatt     Hell 
## 0.006558 0.993442 0.999953 0.006857 
## [1] "Measures for variable: territory"
## [1] "Stratum:  Female.(15,24]"
##      tvd  overlap    Bhatt     Hell 
## 0.006561 0.993439 0.999955 0.006726 
## [1] "Measures for variable: territory"
## [1] "Stratum:  Male.(24,34]"
....
```

```
##       territory  famsize  student workhours housework
##  [1,] 0.0065575 0.008604 0.070795   0.32800  0.060678
##  [2,] 0.9934425 0.991396 0.929205   0.67200  0.939322
##  [3,] 0.9999530 0.998998 0.997410   0.93960  0.996816
##  [4,] 0.0068574 0.031660 0.050891   0.24577  0.056424
##  [5,] 0.0065607 0.010524 0.129902   0.29283  0.056420
##  [6,] 0.9934393 0.989476 0.870098   0.70717  0.943580
##  [7,] 0.9999548 0.999831 0.990838   0.95052  0.998255
##  [8,] 0.0067261 0.013016 0.095721   0.22244  0.041774
##  [9,] 0.0027901 0.062548 0.045987   0.26785  0.111351
....
```

**First selection**

A first, tentative selection of variables by `agesex` values is done in table 2:

Stratum   | Selected variables
------------- | ------------------
Male.15-24  | student, seekjob
Female.15-24  | student, seekjob
Male.25-34  | seekjob, housework  
Female.25-34  | unemployed, housework
Male.35-44  | unemployed, famsize
Female.35-44  | unemployed, occupied
Male.45-54  | unemployed, seekjob
Female.45-54  | unemployed, seekjob
Male.55-64  | inactive, seekjob
Female.55-64  | inactive
Male.65+  | famsize
Female.65+  | famsize

*Table 2. A tentative selection of shared variables based on coherence study*

#### Step 2-2: Assess predictive value

For the pre-selected variables, we will assess the predictive value with respect to the `specvars` in each of the files.

We can use `predictvalue` method to assess the predictive value of `matchvars` with respect to `specvars`:

* In `pra` file, the (unique) specific variable is `labour`:


```r
predictvalue(x = remove(don, "workhours")) 
```

```
## [[1]]
## [[1]]$V
##  labour.territory        labour.sex        labour.age     labour.agesex 
##           0.03193           0.43289           0.37585           0.48260 
##    labour.famsize    labour.student    labour.seekjob   labour.employed 
##           0.21081           0.30929           0.85599           1.00000 
## labour.unemployed   labour.inactive  labour.housework 
##           0.99892           0.99982           0.57507 
## 
## [[1]]$lambda
....
```

        * Note. `workhours` is excluded since the original function in `StatMatch`, 
        `pw.assoc`, returns an error. This is because this variable only applies to 
        occupied people:
        

```r
table(pra$labour, pra$workhours)
```

```
##                                                 
##                                                  [0,14] (14,35] (35,44]
##   Occupied                                          114    1324    3233
##   Non-working activity (seeking job)                281       0       0
##   Unemployed (strict)                               202       0       0
##   Non-working activity (studying, housework,...)   3830       0       0
##   Inactive or retired                              1342       0       0
##                                                 
##                                                  (44,99]
##   Occupied                                           186
....
```

* In `ecv` file, we have a set of `specvars`:


```r
predictvalue(x = remove(rec, "workhours"))
```

```
## Warning: Chi-squared approximation may be incorrect
## Warning: Chi-squared approximation may be incorrect
```

```
## [[1]]
## [[1]]$V
##  healthproblems.territory        healthproblems.sex 
##                   0.12844                   0.01800 
##        healthproblems.age     healthproblems.agesex 
##                   0.30384                   0.30524 
##    healthproblems.famsize    healthproblems.student 
##                   0.17705                   0.10186 
##    healthproblems.seekjob   healthproblems.employed 
##                   0.07394                   0.27480 
....
```

Now we should inspect what happens within levels of `agesex`, i.e. repeat the previous analysis by strata.

For the pre-selected variables (see Table 2), the `select` and `predictvalue` methods can be easily combined to obtain results for `agesex` groups:

**Example: strata Male.15-24**

We inspect the predictive value of preselected variables: `student`, `seekjob` within this group.

In `pra`:


```r
levels(ecv$agesex)
```

```
##  [1] "Male.(15,24]"   "Female.(15,24]" "Male.(24,34]"   "Female.(24,34]"
##  [5] "Male.(34,44]"   "Female.(34,44]" "Male.(44,54]"   "Female.(44,54]"
##  [9] "Male.(54,64]"   "Female.(54,64]" "Male.65+"       "Female.65+"
```

```r
don2.M1524 <- select_strata(x = don2, value = "Male.(15,24]")
table(slot(don2.M1524, "data")[,"agesex"]) #ok
```

```
## 
##   Male.(15,24] Female.(15,24]   Male.(24,34] Female.(24,34]   Male.(34,44] 
##            512              0              0              0              0 
## Female.(34,44]   Male.(44,54] Female.(44,54]   Male.(54,64] Female.(54,64] 
##              0              0              0              0              0 
##       Male.65+     Female.65+ 
##              0              0
```

```r
varshared[-c(6,7)] #variables to keep
```

```
##  [1] "territory"  "sex"        "age"        "agesex"     "famsize"   
##  [6] "employed"   "unemployed" "inactive"   "workhours"  "housework"
```

```r
#
predictvalue(x = remove(don2.M1524 , varshared[-c(6,7)]))
```

```
## Warning: Chi-squared approximation may be incorrect
## Warning: Chi-squared approximation may be incorrect
```

```
## [[1]]
## [[1]]$V
## labour.student labour.seekjob 
##         0.8857         0.9081 
## 
## [[1]]$lambda
## labour.student labour.seekjob 
##         0.5025         0.1823 
## 
## [[1]]$tau
....
```

In this case the predictive value is high so we decide to keep both: `student` and `seekjob`.
TODO: PRINT TABLES.

Proceeding this way, we finally keep all variables in Table 2 and proceed to perform hot-deck imputation.

### Step 3: Nearest neighbour hot-deck imputation

Take first 10 rows and concatenate


```r
rec2.prueba <- select_observations(x = rec2, obs = 1:5)
don2.prueba <- select_observations(x = don2, obs = 1:5)
concat.prueba <- concatenate(x = rec2.prueba, y = don2.prueba)
concat.prueba
```

```
## An object of class "fusedfile"
## Slot "origin_specvars":
##  [1] "file1" "file1" "file1" "file1" "file1" "file1" "file1" "file1"
##  [9] "file1" "file1" "file1" "file1" "file1" "file2"
## 
## Slot "origin_weights":
## [1] "file1" "file2"
## 
## Slot "method":
## [1] "concatenation"
....
```

Match via hot-deck

```r
filled.rec2.prueba <- match.hotdeck(x = rec2.prueba, y = don2.prueba)
```

```
## Warning: The  Manhattan  distance is being used
## All the categorical matching variables in rec and don 
##  data.frames, if present are recoded into dummies
```

```r
filled.rec2.prueba
```

```
## An object of class "fusedfile"
## Slot "origin_specvars":
##  [1] "file1" "file1" "file1" "file1" "file1" "file1" "file1" "file1"
##  [9] "file1" "file1" "file1" "file1" "file1" "file2"
## 
## Slot "origin_weights":
## [1] "file1"
## 
## Slot "method":
## [1] "distance-hotdeck"
....
```

Match obsevations for strata "Male.15-24".

**With all variables!**

* Match


```r
#Select strata
rec2.M1524 <- select_strata(x = rec2, value = "Male.(15,24]")
don2.M1524 <- select_strata(x = don2, value = "Male.(15,24]")
#Match
filled.rec2.M1524 <- match.hotdeck(x = rec2.M1524, y = don2.M1524)
```

* Validate observed vs imputed `labour` variable.


```r
plot2cat(data_A = slot(filled.rec2.M1524, "data"), 
             data_B = slot(don2.M1524, "data"),
             var_A = "labour",
             var_B = "labour",
             weights_A = "weights",
             weights_B = "weights",
             cell_values = "rel")
```

Bad results!

**With variable selection**

* Match


```r
#Match
varshared[-c(6,7)] #variables to keep
filled.rec2.M1524 <- match.hotdeck(x = remove(rec2.M1524, vars = varshared[-c(6,7)]),
                                   y = remove(don2.M1524, vars = varshared[-c(6,7)]))
```

* Validate


```r
plot2cat(data_A = slot(filled.rec2.M1524, "data"), 
             data_B = slot(don2.M1524, "data"),
             var_A = "labour",
             var_B = "labour",
             weights_A = "weights",
             weights_B = "weights",
             cell_values = "rel")
```

Results are much better with variable selection.

        *TODO. Programar matching por estratos identificando una lista tipo...


```r
#c("student", "seekjob") %in% varshared
#varselected <- list(c("student", "seekjob"), )
#luego lapply replicando lo hecho con el primer estrato.
#englobar los resultados en un unico objeto.
```

        *TODO.Validar los resultados con un objeto que englobe los 'fusedfile' 
        imputados de todos los estratos.Con esto, termina el ejemplo ecv-pra.

        *TODO. Siguiente ejemplo: pisa-talis y MICE sobre fichero concatenado.


