## PAQUETES ##
library(readr)
library(readxl)
library(janitor)
library(dplyr)
library(haven)
library(tidyr)

internet <- "TP1/data/internet_users_world_wide.csv"
metadata <- "TP1/data/metadata_countries_internet_users.csv"

## LIMPIEZA Y JOIN DE TABLAS ##
internet <- read_csv(
  internet, 
  skip = 3)

metadata <- read_csv(metadata)

# Transformar en formato long
internet_long <- internet %>%
  pivot_longer(
    cols = "1960":"2025",
    names_to = "year",
    values_to = "usuarios_internet")

internet_long <- internet_long %>%
  filter(!is.na(usuarios_internet)) %>%
  select(-...71) #VER ESTO!!!!!!

# Left join
datos <- internet_long %>%
  left_join(metadata, by = "Country Code")

## HIPOTESIS ##
hipotesis <- datos %>%
  group_by(year, IncomeGroup) %>%
  summarize(promedio_internet = mean(usuarios_internet, na.rm = TRUE))

hipotesis_wide <- hipotesis %>%
  pivot_wider(
    names_from = IncomeGroup,
    values_from = promedio_internet)




