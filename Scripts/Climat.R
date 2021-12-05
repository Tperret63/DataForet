library(sf)
library(tidyverse)
library(gridExtra)
library(DataForet)

data(Climat)
data(Communes)
data(TypoClimat)

tab <- Climat %>% 
  filter(PTO != -9999) %>% 
  mutate(PTO = ifelse(PTO > 2157, NA, PTO),
         TEE = ifelse(TEE > 10, NA, TEE),
         TEH = ifelse(TEH > 10, NA, TEH),
         PEE = ifelse(PEE > 100, NA, PEE)) %>%
  left_join(Communes, by = "INSEE") %>% 
  st_sf()
  
g1 <- ggplot(tab) +
  geom_sf(aes(fill=PTO, color=PTO)) +
  theme_bw() +
  scale_colour_gradient(low = "#CCFFFF", high = "#003366") +
  scale_fill_gradient(low = "#CCFFFF", high = "#003366")
  
g2 <- ggplot(tab) +
  geom_sf(aes(fill=TMX, color=TMX)) +
  theme_bw() +
  scale_colour_gradient(low = "#FFCCCC", high = "#660000") +
  scale_fill_gradient(low = "#FFCCCC", high = "#660000")

g3 <- ggplot(tab) +
  geom_sf(aes(fill=PEE, color=PEE)) +
  theme_bw() +
  scale_colour_gradient(low = "#CCFFFF", high = "#003366") +
  scale_fill_gradient(low = "#CCFFFF", high = "#003366")

grid.arrange(g1,g2,g3, ncol=3)






tab <- data.frame(Type = 1:8,
                  Nom = c("Montagne","Semi-continental","Océanique dégradé",
                          "Océanique altéré","Océanique","Méditerranéen altéré",
                          "Bassin du Sud-Ouest","Méditerranéen"))
