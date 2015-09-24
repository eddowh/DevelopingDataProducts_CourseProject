state <- read.csv('state_latlon.csv')

state <- state[, -1]

names(state) <- c("Latitude", "Longitude")

state$Population <- 1:nrow(state)
state$Proportion <- with(state, Population / sum(Population)) * 15

state <- state[, -3]

saveRDS(state, './testShinyGlobe.Rds')
readRDS('testShinyGlobe.Rds')