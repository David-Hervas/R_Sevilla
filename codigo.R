# Load packages
library(clickR)
library(repmod)
library(brms)
library(isaves)

# Load the data
datos <- mtcars_messy  #Here we use some preloaded data from clickR package

descriptive(datos)

# After some data cleaning... (see clickR package if you are interested in semi-automatic data cleaning)
datos_f <- nice_names(datos)
datos_f <- fix_numerics(datos_f)
datos_f <- fix_dates(datos_f)
datos_f <- fix_factors(datos_f)
datos_f <- fix_NA(datos_f)

descriptive(datos_f)

# It can be useful to comment the objects for their identification
comment(datos) <- "Original data" 
comment(datos_f) <- "Cleaned data"

# Now I want to save the objects to disk
save_incremental()

# Each object is saved in a different .rds file. Information about the objects can be retrieved by running
ws_ref_table()

# We continue by fitting some models
mod1 <- brm(mpg ~ hp + wt + am, data=datos_f)
mod2 <- brm(mpg ~ hp * wt + am, data=datos_f)

# This takes some time, I don't want to run it again the next time I load my project, so I save it
save_incremental(annotation = "bayesian modeling")  #In addition to individual comments, you can also have annotation labels for each call to save_incremental

x <- rnorm(100)
y <- sample(letters, 10)
z <- rbinom(50, 10, 0.2)

#We can choose which objects to save
save_incremental(c("x", "y"))  # "z" is not saved

# We can check the reference table again
ws_ref_table() #This time, only mod1, mod2, x and y have been saved. The other objects were already saved before and haven't changed


# What happens if I modify a previously saved object and then run save_incremental()?
datos_f$mpg[1] <- NA
save_incremental() #Now the object saves again, because it's "new"

ws_ref_table() # We can see that there are two versions of "datos_f". They are named the same, but have different hash.

# Let's simulate that we exit and start with a clean Global environment
rm(list=ls())

# We can load all objects with load_incremental()
load_incremental() 
datos_f$mpg[1] #Notice that only the updated version of datos_f was loaded

# What if I want the older version?
#There are two options:
load_incremental(hash == "d1d313a2a06040b967d8297a7550579a", overwrite = TRUE) #Overwrite the new version with the old one
load_incremental(hash == "d1d313a2a06040b967d8297a7550579a") #Load both versions with different names

# And what happens if I already have objects in my workspace before loading and they have the same names?
rm(list=ls())
datos_f <- rnorm(100)
load_incremental()  #No problem, the exisiting objects are preserved
load_incremental(hash == "d1d313a2a06040b967d8297a7550579a") #We can even load the older version of "datos_f"

datos_f[1]
datos_f_2024.11.03_23.47.37.796364$mpg[1]
datos_f_2024.11.03_23.43.10.207812$mpg[1]

rm(list=ls())

# As you can see, load_incremental can load objects selectively
load_incremental(date > as.POSIXct("2024-11-03 23:45:00"))
rm(list=ls())

#Or 
load_incremental(class == "data.frame" & size > 20000)
rm(list=ls())

#There is also an option for lazy loading
load_incremental(lazyload = TRUE)

#It is possible to remove saved objects with purge_ws_table()
purge_ws_table(size > 20000)  #With default arguments, no objects are removed
purge_ws_table(remove = TRUE) #To actually remove objects, you have to set remove = TRUE. WARNING: This cannot be undone!
ws_ref_table()

