install.packages("tidytext")
install.packages("udpipe")

library(tidyverse)
library(tidytext)
library(rvest)
library(here)
library(udpipe)

# Carga de datos del scraping
df_tabla <- readRDS(here("TP2/data/tabla_scraping_oea.rds"))

# Punto a. Limpieza del texto
message("Realizando limpieza del texto")

df_tabla <- df_tabla %>%
  mutate(texto = str_to_lower(cuerpo),
         texto = str_remove_all(texto, "[0-9]+"),
         texto = str_remove_all(texto, "[[:punct:]¿¡]"),
         texto = str_squish(texto))

# Punto b. Lematizacion  
message("Proceso de lematización")

modelo <- udpipe_download_model(language = "spanish")
modelo_ud <- udpipe_load_model(modelo$file_model)

anotado <- udpipe_annotate(modelo_ud, x = df_tabla$texto)
df_lem <- as_tibble(anotado)

tokens <- df_lem %>%
  filter(upos %in% c("NOUN", "VERB", "ADJ")) %>%  # primero filtrás por tipo
  filter(!is.na(lemma)) %>%
  transmute(
    id = doc_id,
    palabra = str_to_lower(lemma))

# Punto c. remover stopwords
message("Removiendo stopwords")

lista_palabras <- get_stopwords("es")

texto_nuevo <- tokens %>%
  anti_join(lista_palabras, by = c("palabra" = "word")) %>%
  # Limpieza extra: filtramos palabras muy cortas que suelen ser ruidos del scraping
  filter(nchar(palabra) > 2)

# Guardar tabla final
saveRDS(texto_nuevo, here("TP2/output/processed_text.rds"))

message("Se guardó 'processed_text.rds' en /output")

