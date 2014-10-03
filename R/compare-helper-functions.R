# Helper (internal) functions for methods/functions comparing variables
# Tabulate one variable in a data frame
".tabulate_1_categorical" <- function(data, var, weights = NULL){
        # Tabulates a single categorical variable with or without weights
        ## Parameters: data, var, weights (defaults to NULL)
        ## Returns: a table.
        # Extract column vector corresponding to var
        x_vector <- data[,var] 
        if(!is.null(weights)){
                w_vector <- data[, weights]
                form <- as.formula("w_vector ~ x_vector")
        } else {form <- as.formula(" ~ x_vector")}
        # Return final table
        t <- xtabs(form, data)
#         names(attr(t, "dimnames")) <- var
        return(t)
#         return(xtabs(form, data))
}

### NOT USED.
# Tabulate two categorical variables in a data frame
# ".tabulate_2_categorical" <- function(data, var1, var2, weights = NULL){
#         # Tabulates a single categorical variable with or without weights
#         ## Parameters: data, var, weights (defaults to NULL)
#         ## Returns: a table.
#         # Extract column vector corresponding to var
#         x1_vector <- data[,var1]
#         x2_vector <- data[,var2]
#         if(!is.null(weights)){
#                 w_vector <- data[, weights]
#                 form <- as.formula("w_vector ~ x1_vector + x2_vector")
#         } else {form <- as.formula(" ~ x1_vector + x2_vector")}
#         # Return final table
#         return(xtabs(form, data))
# }