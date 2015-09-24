##  check if file exists; if not, download the file again
if(!file.exists("repdata-data-StormData.csv.bz2")){
    library(utils)
    message("Downloading data")
    fileURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
    download.file(fileURL, destfile = "./repdata-data-StormData.csv.bz2", "libcurl")
}

## read data
storm <- read.csv('repdata-data-StormData.csv.bz2')

##  store it as 'tbl_df' for faster processing
library(dplyr)
storm <- tbl_df(storm)

##  transform BGN_DATE into Date format
if (class(storm$BGN_DATE) != "Date") {
    storm <- tbl_df(transform(storm, BGN_DATE = as.Date(storm$BGN_DATE, format = "%m/%d/%Y")))
}

##  set cutoff date and filter
dateCutoff <- as.Date("1996-01-01", format = "%Y-%m-%d")
storm <- subset(storm, BGN_DATE >= dateCutoff)

##  create character vector of useful variables
neededCols <- c("STATE", "EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "PROPDMGEXP", "CROPDMG", "CROPDMGEXP", "REFNUM")

##  filter variables in storm data
newStorm <- storm[, neededCols]

##  read state longitude latitude locations
state_latlon <- read.csv("./state_latlon.csv")
valid_states <- as.character(state_latlon$state)

##  filter rows that are not valid states
newStorm$STATE <- as.character(newStorm$STATE)
newStorm <- subset(newStorm, STATE %in% valid_states)

##  remove rows with no damage whatsoever
newStorm <- subset(newStorm, !(FATALITIES<=0 & INJURIES<=0 &PROPDMG<=0 & CROPDMG<=0))
dim(newStorm)

##  sum all the data up and save new data into new variable
harmHealth <- with(newStorm, aggregate(list(Total_Fatalities = FATALITIES,
                                            Percent_Fatality = 0,
                                            Total_Injuries = INJURIES,
                                            Percent_Injury = 0),
                                       list(state = STATE),
                                       sum))

##  define percentage rates
harmHealth$Percent_Fatality <- with(harmHealth, Total_Fatalities / sum(Total_Fatalities))
harmHealth$Percent_Injury <- with(harmHealth, Total_Injuries / sum(Total_Injuries))

##  merge with latitude and longitude data
percent_injury <- merge(state_latlon, harmHealth)[, c("state", "latitude", "longitude", "Percent_Injury")]
percent_fatality <- merge(state_latlon, harmHealth)[, c("state", "latitude", "longitude", "Percent_Fatality")]

##  rename column names
names(percent_injury) <- c("State", "Latitude", "Longitude", "Percent")
names(percent_fatality) <- c("State", "Latitude", "Longitude", "Percent")

##  rescale percentage
PERCENT_SCALE <- 10
percent_injury$Percent <- percent_injury$Percent * PERCENT_SCALE
percent_fatality$Percent <- percent_fatality$Percent * PERCENT_SCALE

##  write into new RDS
saveRDS(percent_injury, './percent_injury.Rds')
saveRDS(percent_fatality, './percent_fatality.Rds')

##  load 'car' package for recode function
library(car)

##  define numeric converter
numConvert <- "'B'=1000000000; 'M'=1000000; 'K'=1000"

##  correct property damage multiplier
newStorm[newStorm$REFNUM == 605943, ]$PROPDMGEXP <- "M"

##  transform variable columns of multipliers to character form
newStorm$PROPDMGEXP <- as.character(newStorm$PROPDMGEXP)
newStorm$CROPDMGEXP <- as.character(newStorm$CROPDMGEXP)

##  create new variable column for numeric multiplier
newStorm$PROPDMGMULT <- as.numeric(recode(newStorm$PROPDMGEXP, numConvert))
newStorm$CROPDMGMULT <- as.numeric(recode(newStorm$CROPDMGEXP, numConvert))

##  create new variable column for total damage incurred
newStorm$PROPDMGTOT <- with(newStorm, PROPDMG * PROPDMGMULT)
newStorm$CROPDMGTOT <- with(newStorm, CROPDMG * CROPDMGMULT)
newStorm$DMGTOT <- with(newStorm, PROPDMGTOT + CROPDMGTOT)

##  sum all the data up and save new data into new variable
harmEcon <- with(newStorm, aggregate(list(Property_Damage = PROPDMGTOT,
                                          Percent_Property_Damage = 0,
                                          Crop_Damage = CROPDMGTOT,
                                          Percent_Crop_Damage = 0,
                                          Total_Damage = DMGTOT,
                                          Percent_Total_Damage = 0),
                                     list(state = STATE),
                                     sum,
                                     na.rm = TRUE))

##  define percentage rates
harmEcon$Percent_Property_Damage <- with(harmEcon, Property_Damage / sum(Property_Damage))
harmEcon$Percent_Crop_Damage <- with(harmEcon, Crop_Damage / sum(Crop_Damage))
harmEcon$Percent_Total_Damage <- with(harmEcon, Total_Damage / sum(Total_Damage))

##  merge with latitude and longitude data
percent_property_damage <- merge(state_latlon, harmEcon)[, c("state", "latitude", "longitude", "Percent_Property_Damage")]
percent_crop_damage <- merge(state_latlon, harmEcon)[, c("state", "latitude", "longitude", "Percent_Crop_Damage")]
percent_total_damage <- merge(state_latlon, harmEcon)[, c("state", "latitude", "longitude", "Percent_Total_Damage")]

##  rename columns
names(percent_property_damage) <- c("State", "Latitude", "Longitude", "Percent")
names(percent_crop_damage) <- c("State", "Latitude", "Longitude", "Percent")
names(percent_total_damage) <- c("State", "Latitude", "Longitude", "Percent")

##  rescale percentage
PERCENT_SCALE <- 5
percent_property_damage$Percent <- percent_property_damage$Percent * PERCENT_SCALE
percent_crop_damage$Percent <- percent_crop_damage$Percent * PERCENT_SCALE
percent_total_damage$Percent <- percent_total_damage$Percent * PERCENT_SCALE

##  write to new RDS
saveRDS(percent_property_damage, './percent_property_damage.Rds')
saveRDS(percent_crop_damage, './percent_crop_damage.Rds')
saveRDS(percent_total_damage, './percent_total_damage.Rds')
