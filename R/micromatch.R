#' A package with utilities and functions for statistically matching official microdata files
#' 
#' \code{micromatch} package provides the user with some utilities and functions to help in the 
#' task of fusing or merging independent microdata files, with a particular orientation to official statistics.
#' 
#' @details
#' By applying statistical matching methods, the user can perform statistical analyses
#' for variables coming from different data sources (usually, independent surveys run on 
#' a certain population of interest), thus enhancing the analytical possibilities for 
#' existing microdata files.
#' 
#' 
#' @section Package structure:
#' 
#' The functions, classes and methods in \code{micromatch} are organized according 
#' to the four main stages in the statistical matching process, namely: 
#' 
#' \itemize{
#'      \item{Stage #1: Specify matching objectives}
#'      \item{Stage #2: Selecting matching variables}
#'      \item{Stage #3: Applying matching method}
#'      \item{Stage #4: Validating results}
#' }
#' 
#' Each stage of the matching process is covered by a family of functions, classes or methods in \code{micromatch}.
#' 
#' @section Specify matching objectives:
#' 
#' \itemize{
#'      \item \code{\link{matchdesign-class}}: performs...
#'      \item \code{\link{compareVar}}
#'      \item \code{\link{compareMultivar}}
#' }
#'      
#' @section Selecting matching variables:
#' @section Applying matching method:
#' @section Validating results:
#' @section Example data:
#' Example data is also available in \code{micromatch}
#' 
#' \itemize{
#'      \item \code{\link{ecv}}: Data from the Living Conditions Survey, year 2009, run by Eustat (Basque Statistical Office, Spain)
#'      \item \code{\link{pra}}: Data from the Population with Relation to Activity Survey, 4th quarter of 2009, run by Eustat (Basque Statistical Office, Spain)
#' }
#' 
#' 
#' @author Ines Garmendia
#' @import StatMatch ggplot2 gridExtra mice vcd
#' @docType package
#' @name micromatch
NULL


