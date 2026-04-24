library(tidyverse)
library(tidytext)
library(here)
library(ggplot2)

message("Lectura del archivo")
lem <- readRDS(here("TP2/output/processed_text.rds"))

# Matriz de frecuencia de terminos
frecuencia <- lem %>%
  count(palabra, sort = TRUE)

# Ver palabras mas frecuentes
head(frecuencia, 30)

palabras_clave <- c("oea", "misión", "proceso", "organización", "electoral")

top5 <- frecuencia %>%
  filter(palabra %in% palabras_clave)

message("Generando grafico")

# Grafico
grafico_oea <- ggplot(top5, aes(x = reorder(palabra, n), y = n, fill = palabra)) +
  geom_col(show.legend = FALSE, width = 0.7) +
  # Agregamos etiquetas de datos arriba de las barras
  geom_text(aes(label = n), hjust = -0.2, size = 4) +
  coord_flip() + # Barras horizontales para mejor lectura
  theme_minimal() +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title = "Frecuencia de términos institucionales clave",
    subtitle = "Comunicados de Prensa OEA (Enero - Abril 2026)",
    x = "Términos seleccionados",
    y = "Cantidad de menciones totales",
    caption = "Fuente: Scraping automatizado de OAS.org - TP2 Martina Boba Fernandez"
  ) +
  # Ajustamos los límites para que no se corten los números
  expand_limits(y = max(top5$n) * 1.1)

print(grafico_oea)
