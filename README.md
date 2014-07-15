micromatch package
==================

Repository for micromatch package.

More information on uses & actual degree of development: (http://rpubs.com/inesgn/micromatch_explained)

### What is the aim of this package?
The aim of `micromatch` is to provide the user with some utilities and functions to ease the task of statistical matching of official microdata files.

### What is statistical matching, anyway?
The methodology of statistical matching (survey linking, or data fusion more generally) is closely related to two projects of the European Statistical System (ESSnet), led by the Italian Statistical Office (ISTAT) during the years 2009-2011 and 2006-2008, and aims to integrate data from independent surveys referred to the same population.
The idea behind this methodology is that many surveys run in the same population (i.e. referred to the same place and time) have certain variables in common that we could use to extract specific conclusions regarding to non-jointly observed measures, that is, variables that are not measured by the same questionnaire.

For example, one survey could measure family expenditures, while another measures income. The solution of designing an unique questionnaire to measure all the dimensions is not always viable: questionnaires quickly become too costly and too long. 

Besides, oftentimes, people interested in analyzing survey data are not the ones that produce them; also, surveys are often produced by different institutions; in this cases, statistical matching is the only possible choice. 

### Why do we need this package?

Many functions exists accross R packages that are helpful for the statistical matching task. However, it seems there's a lack of process view, that is, it seems that no package organizes the statistical matching task according to the different phases it must tackle: variable selection, applying a particular method to get results (usually, in the form of a fused file, or synthetic file with all the variables of interest), and assessing the results.

This package focuses on this process view in order to help the user easily undertake the statistical matching task.

### References
* *Data Integration* ESSnet project (http://www.cros-portal.eu/content/data-integration-finished)
* *ISAD* ESSnet project (http://www.cros-portal.eu/content/isad-finished)
* *Statistical matching: a model based approach for data integration*, Eurostat methodolgies and working papers, 2013.
* *Statistical Matching, Theory and Practice*, Marcello D'Orazio, Marco Di Zio, Mauro Scanu, Wiley, 2006.
* *Statistical Matching: A Frequentist Theory, Practical Applications and Alternative Bayesian Approaches (Lecture Notes in Statistics)*, S. Rässler, Springer, 2002.
