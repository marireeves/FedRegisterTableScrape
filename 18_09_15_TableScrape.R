#Mari K Reeves
#June 22, 2017
#Scraping Federal Register Documents to convert tables to csv files

#Our primary goal is to get a list of species attached to each critical habitat unit

#Our secondary goal is to get a table of primary constituent elements for each crit hab unit

#This code takes a folder of pdf documents on your hard drive and 
#Extracts the tables from them and sends those to individual csv files in your working directory
#it could be adapted pretty easily to go get files online, if that's what you want.

rm(list = ls()) #remove all past worksheet variables

# Read in Base Packages ---------------------------------------------------

pckg <- c('pdftools',"rJava",'dplyr','stringr', 'tm','SnowballC', "RColorBrewer", "ggplot2", "wordcloud", "biclust", "cluster") 


# READING IN PACKAGES (fancy code from my friend Adam Vorsino)...
for(i in 1:length(pckg)){
  if ((!pckg[i] %in% installed.packages())==T) {
    install.packages(pckg[i], repos="http://cran.us.r-project.org", 
                     dependencies = T)
    print(pckg[i])
    do.call("library", list(pckg[i]))
  }else{
    print(pckg[i])
    do.call("library", list(pckg[i]))
  }
}

# You do need the pdftools package. From:https://github.com/ropensci/pdftools#readme


# Read in Data' -----------------------------------------------------------
#You will want to locate your pdf files in the same folder 
#and tell R where that folder is located here
BaseDir <- "C:/Users/marireeves/Documents/Bats/SpeciesStatusAssessments/Bats/Mariana Pacific Sheath-Tailed Bat/"
WorkingDir <- paste0(BaseDir, "scrapeR")

#This code uses the "tabulizer" package from https://github.com/ropensci/tabulizer
#The following "tabulizer" function reaches out to Tabula free opensource software
#to recognize tables in a pdf and extract them 
#https://github.com/ropensci/tabulizer/blob/master/README.Rmd
if (!require("remotes")) {
  install.packages("remotes")
}
# on 64-bit Windows
remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"), INSTALL_opts = "--no-multiarch")
# elsewhere
remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"))

library("tabulizer")

#This was useful, not sure if the code requires it anymore, but I left it in
#http://data.library.virginia.edu/reading-pdf-files-into-r-for-text-mining/
Rpdf <- readPDF(control = list(text = "-layout"))

#This needs to be applied to the vector of filenames, but testing here to see if I can get
#R to interface with Tabula and make me a table
#This is a quick example of extracting an online pdf to text with pdftools

hnl<-download.file("http://www.hicentral.com/pdf/annsales.pdf", "annsales.pdf", mode = "wb")
txt <- pdf_text("annsales.pdf")

# first page text - this works...now how to get the tables without paying for software...
cat(txt[1])


#~~~~~~~~~~~~~~~~~~~~~Bring in Files~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Tell R what folder contains your PDFs (this is where mine are, so you need to change this)

setwd(WorkingDir)
#make a list of the files 
myfiles <- list.files(path = WorkingDir, pattern = "pdf",  full.names = TRUE)
#get rid of spaces in filenames
sapply(myfiles, FUN = function(i){
  file.rename(from = i, to =  paste0(dirname(i), "/", gsub(" ", "", basename(i))))
})

# make a list of PDF file names
myfiles <- list.files(path = WorkingDir, pattern = "pdf",  full.names = TRUE)

#Here is where we now take that list of pdf files you just made
#and apply the tabulizer "extract_tables" function to each pdf 
#in the list, and dump them to your working directory as csv files
# with the name of the doucment. Tabulizer in action.
#This takes awhile, depending how big your pdf files
#are, but you can monitor progress in windows explorer 
#by just going to your working directory folder and seeing the files
#get created.

#https://github.com/ropensci/tabulizer/blob/master/README.Rmd  Here is useful information about the functions

#Note that for large PDF files, it is possible to run up against Java memory constraints, 
#leading to a java.lang.OutOfMemoryError: Java heap space error message. 
#Memory can be increased using options(java.parameters = "-Xmx16000m") set to some reasonable amount of memory.

options(java.parameters = "-Xmx16000m")

crithabtables<-lapply(myfiles, extract_tables, method = "stream", outdir = WorkingDir, output = "csv")

#This runs! It's not perfect, in that it finds too many tables and they are sometimes wierd, but
# if makes table extraction an easier  task nonetheless than doing it manually with 
#Tabula and seems to work great for traditionally
#formatted data tables. 