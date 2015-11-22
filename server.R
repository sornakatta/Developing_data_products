#server.R


library(shiny)

#For ggplot2 Graphics Library
library(ggplot2)

# Analysis Code
births <- read.table("Gelman-death_trends/births.txt", header=TRUE)
mean_age_45_54 <- function(yr){
        ages <- 45:54
        ok <- births$year %in% (yr - ages)
        return(sum(births$births[ok]*rev(ages))/sum(births$births[ok]))
}
for (yr in 1989:2015) print(mean_age_45_54(yr))

## from life table

deathpr_by_age <- c(.003064, .003322, .003589, .003863, .004148, .004458, .004800, .005165, .005554, .005971)

deathpr_male <- c(.003244, .003571, .003926, .004309, .004719, .005156, .005622, .006121, .006656, .007222)
deathpr_female <- c(.002069, .002270, .002486, .002716, .002960, .003226, .003505, .003779, .004040, .004301)

## sum it up

pop <- read.csv("Gelman-death_trends/US-EST00INT-ALLDATA.csv")
years <- 1989:2013
deathpr_1 <- rep(NA, length(years))
deathpr_2 <- rep(NA, length(years))
for (i in 1:length(years)){
        ages_in_2000 <- (2000 - years[i]) + (45:54)
        ok <- pop[,"AGE"] %in% ages_in_2000 & pop[,"MONTH"]==4 & pop[,"YEAR"]==2000
        pop_male <- pop[ok,"NHWA_MALE"]
        pop_female <- pop[ok,"NHWA_FEMALE"]
        print(c(weighted.mean(45:54, pop_male), weighted.mean(45:54, pop_female)))
        deathpr_1[i] <- weighted.mean(deathpr_by_age, pop_male + pop_female)
        deathpr_2[i] <- sum(deathpr_male* pop_male + deathpr_female*pop_female)/sum(pop_male + pop_female)
}

deaton <- read.table("Gelman-death_trends/deaton.txt", header=TRUE)

ages_all <- 35:64
ages_decade <- list(35:44, 45:54, 55:64)
years_1 <- 1999:2013
mort_data <- as.list(rep(NA,3))
group_names <- c("Non-Hispanic white", "Hispanic white", "African American")
mort_data[[1]] <- read.table("Gelman-death_trends/white_nonhisp_death_rates_from_1999_to_2013_by_sex.txt", header=TRUE)
mort_data[[2]] <- read.table("Gelman-death_trends/white_hisp_death_rates_from_1999_to_2013_by_sex.txt", header=TRUE)
mort_data[[3]] <- read.table("Gelman-death_trends/black_death_rates_from_1999_to_2013_by_sex.txt", header=TRUE)


raw_death_rate <- array(NA, c(length(years_1), 3, 3))
male_raw_death_rate <- array(NA, c(length(years_1), 3, 3))
female_raw_death_rate <- array(NA, c(length(years_1), 3, 3))
avg_death_rate <- array(NA, c(length(years_1), 3, 3))
male_avg_death_rate <- array(NA, c(length(years_1), 3, 3))
female_avg_death_rate <- array(NA, c(length(years_1), 3, 3))
for (k in 1:3){
        data <- mort_data[[k]]
        male <- data[,"Male"]==1
        for (j in 1:3){
                for (i in 1:length(years_1)){
                        ok <- data[,"Year"]==years_1[i] & data[,"Age"] %in% ages_decade[[j]]
                        raw_death_rate[i,j,k] <- 1e5*sum(data[ok,"Deaths"])/sum(data[ok,"Population"])
                        male_raw_death_rate[i,j,k] <- 1e5*sum(data[ok&male,"Deaths"])/sum(data[ok&male,"Population"])
                        female_raw_death_rate[i,j,k] <- 1e5*sum(data[ok&!male,"Deaths"])/sum(data[ok&!male,"Population"])
                        avg_death_rate[i,j,k] <- mean(data[ok,"Rate"])
                        male_avg_death_rate[i,j,k] <- mean(data[ok&male,"Rate"])
                        female_avg_death_rate[i,j,k] <- mean(data[ok&!male,"Rate"])
                }
        }
}


shinyServer(
        function(input, output) {
                #Draw ggplot based/reactive on user input
                output$plot <- reactivePlot(function() {
                        
                        if(input$Adjustment == "Unadjusted"){
                        par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
                        plot(years_1, raw_death_rate[,2,1],  ylim=c(382,  416), xaxt="n", yaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Death rate per 100,000", main="Unadjusted death rates for non-Hispanic whites aged 45-54")
                        axis(1, seq(1990,2020,5))
                        axis(2, seq(390, 420, 10))
                        grid(col="gray")
                        }
                        if(input$Adjustment == "Age adjusted"){
                        par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
                        plot(years_1, avg_death_rate[,2,1],  ylim=c(382, 416), xaxt="n", yaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Death rate per 100,000", main="Age-adjusted death rates for non-Hispanic whites aged 45-54")
                        axis(1, seq(1990,2020,5))
                        axis(2, seq(390, 420, 10))
                        grid(col="gray")
                        }
                        if(input$Adjustment == "Split by gender"){
                                par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
                                plot(range(years_1), c(1, 1.1), xaxt="n", yaxt="n", type="n", bty="l", xaxs="i", xlab="", ylab="Death rate relative to 1999", main="Age-adjusted death rates for non-Hispanic whites aged 45-54:\nTrends for women and men")
                                lines(years_1, male_avg_death_rate[,2,1]/male_avg_death_rate[1,2,1], col="blue")
                                lines(years_1, female_avg_death_rate[,2,1]/female_avg_death_rate[1,2,1], col="red")
                                axis(1, seq(1990,2020,5))
                                axis(2, seq(1, 1.1, .05))
                                text(2011.5, 1.075, "Women", col="red")
                                text(2010.5, 1.02, "Men", col="blue")
                                grid(col="gray")
                        }
                }, height=500, width = 500)               
                
                        
                }
        
)