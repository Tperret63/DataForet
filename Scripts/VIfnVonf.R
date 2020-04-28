library(tidyverse)

data(IFNarbres)
data(IFNplacettes)

df <- IFNarbres %>% 
  filter(!is.na(v)) %>%
  filter(!is.na(htot))
  
df <- Tarif_EMERGE(df, df$htot, df$c13)

compare <- df %>% 
  left_join(IFNplacettes, by = c("idp", "Annee")) %>% 
  filter(!is.na(ser)) %>% 
  group_by(ser, Essence) %>% 
  summarise(Vifn = sum(v*w),
            Vonf = sum(VTot*w))


