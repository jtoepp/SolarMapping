# data retrieved from https://rredc.nrel.gov/solar/old_data/nsrdb/1991-2005/tmy3/
# define project home directory
home <- "/Documents/02 - Personal Projects/01 - Solar Mapping Project"

# set working directory for the current project
setwd(home)

# verify 
getwd()

# specify the packages of interest
packages = c("ggplot2",
             "ggcharts",
             "dplyr",
             "readxl",
             "data.table",
             "purrr",
             "tidyr",
             "lubridate",
             "chron",
             "DataExplorer")

# use this function to check if each package is on the local machine
# if a package is installed, it will be loaded
# if any are not, the missing package(s) will be installed and loaded
package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

##### 
##### replaced with function etlTMY3
# # read in excel file and store in a dataframe
# dfRaw = read.table("Data/TMY3/0_34.3_-116.17_tmy3.csv", header = FALSE, sep = ",", fill = TRUE)
# 
# # pull out lat, lon, and elevation from the first two rows
# lat <- dfRaw[2,6]
# lon <- dfRaw[2,7]
# elevation <- dfRaw[2,9]
# 
# # remove first 4 rows to get to the meat of the data
# dfTest <- slice(dfRaw, 4:n())
# 
# # combine all columns and force lat, lon, and elevation to repeat for every column
# dfTestConcat <- cbind(dfTest, lat, lon, elevation)

# # set the input path
# inDir <- "/Documents/02 - Personal Projects/01 - Solar Mapping Project/Data/TMY3"

# # get a list of all the files
# file_list <- list.files(path=inDir, pattern="*.csv")

# # change directory to file locations
# setwd("/Documents/02 - Personal Projects/01 - Solar Mapping Project/Data/TMY3")

# get each file and perform read table on each and pass them to the global environment
# list2env(
#   lapply(setNames(file_list,
#     make.names(file_list)),
#   read.table, header = FALSE, sep = ",", fill = TRUE),
#   envir = .GlobalEnv)
    
#####
##### create a custom function to do the following: 
# read in excel file and store in a dataframe
# pull out lat, lon, and elevation from the first two rows
# remove first 4 rows to get to the meat of the data
# combine all columns and force lat, lon, and elevation to repeat for every column
# etlTMY3 <- function(file){
#   raw <- read.table(file, header = FALSE, sep = ",", fill = TRUE)
#   lat <- raw[2,6]
#   lon <- raw[2,7]
#   elevation <- raw[2,9]
#   raw <- slice(raw, 4:n())
#   raw <- cbind(raw, lat, lon, elevation)
# }

# # set the output path
# outDir <- "Data/TMY3_out"
# 
# # change wd to ouput path
# setwd(outDir)
# 
# # export the edited file to a new .csv file and directory
# mapply(write.csv, file_list, file = paste0(names(file_list)), ".csv")



# set the input path
inDir <- "/Documents/02 - Personal Projects/01 - Solar Mapping Project/Data/TMY3"

# change the working directory 
setwd(inDir)

# combine all files in the listed directory into one dataframe
df = list.files(path=inDir, pattern="*.csv") %>% 
  map_df(~fread(.))

# take a look 
head(df)

# rename col names
df = df %>% 
  rename(Year = V1, 
         Month = V2, 
         Day = V3, 
         Hour = V4, 
         Minute = V5, 
         DHI = V6, 
         DNI = V7, 
         GHI = V8, 
         DewPoint = V9,
         Temperature = V10, 
         Pressure = V11, 
         RelativeHumidity = V12, 
         WindSpeed = V13, 
         Latitude = V14,
         Longitude = V15, 
         Elevation = V16)

# store as a tibble in a new dataframe
dfFinal <- as_tibble(df)

# take a look
head(dfFinal)

# add a new date column combining Month and Day columns and store in new dataframe
dfSolar <- unite(dfFinal, Date, c(Month, Day), remove = FALSE)

# take a look
head(dfSolar)

# convert Date column to Date format
dfSolar$Date <- as.Date(dfSolar$Date, format="%m_%d")

# verify correct Date class for Date column
str(dfSolar$Date)

# take another look
head(dfSolar)

# drop old Month and Day columns
dfSolar <- dfSolar %>% 
  select(-Month, -Day)

# take a final look
head(dfSolar) 

# Because of the year being a Typical Meteorological Year, it does not have a date
# However... as.date() automatically fills in the current year if none is provided
# It is good to keep in mind that this is not a valid year and should not be used in plots/reports

# return to home directory
setwd(home)

# verify directory
getwd()

### Get a better idea of each variable
# summarize each column with introduce(), and transform from 1x9 tibble to 8x2 for easier viewing
introduce(dfSolar) %>% 
  gather(var, val, 2:ncol(dfSolar)) %>% 
  spread_(names(dfSolar)[1], "val")

# utilize plot_intro to visualize
plot_intro(dfSolar) # confirmed no N/A observations to deal with

# # not needed due to no missins observations
# # visualize columns with N/A observations
# plot_missing(dfSolar)

# set a save path for later use of ggsave()
plotPath = "./Plots"

# visualize distribution
dfSolar %>% 
  bar_chart(x = Year) +
  labs(x = "Year",
       y = "Frequency",
       title = "Frequency of Each String Occurrence") +
  theme_nightblue(grid = "XY",
                  axis = "x",
                  ticks = "x") 
  # ggsave("StringFrequency.png",
  #        plot = last_plot(),
  #        path = plotPath)

# with the only value in Year being Typical, drop the column
dfSolar <- dfSolar %>% 
  select(-Year)

# take a look with glimpse() to see all 14 columns vertically
glimpse(dfSolar)


# take a look at the original df to pull the Month column out for later aggregation
head(dfFinal)

# take a more useful look
glimpse(dfFinal)

# convert dataframe to long format for plotting with facet_wrap()
# and remove Hour and Minute so the focus is on the date
dfSolar_long <- dfFinal %>%
  select(-Year, -Day, -Hour, -Minute, -Latitude, -Longitude) %>%
  gather(Variable, Value, -Month)

# take a look
head(dfSolar_long)

########## LEFT OFF HERE ##########
# aggregate based on Date
dfSolar_aggregate <- aggregate(dfSolar_long,
                               by = list(dfSolar_long$Month),
                               FUN = sum)

# take a look
head(dfSolar_aggregate)

# histogram of all columns with facet_wrap()
ggplot(dfSolar, 
       aes(x = Date,
           y = Value,
           linetype = Variable,
           color = Variable)) +
  geom_smooth(method = "loess", linetype = 1, color = "lightgray") +
  geom_line(linetype = 1) +
  facet_wrap(~Variable, scales="free_y", nrow=2, strip.position="top") +
  theme_dark() +
  labs(name = "Variable",
       title = "Air Quality Dataset (1973)",
       subtitle = "Individual plots of each variable utilizing 'loess'
  - t-based approximation for a smoothing curve and confidence interval",
       caption = "Units:
       Ozone (parts per billion)
       Solar (Watts per square meter)
       Wind (Miles per Hour)
       Temp (degrees Fahrenheit)",
       ylab = "Values*") 
  # ggsave("Fig12.png",
  #        plot = last_plot(),
  #        path = pathGraphs)





##### Testing Chron function to convert to a time data type #####
# convert Date column to Date format
dfSolar$Date <- chron(dfSolar$Date, format = c( 'm-d' , 'h:m' ))

# verify correct Date class for Date column
str(dfSolar$Date)













