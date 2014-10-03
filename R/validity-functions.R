# Valid genericmatch objects

".genericmatch.valid" <- function(object){
        if(is.null(slot(object,"matchvars"))){
                return("Error: at least one maching (common) variable has to be specified")
        }
        ## Auxiliary logical vectors
        # matchvars in data frame? 
        logical_vec_matchvars <- slot(object,"matchvars") %in% names(slot(object,"data"))
        # specvars in data frame? 
        logical_vec_specvars <- slot(object,"specvars") %in% names(slot(object,"data"))
        # stratavars in data frame? 
        logical_vec_stratavars <- slot(object,"stratavars") %in% names(slot(object,"data"))
        # weights in data frame?
        logical_vec_weights <- slot(object,"weights") %in% names(slot(object,"data"))
        #
        # specvars in matchvars list
        logical_vec_specinmatch <- slot(object,"specvars") %in% slot(object,"matchvars")
        # stratavars in matchvars list
        logical_vec_stratainmatch <- slot(object,"stratavars") %in% slot(object,"matchvars")
        # weights in matchvars list
        logical_vec_weightsinmatch <- slot(object,"weights") %in% slot(object,"matchvars")
        # weight variables vector: extract last
        last_weights <- slot(object, "weights")[length(slot(object, "weights"))]
        # Testing
        if(length(logical_vec_matchvars[logical_vec_matchvars == FALSE]) > 0){
                return("Error: Common (matching) variables are not in the data frame")
        }
        if(length(logical_vec_specvars[logical_vec_specvars == FALSE]) > 0){
                return("Error: Specific variables are not in the data frame")
        }
        if(length(logical_vec_stratavars[logical_vec_stratavars == FALSE]) > 0){
                return("Error: Strata variables are not in the data frame")
        }
        if(length(logical_vec_weights[logical_vec_weights == FALSE]) > 0){
                return("Error: Weight variables are not in the data frame")
        }
        if(length(logical_vec_specinmatch[logical_vec_specinmatch == TRUE]) > 0){
                return("Error: Specific variables cannot be in the list of common (matching) variables")
        }
        if(length(logical_vec_stratainmatch[logical_vec_stratainmatch == TRUE]) > 0){
                return("Error: Strata variables cannot be in the list of common (matching) variables")
        }
        if(length(logical_vec_weightsinmatch[logical_vec_weightsinmatch == TRUE]) > 0){  
                return("Error: Weight variables cannot be in the list of common (matching) variables")
#         }        
#         if(!is.numeric(slot(object,"data")[,slot(object,"weights")])){  
#                 return("Error: Weight variable must be numeric")
        }        
#         if(!is.numeric(slot(object,"data")[ ,last_weights])){  
#                 return("Error: Weight variable must be numeric")
        if(!is.null(slot(object, "weights")) & !is.numeric(slot(object,"data")[ ,last_weights])){  
                return("Error: Weight variable must be numeric")
        } else {
                return(TRUE)
        }    
}

setValidity(Class = "genericmatch", .genericmatch.valid)
