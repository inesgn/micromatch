# Update 'filetomatch' objects with new slot values

".update" <- function(x = "filetomatch", data = NULL, matchvars = NULL, specvars = NULL, stratavars = NULL, weights = NULL, role = NULL){
        if(!is.null(data)){ x <- initialize(x, data = data) }
        if(!is.null(matchvars)) { x <- initialize(x, matchvars = matchvars) }
        if(!is.null(specvars)) { x <- initialize(x, specvars = specvars) }
        if(!is.null(stratavars)) { x <- initialize(x, stratavars = stratavars) }
        if(!is.null(weights)) { x <- initialize(x, weights = weights) }
        if(!is.null(role)) { x <- initialize(x, role = role) }
        return(x)
}

".add_matchvar" <- function(x = "filetomatch", var = "character"){
        initialize(x, matchvars = c(slot(x,"matchvars"), var))
}

".remove1var" <- function(x = "filetomatch", var = "character"){
        imatchvars <- which(var == slot(x, "matchvars"))
        ispecvars <- which(var == slot(x, "specvars"))
        istratavars <- which(var == slot(x, "stratavars"))
        iweights <- which(var == slot(x, "weights"))
        if(var %in% slot(x, "matchvars")){ 
                matchvars <- slot(x, "matchvars")[-imatchvars]
                if(length(matchvars) > 0){
                        x <- initialize(x, matchvars = matchvars)
                } else {
                        x <- initialize(x, matchvars = NULL)
                }
        }
        if(var %in% slot(x, "specvars")){ 
                specvars <- slot(x, "specvars")[-ispecvars]
                if(length(specvars) > 0){
                        x <- initialize(x, specvars = specvars)
                } else {
                        x <- initialize(x, specvars = NULL)
                }
        }
        if(var %in% slot(x, "stratavars")){ 
                stratavars <- slot(x, "stratavars")[-istratavars]
                if(length(stratavars) > 0){
                        x <- initialize(x, stratavars = stratavars)
                } else {
                        x <- initialize(x, stratavars = NULL)
                }
        }
        if(var %in% slot(x, "weights")){ 
                weights <- slot(x, "weights")[-iweights]
                if(length(weights) > 0)
                        {x <- initialize(x, weights = weights)
                } else {
                        x <- initialize(x, weights = NULL)
                }                
        }
        return(x)
}

".remove" <- function(x = "filetomatch", vars = "character"){
        stopifnot(length(vars) > 0)
        for(i in 1:length(vars)){
                x <- ".remove1var"(x = x, var = vars[i])
        }
        return(x)
}

".include" <- function(x = "filetomatch", vars = "character", as = "matchvars"){
        stopifnot(length(vars) > 0)
        if(identical(as, "matchvars")){
                x <- initialize(x, matchvars = c(slot(x,"matchvars"), vars))
        } 
        if(identical(as, "specvars")){
                x <- initialize(x, specvars = c(slot(x,"specvars"), vars))
        } 
        if(identical(as, "stratavars")){
                x <- initialize(x, stratavars = c(slot(x, "stratavars"), vars))
        }
        if(identical(as, "weights")){
                x <- initialize(x, weights = c(slot(x, "weights"), vars))
        }
        return(x)
}

".select_strata_value" <- function(x = "filetomatch", value = "character"){
        # Parameters: x filematch object, value strata value to be selected
        # Returns: updated filematch object
        data <- slot(x, "data")
        stratavar <- slot(x, "stratavars")
        slevels <- levels(data[,stratavar])
        stopifnot(value %in% slevels)
        #newdata <- subset(data, eval(expression(stratavar, enclos=data)) == value)
        newdata <- data[which(data[, stratavar] == value),]
        x <- initialize(x, data = newdata)
}

".select_observations" <- function(x = "filetomatch", obs = "numeric"){
        # Parameters: x filematch object, obs indices of observations to be selected
        # Returns: updated filematch object
        data <- slot(x, "data")
        newdata <- data[obs,]
        x <- initialize(x, data = newdata)
}