
# cargar paquetes
library(tidyverse)

# install.packages("lubridate")
# install.packages("janitor")
# install.packages("readxl")
library(tidyverse)
library(lubridate)
library(janitor)
library(readxl)

dat = read_excel("datos/daniel/cda-export.xls") %>% 
  clean_names() %>%
  separate(anomesentrada, 
           into = c("ano", "mes"),
           convert = TRUE) %>% 
  pivot_longer(ejecucion_de_penas:terminacion_anticipada,
               names_to = "variable",
               values_to = "valor") %>% 
  mutate(valor = if_else(is.na(valor), 0, valor),
         fecha = dmy(paste("01",mes,ano)))

# hacer un panel por variables, con eje y "libre"
dat %>% 
  ggplot(aes(x = fecha, y = valor)) +
  geom_line() +
  facet_wrap(~variable,
             scales = "free_y")

dat %>% 
  group_by(ano, variable) %>% 
  summarize(valor = sum(valor)) %>% 
  ungroup()%>% 
  ggplot(aes(x = ano, y = valor)) +
  geom_col() +
  facet_wrap(~variable,
             scales = "free_y")

# total de registros
dat %>% 
  group_by(fecha) %>% 
  summarize(total = sum(valor)) %>% 
  ggplot(aes(x = fecha, y = total)) + 
  geom_line()

# ----------------------------------------------- #
# unir datos. Hemos ido a datos abiertos de colombia
# hemos eligido datos diarios de COVID-19 casos registrados
# ----------------------------------------------- #


C19 <- read_csv("datos/daniel/Casos_positivos_de_COVID-19_en_Colombia.csv")

C19 %>% 
  group_by(`Fecha de diagnóstico`) %>% 
  summarize(casos = n()) %>% 
  ggplot(aes(x = `Fecha de diagnóstico`, y = casos)) +
  geom_line()

C19_months <-
C19 %>% 
  mutate(ano = year(`Fecha de diagnóstico`),
         mes = month(`Fecha de diagnóstico`),
         ano = if_else(is.na(ano), year(`Fecha de notificación`), ano),
         mes = if_else(is.na(mes), month(`Fecha de notificación`), mes)) %>% 
  group_by(ano, mes) %>% 
  summarize(casos = n()) 

right_join(dat, C19_months, 
           by = c("ano", "mes")) 

left_join(dat, C19_months,
           by = c("ano", "mes")) 

inner_join(dat, C19_months,
          by = c("ano", "mes")) 
