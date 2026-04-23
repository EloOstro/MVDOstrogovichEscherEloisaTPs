library(tidyverse) 
library(rvest) 
library(here) 
library(xml2)

## Primer mensaje
message("Iniciando scraping OEA")

## Configuracion de la base
meses <- 1:4
total_links <- c()

for(mes in meses){
  url <- paste0("https://www.oas.org/es/centro_noticias/comunicados_prensa.asp?nMes=", mes, "&nAnio=2026")
  message("Leyendo mes: ", mes)
  pagina <- tryCatch(read_html(url), error = function(e) return(NULL))
  if (is.null(pagina)) next
  links <- pagina %>%
    html_elements(".headlinelink") %>%
    html_attr("href") %>% 
    # Limpiamos los links para que sean direcciones completas
    paste0("https://www.oas.org/es/centro_noticias/", .) %>%
    unique()
  total_links <- c(total_links, links)
}

tabla <- tibble()
id <- 1

for(link in total_links){
  Sys.sleep(3)  # Crawl-delay robots.txt
  message("Procesando: ", link)
  html <- read_html(link)
  
  write_html(
    html,
    here("TP2/data", paste0("oea_raw_", id, "_", Sys.Date(), ".html")))
  
  titulo <- html |>
    html_element("h1") |>
    html_text(trim = TRUE)
  
  cuerpo <- html |>
    html_elements("p") |>
    html_text() |>
    paste(collapse = " ")
  
  tabla <- bind_rows(
    tabla,
    tibble(
      id = id,
      titulo = titulo,
      cuerpo = cuerpo))
  id <- id + 1
  }

