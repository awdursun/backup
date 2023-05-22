
library(tidyverse)
library(raster)
library(EBImage)
library(sp)


# import image
image_path <- "C:/Users/Adursun/OneDrive/interpolate_bilinear.jpg"
img <- readImage(image_path)  
image <- raster(image_path)

img
plot(img)

# split image into rgb components
red <- img[,,1]
green <- img[,,2]
blue <- img[,,3]


# create annotation region
x_coords <- c(10, 20, 30, 80, 10)  
y_coords <- c(10, 30, 100, 10, 10) 

polygon <- data.frame(x = x_coords, y = y_coords)
polygon <- rbind(polygon, polygon[1, ])

# show annotation region
polygon_sp <- SpatialPolygons(list(Polygons(list(Polygon(cbind(x_coords, y_coords))), "polygon")))
subset_image <- mask(image, polygon_sp)
plot(subset_image)


# identify points inside polygon
points <- expand.grid(x = 1:dim(img)[1], y = 1:dim(img)[2])
inside_polygon <- sp:::point.in.polygon(points$x - 0.5, points$y - 0.5, polygon$x, polygon$y)

plot(subset_image)

matrix(inside_polygon, nrow=100, byrow=FALSE) %>% 
  as.data.frame() %>% 
  mutate(index = 1:100) %>% 
  pivot_longer(-index) %>% 
  mutate(name = as.numeric(gsub("V", "", name))) %>% 
  filter(value == 1) %>% 
  ggplot(aes(x=index, y=name)) +
  geom_point(size=0.8, alpha=0.5)

img[which(inside_polygon == 1)]

plot(img)


# function to expand the boundary outward by number of pixels
expand_boundary_outward <- function(x_coords, y_coords, pixels) {
  
  min_x <- min(x_coords)
  max_x <- max(x_coords)
  min_y <- min(y_coords)
  max_y <- max(y_coords)
  
  x_midpoint <- (min_x + max_x) / 2
  y_midpoint <- (min_y + max_y) / 2
  
  x_coords_expanded <- ifelse(x_coords > x_midpoint, x_coords + pixels, x_coords - pixels)
  y_coords_expanded <- ifelse(y_coords > y_midpoint, y_coords + pixels, y_coords - pixels)
  
  return(list(x_coords = x_coords_expanded, y_coords = y_coords_expanded))
  
}

expanded_coords <- expand_boundary_outward(x_coords, y_coords, 5)
x_coords_expanded <- expanded_coords$x_coords
y_coords_expanded <- expanded_coords$y_coords


border <- data.frame(x = x_coords_expanded, y = y_coords_expanded)
border <- rbind(border, border[1, ])


# identify points inside border
points_border <- expand.grid(x = 1:dim(img)[1], y = 1:dim(img)[2])
inside_border <- sp:::point.in.polygon(points_border$x - 0.5, points_border$y - 0.5, border$x, border$y)


matrix(inside_border, nrow=100, byrow=FALSE) %>% 
  as.data.frame() %>% 
  mutate(index = 1:100) %>% 
  pivot_longer(-index) %>% 
  mutate(name = as.numeric(gsub("V", "", name))) %>% 
  filter(value == 1) %>% 
  ggplot(aes(x=index, y=name)) +
  geom_point(size=0.8, alpha=0.5)

img[which(inside_border == 1 & inside_polygon != 1)]

# rgb analysis
r_annot <- red[which(inside_polygon == 1)]
r_border <- red[which(inside_border == 1 & inside_polygon != 1)]

g_annot <- green[which(inside_polygon == 1)]
g_border <- green[which(inside_border == 1 & inside_polygon != 1)]

b_annot <- blue[which(inside_polygon == 1)]
b_border <- blue[which(inside_border == 1 & inside_polygon != 1)]

mean(r_annot)
mean(g_annot)
mean(b_annot)

mean(r_border)
mean(g_border)
mean(b_border)
