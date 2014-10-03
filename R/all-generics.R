### All generic functions

#' Generic: "remove"
#' applies to a 'filetomatch' object
#' @export
setGeneric("remove",
           function(x="filetomatch",...) {
                   standardGeneric("remove")
})

#' Generic: "include"
#' applies to a 'filetomatch' object
#' @export
setGeneric("include",
           function(x="filetomatch",...) {
                   standardGeneric("include")
})

#' Generic: "select_strata"
#' applies to a 'filetomatch' object
#' @export
setGeneric("select_strata",
           function(x="filetomatch",...) {
                   standardGeneric("select_strata")
})

#' Generic: "select_observations"
#' applies to a 'filetomatch' object
#' @export
setGeneric("select_observations",
           function(x="filetomatch",...) {
                   standardGeneric("select_observations")
})

#' Generic: "compare_var"
#' applies to pairs of 'filetomatch' objects
#' @export
setGeneric("compare_var",
           function(x="filetomatch", y="filetomatch",...) {
                   standardGeneric("compare_var")
})

#' Generic: "compare_var_strata"
#' applies to pairs of 'filetomatch' objects
#' @export
setGeneric("compare_var_strata",
           function(x="filetomatch", y="filetomatch",...) {
                   standardGeneric("compare_var_strata")
})

#' Generic: "compare_matchvars"
#' applies to pairs of 'filetomatch' objects
#' @export
setGeneric("compare_matchvars",
           function(x="filetomatch", y="filetomatch",...) {
                   standardGeneric("compare_matchvars")
})

#' Generic: "predictvalue"
#' applies to a 'filetomatch' object
#' @export
setGeneric("predictvalue",
           function(x="filetomatch",...) {
                   standardGeneric("predictvalue")
})

#OJO. compare no necesario, eliminar.
#' Generic: "compare"
#' applies to pairs of 'filetomatch' objects
#' @export
setGeneric("compare",
           function(x="filetomatch",y="filetomatch",...) {
                   standardGeneric("compare")
})

#' Generic: "concatenate"
#' applies to pairs of 'filetomatch' objects
#' @export
setGeneric("concatenate",
           function(x="filetomatch",y="filetomatch",...) {
                   standardGeneric("concatenate")
})

#' Generic: "match"
#'  applies to pairs of 'filetomatch' objects
#' @export
setGeneric("match.hotdeck",
           function(x="filetomatch",y="filetomatch",...) {
                   standardGeneric("match.hotdeck")
})

