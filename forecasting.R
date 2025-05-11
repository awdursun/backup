
# There are many different approaches to time series analysis, and within R there are various tools we have
# to choose from.  This module will focus on the tsibble package for working with time series objects.  To
# get started, install the tsibble package and its complimentary libraries using the following:

install.packages("fpp3")

# Install the dependances if asked to.  Load the this family of libraries with the following:

library(fpp3)

# We will use some built-in datasets to learn more about the tsibble package and how to efficiently work
# with time series data.  Let's take a look at the aus_retail dataset:

aus_retail

# At the head of the output, we see that it is a tsibble object with 64,532 observations and 5 columns.  We
# also quickly see we are working with monthly data, as indicated by the [1M].  We also see that we have
# multiple time series contained within this single dataset.  We know this because there are 2 columns listed
# as keys.  So for each state, there are individual time series for various industries.  This particular
# dataset also provides a "Series ID" indicator that we can use to filter out individual time series:

aus_retail %>%
  filter(`Series ID`=="A3349640L") %>%
  autoplot(Turnover)

# The autoplot() command quickly allows us to create a ggplot visualization.  When autoplot() is called,
# it tries to figure out what type of plot is best suited for the data you have provided it.  We can generate
# the same plot explicitly with the following:

aus_retail %>% 
  filter(`Series ID`=="A3349640L") %>%
  ggplot(aes(x=Month, y=Turnover)) +
  geom_line()
  

# It is useful to plot out our existing data, but with time series data we are often interested in also
# plotting forecasts.  This can all be done in the same line of code using the tsibble package with
# autoplot().  The following creates an exponential smoothing forecast to predict possible outcomes
# for turnover, and plots the results with 80 and 95 percent confidence regions:

aus_retail %>% 
  filter(`Series ID`=="A3349640L") %>%
  model(ETS(Turnover)) %>%
  forecast() %>% 
  autoplot(aus_retail[aus_retail$`Series ID`=="A3349640L",])

# Comparing forecasting models can be done by simply changing the function in the model() call.  Here
# we are analyzing an ARIMA model:

aus_retail %>% 
  filter(`Series ID`=="A3349640L") %>%
  model(ARIMA(Turnover)) %>%
  forecast() %>% 
  autoplot(aus_retail[aus_retail$`Series ID`=="A3349640L",])
