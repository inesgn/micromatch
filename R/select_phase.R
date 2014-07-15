# 1st family of functions: Select variables

#' Grouped bars to compare two categorical variables
#'
#' @description 
#' Internal function that computes grouped bars for comparting a factor variable between two files, 
#' to be used inside other functions in micromatch.
#' @details 
#' Details here if necessary.
#' @author "Ines Garmendia <ines.garmendia@@gmail.com>"
#' @param table1 distribution of the variable in the 1st file, result of as.data.frame(xtabs()). Counts (type='abs') or freqs (type='rel')
#' @param table2 distribution of the variable in the 2nd file, result of as.data.frame(xtabs()). Counts (type='abs') or freqs (type='rel')
#' @param type type of values associated with the levels of the factor: absolute (abs) or relative (rel)
#' @return a graphical object (barplot)
#' @keywords graphics
#' @family "Select variables"
#' @import ggplot2
#' @export

plot2Cat <- function(table1, table2, type="rel"){
        
        #levels to plot
        lev <<- levels(as.data.frame(table1)$x1)
        l <<- length(lev)
        
        # Prepare data frame to plot
        df <- as.data.frame(c(table1,table2))
        df$labels <- c(lev)
        df$group <- c(rep("fileA",l),rep("fileB",l))
        names(df)[1] <- "y"
        
        # Plot
        # --> Case type='rel'
        if(type == 'rel'){
                g <<- ggplot(df, aes(x=labels,y=y, fill=group)) + 
                        geom_bar(stat="identity",position="dodge") +
                        geom_text(aes(label=round(y,1)), vjust=1.5, colour="white",size=4, position=position_dodge(1)) +
                        theme(axis.title.x=element_blank(), axis.title.y=element_blank()) +
                        scale_y_continuous(limits=c(0,100)) 
                
        }
        return(g)
}


#' Visual representation of a 2-way&3tley contingency tables based on vcd structplot
#'
#' @description Internal function to visualize 3-way contingency tables, to be used inside other functions in micromatch. Usage: two ways are for strata variables (e.g. sex and age) and third for variable of interest (common or specific)
#' 
#' @param table xtabs object crossing the three variables (usually the specific will be the last), cells can be absolute or relative values.     
#' @return a graphical object (structplot)
#' @keywords graphics
#' @author "Ines Garmendia <ines.garmendia@@gmail.com>"
#' @family "Select variables"
#' @import vcd
#' @export

plotTable <- function( table ){
        
        require(vcd)
        g <<- strucplot(x= table)
        
}

#' Comparing distributions of a variable in distinct microdata files
#' 
#' @description 
#' This function sompares the observed distribution of a variable (continuous or categorical)
#' in two distinct, independent microdata files
#' @details
#' Put more details, if necessary
#' @author "Ines Garmendia <ines.garmendia@@gmail.com>"
#' @param varA name of the variable in the first file
#' @param varB name of the variable in the second file
#' @param wA name of variable containing weights for the first file (optional)
#' @param wB name of variable containing weights for the second file (optional)
#' @param compareas Indicates how variables are to be compared: 'categorical' or 'numeric'
#' @param plot logical value. TRUE if a plot is desired, FALSE otherwise. Defaults to FALSE.
#' @param type character value if x1, x2 character vectors: type of values desired for cells ('abs' or 'rel'). 
#' @param measures similarity measures for categorical x1, x2 or descriptives for numerical x1, x2
#' @return list: table, measures, plot (if plot=TRUE) 
#' @details Dependencies: StatMatch, Hmisc, ggplot2
#' @family "Select variables" "Assess matching results"
#' @import StatMatch ggplot2 gridExtra
#' @export

compareVar <- function( varA, varB, fileA, fileB, wA=NULL, wB=NULL, plot=FALSE, compareas = "categorical", type="abs", measures=FALSE, ... ){
        
        ##dependencies with own functions: plotCat.R
        
        # Create column vectors
        x1 <- fileA[, varA]
        x2 <- fileB[, varB]
        
        # Create weight vectors, if names given
        if( !is.null(wA) ){
                w1 <- fileA[, wA]
        }
        if( !is.null(wB) ){
                w2 <- fileB[, wB]
        }       
        
        ## ---- Coherence checks -----
        #x1, x2 same class (both categorical or both numeric)
        if( !(identical(class(x1), class(x2))) ) 
                stop('x1, x2 are not of the same class')
        
        #checks when wA is given
        if( !is.null(wA) ) { 
                if( !is.numeric(w1) )
                        stop('w1 is not a numeric vector')
                
                if( length(x1) != length(w1) )
                        stop('lengths of x1, w1 are different')
        }
        #checks when wB is given
        if( !is.null(wB) ) {
                if( !is.numeric(w2) )
                        stop('w2 is not a numeric vector')
                if( length(x2) != length(w2) )
                        stop('lengths of x2, w2 are different')
        } 
        
        ##type tiene que tener un valor en la lista
        ## WARNINGS: w1, w2 given at the same time        
        
        ## ---- Block if x1,x2 categorical ----- ##
        ##METER TODO ESTO EN UN IF (VAR CATEGORICAL)
        
        if( compareas == "categorical" ){
                #action if wA is given
                if( !is.null(wA) ){
                        formula1 <- as.formula("w1~x1")
                }
                #action if not given
                else if( is.null(wA) ){
                        formula1 <- as.formula(" ~x1")
                }
                #action if wB is given
                if( !is.null(wB) ){
                        formula2 <- as.formula("w2~x2")
                }
                #action if not given
                else if( is.null(wB) ){
                        formula2 <- as.formula(" ~x2")
                }
                
                #intermediate tables
                t1 <- xtabs(formula1) 
                t2 <- xtabs(formula2)
                
                #similarity/disimilarity measures
                m <- comp.prop(p1=t1, p2=t2, n1=length(x1), n2=length(x2), ref=FALSE)$meas
                
                #transformed tables
                if( type == "abs" ){
                        rt1 <- round(t1)
                        rt2 <- round(t2)
                }
                else if( type == "rel" ){
                        rt1 <- prop.table(t1)*100
                        rt2 <- prop.table(t2)*100
                }
                
                # ---- Plots
                table1 <<- rt1
                table2 <<- rt2
                
                #barplots
                if( plot == TRUE ){
                        type <<- type                        

                        g <<- plot2Cat(table1=table1,table2=table2,type=type)
                        print(g)
                }
        }
        
        # ---- Return
        
        l1 <- addmargins(round(rt1,2))
        l2 <- addmargins(round(rt2,2))
        if( measures == TRUE){
                l3 <- m   
        }
        else if( measures == FALSE ){
                l3 <- NULL
        }
        
        return( list("table for file #1" = l1, "table for file #2" = l2, "measures"= l3) )        
}

#' Comparing multivariate distributions of categorical variables in two files
#' 
#' @description Compares distribution categorical variables (maximum 3) in two distinct files
#' @param var1A name of first variable (independet) in the first file
#' @param var1B name of first variable (independent) in the second file
#' @param var2A name of second variable (dependent) in the first file 
#' @param var2B name of second variable (dependent) in the first file 
#' @param var3B name of third variable (independent) in the first file (optional)
#' @param var3B name of third variable (independet) in the first file (optional)
#' @param fileA data frame containing first file
#' @param fileB data frame containing second file
#' @param wA name of variable containing weights for the first file (optional)
#' @param wB name of variable containing weights for the second file (optional)
#' @param plot logical value. TRUE if a plot is desired, FALSE otherwise. Defaults to FALSE.
#' @param type character value if x1, x2 character vectors: type of values desired for cells ('abs' or 'rel'). 
#' @param measures similarity measures for categorical x1, x2 or descriptives for numerical x1, x2
#' @return list: table, measures, plot (if plot=TRUE) 
#' @details Dependencies: StatMatch, Hmisc, ggplot2, vcd
#' @family "Select variables"
#' @import StatMatch ggplot2 gridExtra vcd
#' @export

compareMultivar <- function( var1A, var1B, var2A, var2B, var3A=NULL, var3B=NULL, fileA, fileB, wA=NULL, wB=NULL, plot=FALSE, type="abs", measures=FALSE, ... ){
        
        ##dependencies with own functions: plot3W.R
        
        # Create column vectors
        x1 <- fileA[, var1A]
        x2 <- fileB[, var1B]
        y1 <- fileA[, var2A]
        y2 <- fileB[, var2B]
        
        # Create weight vectors, if names given
        if( !is.null(wA) ){
                w1 <- fileA[, wA]
        }
        if( !is.null(wB) ){
                w2 <- fileB[, wB]
        }       
        
        ## ---- Coherence checks -----
        #Check var3A given then var3B given too
        
        ##type tiene que tener un valor en la lista
        ## WARNINGS: w1, w2 given at the same time 
        
        ## ---- Block if third variable given ----- ##
        if( !is.null(var3A) ){
                #create vectors
                z1 <- fileA[, var3A]
                z2 <- fileB[, var3B]
                
                #action if w1 is given
                if( !is.null(wA) ){
                        formula1 <- as.formula("w1~x1+z1+y1")
                }
                #action if not given
                else if( is.null(wA) ){
                        formula1 <- as.formula(" ~x1+z1+y1")
                }
                #action if w2 is given
                if( !is.null(wB) ){
                        formula2 <- as.formula("w2~x2+z2+y2")
                }
                #action if not given
                else if( is.null(wB) ){
                        formula2 <- as.formula(" ~x2+z2+y2")
                }
        }
        
        ## ---- Block if third variable NOT given ----- ##
        else if( is.null(var3A) ){
                
                #action if w1 is given
                if( !is.null(wA) ){
                        formula1 <- as.formula("w1~x1+y1")
                }
                #action if not given
                else if( is.null(wA) ){
                        formula1 <- as.formula(" ~x1+y1")
                }
                #action if w2 is given
                if( !is.null(wB) ){
                        formula2 <- as.formula("w2~x2+y2")
                }
                #action if not given
                else if( is.null(wB) ){
                        formula2 <- as.formula(" ~x2+y2")
                }
                
        }
        
        #Tables
        t1 <- xtabs(formula1) 
        t2 <- xtabs(formula2)
        
        #similarity/disimilarity measures
        m <- comp.prop(p1=t1, p2=t2, n1=length(x1), n2=length(x2), ref=FALSE)$meas
        
        #transformed tables
        if( type == "abs" ){
                rt1 <- round(structable(t1), 0)
                rt2 <- round(structable(t2), 0)
        }
        else if( type == "rel" ){
                rt1 <- round(prop.table(structable(t1))*100,2)
                rt2 <- round(prop.table(structable(t2))*100,2)
        }
        
        # ---- Plots
        
        #barplots
        if( plot == TRUE ){
                par(mfrow=c(2,1))
                table1 <<- t1
                g1 <<- plotTable( table=t1 )
                
                table2 <<- t2
                g2 <<- plotTable( table=t2 )
                
        }
        
        # ---- Return
        
        l1 <- rt1
        l2 <- rt2
        if( measures == TRUE){
                l3 <- m   
        }
        else if( measures == FALSE ){
                l3 <- NULL
        }
        
        
        return( list("table for file #1" = l1, "table for file #2" = l2, "measures"= l3) )
        
}

#' 
#' Evaluating predictive value of individual variables w.r.t. a specific variable
#'   
#' @description Evaluates predictive value of a common variable \texttt{x} with respect to a specific variable \texttt{y}, in the context of statistically matching two independent files.
#' @param varx name of common variable 
#' @param vary name of specific variable
#' @param data name of data-frame containing both x and y
#' @param varw name of weights variable in data-frame data (optional)
#' @param plot logical value. TRUE if a plot is desired, FALSE otherwise. Defaults to FALSE.
#' @param measures logical value. TRUE if measures of predictive value are desired.
#' @param type type of cell values desired in the table: 'abs' or 'rel'
#' @return list: table, measures, plot
#' @details Dependencies: StatMatch, Hmisc, ggplot2
#' @family "Select variables"
#' @import StatMatch vcd
#' @export

predictvalue <- function(varx, vary, data, varw=NULL, plot=FALSE, measures=FALSE, type = 'abs',...){
        
        #Create vectors
        x <- data[,varx]
        y <- data[,vary]
        
        #---- Actions if both x, y categorical
        # Measures
        formula <- as.formula(y ~ x)
        
        # if weights given
        if( !is.null(varw) ){
                w <- data[,varw]
                t <- xtabs(w ~ x+y, data=data) #para representar  
                if( measures == TRUE ){
                        m <- pw.assoc(formula, data = data, weights=varw) 
                }
                else if( measures == FALSE ){
                        m <- "measured not requested"
                }
        }
        else if( is.null(varw) ){
                m <- pw.assoc(formula, data = data )      
                t <- xtabs(~x+y, data=data)
                if( measures == TRUE ){
                        m <- pw.assoc(formula, data = data, weights=varw) 
                }
                else if( measures == FALSE ){
                        m <- "measured not requested"
                }
        }
        
        #Plot
        if(plot == TRUE){
                g <- mosaicplot( x=t ,dir="h",off=30)
                g
        }
        
        #Table
        if( type == "abs" ){
                rt <- addmargins(round(t,0))    
        }
        else if( type == "rel" ){
                rt <- addmargins(round(prop.table(t,1) * 100,2)) #row percents
        }    
        
        l <- list('Table' = rt, 'Measures' = m)
        return(l)
}

#' 
#' Variable selection by evaluating uncertainty in contingency table estimation
#'   
#' @description Computes uncertainty based on Frechet bounds for the contingency table for two specific variables (each in a file) given a list of common variables between the files, and selects the best combination of common variables from the list.
#' @param varx name of specific variable in the first file
#' @param vary name of specific variable in the second file
#' @param data1 data-frame for the first file
#' @param data2 data-frame for the second file
#' @param basedata data from which to estimate marginal distributions for commomn variables, choose between values given in data1 or data2
#' @param varw1 name of weights variable in data1 (optional)
#' @param varw2 name of weights variable in data2 (optional)
#' @param varlist list of common variables present in both files, candidates for matching
#' @return list: name of varx, name of vary, best overall uncertainty, variable list for best ov.uncertainty
#' @details Dependencies: StatMatch
#' @family "Select variables"
#' @import StatMatch
#' @export

uncertvarxvary <- function(varx, vary, data1, data2, basedata=NULL, varw1=NULL, varw2=NULL, varlist,...){
        
        #Checks
        if ( is.null(basedata) ) stop("Indicate which df (data1 or data2) to use to compute marginal distributions for common variables")
        
        #Create formulas
        if( identical(basedata,data1) ) {#use varw1
                formulazz <<- as.formula(paste(varw1, " ~ ", paste(varlist, collapse= "+")))
        }
        else if( identical(basedata,data2) ) {#use varw2
                formulazz <<- as.formula(paste(varw2, " ~ ", paste(varlist, collapse= "+")))
        }
        formulaxz <<- as.formula(paste(varw1, " ~ ", paste(c(varlist,varx), collapse= "+")))
        formulayz <<- as.formula(paste(varw2, " ~ ", paste(c(varlist,vary), collapse= "+")))
        
        #compute marginal distributions
        
        zz <- xtabs(formula=formulazz , data = basedata)#data1 or data2
        xz <- xtabs(formula=formulaxz , data = data1)
        yz <- xtabs(formula=formulayz, data = data2)
        
        #compute uncertainty bounds
        out.fbw <- Fbwidths.by.x(tab.x=zz, tab.xy=xz, tab.xz=yz)
        best <- out.fbw$sum.unc[order(out.fbw$sum.unc$ov.unc),][1,]      
        
        #return values
        
        bestvars <- rownames(best)
        bestn <- best$x.vars
        bestcells <-  best$x.cells
        bestval <- best$ov.unc
        
        l <- list('Best'=bestvars, 
                  'NumberVariables'=bestn, 
                  'NumberCells'=bestcells, 
                  'OvUncert'=bestval)
        return(l)
}