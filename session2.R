
# cargar paquetes

# install.packages("lubridate")
# install.packages("janitor")
# install.packages("readxl")
library(tidyverse)
library(lubridate)
library(janitor)
library(readxl)

dat = read_excel("datos/daniel/cda-export.xls") %>% 
  # simplificar nombres de variables (para poder escribir mas facil)
  clean_names() %>%
  # dividir anomesentrada en 2 columnas:
  separate(anomesentrada, 
           into = c("ano", "mes"),
           convert = TRUE) %>% 
  # alargar los datos, colectando los variables una una sola columna de 
  # valores, con un nuevo identificador para saber cual variable (hacemos
  # esto porque facet_wrap() quiere un variable para definir subgraficos)
  pivot_longer(ejecucion_de_penas:terminacion_anticipada,
               names_to = "variable",
               values_to = "valor") %>% 
  # poner 0s donde hay NAs
  mutate(valor = if_else(is.na(valor), 0, valor),
         # crear fecha valida para eje x
         fecha = dmy(paste("01",mes,ano)))

# hacer un panel por variables, con eje y "libre".
# mal para comunicacion, bien para exploracion y para
# entender tendencias
dat %>% 
  ggplot(aes(x = fecha, y = valor)) +
  geom_line() +
  facet_wrap(~variable,
             scales = "free_y")

# aggregaciones (funciona):
dat_annual =
  dat %>% 
  # declarar grupos
  group_by(ano, variable) %>% 
  # aggregagr (dentro de grupos)
  summarize(
    mean_valor = mean(valor),
    sd_valor = sd(valor),
    total_valor = sum(valor)) %>% 
  ungroup() 

# -------------------------------------------------#
# porque no funciono cuando intente esto en clase?
# no me di cuenta de lo siguiente:
dat %>% 
  # declarar grupos
  group_by(ano, variable) %>% 
  # aggregagr (dentro de grupos)
  summarize(
    valor = sum(valor), # <- va primero
    mean_valor = mean(valor),
    sd_valor = sd(valor)) %>% 
  ungroup() 
# explicacion: sum(valor) ha sobreescrito a valor,
# por lo tanto mean() y sd() solo tenian la nueva
# suma de valor. mean(10) = 10, sd(10) = NA ... 
# -------------------------------------------------#

# ver los totales anuales
dat_annual %>% 
  ggplot(aes(x = ano, y = total_valor)) +
  # barras
  geom_col() +
  facet_wrap(~variable,
             scales = "free_y")
# aqui por ejemplo el coefficiente de variacion:
dat_annual %>% 
  ggplot(aes(x = ano, 
             # formula aqui mismo si quieres!!
             # sino tb lo puedes precalcular en mutate()
             y = sd_valor/mean_valor)) +
  geom_col() +
  facet_wrap(~variable,
             scales = "free_y")

# total marginal de registros, misma idea,
# cuantos desapariciones forzadas estan registradas
# en este sistema por mes/año
dat %>% 
  group_by(fecha) %>% 
  summarize(total = sum(valor)) %>% 
  ggplot(aes(x = fecha, y = total)) + 
  geom_line()

# ----------------------------------------------- #
# unir datos. Hemos ido a datos abiertos de colombia
# hemos eligido datos diarios de COVID-19 casos registrados
# ----------------------------------------------- #

# datos individuales, 1Gb!
C19 <- read_csv("datos/daniel/Casos_positivos_de_COVID-19_en_Colombia.csv")
dim(C19) # 6+ milliones de casos

# serie temporal de casos diarios segun momento de diagnotsico,
# no de registro (algo mas tarde normalmente)
C19 %>% 
  group_by(`Fecha de diagnóstico`) %>% 
  # n() nos cuenta filas dentro de grupos :-)
  summarize(casos = n()) %>% 
  ggplot(aes(x = `Fecha de diagnóstico`, y = casos)) +
  geom_line()

# para unir a los datos de Daniel, hay que procurar que
# los variables de union (mes y año) cuadran. Explotamos
# unas funciones de lubridate para extraer el año y mes
# de una fecha completa
C19_months <-
C19 %>% 
  mutate(ano = year(`Fecha de diagnóstico`),
         mes = month(`Fecha de diagnóstico`),
         # si falta fecha diagnostico usamos notificacion
         ano = if_else(is.na(ano), year(`Fecha de notificación`), ano),
         mes = if_else(is.na(mes), month(`Fecha de notificación`), mes)) %>% 
  # tabular:
  group_by(ano, mes) %>% 
  # n() nos cuenta filas dentro de grupos :-)
  summarize(casos = n()) 

# aqui C19_months es "dominante"
right_join(dat, C19_months, 
           by = c("ano", "mes")) 

# aqui dat es "dominante"
left_join(dat, C19_months,
           by = c("ano", "mes")) 

# solo casos que solapen entre fuentes
inner_join(dat, C19_months,
          by = c("ano", "mes")) 

# no perdemos nada
inner_join(dat, C19_months,
           by = c("ano", "mes")) 
