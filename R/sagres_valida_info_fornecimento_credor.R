#' @title Carrega informações de credores
#' @description Recupera informações de empenhos a partir de um CPF/CNPJ e uma data limite. As informações são o total pago e o total estornado
#' @param db_user Usuario utilizado para conexão no BD
#' @param cd_Credor Código do Credor (CPF ou CNPJ)
#' @param dt_Inicio Data limite para a data do pagamento e do estorno
#' @return Lista com dois data frames: um contendo as informações do total pago por ano e outro contendo informações do total estornado por ano
#' @export
info_credor_data <- function(db_user, cd_Credor, dt_Inicio) {
    conn <- dbConnect(RMySQL::MySQL(),
                      dbname = "sagres_municipal",
                      group = "rsagrespb",
                      username = db_user)

    template <- ('
                    SELECT cd_UGestora, dt_Ano, cd_UnidOrcamentaria, nu_Empenho, nu_Licitacao, tp_Licitacao, cd_Credor, no_Credor
                    FROM Empenhos
                    WHERE cd_Credor = "%s"
                 ')

    query <- template %>%
        sprintf(cd_Credor) %>%
        sql()

    empenhos <- tbl(conn, query) %>%
        compute(name = "emp") %>%
        collect(n = Inf)

    template <- ('
                    SELECT p.cd_UGestora, p.dt_Ano, p.cd_UnidOrcamentaria, p.nu_Empenho, p.nu_Parcela, p.tp_Lancamento, dt_Pagamento, vl_Pagamento
                    FROM Pagamentos p
                    INNER JOIN emp
                    USING (cd_UGestora, nu_Empenho, cd_UnidOrcamentaria, dt_Ano)
                ')

    query <- template %>%
        sql()

    pagamentos <- tbl(conn, query) %>%
        compute(name = "pag") %>%
        collect(n = Inf)

    template <- ('
                    SELECT ep.cd_UGestora, ep.cd_UnidOrcamentaria, ep.nu_EmpenhoEstorno, ep.nu_ParcelaEstorno, ep.tp_Lancamento, ep.dt_Ano,
                         ep.dt_Estorno, ep.vl_Estorno
                    FROM EstornoPagamento ep
                    INNER JOIN pag
                    ON
                        ep.cd_UGestora = pag.cd_UGestora AND
                        ep.cd_UnidOrcamentaria = pag.cd_UnidOrcamentaria AND
                        ep.nu_EmpenhoEstorno = pag.nu_Empenho AND
                        ep.nu_ParcelaEstorno = pag.nu_Parcela AND
                        ep.tp_Lancamento = pag.tp_Lancamento AND
                        ep.dt_Ano = pag.dt_Ano
                ')

    query <- template %>%
        sql()

    ## Carrega os estornos associados aos pagamentos
    estornos_pagamento <- tbl(conn, query) %>%
        collect(n = Inf)

    DBI::dbDisconnect(conn)

    pagamentos_credor <- pagamentos %>%
        filter(dt_Pagamento < dt_Inicio) %>%
        group_by(cd_UGestora, nu_Empenho, cd_UnidOrcamentaria, dt_Ano) %>%
        summarise(vl_Pago = sum(vl_Pagamento)) %>%
        ungroup()

    estornos_credor <- estornos_pagamento %>%
        filter(dt_Estorno < dt_Inicio) %>%
        group_by(cd_UGestora, nu_EmpenhoEstorno, cd_UnidOrcamentaria, dt_Ano) %>%
        summarise(vl_Estornado = sum(vl_Estorno)) %>%
        ungroup()

    total_pago_empenhos <- pagamentos_credor %>%
      group_by(dt_Ano) %>%
      summarise(vl_Pago = sum(vl_Pago))

    total_estornos <- estornos_credor %>%
      group_by(dt_Ano) %>%
      summarise(vl_Estornado = sum(vl_Estornado))

    return(list(total_pago_empenhos, total_estornos))
}
