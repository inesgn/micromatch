# Function concat, to be used by the generic with the same name
#' @importFrom plyr rbind.fill
".concat" <- function(x="filetomatch", y="filetomatch"){
        ## paramameters: x,y: 'filetomatch' pair
        ## performs: concatenates two filetomatch objects
        ## returns: data frame with columns from both files, to be transformed to fusedfile object
        #
        # extract data slot
        df1 <- slot(x,"data")
        df2 <- slot(y,"data") 
        #concatenate using plyr() package
        newdata <- plyr::rbind.fill(df1,df2)
        #new weights (concatenated)
        #newdata$cweights <- as.numeric(c(df1[,unlist(slot(x,"weights"))], df2[,unlist(slot(y,"weights"))]))
        #origin identifier
        newdata$origin <- c(rep("file1",nrow(df1)),rep("file2",nrow(df2)))
        #
        return(newdata)
}