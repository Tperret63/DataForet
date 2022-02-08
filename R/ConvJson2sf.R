#' Convertisseur format JSON en SF
#'
#' @description La fonction permet de cpnvertir des fichiers au format .json en objet sf.
#' 
#' @param myurl = adresse du fichier json.
#' 
#' @import geojsonsf
#' @import sf
#' 
#' @examples
#' myurl = "http://eric.clst.org/assets/wiki/uploads/Stuff/gz_2010_us_050_00_500k.json"
#' sf <- geojson_sf(myurl)
#' 
#' @author Bruciamacchie Max
#' 
#' @export

ConvJson2sf <- function(myurl){
  sf <- geojson_sf(myurl)
  return(sf)
}
myurl <- "/Users/maxbruciamacchie/Downloads/cadastre-10210-parcelles.json"
sf <- geojson_sf(myurl)