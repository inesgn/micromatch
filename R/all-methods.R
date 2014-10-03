#' Remove variables from a 'filetomatch' object
#' 
#' @family 'Utilities'
#' @exportMethod remove

setMethod("remove", 
          signature=list(x="filetomatch"), 
          function(x, vars,...){
                  .remove(x = x, vars = vars)
          }
)

#' Include variables to a 'filetomatch' object
#' 
#' @family 'Utilities'
#' @exportMethod include

setMethod("include", 
          signature=list(x="filetomatch"), 
          function(x, vars, as,...){
                  .include(x = x, vars = vars, as = as)
          }
)

#' Select strata values in a 'filematch' object
#' 
#' @family 'Utilities'
#' @exportMethod select_strata

setMethod("select_strata", 
          signature=list(x="filetomatch"), 
          function(x, value,...){
                  .select_strata_value(x = x, value = value,...)
          }
)

#' Select observations (i.e rows of data frame) in a 'filematch' object
#' 
#' @family 'Utilities'
#' @exportMethod select_observations

setMethod("select_observations", 
          signature=list(x="filetomatch"), 
          function(x, obs,...){
                  .select_observations(x = x, obs = obs,...)
          }
)

#' Compare a (single) shared variable across two 'filetomatch' objects
#' 
#' @family 'Select matching variables'
#' @exportMethod compare_var

setMethod("compare_var", 
          signature=list(x="filetomatch", y="filetomatch"), 
          function(x, y, var_A, var_B, type = "table", weights = FALSE,...){
                  #de momento comparamos la primera
                  #y solamente tabulate
                  if(identical(weights, TRUE)){
                          weights_A = slot(x, "weights")[1]
                          weights_B = slot(y, "weights")[1]
                  } else {
                          weights_A = NULL
                          weights_B = NULL
                  } 
                  if(identical(type, "table")){
                          t <- tabulate2cat(data_A = slot(x, "data"),
                                       data_B = slot(y, "data"),
                                       var_A = var_A,
                                       var_B = var_B,
                                       weights_A = weights_A,
                                       weights_B = weights_B,...)
                          print(t)
#                           return(t)
                  }
                  if(identical(type, "plot")){
                          g <- plot2cat(data_A = slot(x, "data"),
                                   data_B = slot(y, "data"),
                                   var_A = var_A,
                                   var_B = var_B,
                                   weights_A = weights_A,
                                   weights_B = weights_B,...)
                          print(g)
                  }
                  if(identical(type, "measures")){
                          m <- similarity2cat(data_A = slot(x, "data"),
                                   data_B = slot(y, "data"),
                                   var_A = var_A,
                                   var_B = var_B,
                                   weights_A = weights_A,
                                   weights_B = weights_B,...)
                          return(m)
                  }
          }
)

#' Compare a (single) shared variable across two 'filetomatch' objects, by a stratum variable
#' 
#' @family 'Select matching variables'
#' @exportMethod compare_var_strata

setMethod("compare_var_strata", 
          signature=list(x="filetomatch", y="filetomatch"), 
          function(x, y, var_A, var_B, type = "table", weights = FALSE, stratavar, ...){
                  stopifnot(stratavar %in% names(slot(x, "data")))
                  stopifnot(stratavar %in% names(slot(y, "data")))
                  slevels <- levels(slot(x, "data")[, stratavar])
                  #iterate over values creating temporary 'filetomatch' objects
                  sapply(X = slevels, FUN = function(s){
                          xnew <- initialize(x, data = slot(x,"data")[which(slot(x,"data")[, stratavar] == s),])
                          ynew <- initialize(y, data = slot(y,"data")[which(slot(y,"data")[, stratavar] == s),])
                          c <- compare_var(x = xnew, y = ynew, var_A = var_A, var_B = var_B, type = type, weights = weights)
                          if(identical(type, "table") | identical(type, "measures")){
                                  print(paste("Stratum: ", s))
                                  print(c)                                  
                          } else if (identical(type, "plot")){
                                  print(paste("Stratum: ", s))
                                  print(c)
                          }
                  })
          }                  
)

#' Compare a (single) shared variable across two 'filetomatch' objects, by a stratum variable
#' 
#' @family 'Select matching variables'
#' @exportMethod compare_var_strata

setMethod("compare_matchvars", 
          signature=list(x="filetomatch", y="filetomatch"), 
          function(x, y, type = "table", weights = FALSE, strata = FALSE, ...){
                  vars <- slot(x, "matchvars")
                  if(strata == TRUE){
                          sapply(vars, FUN = function(var){
                                  compare_var_strata(x = x, y = y, var_A = var, var_B = var, type = type, weights = weights, stratavar = slot(x, "stratavars"),...)
                          })
                  } else {
                          sapply(vars, FUN = function(var){
                                  compare_var(x = x, y = y, var_A = var, var_B = var, type = type, weights = weights,...)
                          })
                  }
})
    
#' Assess predictive value of common variables w.r.t specific variables in a 'filetomatch' object
#' 
#' @family 'Select matching variables'
#' @exportMethod predictvalue

setMethod("predictvalue", 
          signature=list(x="filetomatch"), 
          function(x,...){
                  data <- slot(x, "data")
                  vars_x <- slot(x, "matchvars")
                  vars_y <- slot(x, "specvars")
                  lapply(vars_y, FUN = function(var){
                          predictvalue_var(data = data, vars_x = vars_x,
                                           var_y = var, weights = weights)
                  })
})

#' Concatenate two 'filetomatch' objects
#' 
#' @family 'Apply matching method'
#' @exportMethod concatenate

setMethod("concatenate", 
          signature=list(x="filetomatch", y="filetomatch"), 
          function(x,y){
                  .convertToFusedfile(x=x, y=y, data=.concat(x,y), transformation="fillboth")
          }
)

#' Match two 'filetomatch' objects via distance hot-deck
#' 
#' @family 'Apply matching method'
#' @exportMethod match.hotdeck

setMethod("match.hotdeck", 
          signature=list(x='filetomatch', y='filetomatch'), 
          function(x,y){
                  .convertToFusedfile(x=x, y=y, data=.match_disthotdeck(x,y), transformation="fillreceptor")
          }
)


# Generic: as.data.frame
#   applies to all 'genericmatch'
#' Coerce 'genericmatch' to 'data.frame'

# setMethod("as.data.frame",
#           signature="filetomatch",
#           function(x, row.names = NULL, optional = FALSE, ...){as(x,"data.frame")})
# 
# setAs("filetomatch","data.frame",function(from){
#         return(from@data)}
# )

