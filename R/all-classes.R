#Class unions
#' @import methods
#' @exportClass charOrNull
setClassUnion("charOrNull", c("character","NULL"))

#' @exportClass dataOrNull
setClassUnion("dataOrNull", c("data.frame","NULL"))

#' Generic matching class
#' 
#' @name genericmatch-class
#' @rdname genericmatch-class
#' @family "Matching definition step"
#' @exportClass genericmatch
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
#' @name filetomatch-class
#' @rdname filetomatch-class
#' @family "Matching definition step"
#' @exportClass filetomatch
setClass("filetomatch", 
         representation(role = "character"), 
         contains = "genericmatch",
         prototype(role = "symmetric")
) 

#' Microdata file after matching or concatenation w.r.t. another microdata file
#' 
#' @name fusedfile-class
#' @rdname fusedfile-class
#' @family "Matching definition step"
#' @exportClass fusedfile 
setClass("fusedfile", 
         representation(origin_specvars = "character",
                        origin_weights = "character",
                        method = "character"), 
         contains = "filetomatch"
)