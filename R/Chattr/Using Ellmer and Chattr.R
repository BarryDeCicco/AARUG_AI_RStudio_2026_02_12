
## USING ELLMER and CHATTR (https://ellmer.tidyverse.org/)



## install.packages("ellmer")
library(ellmer)

chat <- chat_openai(model = "gpt-4o")

chat <- chat_anthropic()


## chat$chat("Hello from ellmer!")

chat$chat("please analyze the data set 'airquality'")


#################### Interactive chat console ################

live_console(chat)

