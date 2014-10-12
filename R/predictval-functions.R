#' 
#' Assess predictive value of a variable w.r.t. another variable in a data frame
#'   
#' @description Evaluates predictive value of a common variable \code{x} 
#' with respect to a specific variable \code{y}
#' 
#' @details This function relies on function \code{pw.assoc()} from 
#' \code{StatMatch} package.
#' 
#' @param data name of data frame containing both x and y
#' @param vars_x name of common variable(s) 
#' @param var_y name of a specific variable
#' @param weights weight vector name (optional)
#' @return A list with four components:
#' \itemize{
#'      \item \code{V} A vector with the estimated Cramer's V for each couple response-predictor.
#'      \item \code{lambda} A vector with the values of Goodman-Kruscal lambda(R|C) for each couple response-predictor.
#'      \item \code{tau} A vector with the values of Goodman-Kruscal tau(R|C) for each couple response-predictor.
#'      \item \code{U} A vector whit the values of Theil's uncertainty coefficient U(R|C) for each couple response-predictor.
#' }
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
