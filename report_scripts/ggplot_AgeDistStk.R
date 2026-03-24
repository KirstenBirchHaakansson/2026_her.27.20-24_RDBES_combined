## Estimated age-distribution in the stock
## Valerio Bartolino, SLU-Aqua

ggAgeDistStk2 <- function(fit, yrs=NULL, ageVec=NULL, biomass=FALSE, ...){

    require(dplyr)
    require(reshape2)
    require(RColorBrewer)
    require(ggplot2)
    require(viridis)
    
    ## myColorPalette <- rep(brewer.pal(12,"Paired"),100)
    myColorPalette <- rep(brewer.pal(11,"Spectral"),100)

    tmp <- ntable(fit)
    
    ## calculate biomass
    if(biomass==TRUE){
        tmp <- ntable(fit) * fit$data$stockMeanWeight
    } else {NULL}

    tmp <- data.frame(year=as.numeric(rownames(tmp)), tmp)
    tmp <- tmp %>% gather("age","number",-1) %>% mutate(age=as.numeric(substring(age,2,3)))
    
    ## subset selected years
    if(!is.null(yrs)){
        tmp <- tmp[tmp$year %in% yrs,]
    }
    
    YrIni <- min(tmp$year,na.rm=T)
    YrFin <- max(tmp$year,na.rm=T)
    
    if(!is.null(ageVec)==TRUE){
        tmp <- filter(tmp, age %in% ageVec)
    } else { NULL }
    tmp$yc <- tmp$year-tmp$age

    # '+' on plus-group if needed
    tmp$age <- ifelse(tmp$age==fit$conf$maxAge & fit$conf$maxAgePlusGroup==1,
                      paste(tmp$age,"+",sep=""),
                      tmp$age)
    
    # plot
    n <- length(unique(tmp$yc))
        ggplot(tmp, aes(year, number, fill=factor(yc))) +
          #theme_bw() +
          geom_bar(stat = "identity") +
          expand_limits(x = c(YrIni,YrFin), y = 0) +
          scale_fill_manual(values=myColorPalette[1:n]) +
          facet_grid(age ~ ., scale = "free_y") +
          theme(legend.position = "none")
          ## theme(legend.position = "none",axis.text.y=element_blank())
    
}
