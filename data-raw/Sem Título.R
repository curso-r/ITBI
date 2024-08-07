library(tidyverse)
library(lubridate)
library(sidrar)

# O preço médio dos imoveis subiu? ----------------------------------------

ipca = get_sidra(api = '/t/1737/n1/all/v/2266/p/all/d/v2266%2013') %>%
  mutate(date = parse_date(`Mês (Código)`, format = "%Y%m")) %>%
  mutate(inflacao_mensal = (Valor/lag(Valor,1)-1)*100,
         inflacao_anual = (Valor/lag(Valor,12)-1)*100) %>%
  dplyr::rename(indice = Valor) %>%
  select(date, indice, inflacao_mensal, inflacao_anual) %>%
  as_tibble()

ipca_anual <- ipca |> 
  group_by(
    ano = year(date)
  ) |> 
  filter(date == max(date)) |> 
  filter(ano >= 2006) |> 
  mutate(tipo = "IPCA",
         inflacao_anual = inflacao_anual/100) 

dados_raw |> 
  filter(tipo_imovel %in% c("casa", "apartamento"),
         venda_prop_transmitida == 100) |> 
  group_by(
    ano = year(venda_data)
  ) |> summarise(
    preco_mediano = median(venda_valor, na.rm = TRUE),
    preco_medio = mean(venda_valor)
  ) |> 
  filter(ano >= 2006) |> 
  arrange(ano) |> 
  mutate(
    inflacao_anual = preco_medio/lag(preco_medio)-1,
    tipo = "Preço Médio Imóveis"
  ) |> 
  bind_rows(ipca_anual) |> 
  ggplot(aes(x = ano, y = inflacao_anual, color = tipo)) + 
  geom_line() + 
  geom_point() + 
  theme_bw() +
  labs(x = "Ano", y = "Inflação", color = "Índice") +
  theme(legend.position = 'bottom') +
  scale_y_continuous(label = scales::percent_format(decimal.mark = ","))

# Será que o aumento de preço é igual em todos os bairros? ----------------

dados_raw |> 
  filter(tipo_imovel %in% c("casa", "apartamento"),
         venda_prop_transmitida == 100) |> 
  filter(
    #is.na(end_bairro)
    end_bairro %in% c("TATUAPE", "SANTO AMARO", "PERDIZES", "MOOCA", "SAUDE", 
                      "BUTANTA", "CERQUEIRA CESAR", "JABAQUARA", "PINHEIROS")
  ) |> 
  group_by(
    end_bairro,
    ano = year(venda_data)
  ) |> summarise(
    preco_mediano = median(venda_valor, na.rm = TRUE),
    preco_medio = mean(venda_valor, na.rm = TRUE),
    freq = n()
  ) |> 
  filter(ano >= 2018) |> 
  arrange(end_bairro, ano) |> 
  group_by(end_bairro) |> 
  mutate(
    inflacao_anual = preco_mediano/lag(preco_mediano)-1,
    tipo = "Preço Médio Imóveis"
  ) |> 
  #bind_rows(ipca_anual) |> 
  ggplot(aes(x = ano, y = inflacao_anual, color = tipo)) + 
  geom_line() + 
  geom_line(data = filter(ipca_anual, ano >= 2018)) + 
  geom_point() + 
  theme_bw() +
  labs(x = "Ano", y = "Inflação", color = "Índice") +
  theme(legend.position = 'bottom') +
  scale_y_continuous(label = scales::percent_format(decimal.mark = ",")) +
  facet_wrap(~end_bairro, nrow = 3, scales = 'free')


# Tabela bairros com maior aumento ----------------------------------------

dados_raw |> 
  filter(tipo_imovel %in% c("casa", "apartamento"),
         venda_prop_transmitida == 100) |> 
  group_by(
    end_bairro,
    ano = year(venda_data)
  ) |> summarise(
    preco_mediano = median(venda_valor, na.rm = TRUE),
    preco_medio = mean(venda_valor, na.rm = TRUE),
    freq = n()
  ) |> 
  filter(ano >= 2018) |> 
  arrange(end_bairro, ano) |> 
  group_by(end_bairro) |> 
  mutate(
    inflacao_anual = preco_mediano/lag(preco_mediano)-1,
    tipo = "Preço Médio Imóveis"
  ) |> 
  mutate(
    total_vendas = sum(freq)
  ) |> 
  arrange(desc(ano), desc(total_vendas)) |> View()

# inflacao_do_m2 ----------------------------------------------------------

dados_raw |> 
  filter(tipo_imovel %in% c("casa", "apartamento"),
         venda_prop_transmitida == 100) |> 
  group_by(
    ano = year(venda_data)
  ) |> summarise(
    preco_mediano = median(venda_valor, na.rm = TRUE),
    preco_medio = mean(venda_valor),
    m2_medio = mean(venda_valor/(1+imovel_area)),
    m2_mediano = median(venda_valor/(1+imovel_area))
    
  ) |> 
  filter(ano >= 2006) |> 
  arrange(ano) |> 
  mutate(
    inflacao_anual = m2_mediano/lag(m2_mediano)-1,
    tipo = "Variação (%) Preço Mediano Imóveis"
  ) |> 
  bind_rows(ipca_anual) |> 
  ggplot(aes(x = ano, y = inflacao_anual, color = tipo)) + 
  geom_line() + 
  geom_point() + 
  theme_bw() +
  labs(x = "Ano", y = "Inflação", color = "Índice",
       caption = "Fonte:  Prefeitura de São Paulo, IBGE",
       title = "Inflação de Imóveis em São Paulo Capital X IPCA") +
  theme(legend.position = 'bottom') +
  scale_y_continuous(label = scales::percent_format(decimal.mark = ",")) 

