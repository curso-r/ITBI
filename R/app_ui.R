#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    bslib::page_navbar(
      title = "SP Imóveis",
      fillable = FALSE,
      bslib::nav_panel(
        title = "Buscar por rua",
        mod_pag_buscar_por_rua_ui("pag_buscar_por_rua_1")
      ),
      bslib::nav_panel(
        title = "Busca avançada",
        mod_pag_busca_avancada_ui("pag_busca_avancada_1")
      ),
      bslib::nav_panel(
        title = "Buscar no mapa"
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "ITBI"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
