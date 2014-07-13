# 2nd family of functions: Apply matching

#' Create fused file using NN hot deck for a given strata and a given list of categorical matching variables
#' 
#' @description For a given strata and a list of variables, it performs nearest neighbour hot deck matching for categorical variables using Gower's distance and constrained matchinig
#' @author "Ines Garmendia"
#' @param rec recipient file data frame
#' @param don donor file data frame
#' @param stratalevel character identifying strata: a level of stratavar
#' @param stratavar name of the variable to define the strata given by strataid
#' @param matchvars character vector with names of matching variables
#' @param vary variables in donor file to be imputed to the recipient file
#' @param checdiffs logical value indicating if a check of differences between donor-recipient files is desired
#' @return Fused file
#' @family "Apply matching method"
#' @import StatMatch
#' @export

nnhdbystrata <- function(rec, don, stratalevel, stratavar, matchvars, vary, checkdiffs=FALSE){
        
        #require(StatMatch)
        
        #donor and recipient files filtered by stratavar
        don.strata <-  don[which(don[,stratavar] == stratalevel), ]
        rec.strata <-  rec[which(rec[,stratavar] == stratalevel), ]
        
        #compute recipient-donor pairs
        out.nnd <- NND.hotdeck(data.rec = rec.strata, data.don = don.strata, dist.fun = "Gower", match.vars = matchvars, 
                               constrained = TRUE)
        #create fused file
        fused <- create.fused(data.rec=rec.strata, data.don=don.strata,
                              mtc.ids=out.nnd$mtc.ids,
                              z.vars=c(vary,matchvars) )
        
        
        ## Check differences between recipient-donor files
        #Change matching variable names for traceability
        #identify start position of vary
        pos <- min(which((names(fused) == vary) == TRUE))
        l <- length(c(vary,matchvars))
        #change names of matching variables in the fused file 
        #(to distinguish from original variables)
        names(fused)[(pos+1):(pos+l-1)] <- paste0(names(fused)[(pos+1):(pos+l-1)],".don")
        
        if( checkdiffs ){
                
                sapply(1:length(matchvars) , FUN=function(x) {
                        t <- xtabs( as.formula(paste("~","fused$",matchvars[x],"+","fused$",matchvars[x],".don", sep="")))
                        print(t)
                }
                )               
        }
        
        #delete columns corresponding to match.vars in the fused file
        fused <- fused[,-c((pos+length(vary)):(pos+length(vary)+length(matchvars)-1))]
        #return
        return(fused)       
}
