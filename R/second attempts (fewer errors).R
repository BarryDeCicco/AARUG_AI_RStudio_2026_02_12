

# list data sets available in the current R envrionment
data()

# load the airquality data set


# view the first few rows of the data set
# view the structure of the data set
# view the summary of the data set

# show me the structure of the data set
str(airquality)
# show me the summary of the data set
summary(airquality)


# write a tidyverse code to create a summary of the airquality data set by month, showing the average Ozone levels for each month
library(dplyr)
airquality %>%
  group_by(Month) %>%
  summarise(avg_ozone = mean(Ozone, na.rm = TRUE)) %>%
  arrange(Month)

# write a tidyverse code to create a summary of the airquality data set by month, showing the average Ozone levels for each month, and then arrange the results in descending order of average Ozone levels
airquality %>%
  group_by(Month) %>%
  summarise(avg_ozone = mean(Ozone, na.rm = TRUE)) %>
  arrange(desc(avg_ozone))

# correct the above code block
airquality %>%
  group_by(Month) %>%
  summarise(avg_ozone = mean(Ozone, na.rm = TRUE)) %>%
  arrange(desc(avg_ozone))

# for the above code block, put the results into a good-looking table
library(knitr)
library(kableExtra)
airquality %>%
  group_by(Month) %>%
  summarise(avg_ozone = mean(Ozone, na.rm = TRUE)) %>%
  arrange(desc(avg_ozone)) %>%
  kable() %>%
  kable_styling(bootstrap_options = "striped", full_width = FALSE)





