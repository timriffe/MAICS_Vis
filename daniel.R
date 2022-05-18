library(tidyverse)
library(readxl)
library(janitor)
library(lubridate)

# lectura y limpieza basica
dat <-
  read_excel("datos/daniel/cda-export.xls") %>% 
  clean_names() %>% 
  separate(anomesentrada, 
           into = c("ano","mes"), 
           convert = TRUE) %>% 
  mutate(fecha = dmy(paste("01",mes,ano,sep = "-")), 
         .before = ano) %>% 
  arrange(fecha) %>% 
  # hacer mas largo para poder hacer facetting por variables
  pivot_longer(ejecucion_de_penas:terminacion_anticipada,
               names_to = "variable",
               values_to = "valor") 
  
# vista inicial
dat %>% 
  ggplot(aes(x = fecha, y = valor)) +
  geom_line() +
  facet_wrap(~variable, scales = "free_y")

# o por años
dat %>% 
  # definir grupos a agregar
  group_by(ano, variable) %>%
  # agregegar, tratando NA como 0s
  summarize(valor = sum(valor, na.rm = TRUE), 
            .groups = "drop") %>% 
  ggplot(aes(x = ano, y = valor)) +
  geom_col() +
  facet_wrap(~variable, scales = "free_y")
