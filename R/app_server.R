#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  
  con <- RSQLite::dbConnect(RSQLite::SQLite(), "dados.sqlite")
  
  mod_pag_buscar_por_rua_server("pag_buscar_por_rua_1", con)
  mod_pag_busca_avancada_server("pag_busca_avancada_1", con)
}
