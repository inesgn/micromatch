### All generic functions

###Utilities
#' Remove variables from a \code{filetomatch} object
#' 
#' @description \code{remove} creates a new \code{\link{filetomatch}} object by removing the 
#' indicated variables from the corresponding place in the \code{filematch} objects: 
#' \code{matchvars}, \code{stratavars}, or \code{weightvars}. 
#' 
#' Note that the new object must be assigned to a name in order to re-use it.
#' 
#' @param x a \code{\link{filetomatch}} object
#' @param vars names of variables to be removed (can be more than one)
#' @family "Utilities"
#' @export
setGeneric("remove",
           function(x="filetomatch",...) {
                   standardGeneric("remove")
})

#' Add variables to a \code{filetomatch} object
#' 
#' @description \code{include} creates a new \code{\link{filetomatch}} object by adding the 
#' indicated variables to a \code{filematch} object. 
#' 
#' The type of varible has to be specified by means of the \code{as} parameter value:
#' \code{matchvars}, \code{stratavars}, or \code{weightvars}. 
#' 
#' @param x a \code{\link{filetomatch}} object
#' @param vars names of variables to be removed (can be more than one)
#' @param as name of slot where variables are to be added: \code{matchvars}, \code{specvars}, \code{stratavars} or \code{weightvars}
#' @family "Utilities"
#' @export
setGeneric("include",
           function(x="filetomatch",...) {
                   standardGeneric("include")
})

#' Update definition of a \code{filetomatch} object
#' 
#' @description \code{update} creates a new \code{\link{filetomatch}} object with updated values. 
#' 
#' The user may want to change any of these values (or any combination) in the definition of a previously created
#' \code{filetomatch} object: \code{data}, \code{matchvars}, \code{specvars}, \code{weights} 
#' or \code{role}.
#' 
#' @details
#' Note that, in particular, the role of a \code{receptor} file can be changed to \code{donor} 
#' or \code{symmetric}, or viceversa by updating the \code{role} value.
#' 
#' Note that the new object has to be stored (i.e. must be given a name).
#' 
#' @param x a \code{\link{filetomatch}} object
#' @param data new data frame
#' @param matchvars names of new matching variables
#' @param specvars names of new specific variables
#' @param stratavars names of new strata variables
#' @param weights names of weights variables
#' @param role new role: receptor, donor or symmetric
#' @family "Utilities"
#' @export
setGeneric("update",
           function(x="filetomatch",...) {
                   standardGeneric("update")
})

#' Select data for a strata value in a \code{filetomatch} object
#' 
#' @description \code{select_strata} creates a new \code{\link{filetomatch}} object 
#' by selecting the indicated strata value for a \code{stratavars} variable 
#' in the object. 
#' 
#' The result is a new \code{filematch} object where rows have been filtered for the 
#' by the indicated strata value in \code{data}.
#' 
#' @param x a \code{\link{filetomatch}} object
#' @param value wanted value to filter with \code{stratavars} variable
#' @family "Utilities"
#' @export
setGeneric("select_strata",
           function(x="filetomatch",...) {
                   standardGeneric("select_strata")
})

#' Select data for a strata value in a \code{filetomatch} object
#' 
#' @description \code{select_strata} creates a new \code{\link{filetomatch}} object 
#' by selecting the indicated rows value for the \code{data}.
#' 
#' The result is a new \code{filematch} object where rows have been filtered for the 
#' as indicated.
#' 
#' @param x a \code{\link{filetomatch}} object
#' @param obs indices of rows to keep in \code{data}
#' @family "Utilities"
#' @export
setGeneric("select_observations",
           function(x="filetomatch",...) {
                   standardGeneric("select_observations")
})

###Comparison functions
#' Compare a (single) shared variable across two \code{filetomatch} objects
#' 
#' @description \code{compare_var} function compares a single variable across two
#' separate \code{\link{filetomatch}} objects.
#' 
#' @details The name of the variables in each of the files (\code{var_A} and \code{var_B}) 
#' could be different, but the categories must be exactly the same in order to 
#' avoid problems when making the comparison.
#' 
#' Note that \code{weights} names (if used) must be equal in the two \code{filetomatch} objects.
#' 
#' @family "Select matching variables"
#' @return Table, plot or measures
#' @param x \code{filetomatch} object
#' @param y \code{filetomatch} object
#' @param var_A name of variable in the first file
#' @param var_B name of variable in the second file
#' @param type type of desired result: table, plot or disimilarity measures
#' @param weights logical (\code{TRUE} or \code{FALSE}) to indicate if weights are to be used in the comparison
#' @export
setGeneric("compare_var",
           function(x="filetomatch", y="filetomatch",...) {
                   standardGeneric("compare_var")
})

#' Compare a (single) shared variable across two \code{filetomatch} objects 
#' by groups defined by the strata variable
#' 
#' @description \code{compare_var_strata} function compares a single variable 
#' across two separate \code{\link{filetomatch}} objects by considering groups 
#' defined by the \code{stratavars} variable in the \code{filetomatch} objects.
#' 
#' @details The name of the variables in each of the files (\code{var_A} and \code{var_B}) 
#' could be different, but the categories must be exactly the same in order to 
#' avoid problems when making the comparison.
#' 
#' Note that both \code{stratavars} and \code{weights} names (if used) 
#' must be equal in the two \code{filetomatch} objects.
#' 
#' @return Table, plot or measures by strata groups
#' @param x \code{filetomatch} object
#' @param y \code{filetomatch} object
#' @param var_A name of variable in the first file
#' @param var_B name of variable in the second file
#' @param type type of desired result: table, plot or disimilarity measures
#' @param weights logical (\code{TRUE} or \code{FALSE}) to indicate if weights are to be used in the comparison
#' @param stratavar name of the strata variable.
#' @family "Select matching variables"
#' @export
setGeneric("compare_var_strata",
           function(x="filetomatch", y="filetomatch",...) {
                   standardGeneric("compare_var_strata")
})

#' Compare matching variables between two \code{filetomatch} objects
#' 
#' @description \code{compare_matchvars} makes a comparison of the empirical 
#' distributions observed in two separate \code{\link{filetomatch}} objects for the 
#' list of defined \code{matchvars}.
#' 
#' @details Using weights is optional. Also, the comparison can be made by levels of
#' a strata variable. 
#' 
#' Note that the strata variable must be defined in the \code{stratavars} slots in 
#' the \code{\link{filetomatch}} variables.
#' 
#' @return Tables, plots or measures.
#' @param x \code{filetomatch} object
#' @param y \code{filetomatch} object
#' @param type type of desired result: table, plot or disimilarity measures
#' @param weights logical (\code{TRUE} or \code{FALSE}) to indicate if weights are to be used in the comparison
#' @param strata logical (\code{TRUE} or \code{FALSE}) to indicate if comparison is to be made by levels of a strata variable
#' @family "Select matching variables"
#' @export
setGeneric("compare_matchvars",
           function(x="filetomatch", y="filetomatch",...) {
                   standardGeneric("compare_matchvars")
})

###Assessing preditive value
#' Assess predictive value of common variables w.r.t specific variables in a \code{filetomatch} object
#' 
#' @description \code{predictvalue} evaluates the predictive value for each
#' \code{matchvars} variable with respect to the \code{specvars} in a 
#' \code{\link{filetomatch}} object.
#' 
#' @family "Select matching variables"
#' @param x \code{filetomatch} object
#' @return \code{predictvalue} function returns a list with measures for
#' each combination of variables in \code{matchvars} and \code{specvars}.
#'
#' Specifically, for each combination it returns a list with four values:
#' \itemize{
#'      \item \code{V}: a vector with the estimated Cramer's V for each couple response-predictor.
#'      \item \code{lambda}: a vector with the values of Goodman-Kruscal lambda(R|C) for each couple response-predictor.
#'      \item \code{tau}: a vector with the values of Goodman-Kruscal tau(R|C) for each couple response-predictor.
#'      \item \code{U}: a vector whit the values of Theil's uncertainty coefficient U(R|C) for each couple response-predictor.
#' }
#' @export
setGeneric("predictvalue",
           function(x="filetomatch",...) {
                   standardGeneric("predictvalue")
})

#' Concatenate two \code{filetomatch} objects
#' 
#' @description \code{concatenate} takes data from two \code{\link{filetomatch}} objects
#' and produces a \code{\link{fusedfile}} object which contains data from both sources.
#' 
#' @details In the resulting \code{\link{fusedfile}} object, \code{data} contains
#' all rows (observations) and columns (variables) in the original files, as well as 
#' additional information to trace back the origin of variables. 
#' 
#' Specifically:
#' \itemize{
#'      \item \code{origin_specvars} stores the source of \code{specvars} in the original files, in corresponding order.
#'      \item \code{origin_weights} stores the source of \code{weights} in the original files, in corresponding order.
#' }
#' 
#' @family "Apply matching method"
#' @param x \code{filetomatch} object
#' @param y \code{filetomatch} object
#' @return A \code{\link{fusedfile}} object for which \code{data} that contains all
#' rows in both \code{data} slots, and in which non-observed values are filled with \code{NA}'s.
#' 
#' @export
setGeneric("concatenate",
           function(x="filetomatch",y="filetomatch",...) {
                   standardGeneric("concatenate")
})

#' Match two 'filetomatch' objects via distance hot-deck
#' 
#' @description \code{math.hotdeck} takes two \code{\link{filetomatch}} objects 
#' and produces a \code{\link{fusedfile}} object with complete \code{data} for the
#' object playing the \code{receptor} role.
#' 
#' @details In the resulting \code{\link{fusedfile}} object, \code{data} contains
#' all rows (observations) and columns (variables) in the object acting as \code{receptor},
#' Additionaly the resulting \code{fusedfile} will store additional information, namely:
#' 
#' \itemize{
#'      \item \code{origin_specvars} with the source of \code{specvars} in the original files, in this case, the object acting as \code{receptor}.
#'      \item \code{origin_weights} stores the source of \code{weights} in the original files, in this case, the object acting as \code{receptor}.
#' }
#' 
#' The missing values are filled via hot-deck imputation. 
#' 
#' Specifically, function \code{NND.hotdeck} from \code{StatMatch} package is used. This function
#' finds a donor record for each receptor record. In the unconstrained case it searches for the 
#' closest donor
#' 
#' @family "Apply matching method"
#' @param x \code{filetomatch} object
#' @param y \code{filetomatch} object
#' @param dist.fun distance function. Default is "Gower"
#' @param constrained logical (\code{TRUE} or \code{FALSE}). Default is \code{FALSE}.
#' @return A \code{\link{fusedfile}} object for which \code{data} contains complete observations
#' from the receptor file. 
#' 
#' Missing values are filled via distance hot-deck imputation by means of
#' \code{NDD.hotdeck} function from \code{StatMatch} package.
#' 
#' @export
setGeneric("match.hotdeck",
           function(x="filetomatch",y="filetomatch",...) {
                   standardGeneric("match.hotdeck")
})

