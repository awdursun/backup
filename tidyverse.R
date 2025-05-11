
# Tidyverse is a collection of packages designed to work together and help streamline the data science workflow in R.  
# It provides an alternative to using base R functions for data cleaning, data manipulation, and plotting.  Some
# tasks may be easier/cleaner using base R, and other tasks might favor using Tidyverse.  It often just comes down 
# to preference for the individual user on what style to code in.  This module is meant to be a brief overview of
# Tidyverse, how the syntax looks, and how some of the functions work together.  

# Tidyverse revolves around tidy data, meaning each column of a dataframe represents a variable, and each row
# represents an observation.

# To get started with Tidyverse, install the Tidyverse package:

install.packages("tidyverse")

# This will install the collection of packages that comprise the Tidyverse.  Install the dependencies if asked to.
# Load the Tidyverse library with the following:

library(tidyverse)

# We will use built-in datasets to familiarize ourselves with Tidyverse.  Tidyverse is developed to be easy to
# understand, even with little to no programming experience.  To begin, let's look at the airquality dataset.

View(airquality)

# This dataset shows daily air quality measurements in New York, May to September 1973.  For more information
# about built-in datasets, we can pull up the help file:


?airquality




# Data manipulation

# What if we want to calculate the average temperature for the first 10 days of each month?  The following code 
# does that in a concise way:

airquality %>%
  filter(Day <= 10) %>%
  group_by(Month) %>%  
  summarise(avg_temp = mean(Temp))


# Tidyverse syntax is often written similar to the above.  The %>% command is called the piping operator,
# and it chains together a series of functions.  It allows us to read and write code sequentially, instead
# of wrapping functions around each other and reading code from the inside out.

# The following code uses the same exact functions to get the same end results, but because it is a series 
# of nested functions it is not as easy to read and understand.

summarise(group_by(filter(airquality, Day <= 10), Month), avg_temp = mean(Temp))



# For reference, to achieve this using base R, the following produces the same results:

aggregate(formula = Temp ~ Month, data = airquality, FUN = mean, subset = airquality$Day <= 10)

aggregate(Temp ~ Month, airquality, mean, airquality$Day <= 10)

# Piping also allows us to not have to create new variables at each step.  For example, we could have also 
# done the above code by defining new variables at each step:

aq_filtered <- airquality %>% filter(Day <= 10)  
aq_grouped <- aq_filtered %>% group_by(Month)
aq_summarised <- aq_grouped %>% summarise(avg_temp = mean(Temp)) 

aq_summarised

# This is not a problem when working in a small project with a manageable size dataset, but it is not a clean
# approach.  That said, if you are unsure about any intermediary step, feel free to break up sequences of 
# function calls to get a better idea of what your data looks like.



##### Exercise #####

# There is a built-in dataset named ChickWeight.  It shows the weights of 50 different chicks at various time 
# intervals.  Compute the average chick `weight` for each `Diet`, but only use the latest (maximum) `Time`.

ChickWeight %>% 
  filter(Time == max(Time)) %>% 
  group_by(Diet) %>% 
  summarise(avg_weight = mean(weight))







# Within Tidyverse, there are functions to create new columns to enrich the data we are working with.  This
# is achieved by using the `mutate` function (or one of its variants).  

# Let's create a column in the airquality datset to show the temperature in Celcius.

airquality %>% 
  mutate(temp_c = ((Temp - 32) * 5/9))

# This is kinda the same as using base R in the following way:

airquality$temp_c <- (airquality$Temp - 32) * 5/9

# There is a differnce though.  In the first approach, no new data assignments occurred, and the `temp_c`
# variable was not saved to the airquality dataset.  If you run the first approach and call the airquality
# dataset again, the new variable will not be included.  In order to save the variable to the dataset,
# and assignment ( `<-` ) must be explicitly done.


rm(airquality)


airquality %>% 
  mutate(temp_c = ((Temp - 32) * 5/9))

airquality  # temp_c is not saved!


airquality <- airquality %>% 
  mutate(temp_c = ((Temp - 32) * 5/9))

airquality$temp_c




# Merging data

# There are also Tidyverse functions that allow us to join datasets.  We often need to work with data from
# different sources, and these functions allow us to merge the data together.  These join functions act in 
# the same way as SQL query joins.  Let's build a couple simple dataframes to demonstrate joins:

df1 <- data.frame(x1 = c("a", "b", "c", "d"),
                  x2 = c(1,2,3,4))

df2 <- data.frame(x1 = c("a", "b", "c", "z"),
                  x3 = c(T, F, T, F))


df1
df2

left_join(df1, df2, by="x1")

right_join(df1, df2, by="x1")
inner_join(df1, df2, by="x1")
full_join(df1, df2, by="x1")

semi_join(df1, df2, by="x1")
anti_join(df1, df2, by="x1")



df1 %>% 
  bind_rows(df2)

bind_rows(df1, df2)



df1
df2

df1 %>% 
  left_join(df2) %>% 
  mutate(x3 = coalesce(x3, x2))

# Plotting with ggplot

# Data visualization is an important part of understanding what we are working with, and communicating our
# results.  A popular alternative to base R plotting is the ggplot package.  ggplot is part of the Tidyverse,
# and it can be chained to a series of function calls.

airquality %>% 
  group_by(Month) %>% 
  summarise(avg_wind = mean(Wind)) %>% 
  ggplot(aes(x=Month, y=avg_wind)) +
  geom_col()

# ggplot is structured by a "grammar of graphics".  Elements of the plot are defined in layers, and these layers are
# added together to produce a final visualization.  Notice that when the ggplot function is called, the syntax changes
# from `%>%` to `+`.

# Inside the initial ggplot function call, we set the aesthetics of the plot.  We define the x-axis as Month, and the
# y-axis as avg_wind.  We need to then specify what kind of plot we want to create, and we do so be adding in geom_col().  
# A ggplot call without a geom added will produce a blank plot.

# As mentioned, elements of the plot can be added as subsequent layers.  If we want to add labels to our plot, we can
# add on a layer that does that:

airquality %>% 
  group_by(Month) %>% 
  summarise(avg_wind = mean(Wind)) %>% 
  ggplot(aes(x=Month, y=avg_wind)) +
  geom_col() +
  geom_text(aes(x=Month, y=avg_wind+1, label=round(avg_wind, 1)))



# When using summarised data as in the above example, the resulting plots are often pretty simplistic.  ggplot is
# flexible enough to accommodate many different types of plots.  


# Histograms

# Let's look at the distibution of temperatures from the airquality dataset:

airquality %>% 
  ggplot(aes(x = Temp)) +
  geom_histogram()

# By default, ggplot uses 30 bins, but we can set this to whatever we want:

airquality %>% 
  ggplot(aes(x = Temp)) +
  geom_histogram(bins = 9)

# For reference, a histogram can be plotted in base R in the following way:

hist(airquality$Temp)




# Scatterplots


# When plotting a quantitative variable with another quantitative variable, a scatterplot is a common visualization
# to utilize.  Let's look at the famous iris dataset:

summary(iris)

# There are 50 observations of 3 different species of irises (setosa, versicolor, virginica), and we are given the
# sepal length, sepal width, petal length, and petal width.  When plotting the petal measurements, we can see a 
# trend in which petal width increases as petal length increases:  

ggplot(iris, aes(x=Petal.Length, y=Petal.Width)) +
  geom_point()

# What if we want to see if there is separation among the 3 species?  We can easily visualize this some separation
# among the species by specifying the colors:
 
ggplot(iris, aes(x=Petal.Length, y=Petal.Width)) +
  geom_point(aes(color=Species))


# There are ways to add interactivity to plots, which is helpful when building tools like dashboards. We can use the
# plotly package to easily convert our previous plot into an interactive plot.

install.packages("plotly")

library(plotly)

# Save our previous plot to an object:

p1 <- ggplot(iris, aes(x=Petal.Length, y=Petal.Width)) +
  geom_point(aes(color=Species))

# Use the ggplotly function to convert the plot:

ggplotly(p1)


# Boxplots

# In the previous example, we created a plot to show the segregation of the species by petal width and petal length using
# a scatterplot.  If we want to show a boxplot instead, this is done by simply changing the x aesthetic in the initial 
# ggplot call, and the geom call to geom_boxplot:

ggplot(iris, aes(x=Species, y=Petal.Width)) +
  geom_boxplot(aes(color=Species))




# Smoothing functions

# ggplot also has built in smoothing functions to highlight patterns in the data.

ggplot(iris, aes(x=Petal.Length, y=Petal.Width)) +
  geom_point() +
  geom_smooth(method = "lm")

# A linear best fit line was applied.  This is the same line we get from using the lm() function:

lm(Petal.Width ~ Petal.Length, iris)

# A base R approach would be:

plot(iris$Petal.Length, iris$Petal.Width)
abline(lm(Petal.Width ~ Petal.Length, iris))

##### Exercise #####

# Let's practice some data manipulation with some plotting using the built-in mtcars dataset. Create 
# a plot of the average mpg for automatic vs. manual transmission to show which is higher.  The 'am' 
# column is used for this.  A value of 0 represents manual transmission, and a value of 1 represents 
# automatic transmission.


# Using the built-in diamonds dataset, plot a histogram of the prices.  Use boxplots to build a 
# visualization showing the distributions of prices by color.

