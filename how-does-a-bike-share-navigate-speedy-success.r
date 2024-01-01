{"metadata":{"kernelspec":{"name":"ir","display_name":"R","language":"R"},"language_info":{"mimetype":"text/x-r-source","name":"R","pygments_lexer":"r","version":"3.6.0","file_extension":".r","codemirror_mode":"r"},"kaggle":{"accelerator":"none","dataSources":[{"sourceId":7319841,"sourceType":"datasetVersion","datasetId":4247819}],"isInternetEnabled":true,"language":"r","sourceType":"notebook","isGpuEnabled":false}},"nbformat_minor":4,"nbformat":4,"cells":[{"cell_type":"code","source":"install.packages(\"tidyverse\")\ninstall.packages(\"janitor\")\ninstall.packages(\"lubridate\")\ninstall.packages(\"dplyr\")\ninstall.packages(\"ggplot2\")\nlibrary(tidyverse)\nlibrary(janitor)\nlibrary(lubridate)\nlibrary(dplyr)\nlibrary(ggplot2)\n\n#Upload all the 12 separate csv file into R and merge it into one\nd1<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202212-divvy-tripdata.csv\")\nd2<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202301-divvy-tripdata.csv\")\nd3<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202302-divvy-tripdata.csv\")\nd4<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202303-divvy-tripdata.csv\")\nd5<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202304-divvy-tripdata.csv\")\nd6<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202305-divvy-tripdata.csv\")\nd7<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202306-divvy-tripdata.csv\")\nd8<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202307-divvy-tripdata.csv\")\nd9<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202308-divvy-tripdata.csv\")\nd10<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202309-divvy-tripdata.csv\")\nd11<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202310-divvy-tripdata.csv\")\nd12<-read.csv(\"https://www.kaggle.com/datasets/mrullldhm/cyclistic-trip-data?select=202311-divvy-tripdata.csv\")\ntrip <- rbind(d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12)\n#Display the summary of the data\nsummary(trip)\n\n#Delete the unnecessary variable\ntrip <- select(trip, -start_lat, -start_lng, -end_lat, -end_lng)\n#Change the string format into time based format\ntrip$started_at <- ymd_hms(trip$started_at)\ntrip$ended_at <- ymd_hms(trip$ended_at)\n#Calculate the duration in minutes.\ndifftime <- difftime(trip$ended_at, trip$started_at, units=\"mins\")\nduration <- as.numeric(difftime)\nduration <- round(duration, digits = 0)\ntrip <- mutate(trip, duration)\n#Identify day of week and month\ntrip <- mutate(trip, day_of_week = wday(started_at, label = TRUE))\ntrip <- mutate(trip, month = format(started_at, \"%b\"))\ntrip$month <- ordered(trip$month, levels = c(\"Jan\", \"Feb\", \"Mar\", \"Apr\", \"May\", \"Jun\", \"Jul\", \"Aug\", \"Sep\", \"Oct\", \"Nov\", \"Dec\"))\n#Check for missing value in dataset\nanyNA(trip)\n\nView(trip)\n\n\n                    #Visualize the data#\n\n#The amount of user based on membership\nuser <- trip %>%\n        group_by(member_casual) %>%\n        summarize(total = n()) %>%\n        mutate (total_user = sum(total)) %>%\n        group_by(member_casual) %>%\n        summarize(percentage_user = total/total_user)\n        user$percentage_user <- as.numeric(user$percentage_user)\npie(x = user$percentage_user,           \n        labels = c(\"Casual 36%\",\"Annual 64%\"), \n        main = \"The Percentage of Membership\",\n        col = blues9, \n        clockwise = TRUE,  \n        init.angle = 90,  \n        border = \"black\",  \n        radius = 1)\n\n#The duration of the usage based on user membership\n\ntime <- trip %>%\n        group_by(member_casual) %>%\n        summarize (total = sum(duration)) %>%\n        mutate(total_time = sum(total)) %>%\n        group_by(member_casual) %>%\n        summarize(percentage_time = total/total_time)\n        time$percentage_time <- as.numeric(time$percentage_time)\npie(x = time$percentage_time,           \n        labels = c(\"Casual 56%\",\"Annual 44%\"), \n        main = \"Percentage Of Duration\",\n        col = blues9, \n        clockwise = TRUE,  \n        init.angle = 90,  \n        border = \"black\",  \n        radius = 1)\n  \n#The day of week and month usage for casual member\n#For marketing timing\ndayofweekcasual <- trip %>%\n             filter(member_casual ==\"casual\") %>%\n             group_by(member_casual, day_of_week) %>% \n             summarise(numberofrides = n(),.groups = \"drop\")\nggplot(data = dayofweekcasual, aes(x = day_of_week, y = numberofrides)) + \n       geom_bar(stat = \"identity\", fill = \"blue\", color = \"black\") +\n       labs(x = \"Day Of Week\", y = \"Number Of Rides\", title = \"Casual Membership Daily usage\")\n  \ndayofweekannual <- trip %>%\n             filter(member_casual ==\"member\") %>%\n             group_by(member_casual, day_of_week) %>% \n             summarise(numberofrides = n(),.groups = \"drop\")\nggplot(data = dayofweekannual, aes(x = day_of_week, y = numberofrides)) + \n       geom_bar(stat = \"identity\", fill = \"blue\", color = \"black\") +\n       labs(x = \"Day Of Week\", y = \"Number Of Rides\", title = \"Annual Membership Daily usage\")\n\nmonthlycasual <- trip %>%\n           filter(member_casual ==\"casual\") %>%\n           group_by(member_casual, month) %>% \n           summarise(numberofrides = n(),.groups = \"drop\")\nggplot(data = monthlycasual, aes(x = month, y = numberofrides)) + \n       geom_bar(stat = \"identity\", fill = \"blue\", color = \"black\") +\n       labs(x = \"Month\", y = \"Number Of Rides\", title = \"Casual Membership Monthly Usage\")\n\nmonthlyannual <- trip %>%\n           filter(member_casual ==\"member\") %>%\n           group_by(member_casual, month) %>% \n           summarise(numberofrides = n(),.groups = \"drop\")\nggplot(data = monthlyannual, aes(x = month, y = numberofrides)) + \n        geom_bar(stat = \"identity\", fill = \"blue\", color = \"black\") +\n        labs(x = \"Month\", y = \"Number Of Rides\", title = \"Annual Membership Monthly Usage\")\n\n#Preferred bike\n#Discount approach for marketing\nbikecasual <- trip %>%\n        filter(member_casual ==\"casual\") %>%\n        group_by(member_casual, rideable_type) %>% \n        summarise(numberofrides = n(),.groups = \"drop\")\nggplot(data = bikecasual, aes(x = rideable_type, y = numberofrides)) + \n       geom_bar(stat = \"identity\", fill = \"blue\", color = \"black\") +\n       labs(x = \"Type Of Ride\", y = \"Nuymber Of Rides\", title = \"Casual Membership Bike Usage\")\n\nbikeannual <- trip %>%\n       filter(member_casual ==\"member\") %>%\n       group_by(member_casual, rideable_type) %>% \n       summarise(numberofrides = n(),.groups = \"drop\")\nggplot(data = bikeannual, aes(x = rideable_type, y = numberofrides)) + \n       geom_bar(stat = \"identity\", fill = \"blue\", color = \"black\") +\n       labs(x = \"Type Of Ride\", y = \"Nuymber Of Rides\", title = \"Annual Membership Bike Usage\")","metadata":{"_uuid":"051d70d956493feee0c6d64651c6a088724dca2a","_execution_state":"idle"},"execution_count":null,"outputs":[]}]}