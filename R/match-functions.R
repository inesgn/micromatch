### Functions for match method
## Nonparametric hot-deck imputation
#
# Types of hot-deck methods: random, rank and distance
# Options: with strata/without strata
#
###########################
# No strata
###########################
# Distance hot-deck
#' @import StatMatch

".match_disthotdeck" <- function(x="filetomatch",y="filetomatch", dist.fun="Gower", constrained=FALSE){
        # parameters: x,y: 'filetomatch' pair, must be receptor & donor
        #             dist.fun: distance function, StatMatch options; defalts to Gower
        #             constrained: TRUE or FALSE (default)
        # returns: data frame with filled receptor data
        # Function
        mtc.ids <- StatMatch::NND.hotdeck(data.rec = slot(.identifyreceptor(x, y), "data"), 
                                          data.don = slot(.identifydonor(x, y), "data"), 
                                          dist.fun = dist.fun, 
                                          match.vars = slot(x, "matchvars"), 
                                          constrained = constrained, 
                                          constr.alg = "Hungarian",
                                          keep.t=TRUE)$mtc.ids     
        #create full receptor file
        fullrec <- StatMatch::create.fused(data.rec = slot(.identifyreceptor(x, y), "data"), 
                                             data.don = slot(.identifydonor(x, y), "data"),
                                             mtc.ids = mtc.ids, 
                                             z.vars= unlist(slot(.identifydonor(x, y),"specvars")))
        #return
        return(fullrec)
}


