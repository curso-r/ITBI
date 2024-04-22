## code to prepare `dados` dataset goes here

dados_raw <- readRDS("data-raw/tudo_junto.rds")

dados_raw <- dados_raw |> 
  #janitor::clean_names() |> 
  dplyr::transmute(
    end_rua = `Nome do Logradouro`,
    end_num = Número,
    end_complemento = Complemento,
    end_bairro = Bairro,
    venda_prop_transmitida = `Proporção Transmitida (%)`,
    venda_valor = `Valor de Transação (declarado pelo contribuinte)`,
    venda_data = `Data de Transação`,
    imovel_area = `Área Construída (m2)`,
    vagas = dplyr::case_when(
      stringr::str_detect(end_complemento, "1 ?VG|E VG") ~ 1,
      stringr::str_detect(end_complemento, "2 ?VGS?") ~ 2,
      stringr::str_detect(end_complemento, "3 ?VGS?") ~ 3,
      stringr::str_detect(end_complemento, "3 ?VGS?") ~ 4,
      TRUE ~ 0
    ),
    tipo_imovel = dplyr::case_when(
      stringr::str_detect(end_complemento, "APT|AP ") ~ "apartamento",
      stringr::str_detect(end_complemento, "CASA") ~ "casa",
      TRUE ~ "outro"
    ),
    imovel_area_liq = pmax(0, imovel_area*0.6-vagas*13.75)
  )

con <- RSQLite::dbConnect(RSQLite::SQLite(), "dados.sqlite")

RSQLite::dbWriteTable(con, "dados", dados, overwrite = TRUE)

