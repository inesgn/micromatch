# Internal helper functions

# Identifies the receptor in a pair of filematch objects
".identifyreceptor" <- function(x="filetomatch",y="filetomatch"){
        stopifnot( (identical(slot(x,"role"),"receptor") & identical(slot(y,"role"),"donor")) |
                    (identical(slot(y,"role"),"receptor") & identical(slot(x,"role"),"donor")) ) 
        if( identical(slot(x,"role"),"receptor") ) { return(x) }
        else if( identical(slot(y,"role"),"receptor") ) { return(y) }
}

# Identifies the donor in a pair of filematch objects
".identifydonor" <- function(x="filetomatch",y="filetomatch"){
        stopifnot( (identical(slot(x,"role"),"receptor") & identical(slot(y,"role"),"donor")) |
                           (identical(slot(y,"role"),"receptor") & identical(slot(x,"role"),"donor")) ) 
        if( identical(slot(x,"role"),"donor") ) { return(x) }
        else if( identical(slot(y,"role"),"donor") ) { return(y) }
}

".convertToFusedfile" <- function(x = "filetomatch", y = "filetomatch", data = "data.frame", role = "character", method = "character", transformation = "character"){
        ## parameters: x,y: 'filetomatch' pair 
        ##             data: df returned by .concat function
        ##             transformation: fill a receptor file (fillreceptor), fill both (fillboth), or fill nothing (concatenate)
        # returns: object from class 'fusedfile'
        #NOTE in receptor, donor case x=receptor, y = donor so as to keep track of weights
        if(identical(transformation, "fillreceptor")){
                weights <- slot(x, "weights")
                origin_weights <- "file1"
        }
        if(identical(transformation, "fillboth")){
                weights <- c(slot(x, "weights"), slot(y,"weights"))
                origin_weights <- c("file1", "file2")        
        }
        new("fusedfile",
            data = data,
            matchvars = slot(x,"matchvars"),
            specvars = c(slot(x, "specvars"), slot(y,"specvars")),
            stratavars = slot(x, "stratavars"),
            weights = weights, 
            origin_specvars = c(rep("file1", length(slot(x, "specvars"))), rep("file2", length(slot(y, "specvars")))),
            origin_weights = origin_weights,
            role = role,
            method = method)  
}