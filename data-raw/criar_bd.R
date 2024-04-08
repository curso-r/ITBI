## code to prepare `dados` dataset goes here

dados_raw <- readRDS("data-raw/dados_raw.rds")

dados <- dados_raw |> 
  janitor::clean_names() |> 
  dplyr::rename(
    end_rua = nome_do_logradouro,
    end_num = numero,
    end_complemento = complemento,
    venda_prop_transmitida = proporcao_transmitida_percent,
    venda_valor = valor_de_transacao_declarado_pelo_contribuinte,
    venda_data = data_de_transacao,
    imovel_area = area_construida_m2
  )

con <- RSQLite::dbConnect(RSQLite::SQLite(), "dados.sqlite")

RSQLite::dbWriteTable(con, "dados", dados, overwrite = TRUE)

