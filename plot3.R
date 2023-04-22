# project data define ----
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
destfile <- "household_power_consumption.zip"

# download data ----
download.file(url,destfile = destfile)

# unzip file to data folder ----
## Create a subfolder called "data" if it doesn't exist
if (!file.exists("data")) {
  dir.create("data")
}
## Unzip the zip file to the "data" subfolder
unzip(destfile, exdir = "data")

datafile <- "data/household_power_consumption.txt"

# Read only the data for the specified dates
data <- read.table(datafile, header = TRUE,sep = ";")
data <- data[data$Date == "1/2/2007" | data$Date == "2/2/2007",]

dim(data)
# [1] 2880    9
str(data)
# 'data.frame':	2880 obs. of  9 variables:
# $ Date                 : Date, format: "2007-02-01" "2007-02-01" "2007-02-01" ...
# $ Time                 : chr  "00:00:00" "00:01:00" "00:02:00" "00:03:00" ...
# $ Global_active_power  : chr  "0.326" "0.326" "0.324" "0.324" ...
# $ Global_reactive_power: chr  "0.128" "0.130" "0.132" "0.134" ...
# $ Voltage              : chr  "243.150" "243.320" "243.510" "243.900" ...
# $ Global_intensity     : chr  "1.400" "1.400" "1.400" "1.400" ...
# $ Sub_metering_1       : chr  "0.000" "0.000" "0.000" "0.000" ...
# $ Sub_metering_2       : chr  "0.000" "0.000" "0.000" "0.000" ...
# $ Sub_metering_3       : num  0 0 0 0 0 0 0 0 0 0 ...

library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyr)

mydata <- data %>%
  mutate_at(vars(3:9), as.numeric) %>% 
  mutate(Timestamp = dmy_hms(paste(Date, Time),tz = "CET"),.before = 1) %>%
  select(Timestamp,Sub_metering_1,Sub_metering_2,Sub_metering_3) %>% 
  arrange(Timestamp) %>%
  pivot_longer(-Timestamp,names_to = "Variable",values_to = "Value")

# plot2  ----
## Open png device; create 'plot3.png' in my working directory
png(file = "plot3.png",width = 480, height = 480) 

## Create plot and send to a file (no plot appears on screen)
ggplot(mydata, aes(x = Timestamp)) +
  geom_line(aes(y=Value,col=Variable),linewidth = 0.1) +
  labs(
    y = "Energy sub metering",
    x = ""
  ) +
  scale_x_datetime(
    date_breaks="1 day",
    date_labels = "%a"
    ) +
  scale_color_manual(
    name="",
    values = c("Sub_metering_1"="black","Sub_metering_2"="red","Sub_metering_3"="blue")
  ) +
  theme(
    legend.position = c(1,1),
    legend.justification=c(1, 1),
    panel.background = element_rect(fill="white"),
    axis.line = element_line(size = 1, colour = "black")
  )

## Close the png file device
dev.off() 
