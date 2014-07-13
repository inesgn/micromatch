#' 
#' Tabulate and visualize ECV(LCS) specific variables with respect to imputed PRA2-LFS segment
#'   
#' @description Tabulates a specific variable coming from Living Conditions Survey (ECV) with respect to the imputed segment from the Labour Force Survey (PRA)
#' @author Ines Garmendia
#' @param varEsp character vector containing specific variables to tabulate
#' @param varEspText character vector containing text to print for the specific variable
#' @param vary character giving the name of the imputed LFS segment variable
#' @param index index of specific variable position in varesp
#' @param data data-frame containing the fused file
#' @param wvar weight variable, if weighting is desired
#' @param table logical value. TRUE if the table is desired, FALSE otherwise. Defaults to TRUE.
#' @param plot logical value. TRUE if a plot is desired, FALSE otherwise. Defaults to FALSE.
#' @return list: table, plots
#' @details Dependencies: ggplot2, gridExtra
#' @import ggplot2 gridExtra
#' @family "Tabulate matching results"
#' @export

tabvisvar <- function(varEsp, varEspText, vary, index, data, wvar=NULL, table=TRUE, plot=FALSE){
        
        #require(ggplot2)
        #require(gridExtra)
        
        if( identical(table,TRUE) ){
                t <- addmargins(xtabs(as.formula(paste0("~",vary , "+", varEsp[index])), data = data))
        }
        
        #generate tables in df format
        df0 <<- as.data.frame(prop.table(xtabs(as.formula(paste0(wvar,"~ ", vary)), data = data)))
        df1 <<- as.data.frame(xtabs(as.formula(paste0(wvar,"~ ", vary,"+",varEsp[index])), data = data))
        
        #generate plots if plot=TRUE       
        if( identical(plot,TRUE) ){
                g0 <- ggplot(df0, 
                             aes(x=df0[,1], y=Freq)) +
                        geom_bar(stat="identity", fill="gray60", colour="gray60") + 
                        geom_text(aes(label=round(Freq,3)*100), vjust=1.5, colour="white",size=4, position=position_dodge(1))
                
                g1 <- ggplot(df1, 
                             aes(x=df1[,1], y=Freq, fill=df1[,2])) +
                        geom_bar(stat="identity", position="fill") +
                        labs(fill=varEsp[index])  + scale_fill_brewer() +
                        theme(legend.position="bottom")                
        }
        
        
        #return
        if( identical(plot,TRUE) ){
                if ( identical(table,TRUE) ){
                        grid.arrange(g1, g0, heights=c(0.7, 0.3), main=varEspText[index])
                        #print(g0)
                        #print(g1)
                        return(t)
                }
        }     
}






