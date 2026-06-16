# Trabalho-BDD2

# Projeto CRM - Varejo

Este projeto foi desenvolvido como trabalho final da disciplina de Banco de Dados II do Centro Universitário UNISATC (2026/1).

## Integrantes do Grupo
- Arthur Santin
- Bruno Pavei
- Davi Goulart
- José Luis

## Descrição do Projeto
  Este sistema é uma solução integrada para gestão comercial de Varejo, atuando como um CRM (Gestão de Relacionamento com o Cliente). O objetivo é centralizar dados de clientes, vendas, produtos, movimentações de estoque e atendimentos.

## Tecnologias Utilizadas
- **Banco de Dados:** PostgreSQL
- **Modelagem:** Modelo ER Físico
- **Documentação:** Dicionário de Dados
- **Versionamento:** Git/GitHub

## Estrutura do Banco de Dados
O banco de dados foi modelado respeitando as regras de integridade referencial, utilizando chaves primárias e estrangeiras para conectar tabelas de forma lógica:
- `usuario`: Controle de acesso.
- `cliente`: Cadastro de clientes.
- `produto` & `categoria`: Gestão de inventário.
- `venda` & `item_venda`: Registro de transações.
- `oportunidade` & `atendimento`: Funil de vendas.
- `pagamento`: Controle financeiro.

## Como Executar
1. Clone este repositório.
2. Utilize um cliente PostgreSQL (como o PGAdmin4) para executar o script `Estrutura_BDD2.sql`.
