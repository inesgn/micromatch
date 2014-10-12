# Functions for match method

# Distance hot-deck
#' @import StatMatch

".match_disthotdeck" <- function(x="filetomatch", y="filetomatch",...){
        # parameters: x,y: 'filetomatch' pair, must be receptor & donor
        # returns: data frame with filled receptor data
        # Function
        mtc.ids <- StatMatch::NND.hotdeck(data.rec = slot(.identifyreceptor(x, y), "data"), 
                                          data.don = slot(.identifydonor(x, y), "data"), 
                                          match.vars = slot(x, "matchvars"),...)$mtc.ids     
        #create full receptor file
        fullrec <- StatMatch::create.fused(data.rec = slot(.identifyreceptor(x, y), "data"), 
                                             data.don = slot(.identifydonor(x, y), "data"),
                                             mtc.ids = mtc.ids, 
                                             z.vars= unlist(slot(.identifydonor(x, y),"specvars")))
        #return
        return(fullrec)
}


