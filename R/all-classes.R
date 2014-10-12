#Class unions
#' @import methods
setClassUnion("charOrNull", c("character","NULL"))

#' @exportClass dataOrNull
setClassUnion("dataOrNull", c("data.frame","NULL"))

setClass("genericmatch", representation(data="dataOrNull",
                                        matchvars = "charOrNull",
                                        specvars = "charOrNull",
                                        stratavars = "charOrNull",
                                        weights = "charOrNull",#<-- para admitir varias columnas de pesos 
                                        "VIRTUAL"),
                         prototype= list(specvars = NULL, stratavars = NULL, weights = NULL)
)

#' Microdata file to be matched: data plus information related to matching
#' 
#' @details \code{filetomatch} objects contain all information needed for matching with
#' other, independent \code{filetomatch} objects.
#'  
#' \code{micromatch} provides specific functions to create \code{filetomatch} objects:
#' \code{\link{receptor}}, \code{\link{donor}} and \code{\link{symmetric}}.
#' (i.e. they should not be created manually by the user).
#' @name filetomatch-class
#' @rdname filetomatch-class
#' @family "Matching definition step"
#' @slot data data frame
#' @slot matchvars name of shared variables with respecto to another independent \code{filetomatch} object
#' @slot specvars name of specific variables. Must be columns in \code{data}
#' @slot stratavars name of a strata variable (optional). Must be a column in \code{data}
#' @slot weights name of weight variables (optional). Must be columns in \code{data}
#' @slot role character indicating role of the file: \code{receptor}, \code{donor} or \code{symmetric}
#' @exportClass filetomatch
setClass("filetomatch", 
         representation(role = "character"), 
         contains = "genericmatch",
         prototype(role = "symmetric")
) 

#' Result of either matching or concatenation of two or more \code{filetomatch} objects
#' 
#' @description Result of either matching (by any method: hot deck, pmm,...) or concatenation of two 
#' or more \code{\link{filetomatch}} objects containing independent microdata files
#' 
#' @details \code{fusedfile} objects contain the result of either matching or concatenation 
#' two or more \code{filetomatch} objects.
#'  
#' \code{micromatch} provides specific functions to create \code{fusedfile} objects:
#' \code{\link{match.hotdeck}}, \code{\link{concatenate}},...
#' 
#' \code{fusedfile} objects should not be created manually by the user.
#' @name fusedfile-class
#' @rdname fusedfile-class
#' @family "Apply matching method"
#' @slot data data frame
#' @slot matchvars name of shared variables with respecto to another independent \code{filetomatch} object
#' @slot specvars name of specific variables. Must be columns in \code{data}
#' @slot stratavars name of a strata variable (optional). Must be a column in \code{data}
#' @slot weights name of weight variables (optional). Must be columns in \code{data}
#' @slot role character indicating role of the file: \code{receptor}, \code{donor} or \code{symmetric}
#' @slot origin_specvars character vector to trace the origin of specific variables (i.e. \code{specvars} of the fused \code{\link{filetomatch}} objects)
#' @slot origin_weights character vector to trace the origin of weight variables (i.e. \code{weights} of the fused \code{\link{filetomatch}} objects)
#' @slot method method used to produce the \code{fusedfile} object: concatenation, hot-deck,...
#' @exportClass fusedfile 
setClass("fusedfile", 
         representation(origin_specvars = "character",
                        origin_weights = "character",
                        method = "character"), 
         contains = "filetomatch"
)