#' Specify matching design object
#' 
#' @description Specify a new matching project to link specific variables from two microdata files based on common variables between them
#' @name matchdesign-class
#' @param rec microdata file acting as receptor file A
#' @param don microdata file acting as donor file B
#' @param matchvars list of common matching variables
#' @param recvars list of specific variables selected in receptor file A
#' @param donvars list of specific variables selected in donor file B
#' @family 'Specify matching objectives'
#' @rdname matchdesign-class
#' @exportClass matchdesign        
matchdesign <- setClass("matchdesign", representation = 
                 list(rec = "data.frame", 
                      don ="data.frame",
                      matchvars = "character",
                      recvars = "character",
                      donvars = "character",
                      stratavar = "character")
)

setGeneric("describe", function(x,...) {
        standardGeneric("describe")
})

setGeneric("compare1", function(x,...){
        standardGeneric("compare1")
})

setGeneric("compare2", function(x,...){
        standardGeneric("compare2")
})

#' Summary method for the matchdesign class
#' 
#' @description Method that gives the number of rows, commmon (matching) and specific variables
#' @exportMethod describe 

setMethod("describe", "matchdesign",
          function(x,...){
                  na <- nrow(x@rec)
                  nb <- nrow(x@don)
                  l <- list('Number of receptor rows:'=na, 
                            'Number of donor rows:'=nb,
                            'Common matching variables:'=x@matchvars,
                            'Specific vars receptor file:'=x@recvars,
                            'Specific vars donor file:'=x@donvars,
                            'Strata variable:'=x@stratavar,
                            'Stratalevels:'=levels(x@rec[,x@stratavar]))
                  return(l)}
)

#' compare1 method for the matchdesign class
#' 
#' @description Measures for comparison of empirical distributions of common variables in an univariate sense
#' @exportMethod compare1

setMethod("compare1", "matchdesign",
          function(x,...){
                  varCom <<- as.character(x@matchvars)
                  rec <<- x@rec
                  don <<- x@don
                  m <- sapply(X=1:length(varCom), FUN=function(x){
                          formula1 <- as.formula(paste("~",varCom[x]))
                          formula2 <- as.formula(paste("~",varCom[x]))
                          p1 <- xtabs(formula1, data=rec)
                          p2 <- xtabs(formula2, data=don)
                          comp <- comp.prop(p1=p1,p2=p2,n1=nrow(rec), n2=nrow(don),ref=FALSE)
                          round(comp$meas,4)
                  })
                  comp <- as.data.frame(cbind(varCom,t(m)))
                  return(comp)
          }
)

#' compare2 method for the matchdesign class
#' 
#' @description Measures for comparison of empirical distributions of common variables in an univariate sense, by strata
#' @exportMethod compare2

setMethod("compare2", "matchdesign",
          function(x,...){
                  varCom <<- as.character(x@matchvars)
                  varStrata <<- as.character(x@stratavar)
                  rec <<- x@rec
                  don <<- x@don
                  slevels <<- levels(rec[,varStrata])
                  #slevels
                  #nrow(rec[which(rec[,varStrata] == slevels[1]),])
                  l <<- list()
                  sapply(X=1:length(slevels), FUN=function(s){
                          srec <<- rec[which(rec[,varStrata] == slevels[s]),]
                          sdon <<- don[which(don[,varStrata] == slevels[s]),]
                          m <- sapply(X=1:length(varCom), FUN=function(v){
                                  formula1 <- as.formula(paste("~",varCom[v]))
                                  formula2 <- as.formula(paste("~",varCom[v]))
                                  p1 <- xtabs(formula1, data=srec)
                                  p2 <- xtabs(formula2, data=sdon)
                                  comp <- comp.prop(p1=p1,p2=p2,n1=nrow(srec), n2=nrow(sdon),ref=FALSE)
                                  return(round(comp$meas,4))
                          })
                          l[[s]] <- as.data.frame(cbind(varCom,t(m))) 
                  }
                )
                 return(l)
          }
)
