library(tidyverse)
library(readr)
library(lubridate)
library(readxl)

columnas <- read_excel("datos/sonia/columnas.xlsx")

dat <- read_fwf("datos/sonia/DA2837.txt", 
         col_positions = fwf_positions(
           start = columnas$desde,
           end = columnas$hasta,
           col_names = columnas$`nombre de la variable`))
dat %>% View()

