install.packages("tidytext")
install.packages("udpipe")

library(tidyverse)
library(tidytext)
library(rvest)
library(here)
library(udpipe)

# Carga de datos del scraping
df_tabla <- readRDS(here("TP2/data/tabla_scraping_oea.rds"))

# Limpieza del texto
message("Realizando limpieza del texto")

# Normalizacion del texto del scraping
df_tabla <- df_tabla %>%
  mutate(texto = str_to_lower(cuerpo),
         texto = str_remove_all(texto, "[0-9]+"),
         texto = str_remove_all(texto, "[[:punct:]¿¡]"),
         texto = str_squish(texto))

# Lematizacion  
message("Proceso de lematización")

# Descarga del modelo odpipe en español para convertir palabras a lema
modelo <- udpipe_download_model(language = "spanish")
modelo_ud <- udpipe_load_model(modelo$file_model)

# Trabaja sobre el texto
texto <- udpipe_annotate(modelo_ud, x = df_tabla$texto)
df_lem <- as_tibble(texto)

# Tomamos solo sustantivos, adjetivos y verbos
tokens <- df_lem %>%
  filter(upos %in% c("NOUN", "VERB", "ADJ")) %>%  # primero filtrás por tipo
  filter(!is.na(lemma)) %>%
  transmute(
    id = doc_id,
    palabra = str_to_lower(lemma))

# Remover stopwords
message("Removiendo stopwords")

# Lista de stopwords en español
lista_palabras <- get_stopwords("es")

# Eliminacion de palabras vacias
texto_nuevo <- tokens %>%
  anti_join(lista_palabras, by = c("palabra" = "word")) %>%
  # Filtro de palabras muy cortas
  filter(nchar(palabra) > 2)

# Guardar tabla final
texto_output <- saveRDS(texto_nuevo, here("TP2/output/processed_text.rds"))

message("Se guardó 'processed_text.rds' en /output")

