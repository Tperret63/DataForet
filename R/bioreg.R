#' Biorégions.
#'
#' @description Carte des biorégions
#'
#' @format Fichier géoréférencé au format sf contenant 3 biorégions.
#' 
#' @param LIBELLE = nom de la région
#' @param geometry = géométrie
#' 
#' @examples
#' data(bioreg)
#' plot(st_geometry(bioreg), border='blue', lwd=2)
#' plot(st_geometry(greco), add=T, border='red')
#' 
#' @source 
"bioreg"
