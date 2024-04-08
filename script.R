library(tidyverse)

# coleta links ------------------------------------------------------------

links <- rvest::read_html(
  "https://www.prefeitura.sp.gov.br/cidade/secretarias/fazenda/acesso_a_informacao/index.php?p=31501") |> 
  rvest::html_node(
    "#content > div.post-text > ul:nth-child(8)"
  ) |> 
  rvest::html_nodes("a") |> 
  rvest::html_attr("href") |> 
  stringr::str_subset(".xlsx")

# baixa dados -------------------------------------------------------------

links |> 
  purrr::walk(function(x){
   httr::GET(x, httr::write_disk(
     overwrite = TRUE,
     path = stringr::str_glue("arquivos/", basename(x))))
    })

# processa arquivos -------------------------------------------------------

arquivos <- list.files("arquivos", full.names = TRUE)

# rascunho com ideias para a função final, abaixo
# ler_uma_tabela <- function(arquivo){
#   nomes <- readxl::excel_sheets(arquivo)
#   
#   planilhas_que_interessam <- stringr::str_subset(
#     nomes, "LEGENDA|EXPLICAÇÕES|Tabela de ", negate = TRUE
#   )
#   
#   purrr::map_dfr(planilhas_que_interessam,
#                  ~readxl::read_excel(arquivo, sheet = .x))
# }

ler_uma_tabela <- function(arquivo){
  nomes <- arquivo |>
    readxl::excel_sheets()

  colunas <- subset(nomes, !stringr::str_detect(nomes, "LEGENDA|EXPLICAÇÕES|Tabela de "))

  tabelona <- purrr::map_dfr(colunas,
               function(coluna){
                 readxl::read_excel(arquivo, sheet = coluna) |>
                   dplyr::mutate(
                     Número = as.character(Número),
                     Bairro = as.character(Bairro),
                     `Tipo de Financiamento` = as.character(`Tipo de Financiamento`)
                   )
                })

}

tudo_junto <- purrr::map_dfr(arquivos, ler_uma_tabela)
               
saveRDS(tudo_junto, "tudo_junto.rds")

# exemplo mapa ------------------------------------------------------------

tudo_junto <- readRDS("tudo_junto.rds")

resuminho <- tudo_junto |> 
  dplyr::filter(
    `Data de Transação` >= "2022-01-01",
    stringr::str_detect(`Nome do Logradouro`, "AV PAULISTA")
  ) |> 
  head(5000) |> 
  mutate(
    street = paste(`Nome do Logradouro`, Número)
  ) |> 
  distinct(`Nome do Logradouro`, `Número`, .keep_all = TRUE)

enderecos <- paste(resuminho$`Nome do Logradouro`, resuminho$Número)

enderecos <- tidygeocoder::geo(
  country = rep("Brazil", length(enderecos)),
  city = rep("São Paulo", length(enderecos)),
  state = rep("São Paulo", length(enderecos)),
  street = enderecos,
  method = "osm") 

library(leaflet)

dinheiro <- scales::dollar_format(prefix = "R$", big.mark = ".", decimal.mark = ",")

enderecos %>%
  left_join(resuminho) |> 
  mutate(
    texto = stringr::str_glue(
      "{street} {Complemento}<br>
      {dinheiro(`Valor de Transação (declarado pelo contribuinte)`)}<br>
      {`Área Construída (m2)`}<br>
      {`Data de Transação`}"
    )
  ) |> 
  drop_na() |> 
  leaflet(
    width = "100%",
    options = leafletOptions(attributionControl = FALSE)) %>%
  setView(lng = mean(enderecos$long, na.rm = TRUE),
          lat = mean(enderecos$lat, na.rm = TRUE), zoom = 500) |> 
  addTiles(group = "OSM") |> 
  addMarkers(popup = ~texto)
