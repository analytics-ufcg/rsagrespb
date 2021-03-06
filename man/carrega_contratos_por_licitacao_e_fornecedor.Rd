% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sagres_carrega_fornecedores_pagamentos.R
\name{carrega_contratos_por_licitacao_e_fornecedor}
\alias{carrega_contratos_por_licitacao_e_fornecedor}
\title{Carrega contratos de uma licitação}
\usage{
carrega_contratos_por_licitacao_e_fornecedor(db_user, ano_inicial = 2014,
  ano_final = 2014)
}
\arguments{
\item{db_user}{Usuario utilizado para conexão no BD}

\item{ano_inicial}{Ano inicial do intervalo de tempo}

\item{ano_final}{Ano final do intervalo de tempo}
}
\value{
Data frame com informações do agrupamento, como o contratado e o soma do valor dos contratos.
}
\description{
Carrega contratos realizados em um intervalo de tempo agrupados por licitação e por fornecedor
O dataframe retornado conta com as seguintes variáveis:
    \describe{
        \item{cd_UGestora}{Unidade Gestora de origem}
        \item{nu_Licitacao}{Número da licitação}
        \item{tp_Licitação}{Tipo da licitação}
        \item{nu_CPFCNPJ}{Código do credor (CPF, CNPJ)}
        \item{vl_SomaContratos}{Valor total dos contratos recebidos pelo credor na licitação}
    }
}
