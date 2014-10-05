---
title: "`micromatch` package: new version"
author: "Ines Garmendia"
date: '2014-10-05'
output: rmarkdown::html_vignette
vignette: >
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteIndexEntry{Vignette Title}
  %\usepackage[utf8]{inputenc}
---

<!--
%\VignetteEngine{knitr::rmarkdown}
%\VignetteIndexEntry{micromatch package: Making statistical matching easier}
-->

`micromatch` provides a set of utilities to ease the task of statistically matching microdata files from official statistics.

The main methods that `micromatch` relies on are described in two books: [1] and [2], and are also a result of two Eurostat projects in data integration and statistical matching (see references [3] and [4]).

What is statistical matching?
=============================
Statistical matching (also known as data fusion, data merging or synthetic matching) is set of techniques for providing joint information on variables or indicators collected through multiple sources, usually, surveys drawn from the same population. The potential benefits of this approach lie in the possibility to enhance the complementary use and analytical potential of existing data sources. (A. Leulescu & M. Agafitei, 2013).

Statistical matching has been widely used in market research, to link consumer behavior data and media consumption data to design better advertising campaigns.

In official statistics, the main interest lies in the possibility to link different aspects that are usually studied separately for the same target population (i.e. the inhabitants in a country or a particular geographic area). The reason is that a long questionnaire covering all aspects such as population health, income, consumption, labour market, social capital... is seldom conceived; such a questionnaire would be too long, leading to a higher response burden, and to poor quality. Normally, a separate survey is conducted to study each specific aspect, the drawback being that the responses lie in separate files.

Statistical matching provides a methodology to explore ways for producing combined analyses or indicators from independent surveys. 

The starting point
------------------

Consider two independent survey samples from the same population of interest, each of which produces measures regarding a specific field (for example, living styles and consumer behavior). The surveys share a block of variables (sociodemographic variables such as the age, sex, or social status). When putting all the observations surveys together, a particular _missing data_ pattern due to the non-observed values emerges (i.e., answers we don't have in one survey just because they correspond to the other, independent survey), see Fig 1.

![alt text](fig1.png)

**Fig 1. The starting point: a block of common variables (Z) and two block of specific, non-jointly-observed, variables (X and Y)**

The aim is to obtain integrated analyses or results relating the non-jointly-observed variables (blocks _X_ and _Y_ in the figure), and to achieve this we need to make use of the common information between the files (block _Z_) in some efficient and reliable way.


        * The basic assumption is that the number of individuals or units in both
        samples (i.e., the overlap) is negligible. 
        
        The fundamental difference with respect to other methods such as "record
        linkage" is that in the latter, we have identical units and we wish to 
        find a correspondence between them to link the files. 
        
        In statistical matching, we "know" the units are different, but we "wish" 
        to find similar ones.

When should we use `micromatch`?
-------------------------------

We should use `micromatch` when having two separate files, A and B, with:

1. _distinct units_ referred to the _same population of interest_, 
2. a common block of variables (which we call _common variables_), and 
3. two sets of distinct variables in each file (which we call _specific variables_),

and we wish to relate the specific variables in order to produce combined statistical analyses. 

What kind of result should we expect?
-------------------------------------

Depeding on the selected approach, we will obtain one of these results:

* a synthetic file containing full information on the variables and all units from both sources. This _enhanced_ dataset can be used later to make combined statistical analyses.

* particular estimates regarding variables living in separate files. The user might wish to estimate a contingency table or correlation coefficient, or any parameter of interest regarding variables in separate files. 

The former is named the _micro_ approach. The latter is the _macro_ approach.

What is the solution implemented in `micromatch`?
-------------------------------------------------

As opposed to other packages such as `StatMatch` or `mice` that provide sophisticated functions to solve different statistical matching tasks, `micromatch` does not offer (genuinely) new functionality but rather a _context_ to make statistical matching easier, independently of which the chosen methodology is. That is: `micromatch` does not offer new functions to solve the statistical matching problem, but, on the contrary, it offers a _framework_ where the main methods implemented across other packages are integrated into a common context.

To achieve this _unification_, `micromatch` uses S4 classes and methods so that the user will start defining particular attributes of the data related to the statistical matching context. In particular, every step needed to tackle a particular problem of statistical matching has its implementation (or definition) in `micromatch`. 

### The matching process

`micromatch` is organized around four families of functions related to the main steps of the statistical matching process, see Fig 2.

<img src="fig2.png" alt="Statistical Matching Process" style="width:500px;height:600px">

**Fig 2: The statistical matching process.**

In a micro setting, we may want to fill one of the files. In this case, we say that:

        * The file to be completed is the _recipient_ file, whereas
        * The file that donates variables the other file is the _donor_. 

We may also want to fill variables in both files: when no distinction is made between receptor and donor files we will assume the files have a `symmetric` role.

**`receptor` and `donor` files in `micromatch`**

In a typical session with `micromatch`, we will start by defining a `receptor` and a `donor` file, or two `symmetric` files. These special objects will contain not only the data frames with observations and variables (i.e. the microdata files themselves), but also some key information related to the statistical matching process. 

In the following we will illustrate the use of `micromatch` by means of real examples.

The first example: matching `ecv` and `pra`
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
library(micromatchdev)
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
##  $ ambientalcond : Factor w/ 3 levels "No problems",..: 2 1 1 1 1 1 3 1 3 2 ...
##  $ econstatus    : Factor w/ 3 levels "Bad","Standard",..: 3 3 2 3 3 3 2 1 2 3 ...
##  $ income        : Factor w/ 4 levels "Low","Medium",..: 3 3 2 2 3 2 2 1 1 2 ...
##  $ moneyend      : Factor w/ 2 levels "Yes","No": 1 1 1 2 1 2 2 2 1 1 ...
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
##  $ inactive  : logi  TRUE TRUE TRUE TRUE TRUE FALSE ...
##  $ workhours : Factor w/ 4 levels "[0,14]","(14,35]",..: 1 1 1 1 1 3 1 1 1 1 ...
##  $ housework : Factor w/ 2 levels "Deals with it",..: 2 1 1 2 1 1 2 2 1 1 ...
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
##  $ inactive  : logi  FALSE TRUE TRUE TRUE TRUE FALSE ...
##  $ workhours : Factor w/ 4 levels "[0,14]","(14,35]",..: 3 1 1 1 1 3 1 1 1 1 ...
##  $ housework : Factor w/ 2 levels "Deals with it",..: 1 2 2 1 1 1 1 1 1 1 ...
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
## $`Table for data:  slot(x, "data")`
## x_vector
##   Male Female 
## 0.4859 0.5141 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
##   Male Female 
##  0.486  0.514 
## 
## $`Table for data:  slot(x, "data")`
## x_vector
## (15,24] (24,34] (34,44] (44,54] (54,64]     65+ 
## 0.09215 0.17364 0.19199 0.17515 0.14561 0.22146 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
## (15,24] (24,34] (34,44] (44,54] (54,64]     65+ 
## 0.09347 0.17272 0.19084 0.17667 0.14498 0.22133 
## 
## $`Table for data:  slot(x, "data")`
## x_vector
##   Male.(15,24] Female.(15,24]   Male.(24,34] Female.(24,34]   Male.(34,44] 
##        0.04743        0.04472        0.08893        0.08471        0.09923 
## Female.(34,44]   Male.(44,54] Female.(44,54]   Male.(54,64] Female.(54,64] 
##        0.09277        0.08662        0.08853        0.07109        0.07451 
##       Male.65+     Female.65+ 
##        0.09260        0.12886 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
##   Male.(15,24] Female.(15,24]   Male.(24,34] Female.(24,34]   Male.(34,44] 
##        0.04838        0.04509        0.08898        0.08375        0.09748 
## Female.(34,44]   Male.(44,54] Female.(44,54]   Male.(54,64] Female.(54,64] 
##        0.09336        0.08733        0.08934        0.07059        0.07438 
##       Male.65+     Female.65+ 
##        0.09321        0.12812 
## 
## $`Table for data:  slot(x, "data")`
## x_vector
##      1      2     3+ 
## 0.1650 0.2617 0.5733 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
##       1       2      3+ 
## 0.09925 0.29070 0.61005 
## 
## $`Table for data:  slot(x, "data")`
## x_vector
##   FALSE    TRUE 
## 0.92003 0.07997 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
##   FALSE    TRUE 
## 0.92712 0.07288 
## 
## $`Table for data:  slot(x, "data")`
## x_vector
##   FALSE    TRUE 
## 0.91559 0.08441 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
##   FALSE    TRUE 
## 0.93436 0.06564 
## 
## $`Table for data:  slot(x, "data")`
## x_vector
##  FALSE   TRUE 
## 0.4874 0.5126 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
##  FALSE   TRUE 
## 0.4901 0.5099 
## 
## $`Table for data:  slot(x, "data")`
## x_vector
##   FALSE    TRUE 
## 0.94399 0.05601 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
##   FALSE    TRUE 
## 0.95155 0.04845 
## 
## $`Table for data:  slot(x, "data")`
## x_vector
##  FALSE   TRUE 
## 0.5686 0.4314 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
##  FALSE   TRUE 
## 0.5584 0.4416 
## 
## $`Table for data:  slot(x, "data")`
## x_vector
##  [0,14] (14,35] (35,44] (44,99] 
## 0.56464 0.09891 0.27530 0.06115 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
##  [0,14] (14,35] (35,44] (44,99] 
## 0.51845 0.13400 0.32785 0.01971 
## 
## $`Table for data:  slot(x, "data")`
## x_vector
##         Deals with it Does not deal with it 
##                0.5412                0.4588 
## 
## $`Table for data:  slot(y, "data")`
## x_vector
##         Deals with it Does not deal with it 
##                0.6164                0.3836
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
## NULL
## 
## $famsize
## NULL
## 
## $student
## NULL
## 
## $seekjob
## NULL
## 
## $employed
## NULL
## 
## $unemployed
## NULL
## 
## $inactive
## NULL
## 
## $workhours
## NULL
## 
## $housework
## NULL
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
## NULL
## 
## $famsize
## NULL
## 
## $student
## NULL
## 
## $seekjob
## NULL
## 
## $employed
## NULL
## 
## $unemployed
## NULL
## 
## $inactive
## NULL
## 
## $workhours
## NULL
## 
## $housework
## NULL
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
## [1] "Measures for variable: workhours"
## [1] "Measures for variable: housework"
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
##      tvd  overlap    Bhatt     Hell 
## 0.002790 0.997210 0.999993 0.002688 
## [1] "Measures for variable: territory"
## [1] "Stratum:  Female.(24,34]"
##      tvd  overlap    Bhatt     Hell 
## 0.002200 0.997800 0.999997 0.001587 
## [1] "Measures for variable: territory"
## [1] "Stratum:  Male.(34,44]"
##      tvd  overlap    Bhatt     Hell 
## 0.001615 0.998385 0.999997 0.001635 
## [1] "Measures for variable: territory"
## [1] "Stratum:  Female.(34,44]"
##       tvd   overlap     Bhatt      Hell 
## 0.0008378 0.9991622 0.9999996 0.0006375 
## [1] "Measures for variable: territory"
## [1] "Stratum:  Male.(44,54]"
##       tvd   overlap     Bhatt      Hell 
## 0.0006825 0.9993175 0.9999997 0.0005181 
## [1] "Measures for variable: territory"
## [1] "Stratum:  Female.(44,54]"
##      tvd  overlap    Bhatt     Hell 
## 0.001992 0.998008 0.999997 0.001669 
## [1] "Measures for variable: territory"
## [1] "Stratum:  Male.(54,64]"
##      tvd  overlap    Bhatt     Hell 
## 0.010843 0.989157 0.999940 0.007729 
## [1] "Measures for variable: territory"
## [1] "Stratum:  Female.(54,64]"
##      tvd  overlap    Bhatt     Hell 
## 0.006398 0.993602 0.999975 0.004989 
## [1] "Measures for variable: territory"
## [1] "Stratum:  Male.65+"
##      tvd  overlap    Bhatt     Hell 
## 0.004456 0.995544 0.999990 0.003163 
## [1] "Measures for variable: territory"
## [1] "Stratum:  Female.65+"
##      tvd  overlap    Bhatt     Hell 
## 0.003046 0.996954 0.999992 0.002761 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Male.(15,24]"
##      tvd  overlap    Bhatt     Hell 
## 0.008604 0.991396 0.998998 0.031660 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Female.(15,24]"
##     tvd overlap   Bhatt    Hell 
## 0.01052 0.98948 0.99983 0.01302 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Male.(24,34]"
##     tvd overlap   Bhatt    Hell 
## 0.06255 0.93745 0.99303 0.08351 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Female.(24,34]"
##     tvd overlap   Bhatt    Hell 
## 0.04669 0.95331 0.99537 0.06803 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Male.(34,44]"
##     tvd overlap   Bhatt    Hell 
##  0.1107  0.8893  0.9881  0.1091 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Female.(34,44]"
##     tvd overlap   Bhatt    Hell 
## 0.10025 0.89975 0.99022 0.09889 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Male.(44,54]"
##     tvd overlap   Bhatt    Hell 
## 0.04631 0.95369 0.99799 0.04484 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Female.(44,54]"
##     tvd overlap   Bhatt    Hell 
##  0.1277  0.8723  0.9802  0.1408 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Male.(54,64]"
##     tvd overlap   Bhatt    Hell 
## 0.05552 0.94448 0.99778 0.04712 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Female.(54,64]"
##     tvd overlap   Bhatt    Hell 
## 0.06496 0.93504 0.99510 0.06999 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Male.65+"
##     tvd overlap   Bhatt    Hell 
## 0.05611 0.94389 0.99662 0.05816 
## [1] "Measures for variable: famsize"
## [1] "Stratum:  Female.65+"
##     tvd overlap   Bhatt    Hell 
## 0.10454 0.89546 0.99348 0.08074 
## [1] "Measures for variable: student"
## [1] "Stratum:  Male.(15,24]"
##     tvd overlap   Bhatt    Hell 
## 0.07080 0.92920 0.99741 0.05089 
## [1] "Measures for variable: student"
## [1] "Stratum:  Female.(15,24]"
##     tvd overlap   Bhatt    Hell 
## 0.12990 0.87010 0.99084 0.09572 
## [1] "Measures for variable: student"
## [1] "Stratum:  Male.(24,34]"
##     tvd overlap   Bhatt    Hell 
## 0.04599 0.95401 0.99460 0.07349 
## [1] "Measures for variable: student"
## [1] "Stratum:  Female.(24,34]"
##      tvd  overlap    Bhatt     Hell 
## 0.008189 0.991811 0.999868 0.011475 
## [1] "Measures for variable: student"
## [1] "Stratum:  Male.(34,44]"
##     tvd overlap   Bhatt    Hell 
## 0.01166 0.98834 0.99752 0.04984 
## [1] "Measures for variable: student"
## [1] "Stratum:  Female.(34,44]"
##     tvd overlap   Bhatt    Hell 
## 0.04421 0.95579 0.99175 0.09082 
## [1] "Measures for variable: student"
## [1] "Stratum:  Male.(44,54]"
##     tvd overlap   Bhatt    Hell 
## 0.04357 0.95643 0.98354 0.12830 
## [1] "Measures for variable: student"
## [1] "Stratum:  Female.(44,54]"
##     tvd overlap   Bhatt    Hell 
## 0.01603 0.98397 0.99739 0.05110 
## [1] "Measures for variable: student"
## [1] "Stratum:  Male.(54,64]"
##      tvd  overlap    Bhatt     Hell 
## 0.005336 0.994664 0.998893 0.033267 
## [1] "Measures for variable: student"
## [1] "Stratum:  Female.(54,64]"
##      tvd  overlap    Bhatt     Hell 
## 0.008842 0.991158 0.999098 0.030026 
## [1] "Measures for variable: student"
## [1] "Stratum:  Male.65+"
##      tvd  overlap    Bhatt     Hell 
## 0.002825 0.997175 0.999495 0.022465 
## [1] "Measures for variable: student"
## [1] "Stratum:  Female.65+"
##     tvd overlap   Bhatt    Hell 
## 0.00399 0.99601 0.99953 0.02160 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Male.(15,24]"
##     tvd overlap   Bhatt    Hell 
##  0.3280  0.6720  0.9396  0.2458 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Female.(15,24]"
##     tvd overlap   Bhatt    Hell 
##  0.2928  0.7072  0.9505  0.2224 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Male.(24,34]"
##     tvd overlap   Bhatt    Hell 
##  0.2679  0.7321  0.9601  0.1998 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Female.(24,34]"
##     tvd overlap   Bhatt    Hell 
##  0.1267  0.8733  0.9838  0.1271 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Male.(34,44]"
##     tvd overlap   Bhatt    Hell 
##  0.3278  0.6722  0.9364  0.2523 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Female.(34,44]"
##     tvd overlap   Bhatt    Hell 
##  0.1344  0.8656  0.9874  0.1120 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Male.(44,54]"
##     tvd overlap   Bhatt    Hell 
##  0.2487  0.7513  0.9617  0.1958 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Female.(44,54]"
##     tvd overlap   Bhatt    Hell 
##  0.1237  0.8763  0.9889  0.1056 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Male.(54,64]"
##     tvd overlap   Bhatt    Hell 
##  0.1521  0.8479  0.9848  0.1233 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Female.(54,64]"
##     tvd overlap   Bhatt    Hell 
## 0.04631 0.95369 0.99293 0.08409 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Male.65+"
##     tvd overlap   Bhatt    Hell 
## 0.03649 0.96351 0.99220 0.08834 
## [1] "Measures for variable: workhours"
## [1] "Stratum:  Female.65+"
##     tvd overlap   Bhatt    Hell 
## 0.02344 0.97656 0.99312 0.08292 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Male.(15,24]"
##     tvd overlap   Bhatt    Hell 
## 0.06068 0.93932 0.99682 0.05642 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Female.(15,24]"
##     tvd overlap   Bhatt    Hell 
## 0.05642 0.94358 0.99825 0.04177 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Male.(24,34]"
##     tvd overlap   Bhatt    Hell 
## 0.11135 0.88865 0.99353 0.08044 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Female.(24,34]"
##     tvd overlap   Bhatt    Hell 
## 0.05725 0.94275 0.99814 0.04308 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Male.(34,44]"
##     tvd overlap   Bhatt    Hell 
## 0.03785 0.96215 0.99928 0.02677 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Female.(34,44]"
##     tvd overlap   Bhatt    Hell 
##  0.1962  0.8038  0.9635  0.1909 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Male.(44,54]"
##     tvd overlap   Bhatt    Hell 
## 0.06806 0.93194 0.99760 0.04895 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Female.(44,54]"
##     tvd overlap   Bhatt    Hell 
##  0.1380  0.8620  0.9775  0.1501 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Male.(54,64]"
##     tvd overlap   Bhatt    Hell 
##  0.1004  0.8996  0.9945  0.0744 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Female.(54,64]"
##     tvd overlap   Bhatt    Hell 
##  0.1492  0.8508  0.9622  0.1943 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Male.65+"
##      tvd  overlap    Bhatt     Hell 
## 0.006476 0.993524 0.999975 0.005016 
## [1] "Measures for variable: housework"
## [1] "Stratum:  Female.65+"
##     tvd overlap   Bhatt    Hell 
##  0.2207  0.7793  0.9577  0.2057
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
## [10,] 0.9972099 0.937452 0.954013   0.73215  0.888649
## [11,] 0.9999928 0.993026 0.994599   0.96007  0.993530
## [12,] 0.0026876 0.083513 0.073488   0.19983  0.080437
## [13,] 0.0022000 0.046690 0.008189   0.12671  0.057252
## [14,] 0.9978000 0.953310 0.991811   0.87329  0.942748
## [15,] 0.9999975 0.995372 0.999868   0.98384  0.998145
## [16,] 0.0015865 0.068026 0.011475   0.12711  0.043075
## [17,] 0.0016154 0.110696 0.011657   0.32781  0.037854
## [18,] 0.9983846 0.889304 0.988343   0.67219  0.962146
## [19,] 0.9999973 0.988099 0.997516   0.93635  0.999283
## [20,] 0.0016349 0.109092 0.049842   0.25229  0.026772
## [21,] 0.0008378 0.100252 0.044210   0.13443  0.196153
## [22,] 0.9991622 0.899748 0.955790   0.86557  0.803847
## [23,] 0.9999996 0.990221 0.991753   0.98745  0.963548
## [24,] 0.0006375 0.098891 0.090815   0.11204  0.190923
## [25,] 0.0006825 0.046306 0.043566   0.24866  0.068058
## [26,] 0.9993175 0.953694 0.956434   0.75134  0.931942
## [27,] 0.9999997 0.997989 0.983539   0.96166  0.997604
## [28,] 0.0005181 0.044842 0.128299   0.19581  0.048948
## [29,] 0.0019916 0.127732 0.016030   0.12372  0.138037
## [30,] 0.9980084 0.872268 0.983970   0.87628  0.861963
## [31,] 0.9999972 0.980166 0.997389   0.98885  0.977460
## [32,] 0.0016692 0.140834 0.051098   0.10558  0.150132
## [33,] 0.0108432 0.055515 0.005336   0.15213  0.100416
## [34,] 0.9891568 0.944485 0.994664   0.84787  0.899584
## [35,] 0.9999403 0.997780 0.998893   0.98479  0.994464
## [36,] 0.0077292 0.047119 0.033267   0.12334  0.074403
## [37,] 0.0063983 0.064964 0.008842   0.04631  0.149235
## [38,] 0.9936017 0.935036 0.991158   0.95369  0.850765
## [39,] 0.9999751 0.995101 0.999098   0.99293  0.962235
## [40,] 0.0049890 0.069991 0.030026   0.08409  0.194331
## [41,] 0.0044564 0.056110 0.002825   0.03649  0.006476
## [42,] 0.9955436 0.943890 0.997175   0.96351  0.993524
## [43,] 0.9999900 0.996617 0.999495   0.99220  0.999975
## [44,] 0.0031627 0.058163 0.022465   0.08834  0.005016
## [45,] 0.0030457 0.104539 0.003990   0.02344  0.220746
## [46,] 0.9969543 0.895461 0.996010   0.97656  0.779254
## [47,] 0.9999924 0.993482 0.999533   0.99312  0.957698
## [48,] 0.0027607 0.080735 0.021601   0.08292  0.205674
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
##           0.03458           0.40929           0.37241           0.47275 
##    labour.famsize    labour.student    labour.seekjob   labour.employed 
##           0.19170           0.32912           0.85022           1.00000 
## labour.unemployed   labour.inactive  labour.housework 
##           0.99873           0.99976           0.54830 
## 
## [[1]]$lambda
##  labour.territory        labour.sex        labour.age     labour.agesex 
##           0.00000           0.05340           0.36552           0.49775 
##    labour.famsize    labour.student    labour.seekjob   labour.employed 
##           0.04432           0.11698           0.04499           0.67370 
## labour.unemployed   labour.inactive  labour.housework 
##           0.05622           0.67370           0.00000 
## 
## [[1]]$tau
##  labour.territory        labour.sex        labour.age     labour.agesex 
##         0.0008986         0.0637361         0.2885097         0.3898190 
##    labour.famsize    labour.student    labour.seekjob   labour.employed 
##         0.0345301         0.0620623         0.0531091         0.6114324 
## labour.unemployed   labour.inactive  labour.housework 
##         0.0694900         0.5832802         0.0736536 
## 
## [[1]]$U
##  labour.territory        labour.sex        labour.age     labour.agesex 
##          0.001056          0.079210          0.280570          0.372135 
##    labour.famsize    labour.student    labour.seekjob   labour.employed 
##          0.031998          0.047612          0.138324          0.611171 
## labour.unemployed   labour.inactive  labour.housework 
##          0.170369          0.604647          0.157469
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
##   Non-working activity (seeking job)                   0
##   Unemployed (strict)                                  0
##   Non-working activity (studying, housework,...)       0
##   Inactive or retired                                  0
```

* In `ecv` file, we have a set of `specvars`:


```r
predictvalue(x = remove(rec, "workhours"))
```

```
## [[1]]
## [[1]]$V
##  healthproblems.territory        healthproblems.sex 
##                   0.10342                   0.01427 
##        healthproblems.age     healthproblems.agesex 
##                   0.30421                   0.30595 
##    healthproblems.famsize    healthproblems.student 
##                   0.16916                   0.09805 
##    healthproblems.seekjob   healthproblems.employed 
##                   0.06781                   0.27590 
## healthproblems.unemployed   healthproblems.inactive 
##                   0.02159                   0.28847 
##  healthproblems.housework 
##                   0.05477 
## 
## [[1]]$lambda
##  healthproblems.territory        healthproblems.sex 
##                         0                         0 
##        healthproblems.age     healthproblems.agesex 
##                         0                         0 
##    healthproblems.famsize    healthproblems.student 
##                         0                         0 
##    healthproblems.seekjob   healthproblems.employed 
##                         0                         0 
## healthproblems.unemployed   healthproblems.inactive 
##                         0                         0 
##  healthproblems.housework 
##                         0 
## 
## [[1]]$tau
##  healthproblems.territory        healthproblems.sex 
##                 0.0106950                 0.0002036 
##        healthproblems.age     healthproblems.agesex 
##                 0.0925443                 0.0936035 
##    healthproblems.famsize    healthproblems.student 
##                 0.0286152                 0.0096141 
##    healthproblems.seekjob   healthproblems.employed 
##                 0.0045980                 0.0761231 
## healthproblems.unemployed   healthproblems.inactive 
##                 0.0004661                 0.0832162 
##  healthproblems.housework 
##                 0.0029997 
## 
## [[1]]$U
##  healthproblems.territory        healthproblems.sex 
##                 0.0097533                 0.0001837 
##        healthproblems.age     healthproblems.agesex 
##                 0.0800527                 0.0812921 
##    healthproblems.famsize    healthproblems.student 
##                 0.0255857                 0.0102825 
##    healthproblems.seekjob   healthproblems.employed 
##                 0.0045818                 0.0705302 
## healthproblems.unemployed   healthproblems.inactive 
##                 0.0004356                 0.0752068 
##  healthproblems.housework 
##                 0.0026980 
## 
## 
## [[2]]
## [[2]]$V
##  languages.territory        languages.sex        languages.age 
##              0.17699              0.02676              0.26705 
##     languages.agesex    languages.famsize    languages.student 
##              0.27079              0.09899              0.33275 
##    languages.seekjob   languages.employed languages.unemployed 
##              0.11842              0.29142              0.04615 
##   languages.inactive  languages.housework 
##              0.30901              0.06084 
## 
## [[2]]$lambda
##  languages.territory        languages.sex        languages.age 
##              0.03181              0.00000              0.15094 
##     languages.agesex    languages.famsize    languages.student 
##              0.16043              0.00000              0.09525 
##    languages.seekjob   languages.employed languages.unemployed 
##              0.01624              0.08000              0.00000 
##   languages.inactive  languages.housework 
##              0.07532              0.00000 
## 
## [[2]]$tau
##  languages.territory        languages.sex        languages.age 
##            0.0214967            0.0002313            0.0891212 
##     languages.agesex    languages.famsize    languages.student 
##            0.0914929            0.0082349            0.0457622 
##    languages.seekjob   languages.employed languages.unemployed 
##            0.0050221            0.0360852            0.0006162 
##   languages.inactive  languages.housework 
##            0.0401371            0.0012527 
## 
## [[2]]$U
##  languages.territory        languages.sex        languages.age 
##            0.0238731            0.0002707            0.0835937 
##     languages.agesex    languages.famsize    languages.student 
##            0.0860781            0.0075648            0.0399309 
##    languages.seekjob   languages.employed languages.unemployed 
##            0.0052366            0.0328254            0.0007589 
##   languages.inactive  languages.housework 
##            0.0372979            0.0013995 
## 
## 
## [[3]]
## [[3]]$V
##  holidaydest.territory        holidaydest.sex        holidaydest.age 
##                0.02696                0.04568                0.17345 
##     holidaydest.agesex    holidaydest.famsize    holidaydest.student 
##                0.17957                0.10774                0.12068 
##    holidaydest.seekjob   holidaydest.employed holidaydest.unemployed 
##                0.04753                0.30155                0.03705 
##   holidaydest.inactive  holidaydest.housework 
##                0.29020                0.03131 
## 
## [[3]]$lambda
##  holidaydest.territory        holidaydest.sex        holidaydest.age 
##               0.000000               0.000000               0.078029 
##     holidaydest.agesex    holidaydest.famsize    holidaydest.student 
##               0.078029               0.034273               0.000000 
##    holidaydest.seekjob   holidaydest.employed holidaydest.unemployed 
##               0.001213               0.074156               0.000000 
##   holidaydest.inactive  holidaydest.housework 
##               0.079580               0.000000 
## 
## [[3]]$tau
##  holidaydest.territory        holidaydest.sex        holidaydest.age 
##              0.0004903              0.0009850              0.0347063 
##     holidaydest.agesex    holidaydest.famsize    holidaydest.student 
##              0.0369593              0.0126042              0.0036114 
##    holidaydest.seekjob   holidaydest.employed holidaydest.unemployed 
##              0.0012472              0.0392954              0.0004572 
##   holidaydest.inactive  holidaydest.housework 
##              0.0365039              0.0004107 
## 
## [[3]]$U
##  holidaydest.territory        holidaydest.sex        holidaydest.age 
##              0.0006071              0.0008755              0.0381948 
##     holidaydest.agesex    holidaydest.famsize    holidaydest.student 
##              0.0405800              0.0097601              0.0054400 
##    holidaydest.seekjob   holidaydest.employed holidaydest.unemployed 
##              0.0009346              0.0389938              0.0006044 
##   holidaydest.inactive  holidaydest.housework 
##              0.0356665              0.0004111 
## 
## 
## [[4]]
## [[4]]$V
##  sparetime.territory        sparetime.sex        sparetime.age 
##              0.03474              0.07454              0.27874 
##     sparetime.agesex    sparetime.famsize    sparetime.student 
##              0.29269              0.16406              0.10051 
##    sparetime.seekjob   sparetime.employed sparetime.unemployed 
##              0.03179              0.40115              0.05462 
##   sparetime.inactive  sparetime.housework 
##              0.37963              0.07213 
## 
## [[4]]$lambda
##  sparetime.territory        sparetime.sex        sparetime.age 
##             0.000000             0.000000             0.213047 
##     sparetime.agesex    sparetime.famsize    sparetime.student 
##             0.213585             0.089320             0.000000 
##    sparetime.seekjob   sparetime.employed sparetime.unemployed 
##             0.001005             0.232026             0.011606 
##   sparetime.inactive  sparetime.housework 
##             0.220420             0.000000 
## 
## [[4]]$tau
##  sparetime.territory        sparetime.sex        sparetime.age 
##            0.0017267            0.0017716            0.0938600 
##     sparetime.agesex    sparetime.famsize    sparetime.student 
##            0.1003318            0.0287919            0.0063213 
##    sparetime.seekjob   sparetime.employed sparetime.unemployed 
##            0.0006365            0.0966504            0.0019044 
##   sparetime.inactive  sparetime.housework 
##            0.0861724            0.0033970 
## 
## [[4]]$U
##  sparetime.territory        sparetime.sex        sparetime.age 
##            0.0012317            0.0028487            0.0808369 
##     sparetime.agesex    sparetime.famsize    sparetime.student 
##            0.0887035            0.0278583            0.0054836 
##    sparetime.seekjob   sparetime.employed sparetime.unemployed 
##            0.0005092            0.0848368            0.0014895 
##   sparetime.inactive  sparetime.housework 
##            0.0751506            0.0026477 
## 
## 
## [[5]]
## [[5]]$V
##  indsocial.territory        indsocial.sex        indsocial.age 
##             0.061094             0.031531             0.108355 
##     indsocial.agesex    indsocial.famsize    indsocial.student 
##             0.115452             0.041322             0.039945 
##    indsocial.seekjob   indsocial.employed indsocial.unemployed 
##             0.017651             0.120289             0.008146 
##   indsocial.inactive  indsocial.housework 
##             0.125178             0.039125 
## 
## [[5]]$lambda
##  indsocial.territory        indsocial.sex        indsocial.age 
##                    0                    0                    0 
##     indsocial.agesex    indsocial.famsize    indsocial.student 
##                    0                    0                    0 
##    indsocial.seekjob   indsocial.employed indsocial.unemployed 
##                    0                    0                    0 
##   indsocial.inactive  indsocial.housework 
##                    0                    0 
## 
## [[5]]$tau
##  indsocial.territory        indsocial.sex        indsocial.age 
##            5.571e-03            5.929e-04            1.812e-02 
##     indsocial.agesex    indsocial.famsize    indsocial.student 
##            1.908e-02            1.704e-03            1.792e-04 
##    indsocial.seekjob   indsocial.employed indsocial.unemployed 
##            2.818e-04            1.313e-02            5.966e-05 
##   indsocial.inactive  indsocial.housework 
##            1.422e-02            9.466e-04 
## 
## [[5]]$U
##  indsocial.territory        indsocial.sex        indsocial.age 
##            4.840e-03            6.456e-04            1.624e-02 
##     indsocial.agesex    indsocial.famsize    indsocial.student 
##            1.810e-02            2.306e-03            1.471e-03 
##    indsocial.seekjob   indsocial.employed indsocial.unemployed 
##            2.043e-04            9.411e-03            4.328e-05 
##   indsocial.inactive  indsocial.housework 
##            1.015e-02            9.935e-04 
## 
## 
## [[6]]
## [[6]]$V
##  famsocial.territory        famsocial.sex        famsocial.age 
##             0.049902             0.051069             0.067930 
##     famsocial.agesex    famsocial.famsize    famsocial.student 
##             0.087608             0.041279             0.020240 
##    famsocial.seekjob   famsocial.employed famsocial.unemployed 
##             0.014914             0.085944             0.008318 
##   famsocial.inactive  famsocial.housework 
##             0.090433             0.034325 
## 
## [[6]]$lambda
##  famsocial.territory        famsocial.sex        famsocial.age 
##                    0                    0                    0 
##     famsocial.agesex    famsocial.famsize    famsocial.student 
##                    0                    0                    0 
##    famsocial.seekjob   famsocial.employed famsocial.unemployed 
##                    0                    0                    0 
##   famsocial.inactive  famsocial.housework 
##                    0                    0 
## 
## [[6]]$tau
##  famsocial.territory        famsocial.sex        famsocial.age 
##            2.750e-03            1.585e-03            4.434e-03 
##     famsocial.agesex    famsocial.famsize    famsocial.student 
##            7.542e-03            1.432e-03            2.368e-04 
##    famsocial.seekjob   famsocial.employed famsocial.unemployed 
##            6.017e-05            3.717e-03            2.513e-05 
##   famsocial.inactive  famsocial.housework 
##            4.064e-03            8.171e-04 
## 
## [[6]]$U
##  famsocial.territory        famsocial.sex        famsocial.age 
##            6.237e-03            3.101e-03            1.110e-02 
##     famsocial.agesex    famsocial.famsize    famsocial.student 
##            1.787e-02            4.082e-03            5.288e-04 
##    famsocial.seekjob   famsocial.employed famsocial.unemployed 
##            2.515e-04            8.919e-03            8.636e-05 
##   famsocial.inactive  famsocial.housework 
##            9.617e-03            1.393e-03 
## 
## 
## [[7]]
## [[7]]$V
##  equipment.territory        equipment.sex        equipment.age 
##             0.040934             0.054942             0.395797 
##     equipment.agesex    equipment.famsize    equipment.student 
##             0.400565             0.274588             0.089946 
##    equipment.seekjob   equipment.employed equipment.unemployed 
##             0.088837             0.285837             0.074397 
##   equipment.inactive  equipment.housework 
##             0.323016             0.002515 
## 
## [[7]]$lambda
##  equipment.territory        equipment.sex        equipment.age 
##                    0                    0                    0 
##     equipment.agesex    equipment.famsize    equipment.student 
##                    0                    0                    0 
##    equipment.seekjob   equipment.employed equipment.unemployed 
##                    0                    0                    0 
##   equipment.inactive  equipment.housework 
##                    0                    0 
## 
## [[7]]$tau
##  equipment.territory        equipment.sex        equipment.age 
##            1.676e-03            3.019e-03            1.567e-01 
##     equipment.agesex    equipment.famsize    equipment.student 
##            1.605e-01            7.540e-02            8.091e-03 
##    equipment.seekjob   equipment.employed equipment.unemployed 
##            7.893e-03            8.170e-02            5.536e-03 
##   equipment.inactive  equipment.housework 
##            1.043e-01            6.334e-06 
## 
## [[7]]$U
##  equipment.territory        equipment.sex        equipment.age 
##            2.566e-03            4.729e-03            2.020e-01 
##     equipment.agesex    equipment.famsize    equipment.student 
##            2.048e-01            1.163e-01            1.989e-02 
##    equipment.seekjob   equipment.employed equipment.unemployed 
##            1.857e-02            1.459e-01            1.376e-02 
##   equipment.inactive  equipment.housework 
##            1.779e-01            9.849e-06 
## 
## 
## [[8]]
## [[8]]$V
##  housemode.territory        housemode.sex        housemode.age 
##              0.05801              0.02055              0.08664 
##     housemode.agesex    housemode.famsize    housemode.student 
##              0.09595              0.03053              0.01435 
##    housemode.seekjob   housemode.employed housemode.unemployed 
##              0.13305              0.05785              0.12096 
##   housemode.inactive  housemode.housework 
##              0.11375              0.06914 
## 
## [[8]]$lambda
##  housemode.territory        housemode.sex        housemode.age 
##                    0                    0                    0 
##     housemode.agesex    housemode.famsize    housemode.student 
##                    0                    0                    0 
##    housemode.seekjob   housemode.employed housemode.unemployed 
##                    0                    0                    0 
##   housemode.inactive  housemode.housework 
##                    0                    0 
## 
## [[8]]$tau
##  housemode.territory        housemode.sex        housemode.age 
##            0.0039185            0.0003378            0.0113214 
##     housemode.agesex    housemode.famsize    housemode.student 
##            0.0123972            0.0014598            0.0001418 
##    housemode.seekjob   housemode.employed housemode.unemployed 
##            0.0141942            0.0022088            0.0111271 
##   housemode.inactive  housemode.housework 
##            0.0092540            0.0038486 
## 
## [[8]]$U
##  housemode.territory        housemode.sex        housemode.age 
##            0.0089093            0.0006457            0.0244510 
##     housemode.agesex    housemode.famsize    housemode.student 
##            0.0292651            0.0028246            0.0002998 
##    housemode.seekjob   housemode.employed housemode.unemployed 
##            0.0204826            0.0051862            0.0162639 
##   housemode.inactive  housemode.housework 
##            0.0212774            0.0074727 
## 
## 
## [[9]]
## [[9]]$V
##  ownvehicles.territory        ownvehicles.sex        ownvehicles.age 
##                0.05372                0.12344                0.28873 
##     ownvehicles.agesex    ownvehicles.famsize    ownvehicles.student 
##                0.30949                0.28521                0.08434 
##    ownvehicles.seekjob   ownvehicles.employed ownvehicles.unemployed 
##                0.03545                0.37342                0.02870 
##   ownvehicles.inactive  ownvehicles.housework 
##                0.36579                0.09607 
## 
## [[9]]$lambda
##  ownvehicles.territory        ownvehicles.sex        ownvehicles.age 
##                0.00000                0.00000                0.08305 
##     ownvehicles.agesex    ownvehicles.famsize    ownvehicles.student 
##                0.09891                0.03975                0.00000 
##    ownvehicles.seekjob   ownvehicles.employed ownvehicles.unemployed 
##                0.00000                0.00000                0.00000 
##   ownvehicles.inactive  ownvehicles.housework 
##                0.00000                0.00000 
## 
## [[9]]$tau
##  ownvehicles.territory        ownvehicles.sex        ownvehicles.age 
##              0.0030574              0.0061332              0.0715905 
##     ownvehicles.agesex    ownvehicles.famsize    ownvehicles.student 
##              0.0842989              0.0656253              0.0027358 
##    ownvehicles.seekjob   ownvehicles.employed ownvehicles.unemployed 
##              0.0005086              0.0574761              0.0003264 
##   ownvehicles.inactive  ownvehicles.housework 
##              0.0555589              0.0035534 
## 
## [[9]]$U
##  ownvehicles.territory        ownvehicles.sex        ownvehicles.age 
##              0.0028496              0.0075533              0.0776997 
##     ownvehicles.agesex    ownvehicles.famsize    ownvehicles.student 
##              0.0878261              0.0820886              0.0035095 
##    ownvehicles.seekjob   ownvehicles.employed ownvehicles.unemployed 
##              0.0006356              0.0723371              0.0004215 
##   ownvehicles.inactive  ownvehicles.housework 
##              0.0675356              0.0045496 
## 
## 
## [[10]]
## [[10]]$V
##  ambientalcond.territory        ambientalcond.sex        ambientalcond.age 
##                  0.07836                  0.01186                  0.09152 
##     ambientalcond.agesex    ambientalcond.famsize    ambientalcond.student 
##                  0.10291                  0.04393                  0.03346 
##    ambientalcond.seekjob   ambientalcond.employed ambientalcond.unemployed 
##                  0.06512                  0.05912                  0.05277 
##   ambientalcond.inactive  ambientalcond.housework 
##                  0.08366                  0.02374 
## 
## [[10]]$lambda
##  ambientalcond.territory        ambientalcond.sex        ambientalcond.age 
##                        0                        0                        0 
##     ambientalcond.agesex    ambientalcond.famsize    ambientalcond.student 
##                        0                        0                        0 
##    ambientalcond.seekjob   ambientalcond.employed ambientalcond.unemployed 
##                        0                        0                        0 
##   ambientalcond.inactive  ambientalcond.housework 
##                        0                        0 
## 
## [[10]]$tau
##  ambientalcond.territory        ambientalcond.sex        ambientalcond.age 
##                7.266e-03                8.746e-05                1.041e-02 
##     ambientalcond.agesex    ambientalcond.famsize    ambientalcond.student 
##                1.244e-02                2.408e-03                6.959e-04 
##    ambientalcond.seekjob   ambientalcond.employed ambientalcond.unemployed 
##                2.533e-03                2.090e-03                1.739e-03 
##   ambientalcond.inactive  ambientalcond.housework 
##                4.258e-03                3.206e-04 
## 
## [[10]]$U
##  ambientalcond.territory        ambientalcond.sex        ambientalcond.age 
##                6.235e-03                7.092e-05                8.609e-03 
##     ambientalcond.agesex    ambientalcond.famsize    ambientalcond.student 
##                1.072e-02                1.952e-03                5.591e-04 
##    ambientalcond.seekjob   ambientalcond.employed ambientalcond.unemployed 
##                2.072e-03                1.766e-03                1.386e-03 
##   ambientalcond.inactive  ambientalcond.housework 
##                3.551e-03                2.839e-04 
## 
## 
## [[11]]
## [[11]]$V
##  econstatus.territory        econstatus.sex        econstatus.age 
##               0.05538               0.05114               0.15172 
##     econstatus.agesex    econstatus.famsize    econstatus.student 
##               0.16251               0.19422               0.02811 
##    econstatus.seekjob   econstatus.employed econstatus.unemployed 
##               0.07331               0.34493               0.14219 
##   econstatus.inactive  econstatus.housework 
##               0.28496               0.03193 
## 
## [[11]]$lambda
##  econstatus.territory        econstatus.sex        econstatus.age 
##               0.00000               0.00000               0.03867 
##     econstatus.agesex    econstatus.famsize    econstatus.student 
##               0.05291               0.01227               0.00000 
##    econstatus.seekjob   econstatus.employed econstatus.unemployed 
##               0.00000               0.14252               0.00000 
##   econstatus.inactive  econstatus.housework 
##               0.10329               0.00000 
## 
## [[11]]$tau
##  econstatus.territory        econstatus.sex        econstatus.age 
##             0.0019908             0.0018729             0.0268785 
##     econstatus.agesex    econstatus.famsize    econstatus.student 
##             0.0306785             0.0259403             0.0003958 
##    econstatus.seekjob   econstatus.employed econstatus.unemployed 
##             0.0023098             0.0591605             0.0074809 
##   econstatus.inactive  econstatus.housework 
##             0.0428647             0.0006163 
## 
## [[11]]$U
##  econstatus.territory        econstatus.sex        econstatus.age 
##             0.0030963             0.0013635             0.0249221 
##     econstatus.agesex    econstatus.famsize    econstatus.student 
##             0.0285046             0.0459469             0.0004167 
##    econstatus.seekjob   econstatus.employed econstatus.unemployed 
##             0.0027058             0.0649024             0.0095622 
##   econstatus.inactive  econstatus.housework 
##             0.0433174             0.0005314 
## 
## 
## [[12]]
## [[12]]$V
##  income.territory        income.sex        income.age     income.agesex 
##           0.12959           0.09853           0.18232           0.20315 
##    income.famsize    income.student    income.seekjob   income.employed 
##           0.24784           0.08452           0.05894           0.37372 
## income.unemployed   income.inactive  income.housework 
##           0.14286           0.31181           0.11875 
## 
## [[12]]$lambda
##  income.territory        income.sex        income.age     income.agesex 
##           0.00000           0.00000           0.00000           0.02391 
##    income.famsize    income.student    income.seekjob   income.employed 
##           0.00000           0.00000           0.00000           0.00000 
## income.unemployed   income.inactive  income.housework 
##           0.00000           0.00000           0.00000 
## 
## [[12]]$tau
##  income.territory        income.sex        income.age     income.agesex 
##         0.0109554         0.0032050         0.0267815         0.0346961 
##    income.famsize    income.student    income.seekjob   income.employed 
##         0.0325829         0.0019216         0.0009594         0.0376483 
## income.unemployed   income.inactive  income.housework 
##         0.0056873         0.0260856         0.0039348 
## 
## [[12]]$U
##  income.territory        income.sex        income.age     income.agesex 
##          0.016543          0.003864          0.037389          0.044657 
##    income.famsize    income.student    income.seekjob   income.employed 
##          0.049639          0.003049          0.001403          0.059771 
## income.unemployed   income.inactive  income.housework 
##          0.007769          0.039622          0.005606 
## 
## 
## [[13]]
## [[13]]$V
##  moneyend.territory        moneyend.sex        moneyend.age 
##            0.106359            0.010298            0.052075 
##     moneyend.agesex    moneyend.famsize    moneyend.student 
##            0.067441            0.008321            0.004652 
##    moneyend.seekjob   moneyend.employed moneyend.unemployed 
##            0.162045            0.101967            0.190185 
##   moneyend.inactive  moneyend.housework 
##            0.014611            0.041234 
## 
## [[13]]$lambda
##  moneyend.territory        moneyend.sex        moneyend.age 
##             0.00000             0.00000             0.00000 
##     moneyend.agesex    moneyend.famsize    moneyend.student 
##             0.00000             0.00000             0.00000 
##    moneyend.seekjob   moneyend.employed moneyend.unemployed 
##             0.05014             0.00000             0.07105 
##   moneyend.inactive  moneyend.housework 
##             0.00000             0.00000 
## 
## [[13]]$tau
##  moneyend.territory        moneyend.sex        moneyend.age 
##           1.131e-02           1.061e-04           2.712e-03 
##     moneyend.agesex    moneyend.famsize    moneyend.student 
##           4.548e-03           6.924e-05           2.166e-05 
##    moneyend.seekjob   moneyend.employed moneyend.unemployed 
##           2.626e-02           1.040e-02           3.617e-02 
##   moneyend.inactive  moneyend.housework 
##           2.135e-04           1.700e-03 
## 
## [[13]]$U
##  moneyend.territory        moneyend.sex        moneyend.age 
##           8.921e-03           8.198e-05           2.088e-03 
##     moneyend.agesex    moneyend.famsize    moneyend.student 
##           3.544e-03           5.335e-05           1.669e-05 
##    moneyend.seekjob   moneyend.employed moneyend.unemployed 
##           1.919e-02           8.046e-03           2.643e-02 
##   moneyend.inactive  moneyend.housework 
##           1.649e-04           1.316e-03
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
## [[1]]
## [[1]]$V
## labour.student labour.seekjob 
##         0.8869         0.9070 
## 
## [[1]]$lambda
## labour.student labour.seekjob 
##         0.5185         0.1725 
## 
## [[1]]$tau
## labour.student labour.seekjob 
##         0.4787         0.1698 
## 
## [[1]]$U
## labour.student labour.seekjob 
##         0.4373         0.2789
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
## [1] "concatenate"
## 
## Slot "role":
## [1] "incomplete"
## 
## Slot "data":
##    territory     age    sex         agesex famsize student seekjob
## 1      Araba (24,34]   Male   Male.(24,34]      3+   FALSE   FALSE
## 2      Araba (24,34]   Male   Male.(24,34]      3+   FALSE   FALSE
## 3      Araba     65+   Male       Male.65+       2   FALSE   FALSE
## 4      Araba (44,54] Female Female.(44,54]      3+   FALSE   FALSE
## 5      Araba (54,64] Female Female.(54,64]      3+   FALSE   FALSE
## 6      Araba     65+   Male       Male.65+       2   FALSE   FALSE
## 7      Araba     65+ Female     Female.65+       2   FALSE   FALSE
## 8      Araba     65+ Female     Female.65+       1   FALSE   FALSE
## 9      Araba     65+   Male       Male.65+       2   FALSE   FALSE
## 10     Araba     65+ Female     Female.65+       2   FALSE   FALSE
##    employed unemployed inactive workhours             housework
## 1      TRUE      FALSE    FALSE   (35,44]         Deals with it
## 2     FALSE      FALSE     TRUE    [0,14] Does not deal with it
## 3     FALSE      FALSE     TRUE    [0,14] Does not deal with it
## 4     FALSE      FALSE     TRUE    [0,14]         Deals with it
## 5     FALSE      FALSE     TRUE    [0,14]         Deals with it
## 6     FALSE      FALSE     TRUE    [0,14] Does not deal with it
## 7     FALSE      FALSE     TRUE    [0,14]         Deals with it
## 8     FALSE      FALSE     TRUE    [0,14]         Deals with it
## 9     FALSE      FALSE     TRUE    [0,14] Does not deal with it
## 10    FALSE      FALSE     TRUE    [0,14]         Deals with it
##    healthproblems        languages holidaydest sparetime
## 1              No Sp+Basque+Others      Abroad      2-4h
## 2              No Sp+Basque+Others      Abroad      2-4h
## 3              No          Spanish      Abroad       +4h
## 4              No        Sp+Others      Abroad      2-4h
## 5              No Sp+Basque+Others No response      2-4h
## 6            <NA>             <NA>        <NA>      <NA>
## 7            <NA>             <NA>        <NA>      <NA>
## 8            <NA>             <NA>        <NA>      <NA>
## 9            <NA>             <NA>        <NA>      <NA>
## 10           <NA>             <NA>        <NA>      <NA>
##                indsocial     famsocial equipment housemode ownvehicles
## 1  At least once a month  No relations      Good     Owner   1 vehicle
## 2  At least once a month  No relations      Good     Owner   2 or more
## 3  At least once a month Very frequent      Good     Owner   1 vehicle
## 4  At least once a month      Frequent      Good     Owner   2 or more
## 5  At least once a month Very frequent      Good     Owner   1 vehicle
## 6                   <NA>          <NA>      <NA>      <NA>        <NA>
## 7                   <NA>          <NA>      <NA>      <NA>        <NA>
## 8                   <NA>          <NA>      <NA>      <NA>        <NA>
## 9                   <NA>          <NA>      <NA>      <NA>        <NA>
## 10                  <NA>          <NA>      <NA>      <NA>        <NA>
##    ambientalcond econstatus income moneyend weights
## 1    One problem       Good   High      Yes  412.24
## 2    No problems       Good   High      Yes  412.24
## 3    No problems   Standard Medium      Yes  347.39
## 4    No problems       Good Medium       No  363.40
## 5    No problems       Good   High      Yes  307.23
## 6           <NA>       <NA>   <NA>     <NA>   88.20
## 7           <NA>       <NA>   <NA>     <NA>   85.09
## 8           <NA>       <NA>   <NA>     <NA>   85.09
## 9           <NA>       <NA>   <NA>     <NA>   88.20
## 10          <NA>       <NA>   <NA>     <NA>   85.09
##                                            labour origin
## 1                                            <NA>  file1
## 2                                            <NA>  file1
## 3                                            <NA>  file1
## 4                                            <NA>  file1
## 5                                            <NA>  file1
## 6                             Inactive or retired  file2
## 7  Non-working activity (studying, housework,...)  file2
## 8  Non-working activity (studying, housework,...)  file2
## 9                             Inactive or retired  file2
## 10 Non-working activity (studying, housework,...)  file2
## 
## Slot "matchvars":
## [1] "territory"  "famsize"    "student"    "seekjob"    "employed"  
## [6] "unemployed" "inactive"   "workhours"  "housework" 
## 
## Slot "specvars":
##  [1] "healthproblems" "languages"      "holidaydest"    "sparetime"     
##  [5] "indsocial"      "famsocial"      "equipment"      "housemode"     
##  [9] "ownvehicles"    "ambientalcond"  "econstatus"     "income"        
## [13] "moneyend"       "labour"        
## 
## Slot "stratavars":
## [1] "agesex"
## 
## Slot "weights":
## [1] "weights" "weights"
```

Match via hot-deck

```r
filled.rec2.prueba <- match.hotdeck(x = rec2.prueba, y = don2.prueba)
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
## [1] "concatenate"
## 
## Slot "role":
## [1] "incomplete"
## 
## Slot "data":
##   territory     age    sex         agesex famsize student seekjob employed
## 1     Araba (24,34]   Male   Male.(24,34]      3+   FALSE   FALSE     TRUE
## 2     Araba (24,34]   Male   Male.(24,34]      3+   FALSE   FALSE    FALSE
## 3     Araba     65+   Male       Male.65+       2   FALSE   FALSE    FALSE
## 4     Araba (44,54] Female Female.(44,54]      3+   FALSE   FALSE    FALSE
## 5     Araba (54,64] Female Female.(54,64]      3+   FALSE   FALSE    FALSE
##   unemployed inactive workhours             housework healthproblems
## 1      FALSE    FALSE   (35,44]         Deals with it             No
## 2      FALSE     TRUE    [0,14] Does not deal with it             No
## 3      FALSE     TRUE    [0,14] Does not deal with it             No
## 4      FALSE     TRUE    [0,14]         Deals with it             No
## 5      FALSE     TRUE    [0,14]         Deals with it             No
##          languages holidaydest sparetime             indsocial
## 1 Sp+Basque+Others      Abroad      2-4h At least once a month
## 2 Sp+Basque+Others      Abroad      2-4h At least once a month
## 3          Spanish      Abroad       +4h At least once a month
## 4        Sp+Others      Abroad      2-4h At least once a month
## 5 Sp+Basque+Others No response      2-4h At least once a month
##       famsocial equipment housemode ownvehicles ambientalcond econstatus
## 1  No relations      Good     Owner   1 vehicle   One problem       Good
## 2  No relations      Good     Owner   2 or more   No problems       Good
## 3 Very frequent      Good     Owner   1 vehicle   No problems   Standard
## 4      Frequent      Good     Owner   2 or more   No problems       Good
## 5 Very frequent      Good     Owner   1 vehicle   No problems       Good
##   income moneyend weights                                         labour
## 1   High      Yes   412.2 Non-working activity (studying, housework,...)
## 2   High      Yes   412.2                            Inactive or retired
## 3 Medium      Yes   347.4                            Inactive or retired
## 4 Medium       No   363.4 Non-working activity (studying, housework,...)
## 5   High      Yes   307.2 Non-working activity (studying, housework,...)
## 
## Slot "matchvars":
## [1] "territory"  "famsize"    "student"    "seekjob"    "employed"  
## [6] "unemployed" "inactive"   "workhours"  "housework" 
## 
## Slot "specvars":
##  [1] "healthproblems" "languages"      "holidaydest"    "sparetime"     
##  [5] "indsocial"      "famsocial"      "equipment"      "housemode"     
##  [9] "ownvehicles"    "ambientalcond"  "econstatus"     "income"        
## [13] "moneyend"       "labour"        
## 
## Slot "stratavars":
## [1] "agesex"
## 
## Slot "weights":
## [1] "weights"
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

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12.png) 

Bad results!

**With variable selection**

* Match


```r
#Match
varshared[-c(6,7)] #variables to keep
```

```
##  [1] "territory"  "sex"        "age"        "agesex"     "famsize"   
##  [6] "employed"   "unemployed" "inactive"   "workhours"  "housework"
```

```r
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

```
## ymax not defined: adjusting position using y instead
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14.png) 

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

### References

[1] D'Orazio, M., Di Zio, M., & Scanu, M. (2006). *Statistical matching: Theory and practice*. John Wiley & Sons.
[2] Rässler, S. (2002). *Statistical matching*. Springer.
[3] * *Data Integration* ESSnet project (http://www.cros-portal.eu/content/data-integration-finished)
[4] * *ISAD* ESSnet project (http://www.cros-portal.eu/content/isad-finished)
[5] Leulescu A. & Agafitei, M. *Statistical matching: a model based approach for data integration*, Eurostat methodologies and working papers, 2013.
