library(tidyverse) 
library(rvest) 
library(here) 
library(xml2)

## Primer mensaje
message("Iniciando scraping OEA")

## Configuracion de la base
meses <- 1:4 # Selecciona los meses que se van a analizar
total_links <- c() # Carpeta en donde se van a guardar los links

# Recorrido de las paginas
for(mes in meses){
  url <- paste0("https://www.oas.org/es/centro_noticias/comunicados_prensa.asp?nMes=", mes, "&nAnio=2026") # Se arma el link con la restriccion mensual y anual
  message("Leyendo mes: ", mes)
  pagina <- tryCatch(read_html(url), error = function(e) return(NULL)) # Lectura de pagina, si falla continua con el siguiente
  if (is.null(pagina)) next
  # Extraccion de enlaces
  links <- pagina %>%
    html_elements(".headlinelink") %>%
    html_attr("href") %>% 
    # Limpieza de links para que sean direcciones completas
    paste0("https://www.oas.org/es/centro_noticias/", .) %>%
    unique()
  total_links <- c(total_links, links)
}

tabla <- tibble() # Tabla que va a guardar la informacion
id <- 1 # Identificador para los comunicados

# Recorrido de los comunicados
for(link in total_links){
  Sys.sleep(3)  # Restriccion de robots.txt
  message("Leyendo: ", link)
  html <- read_html(link) # Lectura del link
  # Guardado de copia original
  write_html(
    html,
    here("TP2/data", paste0("oea_raw_", id, "_", Sys.Date(), ".html")))
  # Extraccion del titulo
  titulo <- html |>
    html_element("h1") |>
    html_text(trim = TRUE)
  # Extraccion de parrafos
  cuerpo <- html |>
    html_elements("p") |>
    html_text() |>
    paste(collapse = " ")
  # Guardado de informacion en la tabla
  tabla <- bind_rows(
    tabla,
    tibble(
      id = id,
      titulo = titulo,
      cuerpo = cuerpo))
  id <- id + 1
  }

df_oea <- bind_rows(tabla)
scraping_output <- saveRDS(df_oea, here("TP2/data/tabla_scraping_oea.rds"))

message("Se guardó 'tabla_scraping_oea.rds' en /data")
