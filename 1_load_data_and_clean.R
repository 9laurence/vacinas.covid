# Dependencies
library(tidyverse)
library(lubridate)

## Load data ----
# Os dados usados foram baixados no dia 04-Jul-2021 e estão disponíveis
# em https://www.saopaulo.sp.gov.br/planosp/simi/dados-abertos/

load("data-raw/20210703_dados_covid_municipios_sp.rds")
load("data-raw/20210703_evolucao_aplicacao_doses.rds")
load("data-raw/20210703_isolamento.rds")
load("data-raw/20210703_leitos_internacoes.rds")

## Clean data ----
# Dados covid
df_covid <- dc %>% mutate(datahora = dmy(datahora)) %>% 
  group_by(datahora) %>% 
  summarise(casos = sum(casos),
            casos_novos = sum(casos_novos),
            casos_100mil = sum(casos_pc),
            casos_mm7d = sum(casos_mm7d),
            obitos = sum(obitos),
            obitos_novos = sum(obitos_novos),
            obitos_100mil = sum(obitos_pc),
            obitos_mm7d = sum(obitos_mm7d),
            letalidade = sum(letalidade)) %>% 
  mutate(dia = day(datahora),
         mes = month(datahora),
         ano = year(datahora))

# Dados isolamento
di_sp <- di %>% janitor::clean_names() %>% 
  filter(municipio1 == "ESTADO DE SÃO PAULO") %>% 
  select(data, media_de_indice_de_isolamento)

virada_ano <- di_sp %>% mutate(row_number = row_number()) %>% 
  filter(data == "quinta-feira, 31/12") %>% 
  pull(row_number)

di_anos <- split(di_sp, cumsum(1:nrow(di_sp) %in% virada_ano))

df_isolamento <- bind_rows(
di_anos$`0` %>%
  mutate(data = gsub("[^0-9]", "", data),
         data = paste0(data, "2021"),
         data = dmy(data)),

di_anos$`1` %>%
  mutate(data = gsub("[^0-9]", "", data),
         data = paste0(data, "2020"),
         data = dmy(data))
) %>% 
  rename(datahora = data,
         isolamento = media_de_indice_de_isolamento) %>% 
  mutate(isolamento = as.numeric(gsub("[^0-9]", "", isolamento)),
         isolamento_mm7d = zoo::rollmean(isolamento, 7, align = "right", fill = NA))

# Dados leitos
df_leitos <- dl %>% filter(nome_drs == "Estado de São Paulo") %>% 
  mutate(datahora = dmy(datahora)) %>% 
  select(datahora,
         pacientes_uti_mm7d,
         total_covid_uti_mm7d,
         ocupacao_leitos,
         pacientes_uti_ultimo_dia,
         total_covid_uti_ultimo_dia,
         ocupacao_leitos_ultimo_dia)

# Dados Vacina
dv2 <- dv %>% janitor::clean_names() %>% 
  mutate(datahora = dmy(dia_de_data_registro_vacina)) %>% 
  select(datahora,
         dose,
         contagem = contagem_de_dose)

df_v1 <- dv2 %>% filter(dose == "1° DOSE") %>% 
  select(-dose) %>% 
  rename(vacina_1d = contagem) %>% 
  arrange(datahora) %>% 
  mutate(vacina_1d_cum = cumsum(vacina_1d))

df_v2 <- dv2 %>% filter(dose == "2° DOSE") %>% 
  select(-dose) %>% 
  rename(vacina_2d = contagem) %>% 
  arrange(datahora) %>% 
  mutate(vacina_2d_cum = cumsum(vacina_2d))

df <- full_join(df_covid, df_isolamento, by = "datahora") %>% 
  full_join(df_leitos, by = "datahora") %>% 
  full_join(df_v1, by = "datahora") %>% 
  full_join(df_v2, by = "datahora")


## Remover dfs que nao serao utilizados ----
rm(dc, di, di_anos, di_sp, dl, dv, dv2, virada_ano,
   df_covid, df_isolamento, df_leitos, df_v1, df_v2)

