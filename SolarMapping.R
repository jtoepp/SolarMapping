# data retrieved from https://rredc.nrel.gov/solar/old_data/nsrdb/1991-2005/tmy3/
# set working directory for the current project
setwd("/Documents/02 - Personal Projects/01 - Solar Mapping Project")

# specify the packages of interest
packages = c("ggplot2",
             "ggcharts",
             "dplyr",
             "readxl")

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

# define new row names and store in a vector
cNames <- c("Year", "Month", "Day", "Hour", "Minute", "DHI", "DNI", "GHI", "DewPoint",
            "Temperature", "Pressure", "RelativeHumidity", "WindSpeed", "Latitude",
            "Longitude", "Elevation")

# set the input path
inDir <- "/Documents/02 - Personal Projects/01 - Solar Mapping Project/Data/TMY3"

# get a list of all the files
file_list <- list.files(path=inDir, pattern="*.csv")

# change directory to file locations
setwd("/Documents/02 - Personal Projects/01 - Solar Mapping Project/Data/TMY3")

# get each file and perform read table on each and pass them to the global environment
list2env(
  lapply(setNames(file_list,
    make.names(file_list)),
  read.table, header = FALSE, sep = ",", fill = TRUE),
  envir = .GlobalEnv)
    
#####
##### create a custom function to do the following: 
# read in excel file and store in a dataframe
# pull out lat, lon, and elevation from the first two rows
# remove first 4 rows to get to the meat of the data
# combine all columns and force lat, lon, and elevation to repeat for every column
etlTMY3 <- function(file){
  raw <- read.table(file, header = FALSE, sep = ",", fill = TRUE)
  lat <- raw[2,6]
  lon <- raw[2,7]
  elevation <- raw[2,9]
  raw <- slice(raw, 4:n())
  raw <- cbind(raw, lat, lon, elevation)
}




# set the output path
outDir <- "Data/TMY3_out"

# change wd to ouput path
setwd(outDir)

# export the edited file to a new .csv file and directory
mapply(write.csv, file_list, file = paste0(names(file_list)), ".csv")












