#' Volume total d'un arbre selon le tarif de cubage du projet EMERGE
#'
#' @description La fonction Tarif_EMERGE est un tarif à trois entrées proposé par l'ONF. 
#' Elle nécessite en entrée un data frame contenant par arbre sa hauteur totale (m),
#' circonférence (cm) et l'essence identifiée par le code IFN.
#'
#' @format Renvoie le data frame avec une nouvelle colonne VTot
#' 
#' @param df = data frame contenant des informations sur les essences, hauteurs et circonférences
#' @param Haut = variable de la hauteur totale en m
#' @param C130 = circonférence mesurée à 1,30m en cm
#' 
#' @import tidyverse
#' 
#' @examples
#' df <- Tarif_EMERGE(df, df$Haut, df$C130)
#' 
#' @author Martin Marie-Laure
#' 
#' @source ONF
#' 
#' @export

Tarif_EMERGE <- function(df, Haut, C130){
  data(VolEmerge)
  data(CodesEssIFN)
  
  Corresp <- VolEmerge %>% 
    dplyr::select(CodeIFN, Essence) %>% 
    rename(espar = CodeIFN)
  
  Coefft <- VolEmerge %>% 
    dplyr::select(-CodeIFN) %>% 
    distinct()

  df <- df %>% 
    left_join(CodesEssIFN, by = c("espar"="code")) %>% 
    left_join(Corresp, by = "espar") %>%
    mutate(Essence = ifelse(!is.na(Essence), Essence,
                            ifelse(grepl("76",espar) | grepl("74",espar) | grepl("73",espar)
                                   | grepl("72",espar)| grepl("70",espar)
                                   | grepl("77",espar)| grepl("69",espar)
                                   | grepl("68",espar)| grepl("67",espar)
                                   | grepl("66",espar)| grepl("59",espar)
                                   | grepl("55",espar),"Résineux", "Feuillus"))) %>% 
    left_join(Coefft, by = c("Essence")) %>% 
    mutate(VTot = ((Haut*(C130*10^-2)^2)/(4*pi*(1-(1.3/Haut))^2)) * (A + B*(sqrt(C130*10^-2)/Haut) + C*(Haut/(C130*10^-2))))
  return(df)
}
