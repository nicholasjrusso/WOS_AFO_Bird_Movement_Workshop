#################################################
##' Upload, visualize, and prepare movement data
##' for integrated Step Selection Analysis (iSSA)
##' Davies lab `amt` workshop
##' 31 Oct. 2025
#################################################

# Clear the R environment
rm(list = ls())

# Set working directory
working_directory <- "~/Dropbox/Harvard/amt Workshop/Movement_Ecology_Workshop/" # SET THIS TO WHERE THE MOVEMENT ECOLOGY WORKSHOP REPOSITORY IS LOCATED ON YOUR COMPUTER PLZ !!!!!
setwd(working_directory) # sets the working directory to the movement ecology workshop repository

## Load required packages
library(amt) # For processing movement data and preparing it for iSSA
library(lubridate) # For working with date and time data
library(terra) # For working with rasters
library(tidyverse) # For reshaping, and generally "wrangling" datasets

## *Download example data from GitHub and store it in your working directory

# Load hornbill GPS data
hornbills <- read.csv("data/white-thighed_hornbill_data.csv")

# Make the tag identifier a character vector
hornbills$tag.local.identifier <- as.character(hornbills$tag.local.identifier)

# Format the timestamps
OlsonNames() # Get a comprehensive list of recognized timezones
hornbills$timestamps <- as.POSIXct(strptime(hornbills$study.local.timestamp, "%Y-%m-%d %H:%M:%S", tz="Africa/Douala")) # Standardize timestamps

# Create a new column for animal ID
hornbills$id <- hornbills$tag.local.identifier

# Load environmental data (predictors of hornbill movement)
canopyHeight <- rast("data/Environmental Data/ch.tif") # Canopy height
dist2gap50 <- rast("data/Environmental Data/d50.tif") # Distance to canopy gap >= 50 m2
dist2gap500 <- rast("data/Environmental Data/d500.tif") # Distance to canopy gap >= 500 m2
VCI <- rast("data/Environmental Data/vc.tif") # Vertical Complexity Index
swamp <- rast("data/Environmental Data/swamp.tif")

# Create a raster stack of all our covariates
veg.stack <- c(canopyHeight, dist2gap50, dist2gap500, VCI, swamp)

## Any anomalies in the data (duplicates, etc.)?

# # Function to remove duplicate timestamps
# dupIt <- function(df) {
#   # Identify duplicated timestamps
#   dups <- which(duplicated(as.POSIXct(strptime(df$timestamp, "%Y-%m-%d %H:%M:%S", tz="GMT"))))
#   # Remove the duplicated timestamps
#   df <- df[-dups,]
# }

# df94 <- dupIt(hornbills[which(hornbills$tag.local.identifier=="9894"),])

# Make a "track" object with hornbill movement data, using the amt package
hornbill.trk <- make_track(hornbills, .x=utm.easting, .y=utm.northing, .t=timestamps, id= id,
                           crs="EPSG:32633",
                           all_cols = TRUE)

# Plot background data
plot(canopyHeight)
# Plot the movement track of one hornbill (9919) in red
lines(hornbill.trk[which(hornbill.trk$tag.local.identifier=="9919"),], col = "red")

#' That makes things easy for a quick visualization, but how can we make
#' a publication - ready figure?
library(sf)

## Create a shapefile for the points of each hornbill
## Transform the coordinates to latitude/longitude (you'll see why)
## 9894
points.9894 <- st_as_sf(df94, coords = c("utm.easting", "utm.northing"))
points.9894 <- points.9894 %>% st_set_crs(32633) %>% st_transform(4326)

## 9919
points.9919 <- st_as_sf(df19, coords = c("utm.easting", "utm.northing"))
points.9919 <- points.9919 %>% st_set_crs(32633) %>% st_transform(4326)

## 11852
points.11852 <- st_as_sf(df52, coords = c("utm.easting", "utm.northing"))
points.11852 <- points.11852 %>% st_set_crs(32633) %>% st_transform(4326)

## 11850
points.11850 <- st_as_sf(df50, coords = c("utm.easting", "utm.northing"))
points.11850 <- points.11850 %>% st_set_crs(32633) %>% st_transform(4326)

## 8970
points.8970 <- st_as_sf(df70, coords = c("utm.easting", "utm.northing"))
points.8970 <- points.8970 %>% st_set_crs(32633) %>% st_transform(4326)

# Bring all the white-thighed hornbill points together
white.thighed <- rbind(points.11850, points.11852, points.9919, points.9894, points.8970)

# Select and rename relevant columns
white.thighed.filter <- white.thighed  %>% dplyr::select(tag.local.identifier, timestamps, geometry)
colnames(white.thighed.filter) <- c("ID", "timestamp", "geometry")

## Load in Dja Reserve Data
dja <- st_read("~/data/DjaFaunalReserveOSM.shp") # Customize the file path for your computer

# Gather all the white-thighed hornbills
hornbill.trk <- make_track(hornbills, .x=utm.easting, .y=utm.northing, .t=timestamps, id= id,
                           crs="EPSG:32633",
                           all_cols = TRUE)

# Convert hornbill points to latitude/longitude to match Dja Reserve shapefile
hornbill.trk.latlon <- hornbill.trk %>% amt::transform_coords(4326)
white.thighed.df <- as.data.frame(hornbill.trk.latlon)

# Using ggplot, plot all the movement tracks on the same plot, with
#* Viridis color scheme
hornbill_plot <- ggplot() + 
  geom_sf(data = dja) +
  geom_sf(data = white.thighed.filter, aes(colour = ID)) + 
  geom_path(data = white.thighed.df, aes(x = x_, y=y_, colour = id)) +
  scale_colour_viridis_d(alpha = 0.3) +
  labs(x="Longitude", y= "Latitude") + 
  theme_classic()

### Back to preparing the data for Step Selection Analysis
# Nest data by individual
trk1 <- hornbill.trk |> nest(data = -"id")

# Summarize sampling rate per individual
trk1 %>%
  mutate(sampling_rate_summary = map(data, summarize_sampling_rate)) %>%
  unnest(sampling_rate_summary)

# Prepare the track object for iSSA
hornbill.extracted <- trk1 |> 
  mutate(steps = map(data, function(x) # Function to generate movement "steps"--straight lines between each consecutive GPS point
    x |> track_resample(rate = minutes(30), tolerance = minutes(10)) |> # Resample track to standardized fix rate (30 mins)
      filter_min_n_burst(min_n = 5) |> # Only return "bursts" of at least 5 consecutive locations
      steps_by_burst() |> # Generate movement steps for each burst
      random_steps(n_control = 10) |> # Generate 10 random steps per observed step
      extract_covariates(veg.stack) # Extract the value of each environmental covariate at the end of each movement step
  ))

# Have a look at the data
View(hornbill.extracted)

# Save the iSSA-ready data
save(hornbill.extracted, file = "output/hornbill.extracted.RData")


