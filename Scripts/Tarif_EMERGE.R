#' Volume total d'un arbre selon le tarif de cubage du projet EMERGE
#'
#' @description La fonction Tarif_EMERGE est un tarif à trois entrées propsé par l'ONF. 
#' Elle nécessite en entrée un data frame contenant par arbre la hauteur totale (m), sa
#' circonférence (cm) et l'essence identifiée par le code IFN.
#'
#' @format Renvoie le data frame avec une nouvelle colonne VTot
#' 
#' @param df = data frame avec les mesures par arbre
#' @param Hauteur = variable de la hauteur totale en m
#' @param Circ130 = circonférence mesurée à 1,30m en cm
#' 
#' @examples
#' df <- Tarif_EMERGE(df, df$Hauteur, df$Circ130)
#' @
#' @source ONF


# Hauteur en m et Diam130 en cm : nécessite un df qui déclarer variable hauteur totale et circonférence
Tarif_EMERGE <- function(df, Hauteur, Circ130){
  data(VolEmerge)
  data(CodesEssIFN)
  
  df <- df %>% 
    left_join(CodesEssIFN, by = c("espar"="code")) %>% 
    left_join(VolEmerge[,1:2], by = c("espar"="CodeIFN")) %>%
    mutate(Essence = ifelse(!is.na(Essence), Essence,
                            ifelse(grepl("76",espar) | grepl("74",espar) | grepl("73",espar)
                                   | grepl("72",espar)| grepl("70",espar)
                                   | grepl("77",espar)| grepl("69",espar)
                                   | grepl("68",espar)| grepl("67",espar)
                                   | grepl("66",espar)| grepl("59",espar)
                                   | grepl("55",espar),"Résineux", "Feuillus"))) %>% 
    left_join(VolEmerge, by = c("Essence")) %>% 
    mutate(VTot = ((Hauteur*(Circ130*10^-2)^2)/(4*pi*(1-(1.3/Hauteur))^2)) * (A + B*(sqrt(Circ130*10^-2)/Hauteur) + C*(Hauteur/(Circ130*10^-2))))
  return(df)
}
