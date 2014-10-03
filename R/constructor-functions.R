# Creator functions - objects from class filetomatch

#' Create receptor file object
#' 
#' Creates a receptor file according to 'filetomatch' class definition. 
#' @details This function creates an object of class 'filetomatch' for a microdata file
#' acting as the receptor file in matching. It is thus assumed that a donor file will be created a the same time.
#' 
#' All the necessary information for matching should be provided:
#' data, identification of common & specific variables (compulsory), identification of a weight variable (optional), and identification
#' of strata variables (optional).
#' @author "Ines Garmendia <ines.garmendia@@gmail.com>"
#' @param data data frame
#' @param matchvars character vector with names of common (matching) variables
#' @param specvars character vector with names of specific variables
#' @param stratavars character vector with names of variables acting as strata (optional)
#' @param weights character vector with the name of the vector with numeric weight (optional, but usually given in survey samples)
#' @return Object of class filetomatch with receptor role
#' @family 'Matching definition step'
#' @details Some amount of pre-processing is needed is this file is to be matched to another independent file
#' In particular, names of matchvars, specvars, stratavars and weights must be the same in all files to match.
#' @export
"receptor" <- function(data, matchvars, specvars, stratavars, weights){
        if(missing(data)){
                data = NULL
        }
        if(missing(matchvars)){
                matchvars = NULL
        }
        if(missing(specvars)){
                specvars = NULL
        }
        if(missing(stratavars)){
                stratavars = NULL
        }
        if(missing(weights)){
                weights = NULL
        }
        new("filetomatch",data=data,matchvars=matchvars,specvars=specvars,stratavars=stratavars,weights=weights,role="receptor")
}

#' Create donor file object
#' 
#' Creates a donor file according to 'filetomatch' class definition
#' @details This function creates an object of class 'filetomatch' for a microdata file
#' acting as the donor file in matching. It this thus assumed that a receptor file will be created 
#' at the same time.
#' 
#' All the necessary information for matching should be provided:
#' data, identification of common & specific variables (compulsory), identification of a weight variable (optional), and identification
#' of strata variables (optional).
#' @author "Ines Garmendia <ines.garmendia@@gmail.com>"
#' @param data data frame where rows are observations and columns contain common & specific variables, and possibly weights
#' @param matchvars character vector with names of common (matching) variables
#' @param specvars character vector with names of specific variables
#' @param stratavars character vector with names of variables acting as strata (optional)
#' @param weights character vector with the name of the vector with numeric weights (optional, but usually given in survey samples)
#' @return Object of class filetomatch with donor role
#' @family 'Matching definition step'
#' @details Some amount of pre-processing is needed is this file is to be matched to another independent file
#' In particular, names of matchvars, specvars, stratavars and weights must be the same in all files to match.
#' @export
"donor" <- function(data, matchvars, specvars, stratavars, weights){
        if(missing(data)){
                data = NULL
        }
        if(missing(matchvars)){
                matchvars = NULL
        }
        if(missing(specvars)){
                specvars = NULL
        }
        if(missing(stratavars)){
                stratavars = NULL
        }
        if(missing(weights)){
                weights = NULL
        }        
        new("filetomatch",data=data,matchvars=matchvars,specvars=specvars,stratavars=stratavars,weights=weights,role="donor")
}

#' Create matching file object with no specific (receptor nor donor) role
#' 
#' Creates a matching file object with no specific role, according to 'filetomatch' class definition
#' @details This function creates an object of class 'filetomatch' for a microdata file
#' to be matched to another, independent file. The file is supposed to lack a specific role in matching,
#' namely (as in the case of receptor and donor pairs), that is, the aim in this case is to fill all the rows in both files. 
#' 
#' All the necessary information for matching should be provided:
#' data, identification of common & specific variables (compulsory), 
#' identification of weight variable (optional), and identification
#' of strata variables (optional).
#' @author "Ines Garmendia <ines.garmendia@@gmail.com>"
#' @param data data frame where rows are observations and columns contain common & specific variables, and possibly weights
#' @param matchvars character vector with names of common (matching) variables
#' @param specvars character vector with names of specific variables in data
#' @param stratavars character vector with names of variables acting as strata (optional)
#' @param weights character vector with the name of the vector with numeric weights (optional, but usually given in survey samples)
#' @return Object of class filetomatch with symetric role
#' @family 'Matching definition step'
#' @details Some amount of pre-processing is needed is this file is to be matched to another independent file
#' In particular, names of matchvars, specvars, stratavars and weights must be the same in all files to match.
#' @export
"symmetric" <- function(data, matchvars, specvars, stratavars, weights){
        if(missing(data)){
                data = NULL
        }
        if(missing(matchvars)){
                matchvars = NULL
        }
        if(missing(specvars)){
                specvars = NULL
        }
        if(missing(stratavars)){
                stratavars = NULL
        }
        if(missing(weights)){
                weights = NULL
        }        
        new("filetomatch",data=data,matchvars=matchvars,specvars=specvars,stratavars=stratavars,weights=weights,role="symmetric")
}