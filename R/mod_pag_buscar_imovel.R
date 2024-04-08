#' pag_buscar_imovel UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_pag_buscar_imovel_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Buscar imóvel"),
    h3("Busca por endereço"),
    includeMarkdown(app_sys("app/md/desc_busca_endereco.md")),
    bslib::layout_columns(
      col_widths = 4,
      textInput(
        ns("endereco"),
        label = "Endereço do imóvel",
        value = "",
        placeholder = "Ex. Rua dos Bobos, 0",
        width = "100%"
      )
    ),
    bslib::accordion(
      bslib::accordion_panel(
        title = "Busca avançada",
        bslib::layout_columns(
          col_widths = c(4, 4, 4),
          dateRangeInput(
            ns("data"),
            label = "Data da transação",
            start = Sys.Date() - 180,
            end = Sys.Date(),
            min = "2006-01-01",
            max = Sys.Date(),
            format = "dd/mm/yyyy",
            language = "pt-BR",
            separator = "a"
          ),
          sliderInput(
            ns("area"),
            label = "Área construída (m²)",
            min = 0,
            max = 1000,
            value = c(100, 500),
            step = 10
          ),
          sliderInput(
            ns("valor"),
            label = "Valor da venda (R$)",
            min = 0,
            max = 10000000,
            value = c(0, 1000000),
            step = 1e4
          )
        )
      )
    ),
    actionButton(ns("buscar"), "Buscar"),
    reactable::reactableOutput(ns("tabela"))
  )
}
    
#' pag_buscar_imovel Server Functions
#'
#' @noRd 
mod_pag_buscar_imovel_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    con <- RSQLite::dbConnect(RSQLite::SQLite(), "dados.sqlite")
    
    tabela <- eventReactive(input$buscar, {
      dplyr::tbl(con, "dados") |> 
        dplyr::filter(
          dbplyr::sql(glue::glue("end_rua LIKE '{input$endereco}'"))
          # venda_data >= input$data[1] & venda_data <= input$data[2],
          # imovel_area >= input$area[1] & imovel_area <= input$area[2],
          # venda_valor >= input$valor[1] & venda_valor <= input$valor[2]
        ) |> 
        dplyr::collect()
    })
    
    output$tabela <- reactable::renderReactable({
      tabela() |> 
        reactable::reactable()
    })
 
  })
}
    
## To be copied in the UI
# mod_pag_buscar_imovel_ui("pag_buscar_imovel_1")
    
## To be copied in the server
# mod_pag_buscar_imovel_server("pag_buscar_imovel_1")
