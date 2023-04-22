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
library(patchwork)

# data for 4 plot task.
mydata <- data %>%
  mutate(Timestamp = dmy_hms(paste(Date, Time),tz = "CET"),.before = 1) %>%
  select(-2,-3)  %>%
  mutate_at(-1, as.numeric)
  
str(mydata)
# data.frame':	2880 obs. of  8 variables:
#  $ Timestamp            : POSIXct, format: "2007-02-01 00:00:00" "2007-02-01 00:01:00" ...
#  $ Global_active_power  : num  0.326 0.326 0.324 0.324 0.322 0.32 0.32 0.32 0.32 0.236 ...
#  $ Global_reactive_power: num  0.128 0.13 0.132 0.134 0.13 0.126 0.126 0.126 0.128 0 ...
#  $ Voltage              : num  243 243 244 244 243 ...
#  $ Global_intensity     : num  1.4 1.4 1.4 1.4 1.4 1.4 1.4 1.4 1.4 1 ...
#  $ Sub_metering_1       : num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Sub_metering_2       : num  0 0 0 0 0 0 0 0 0 0 ...
#  $ Sub_metering_3       : num  0 0 0 0 0 0 0 0 0 0 ...
#  
## Open png device; create 'plot1.png' in my working directory
png(file = "plot4.png",width = 480, height = 480) 

# par(mfrow=c(2,2)) # only work for base plot system, for ggplot2 patchwork package needed.

# plot1  ----
p1 <- ggplot(mydata, 
  aes(x = Timestamp, y = Global_active_power)) +
  geom_line(linewidth = 0.1) +
  labs(
    y = "Global Active Power",
    x = ""
  ) +
  scale_x_datetime(
    date_breaks="1 day",
    date_labels = "%a"
  )

# plot2  ----
p2 <- ggplot(mydata, 
  aes(x = Timestamp, y = Voltage)) +
  geom_line(linewidth = 0.1) +
  labs(
    x = "datetime"
  )+
  scale_x_datetime(
    date_breaks="1 day",
    date_labels = "%a"
  )

# plot3 ----
p3 <- ggplot(mydata, aes(x = Timestamp)) +
  geom_line(aes(y=Sub_metering_1,color="Sub_metering_1"),linewidth = 0.1) +
  geom_line(aes(y=Sub_metering_2,color="Sub_metering_2"),linewidth = 0.1) +
  geom_line(aes(y=Sub_metering_3,color="Sub_metering_3"),linewidth = 0.1) +
  labs(
    y = "Energy sub metering",
    x = ""
  ) +
  scale_x_datetime(
    date_breaks="1 day",
    date_labels = "%a"
  ) +
  scale_color_manual(
    name=" ",
    breaks = c("Sub_metering_1","Sub_metering_2","Sub_metering_3"),
    values = c("Sub_metering_1"="black","Sub_metering_2"="red","Sub_metering_3"="blue")
  ) +
  theme(
    legend.position = "top",
    legend.justification = "right"
  )

# plot4  ----
p4 <- ggplot(mydata, 
  aes(x = Timestamp, y = Global_reactive_power)) +
  geom_line(linewidth = 0.1) +
  labs(
    x = "datetime"
  )+
  scale_x_datetime(
    date_breaks="1 day",
    date_labels = "%a"
  )

(p1|p2)/(p3|p4) # patchwork mode
## Close the png file device
dev.off() 
