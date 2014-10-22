#'
#' Variable selection by uncertainty evaluation
#'
#' @description \code{uncert2vars} evaluates the uncertainty in the contingency table estimation between
#' two specific variables in separate files, given a list of common variables. 
#' The function and selects the 'best' combination of common variables from the list 
#' in terms of uncertainty reduction.
#' 
#' @details Uncertainty evaluation is based on Frechet bounds computation as implemented in
#' StatMatch \code{Fbwidths.by.x}
#' 
#' @param var_x name of (specific) variable in the first file
#' @param var_y name of (specific) variable in the second file
#' @param data_A data-frame for the first file
#' @param data_B data-frame for the second file
#' @param base file from which to estimate marginal distributions for common variables: choose between values in data_A or data_B
#' @param weights_A name of weights variable in data1 (optional)
#' @param weights_B name of weights variable in data2 (optional)
#' @param matchvars list of common variables present in both files, candidates for selection
#' @return list: name of varx, name of vary, best overall uncertainty, variable list for best ov.uncertainty
#' @details Dependencies: StatMatch
#' @family "Select matching variables"
#' @import StatMatch
#' @export

# uncert2vars <- function(var_x, var_y, data_A, data_B, base = NULL, weights_A = NULL, weights_B = NULL, matchvars){
#         
#         #Checks
#         if (is.null(base)) stop("Indicate which df (data_A or data_B) to use to compute marginal distributions for common variables")
#         #Create formulas
#         if(identical(base, data_A)) {#use weights_A
#                 formulazz <- as.formula(paste(weights_A, " ~ ", paste(matchvars, collapse= "+")))
#         }
#         else if(identical(base, data_B)) {#use weights_B
#                 formulazz <- as.formula(paste(weights_B, " ~ ", paste(matchvars, collapse= "+")))
#         }
#         formulaxz <- as.formula(paste(weights_A, " ~ ", paste(c(matchvars,var_x), collapse= "+")))
#         formulayz <- as.formula(paste(weights_B, " ~ ", paste(c(matchvars,var_y), collapse= "+")))
#         
#         #compute marginal distributions
#         zz <- xtabs(formula=formulazz , data = base)#data_A or data_B
#         xz <- xtabs(formula=formulaxz , data = data_A)
#         yz <- xtabs(formula=formulayz, data = data_B)
#         
#         #compute uncertainty bounds
#         out.fbw <- StatMatch::Fbwidths.by.x(tab.x=zz, tab.xy=xz, tab.xz=yz)
#         best <- out.fbw$sum.unc[order(out.fbw$sum.unc$ov.unc),][1,]
#         
#         
#         #return values
#         
#         bestvars <- rownames(best)
#         bestn <- best$x.vars
#         bestcells <-  best$x.cells
#         bestval <- best$ov.unc
#         
#         l <- list('Best'=bestvars,
#                   'NumberVariables'=bestn,
#                   'NumberCells'=bestcells,
#                   'OvUncert'=bestval)
#         return(l)
# }

uncert2vars <- function(var_x, var_y, data_A, data_B, base = NULL, weights_A = NULL, weights_B = NULL, matchvars, n){
        
        #Checks
        if (is.null(base)) stop("Indicate which df (data_A or data_B) to use to compute marginal distributions for common variables")
        #Create formulas
        if(identical(base, data_A)) {#use weights_A
                formulazz <- as.formula(paste(weights_A, " ~ ", paste(matchvars, collapse= "+")))
        }
        else if(identical(base, data_B)) {#use weights_B
                formulazz <- as.formula(paste(weights_B, " ~ ", paste(matchvars, collapse= "+")))
        }
        formulaxz <- as.formula(paste(weights_A, " ~ ", paste(c(matchvars,var_x), collapse= "+")))
        formulayz <- as.formula(paste(weights_B, " ~ ", paste(c(matchvars,var_y), collapse= "+")))
        
        #compute marginal distributions
        zz <- xtabs(formula=formulazz , data = base)#data_A or data_B
        xz <- xtabs(formula=formulaxz , data = data_A)
        yz <- xtabs(formula=formulayz, data = data_B)
        
        #compute uncertainty bounds
        out.fbw <- StatMatch::Fbwidths.by.x(tab.x=zz, tab.xy=xz, tab.xz=yz)
        best <- out.fbw$sum.unc[order(out.fbw$sum.unc$ov.unc),][1:n,]
        
        
        #return values
        
        bestvars <- rownames(best)
        bestn <- best$x.vars
        bestcells <-  best$x.cells
        bestval <- best$ov.unc
        
        l <- list('Best'=bestvars,
                  'NumberVariables'=bestn,
                  'NumberCells'=bestcells,
                  'OvUncert'=bestval)
        return(l)
}

