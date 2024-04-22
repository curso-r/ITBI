## code to prepare `dados` dataset goes here

dados_raw <- readRDS("data-raw/tudo_junto.rds")

dados <- dados_raw |> 
  #janitor::clean_names() |> 
  dplyr::transmute(
    end_rua = `Nome do Logradouro`,
    end_num = Número,
    end_complemento = Complemento,
    end_bairro = Bairro,
    venda_prop_transmitida = `Proporção Transmitida (%)`,
    venda_valor = `Valor de Transação (declarado pelo contribuinte)`,
    venda_data = `Data de Transação`,
    imovel_area = `Área Construída (m2)`
  )

con <- RSQLite::dbConnect(RSQLite::SQLite(), "dados.sqlite")

RSQLite::dbWriteTable(con, "dados", dados, overwrite = TRUE)

