#' 
#' Assess predictive value of a variable w.r.t. another variable in a data frame
#'   
#' @description Evaluates predictive value of a common variable \texttt{x} with respect to a specific variable \texttt{y}
#' @param data name of data frame containing both x and y
#' @param vars_x name of common variable(s) 
#' @param var_y name of specific variable
#' @param weights weight vector name (optional)
#' @details Dependencies: StatMatch
#' @family "Select matching variables"
#' @import StatMatch
#' @export predictvalue_var

predictvalue_var <- function(data, vars_x, var_y, weights=NULL){
        #Parameters: data data frame, 
        #            vars_x independent variable(s) (common variables)
        #            var_y dependent variable (a specific variable)
        #            weights if weights are going to be used.
        # Checks
        stopifnot(var_y %in% names(data))
        # Compute formula
        form <- as.formula(paste(var_y,"~",paste(vars_x, collapse="+")))
        # Compute measures
        StatMatch::pw.assoc(formula = form, data = data, weights = weights) 
}
