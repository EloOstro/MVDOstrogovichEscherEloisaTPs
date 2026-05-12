install.packages("tm")

library(tidyverse)
library(tidytext)
library(here)
library(ggplot2)
library(tm)

# Lectura del texto y carga de base
message("Lectura del archivo")
lem <- readRDS(here("TP2/output/processed_text.rds"))

# Matriz DTM 
dtm_oea <- lem %>%
  count(id, palabra) %>%
  cast_dtm(document = id, term = palabra, value = n)

# Matriz de frecuencia de terminos
frecuencia <- lem %>%
  count(palabra, sort = TRUE)

# Seleccion de posibles palabras relevantes de la OEA
palabras_clave <- c("democracia", "derecho", "estado", "seguridad", "mujer")

top5 <- frecuencia %>%
  filter(palabra %in% palabras_clave)

# Creacion de grafico de barras
message("Generando grafico")
grafico_oea <- ggplot(top5, aes(x = reorder(palabra, n), y = n, fill = palabra)) +
  geom_col(show.legend = FALSE, width = 0.7) +
  geom_text(aes(label = n), hjust = -0.2, size = 4) +
  coord_flip() + # Barras horizontales
  theme_minimal() +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title = "Frecuencia de términos institucionales clave",
    subtitle = "Comunicados de Prensa OEA (Enero - Abril 2026)",
    x = "Términos seleccionados",
    y = "Cantidad de menciones totales",
    caption = "Scraping automatizado de OEA"
  ) +
  expand_limits(y = max(top5$n) * 1.1)

print(grafico_oea)

# Guardado del gráfico
message("Guardando gráfico")

grafico_output <- here("TP2/output/frecuencia_terminos.png")
message("Figura guardada en /output")

ggsave(
  filename = grafico_output,
  plot = grafico_oea,
  width = 10,
  height = 6,
  dpi = 300)

