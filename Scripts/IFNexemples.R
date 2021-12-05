library(sf)
library(tidyverse)
library(DataForet)

data("IFNarbres")
data("IFNplacettes")
data("CodesEssIFN")
data("ser")

ser <- ser %>% 
  group_by(codeser) %>% 
  summarise() %>% 
  filter(codeser!="-1") %>% 
  st_cast("MULTIPOLYGON")
  
IFNplacettes <- IFNplacettes %>%
  filter(!is.na(ser)) %>%
  mutate(greco = substring(ser, 1, 1))
  
nbres <- IFNplacettes %>% 
  group_by(ser) %>% 
  summarise(Freq = n())

tab <- IFNarbres %>% 
  filter(!is.na(w)) %>%
  mutate(espar = as.character(espar)) %>%
  mutate(Diam = round(c13/pi,0)) %>%
  mutate(Classe=floor(Diam/5+0.5)*5) %>% # floor = partie entière (ENT sous excel)
  mutate(Gha = c13^2/pi/40000*w) %>%
  left_join(IFNplacettes, by = c("idp", "Annee")) %>% 
  group_by(ser,espar) %>% 
  summarise(Gha = sum(Gha)) %>% 
  left_join(nbres, by = "ser") %>%
  mutate(Gha = Gha/Freq) %>% 
  select(-Freq) %>% 
  mutate(EssReg = ifelse(Gha <=0.5, "Autres", espar)) %>% 
  group_by(ser,EssReg) %>% 
  summarise(Gha = sum(Gha))

ggplot(tab, aes(x=EssReg)) + geom_bar(aes(y=Gha), stat='identity') + 
  facet_wrap(~ ser, ncol=4, scales="free_x")

tab.m <- tab %>% 
  mutate(greco = substring(ser, 1, 1)) %>% 
  pivot_wider(names_from = "EssReg", values_from="Gha", values_fill = list(Gha=0)) %>% 
  filter(!is.na(ser)) %>% 
  column_to_rownames(var="ser")

library(FactoMineR)
# ACP + CAH
res.pca = PCA(tab.m, scale.unit=F, ncp=5, quali.sup=1, graph=T)
res.hcpc = HCPC(res.pca)
t1 <- res.hcpc$data.clust %>% 
  select(clust) %>% 
  rownames_to_column(var="codeser")

data(ser)
Regser <- ser %>% 
  left_join(t1, by = "codeser") %>% 
  group_by(clust) %>% 
  summarise()
plot(Regser)

res <- kmeans(tab.m[, -1], centers=12, nstart=2)
t1 <- data.frame(codeser = row.names(tab.m)) %>% 
  mutate(clust = as.factor(res$cluster))
Regser <- ser %>% 
  left_join(t1, by = "codeser") %>% 
  group_by(clust) %>% 
  summarise()
plot(Regser)

tab$Groupe <- res$cluster

placettes <- IFNplacettes %>%
  st_as_sf(coords = c("xl93", "yl93"), crs = 2154, remove=F, agr="constant") %>%
  st_intersection(Regser)

nbres <- IFNplacettes %>% 
  group_by(clust) %>% 
  summarise(Freq = n())

tab <- IFNarbres %>% 
  filter(!is.na(w)) %>%
  mutate(espar = as.character(espar)) %>%
  mutate(Diam = round(c13/pi,0)) %>%
  mutate(Classe=floor(Diam/5+0.5)*5) %>% # floor = partie entière (ENT sous excel)
  mutate(Gha = c13^2/pi/40000*w) %>%
  left_join(IFNplacettes, by = c("idp", "Annee")) %>% 
  group_by(ser,espar) %>% 
  summarise(Gha = sum(Gha)) %>% 
  left_join(nbres, by = "ser") %>%
  mutate(Gha = Gha/Freq) %>% 
  select(-Freq) %>% 
  mutate(EssReg = ifelse(Gha <=0.5, "Autres", espar)) %>% 
  group_by(ser,EssReg) %>% 
  summarise(Gha = sum(Gha))

ggplot(tab, aes(x=EssReg)) + geom_bar(aes(y=Gha), stat='identity') + 
  facet_wrap(~ ser, ncol=4, scales="free_x")



library(explor)
explor(res.pca)

res <- explor::prepare_results(res.pca)
explor::PCA_ind_plot(res, xax = 1, yax = 2, ind_sup = FALSE, lab_var = "Lab",
                     ind_lab_min_contrib = 0, col_var = "greco", labels_size = 9, point_opacity = 0.5,
                     opacity_var = NULL, point_size = 64, ellipses = FALSE, transitions = TRUE,
                     labels_positions = NULL, xlim = c(-5.57, 12.8), ylim = c(-10.1, 8.29))


