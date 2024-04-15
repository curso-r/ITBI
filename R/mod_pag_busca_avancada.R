#' pag_busca_avancada UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_pag_busca_avancada_ui <- function(id){
  ns <- NS(id)
  tagList(
    h2("Busca avançada", class = "mb-4"),
    bslib::card(
      bslib::card_header(
        bslib::card_title("Parâmetros de busca")
      ),
      bslib::card_body(
        bslib::layout_columns(
          col_widths = c(3, 3, 3, 3),
          textInput(
            ns("endereco"),
            label = "Rua do imóvel",
            value = "",
            placeholder = "Ex. Rua dos Bobos, 0",
            width = "100%"
          ),
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
        ),
        div(
          class = "text-end",
          actionButton(ns("buscar"), "Buscar", width = "250px")
        )
      )
    ),
    reactable::reactableOutput(ns("tabela"))
  )
}
    
#' pag_busca_avancada Server Functions
#'
#' @noRd 
mod_pag_busca_avancada_server <- function(id, con){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    tabela <- eventReactive(input$buscar, {
      
      rua <- toupper(input$endereco)
      data <- as.numeric(lubridate::as_datetime(input$data))
      
      dplyr::tbl(con, "dados") |> 
        dplyr::filter(
          stringr::str_detect(end_rua, stringr::fixed(rua)),
          venda_data >= !!data[1] & venda_data <= !!data[2],
          imovel_area >= !!input$area[1] & imovel_area <= !!input$area[2],
          venda_valor >= !!input$valor[1] & venda_valor <= !!input$valor[2]
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
# mod_pag_busca_avancada_ui("pag_busca_avancada_1")
    
## To be copied in the server
# mod_pag_busca_avancada_server("pag_busca_avancada_1")
