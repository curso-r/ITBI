#' pag_buscar_por_rua UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_pag_buscar_por_rua_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(
      style = "margin-top: 48px;",
      bslib::layout_columns(
        col_widths = c(-4, 4),
        div(
          class = "text-center",
          h2("Buscar por rua"),
          textInput(
            ns("endereco"),
            label = "",
            value = "",
            placeholder = "Ex. Rua dos Bobos, 0",
            width = "100%"
          ),
          actionButton(ns("buscar"), "Buscar")
        )
      ),
      reactable::reactableOutput(ns("tabela"))
    )
  )
}
    
#' pag_buscar_por_rua Server Functions
#'
#' @noRd 
mod_pag_buscar_por_rua_server <- function(id, con) {
  moduleServer( id, function(input, output, session) {
    ns <- session$ns
    
    tabela <- eventReactive(input$buscar, {
      
      rua <- toupper(input$endereco)
      
      dplyr::tbl(con, "dados") |> 
        dplyr::filter(
          stringr::str_detect(end_rua, stringr::fixed(rua))
        ) |> 
        dplyr::collect() |> 
        dplyr::mutate(
          venda_data = venda_data |> 
            lubridate::as_datetime() |> 
            format("%d/%m/%Y")
        )
    })
    
    output$tabela <- reactable::renderReactable({
      tabela() |> 
        reactable::reactable(
          filterable = TRUE
        )
    })
 
  })
}
    
## To be copied in the UI
# mod_pag_buscar_por_rua_ui("pag_buscar_por_rua_1")
    
## To be copied in the server
# mod_pag_buscar_por_rua_server("pag_buscar_por_rua_1")
