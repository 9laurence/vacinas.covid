# Dependencias
library(tidyverse)
library(lubridate)
library(BayesFactor)
options(scipen = 999)

# Rodar o script "1_load_data_and_clean.R" antes de usar esse script.
# source("1_load_data_and_clean.R")

## Analises ----
## Correlacoes com dados vacina acumulado
# Dados correlacoes
data <- df %>% filter(mes > 2) %>%
  select(ocupacao_leitos, vacina_1d_cum) %>%
  na.omit()

# Correlacao de Pearson
cor <- cor.test(data$ocupacao_leitos, data$vacina_1d_cum)

sink("results/Correlacao_de_peason.txt")
cor
sink()

# Correlacao Bayesiana comparando modelo de relação negativa com positiva
corBF1 <-  correlationBF(data$ocupacao_leitos, data$vacina_1d_cum)
corBF2 <- correlationBF(data$ocupacao_leitos, data$vacina_1d_cum,
  nullInterval = c(-1, 0))

corBF <- c(corBF1, corBF2)

sink("results/Correlacoes_bayesianas_BF.txt")
corBF
sink()

sink("results/BF_negativo_por_nulo.txt")
corBF[2]/corBF[1]
sink()

sink("results/BF_negativo_por_positivo.txt")
corBF[2]/corBF[3]
sink()

## Correlacoes Junho
# Dados correlacoes
data <- df %>% filter(mes == 6) %>%
  select(ocupacao_leitos, vacina_1d_cum) %>%
  na.omit()

# Correlacao de Pearson
cor <- cor.test(data$ocupacao_leitos, data$vacina_1d_cum)

sink("results/Correlacao_de_peason_Junho.txt")
cor
sink()

# Correlacao Bayesiana comparando modelo de relação negativa com positiva
corBF1 <-  correlationBF(data$ocupacao_leitos, data$vacina_1d_cum)
corBF2 <- correlationBF(data$ocupacao_leitos, data$vacina_1d_cum,
                        nullInterval = c(-1, 0))

corBF <- c(corBF1, corBF2)

sink("results/Correlacoes_bayesianas_BF_junho.txt")
corBF
sink()

sink("results/BF_negativo_por_nulo_junho.txt")
corBF[2]/corBF[1]
sink()

sink("results/BF_negativo_por_positivo_junho.txt")
corBF[2]/corBF[3]
sink()

## Correlacoes com dados da primeira dose atrasados em 21 dias
# Dados correlacoes
data <- df %>% filter(mes > 2) %>%
  select(ocupacao_leitos, vacina_1d_mm7d) %>%
  na.omit()

# Correlacao de Pearson
cor <- cor.test(data$ocupacao_leitos, data$vacina_1d_mm7d)

sink("results/not_used/Correlacao_de_peason.txt")
cor
sink()

# Correlacao Bayesiana comparando modelo de relação negativa com positiva
corBF1 <-  correlationBF(data$ocupacao_leitos, data$vacina_1d_mm7d)
corBF2 <- correlationBF(data$ocupacao_leitos, data$vacina_1d_mm7d,
                        nullInterval = c(-1, 0))

corBF <- c(corBF1, corBF2)

sink("results/not_used/Correlacoes_bayesianas_BF.txt")
corBF
sink()

sink("results/not_used/BF_negativo_por_nulo.txt")
corBF[2]/corBF[1]
sink()

sink("results/not_used/BF_negativo_por_positivo.txt")
corBF[2]/corBF[3]
sink()

## Modelo
# Data para o modelo
d <- df %>% filter(mes > 2) %>%  
  select(ocupacao_leitos, vacina_1d_cum, mes) %>% 
  na.omit() %>% 
  mutate(mes = as.factor(mes))

# Modelo de regressão linear entre ocupacoes de leitos e primeira dose da vacina
reg <-  lm(ocupacao_leitos ~ mes + vacina_1d_cum, data = d)

sink("results/not_used/regressao.txt")
summary(reg)
lm.beta::lm.beta(reg)
sink()




## Graficos ----
# Grafico entre ocupacoes e primeira dose pelo tempo com variaveis estandardizadas.
df %>% filter(mes > 2) %>% 
  select(datahora, ocupacao_leitos, vacina_1d_cum) %>%
  na.omit() %>%
  mutate(ocupacao_leitos = scale(ocupacao_leitos),
         vacina_1d_cum = scale(vacina_1d_cum)) %>%
  pivot_longer(-datahora) %>% 
  ggplot(aes(x = datahora, y = value, color = name)) +
  geom_line(size = 1) +
  # annotate("text", label = "Vacinaçao", size = 8, 
  #          x = as_date("2021-06-15"), y = 2.25, color = "#FDE725FF")+
  geom_label(aes(x = as_date("2021-06-10"), y = 2.15, label = "Número de pessoas vacinadas \n com a primeira dose"), 
             size = 4, color = "black", fill = "#FDE725FF")+
  geom_label(aes(x = as_date("2021-06-20"), y = -1.75, label = "Ocupação dos Leitos"), 
             size = 4, color = "white", fill = "#440154FF")+
  labs(x = "Data", y = "Valores", 
       title = "Porcentagem da ocupação de leitos por COVID-19 e número de vacinação",
       subtitle = "Valores entre 01 de março de 2021 e 03 de julho de 2021 no estado de São Paulo.",
       caption = "As variáveis estão estandardizadas para facilitar a compreensão. \n Dados do Governo de São Paulo.") +
  scale_color_ordinal() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  scale_x_date(breaks = scales::pretty_breaks(n = 10))+
  cowplot::theme_cowplot() +
  theme(panel.grid.major.y = element_line(colour = "grey", linetype = 3),
        panel.grid.major.x = element_line(colour = "grey", linetype = 3),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position = "none")

# Salvar grafico
ggsave("figs/vacina_ocupacao.png", dpi = 200, units = "cm", width = 30, height = 15)

# Grafico junho

df %>% filter(mes == 6) %>% 
  select(datahora, ocupacao_leitos, vacina_1d_cum) %>%
  na.omit() %>%
  mutate(ocupacao_leitos = scale(ocupacao_leitos),
         vacina_1d_cum = scale(vacina_1d_cum)) %>%
  pivot_longer(-datahora) %>% 
  ggplot(aes(x = datahora, y = value, color = name)) +
  geom_line(size = 1) +
  # annotate("text", label = "Vacinaçao", size = 8, 
  #          x = as_date("2021-06-15"), y = 2.25, color = "#FDE725FF")+
  geom_label(aes(x = as_date("2021-06-26"), y = 0.5, label = "Número de pessoas vacinadas \n com a primeira dose"), 
             size = 4, color = "black", fill = "#FDE725FF")+
  geom_label(aes(x = as_date("2021-06-25"), y = -1.9, label = "Ocupação dos Leitos"), 
             size = 4, color = "white", fill = "#440154FF")+
  labs(x = "Data", y = "Valores", 
       title = "Porcentagem da ocupação de leitos por COVID-19 e número de vacinação",
       subtitle = "Valores entre 01 de junho de 2021 até 30 de junho de 2021 no estado de São Paulo.",
       caption = "As variáveis estão estandardizadas para facilitar a compreensão. \n Dados do Governo de São Paulo.") +
  scale_color_ordinal() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  scale_x_date(breaks = scales::pretty_breaks(n = 30), expand = c(0,0))+
  cowplot::theme_cowplot() +
  theme(panel.grid.major.y = element_line(colour = "grey", linetype = 3),
        panel.grid.major.x = element_line(colour = "grey", linetype = 3),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.x = element_text(angle = 90),
        legend.position = "none")

ggsave("figs/vacina_ocupacao_junho.png", dpi = 200, units = "cm", width = 30, height = 15)
