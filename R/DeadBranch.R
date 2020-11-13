#' Mortalité des branches
#'
#' @description La fonction DeadBranch exploite l'information sur l'importance de la mortalité des branches 
#' des branches dans la partie supérieure du houppier. Cette information est contenue dans la table IFNarbres.
#' Le code 4 correspond à plus de 95\% des branches mortes dans la moitié supérieure du houppier. 
#' Le code 3 à une mortalité comprise entre 50 et 95\%. Le taux de mortalité est calculé pour chacun des codes 
#' comme le ratio en volume des tiges possédant la caractéristique en référence au volume total de l'essence.
#'
#' @format La fonction renvoie l'évolution au cours du temps du taux de mortalité sous forme de graphique.
#' 
#' @param ess = code d'une ou de plusieurs essences selon l'IFN. 
#' Le code data("CodesEssIFN") rappelle la codification de l'IFN.
#' 
#' @import tidyverse
#' 
#' @examples
#' DeadBranch(c("10","17C"))
#' DeadBranch(c("51","52","61","62","64")) 
#' DeadBranch(c("02","03","05","09","11","15S"))
#' 
#' @author Max Bruciamacchie
#' 
#' @source IFN
#' 
#' @export

DeadBranch <- function(ess) {
  tab <- IFNarbres %>% 
    filter(Annee > 2005) %>% 
    filter(espar %in% ess) %>% 
    filter(!is.na(mortb)) %>% 
    mutate(Vol = v*w) %>% 
    group_by(Annee, espar, mortb) %>% 
    summarise(Vol = sum(Vol)) %>% 
    group_by(Annee, espar) %>%
    mutate(Pourc = Vol/sum(Vol)) %>% 
    filter(mortb %in% c("3","4")) %>% 
    rename(code = espar) %>% 
    left_join(CodesEssIFN, by = "code") 
  
  g <- ggplot(tab, aes(x=factor(Annee), y=Pourc, color=mortb, group=mortb)) + 
    geom_line() + facet_wrap(~ libelle, ncol=3) +
    labs(x="Année", y="Pourcentage") +
    scale_y_continuous(labels = scales::percent)+
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, vjust =0.5))
  
  return(g)
}



