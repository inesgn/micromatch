#' Compare a single categorical variable across two data frames: Tabulate
#' 
#' @description 
#' Frequency tables for a categorical variable in two distinct, independent data frames
#' @details
#' Details.
#' @author Ines Garmendia <ines.garmendia@@gmail.com>
#' @param data_A first data frame
#' @param data_B second, distinct, data frame
#' @param var_A name of the variable in the first file, data_A
#' @param var_B name of the variable in the second file, data_B
#' @param weights_A name of variable containing weights for the first file, data_A (optional)
#' @param weights_B name of variable containing weights for the second file, data_B (optional)
#' @param cell_values type of values desired for cells: 'abs' (absolute values) or 'rel' (relative values). 
#' @return table
#' @family "Select matching variables"
#' @export tabulate2cat

tabulate2cat <- function(data_A, data_B, var_A, var_B, weights_A = NULL, weights_B = NULL, cell_values = "abs"){
        #Valid variables?
        stopifnot(var_A %in% names(data_A))
        stopifnot(var_B %in% names(data_B))
        #Valid weights?
        if(!is.null(weights_A)) {
                if(!weights_A %in% names(data_A)) stop("One weight variable is not a column of the given data frame")
                if(is.null(weights_B)) stop("One weight variable is missing")
        }
        if(!is.null(weights_B)) {
                if(!weights_B %in% names(data_B)) stop("One weight variable is not a column of the given data frame")
                if(is.null(weights_A)) stop("One weight variable is missing")
        }
        # Create tables
        table_var_A <- ".tabulate_1_categorical"(data = data_A, var = var_A, weights = weights_A)
        table_var_B <- ".tabulate_1_categorical"(data = data_B, var = var_B, weights = weights_B)
        if(identical(cell_values, "rel")){
                l <- list(prop.table(table_var_A), prop.table(table_var_B))
        } else {
                l <- list(table_var_A, table_var_B)
        }
        names(l) <- c(paste("Table for data: ",deparse(substitute(data_A))), 
                      paste("Table for data: ",deparse(substitute(data_B))))
        return(l)
}

#' Compare a single categorical variable across two data frames: Plot
#' 
#' @description 
#' Barplots for a single categorical variable in two distinct, independent data frames
#' @family 'Select matching variables'
#' @import ggplot2
#' @export plot2cat

plot2cat <- function(data_A, data_B, var_A, var_B, weights_A=NULL, weights_B=NULL, cell_values="abs"){
        #Valid parameters?
        stopifnot(var_A %in% names(data_A))
        stopifnot(var_B %in% names(data_B))
        if(!is.null(weights_A)) {
                if(!weights_A %in% names(data_A)) stop("One weight variable is not a column of the given data frame")
                if(is.null(weights_B)) stop("One weight variable is missing")
        }
        if(!is.null(weights_B)) {
                if(!weights_B %in% names(data_B)) stop("One weight variable is not a column of the given data frame")
                if(is.null(weights_A)) stop("One weight variable is missing")
        }
        # Create tables
        table_var_A <- ".tabulate_1_categorical"(data = data_A, var = var_A, weights = weights_A)
        table_var_B <- ".tabulate_1_categorical"(data = data_B, var = var_B, weights = weights_B)
        if(identical(cell_values, "rel")){
                table_var_A <- prop.table(table_var_A)
                table_var_B <- prop.table(table_var_B)
        }
        # Create a single data frame
        df_var_A <- as.data.frame(table_var_A)
        df_var_A$group <- "File 1"
        df_var_B <- as.data.frame(table_var_B)
        df_var_B$group <- "File 2"
        df_final <- rbind(df_var_A, df_var_B)
#         names(df_final)[1] <- var_A
        # Plot
        if(identical(cell_values, "abs")){
                ggplot(df_final, aes(x=x_vector, y=Freq, fill=group)) + 
                        geom_bar(stat="identity", position="dodge") +
                        geom_text(aes(label=round(Freq,1)), vjust=1.5, colour="white",size=4, position=position_dodge(1)) +
                        ggtitle(paste("Variable: ", var_A)) +
                        theme(axis.title.x=element_blank(), axis.title.y=element_blank())
        } else {
                ggplot(df_final, aes(x=x_vector, y=Freq*100, fill=group)) + 
                        geom_bar(stat="identity", position="dodge") +
                        geom_text(aes(label=round(Freq,2)*100), vjust=1.5, colour="white",size=4, position=position_dodge(1)) +
                        ggtitle(paste("Variable: ", var_A)) + 
                        theme(axis.title.x=element_blank(), axis.title.y=element_blank()) +
                        scale_y_continuous(limits=c(0,100))
        }
}

#' Compare a single categorical variable across two data frames: Similarity/Disimilarity measures
#' 
#' @description 
#' Similarity/disimilarity measures based on observed empirical distributions in the two data frames.
#' @family 'Select matching variables'
#' @details Details about parameter values for Statmatch comp.prop function
#' @export similarity2cat

similarity2cat <- function(data_A, data_B, var_A, var_B, weights_A=NULL, weights_B=NULL){
        #Valid variables?
        stopifnot(var_A %in% names(data_A))
        stopifnot(var_B %in% names(data_B))
        #Valid weights?
        if(!is.null(weights_A)) {
                if(!weights_A %in% names(data_A)) stop("One weight variable is not a column of the given data frame")
                if(is.null(weights_B)) stop("One weight variable is missing")
        }
        if(!is.null(weights_B)) {
                if(!weights_B %in% names(data_B)) stop("One weight variable is not a column of the given data frame")
                if(is.null(weights_A)) stop("One weight variable is missing")
        }
        # Create tables
        table_var_A <- ".tabulate_1_categorical"(data = data_A, var = var_A, weights = weights_A)
        table_var_B <- ".tabulate_1_categorical"(data = data_B, var = var_B, weights = weights_B)
        # Compute measures
        m <- StatMatch::comp.prop(p1 = table_var_A, p2 = table_var_B, n1 = nrow(data_A), n2 = nrow(data_B), ref=FALSE)$meas
        print(paste("Measures for variable:", var_A)) 
        return(m)
}

# #' Mosaic plot of two categorical variables across two data frames
# #' 
# #' @description 
# #' Similarity/disimilarity measures based on observed empirical distributions in the two data frames.
# #' @family 'Select matching variables'
# #' @details Details.
# #' @export mosaic2cat
# 
# mosaic2cat <- function(data_A, data_B, var_A, var_B, var_condA, var_condB, weights_A=NULL, weights_B=NULL){
#         #Valid variables?
#         stopifnot(var_A %in% names(data_A))
#         stopifnot(var_condA %in% names(data_A))
#         stopifnot(var_B %in% names(data_B))
#         stopifnot(var_condB %in% names(data_B))
#         #Valid weights?
#         if(!is.null(weights_A)) {
#                 if(!weights_A %in% names(data_A)) stop("One weight variable is not a column of the given data frame")
#                 if(is.null(weights_B)) stop("One weight variable is missing")
#         }
#         if(!is.null(weights_B)) {
#                 if(!weights_B %in% names(data_B)) stop("One weight variable is not a column of the given data frame")
#                 if(is.null(weights_A)) stop("One weight variable is missing")
#         }
#         # Create tables
#         table_var_A <- ".tabulate_1_categorical"(data = data_A, var = var_A, weights = weights_A)
#         table_var_B <- ".tabulate_1_categorical"(data = data_B, var = var_B, weights = weights_B)
#         # Compute measures
# 
# }