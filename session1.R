
# unas pocas nociones basicas de R

# esto es una nota que no se va a evaluar cuando ejectamos el codigo
mi_variable = c(3,4.5,6)
dos_veces_mas = mi_variable * 2

# hay muchas 'funciones'. Una funcion come parametros que llamamos
# 'argumentos' y devuelve algo. Aqui una pequeñita:
sum(mi_variable)
# funciones pueden hacer cosas complicadas tambien. Son programitas

# la asignacion reemplaza lo que tenias antes definitivamente
mi_variable <- 4

# se puede asignar con = o con <- como os gusta.
# a mi me gusta <-, pero abajo uso = para que los que
# no esten acostumbrados no tienen que buscar caracteres
# en el teclado

# --------------------------------------------- #
#       saltamos al *tidyverse*                 #
# --------------------------------------------- #

# para hacer cosas mas potentes o especiales usamos paquetes 
# si un paquete esta en el repositorio central (CRAN)
# se puede installar asi (quitar el # para ejecutar,
# no querremos ejecturar la installacion cada vez que
# corremos el codigo!!):
install.packages("tidyverse")
install.packages("gapminder")
install.packages("colorspace")
install.packages("ggridges")

# para usar los contenidos de un paquete hay que cargarlo asi:
library(tidyverse)
library(gapminder)
library(colorspace)
library(ggridges)
# a ver que datos hay:
gapminder # 'evaluar' un objecto lo pone abajo en el 'console'
# abrir en un visor de tablas:
View(gapminder)
# parece un spreadsheet, pero no lo es, no editamos a mano!

# --------------------------------------------- #
# componemos un grafico basico
# --------------------------------------------- #

# 1) # ggplot() siempre abre la composicion,
#      pero no dibjua los datos:
ggplot(gapminder, # primer 'argumento' son los datos
       # ahora lo importante:
       # una expression de 'mapear' variables a esteticas,
       # en este caso solo coordinatas
       mapping = aes(x = gdpPercap, # renta per capita
                     y = lifeExp))  # esperanza de vida

#  2) hay que especificar que forma geometrica usar, tras sumar, asi:
ggplot(gapminder,
       mapping = aes(x = gdpPercap,
                     y = lifeExp)) +
  # todas las opciones geometricas empizan con "geom"
  # si lo empiezas a escribir, saldran una lista de sugerencias 
  geom_point() 


#  3) qualiquier variable es 'mapeable'
ggplot(gapminder, 
       mapping = aes(x = gdpPercap,
                     y = lifeExp,
                     # aqui decimos que el color varie por años,
                     # no pone una 'rampa sequencial' de colores
                     # por defecto
                     color = year)) +
  geom_point()

# 4) se puede añadir otros elementos
ggplot(gapminder, 
       mapping = aes(x = gdpPercap, 
                     y = lifeExp,
                     color = year)) +
  geom_point() +
  # ponemos una tendencia suavizada:
  # se puede cambiar el metodo de suavizacion
  geom_smooth()

# 5) podemos mejorar el señal tras una transformacion
#    de una eje
ggplot(gapminder, 
       mapping = aes(x = gdpPercap,
                     y = lifeExp,
                     color = year)) +
  geom_point() +
  geom_smooth() +
  # transmacion logoritmica de renta per capita
  # nueva interpretacion "un aumento de 10% en la renta
  # implica un aumento ___ " en la esperanza de vida.
  # (mas o menos, en general, etc etc)
  scale_x_log10() 

# 6) si mapeamos un variable categorico el resultado 
#    sera diferente
ggplot(gapminder, 
       mapping = aes(x = gdpPercap,
                     y = lifeExp,
                     # continentes no son continuous
                     # como años, se elige entonces
                     # una peleta *cualitativa*
                     color = continent)) +
  geom_point() +
  # Nota que el suavizador se repite por los
  # grupos definidos por color!!! Esto es porque
  # el mapeamiento esta compartido desde el primer
  # ggplot()
  geom_smooth() +
  scale_x_log10() 

# 6) en vez de compartir mapeaciones esteticas se puede
#    especificarlas dentro de geoms especicos: mira
ggplot(gapminder, 
       mapping = aes(x = gdpPercap,
                     y = lifeExp)) +
  geom_point(mapping = aes(color = continent)) +
  # color solo varie por continentes entre los
  # puntos. Igual tiene mas sentido separarlos,
  # pero el truco nos vale saber
  geom_smooth() +
  scale_x_log10() 

# 7) por ejemplo para destacar un grupo, podemos
#    hacer algo parecido. NOTA: algunos parametros
#    que no estan dentro de aes() no son
#    *mapeaciones* estan decaradas *a mano*
ggplot(gapminder, 
       mapping = aes(x = gdpPercap,
                     y = lifeExp)) +
  
  # alpha para transparencia (1 opaco, 0 invisible)
  # escala gris parecido (0 negro 1 blanco). Asi los
  # puntos forman un nube
  geom_point(alpha = .3, 
             color = gray(.5)) +
  
  # destacamos España encima del nube de puntos
  geom_point(data = filter(gapminder, country == "Spain"), 
             color = "red",
             size = 3) +
  # nuevo geom! mismo truco
  geom_line(data = filter(gapminder, country == "Spain"), 
            color = "red",
            size = 1.5) +
  scale_x_log10() 


# 8) asignar un grafico para  guardar con ggsave
mi_grafico = 
  ggplot(filter(gapminder, # submuestra
              year > 2000), 
       mapping = aes(x = gdpPercap,
                     y = lifeExp,
                     color = continent,
                     
                     # fill para color relleno de areas, aqui aplicable
                     # al incertidumbre de los suavizadores
                     fill = continent)) +
  geom_point() +
  scale_x_log10() +
  # alpha aplicado a los suavizadores
  geom_smooth(alpha = .15) +
  theme_minimal() +
  
  # declaramos otro paleta de colores cualitativos
  # hemos eligido de estas opciones:
  # hcl_palettes(plot = TRUE), fijandonos en el nombre
  scale_color_discrete_qualitative("Dark 3")

# guardar para editar a mano en Inkscape
ggsave(mi_grafico, 
       filename = "gapminder_continentes.pdf",
       height = 8, # unidades son pulgadas, pero nos da igual porque 
       width = 10) # es un grafico *vector*

# ---------------------------------------- #
# otro enfoque                             #
# ---------------------------------------- #
# 9) un panel por continente; 
#    lineas para serie temporal de cada pais

ggplot(gapminder,
       aes(x = year, # tiempo en x = serie temporal
           y = gdpPercap, # renta
           group = country) # una linea por pais (grupos)
       ) +
  geom_line() + # lineas
  scale_y_log10() +
  # paneles por continente (multiples pequeños)
  facet_wrap(~continent) 

# 10) Otro geom: densidad 2-d, como un mapa topografico
ggplot(gapminder,
       aes(x = gdpPercap,
           y = lifeExp)) +
  geom_density2d() +
  scale_x_log10() 
# algunas otra opciones parecidas:
# geom_bin2d(), geom_hex(), 
# contornos rellenos (un poco mas esoterico)
# stat_density_2d(aes(fill = ..level..), geom = "polygon", colour="white")


# 11) una densidad de los ultimos 70 anos
ggplot(gapminder,
       aes(x = lifeExp)) +
  #
  geom_density()

# 12) densidades por años, muy solapados
ggplot(gapminder,
       aes(x = lifeExp,
           # hay que decir tanto relleno como el grupo (son iguales aqui)
           fill = year,
           group = year)) +
  # hacemos semitransparente, se ve cuanto ha disminuido el pico inferior
  geom_density(alpha = .4)

# 13) para estirar el eje x en vertical hacemos un ridgeplot:
# geom_density_ridges() viene del paquete ggridges
ggplot(gapminder,
       aes(x = lifeExp,
           y = year, # año define un eje x desplazado verticalmente
           group = year,
           fill = year)) +
  geom_density_ridges(mapping = aes(y = year),
                      # rel_min_height = .01 elimina las lineas de 0 
                      rel_min_height = .01) +
  # eligimos una rampa de color que no gusta
  scale_fill_continuous_sequential(palette = "ag_Sunset") +
  # un tema minimalista
  theme_minimal()

# RETO

# 1. haz un density ridgeline de lo mismo,
# pero separado por continentes (excluyendo oceania)

# tips: excluir usando filter() sobre los datos
#       separar los graficos (continentes) usando facet_wrap 
#       o facet_grid()
#       cambiar los colores tras seleccionar algo de 
#       hcl_palettes(plot = TRUE)
hcl_palettes(plot = TRUE) # para eligir paleta
# 
ggplot(filter(gapminder, continent != "Oceania"),
       mapping = aes(x = lifeExp,
                     y = year,
                     group = year,
                     fill = year)) +
  geom_density_ridges() +
  # diferente que facet_wrap(). Podemos explicitar una malla con *grid
  facet_grid(col = vars(continent)) +
  scale_fill_continuous_sequential(palette = "BluGrn")


# otro ejercicio ad hoc al final, sin mas:
ggplot(gapminder,
       mapping = aes(x = year,
               y = lifeExp,
               group = country)) +
  geom_line() +
  facet_wrap(~continent)

ggplot(gapminder,
       mapping = aes(x = year,
                     y = pop,
                     group = country)) +
  geom_line() +
  scale_y_log10()+
  facet_wrap(~continent)










