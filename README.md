# Sistema CRM — Varejo

Trabalho Final — Banco de Dados II · Centro Universitário UNISATC · 2026/1

---

## Integrantes

| Nome | GitHub |
|---|---|
| Arthur Santin  | [@ArthurSSantin](https://github.com/ArthurSSantin) |
| Bruno Pavei | [@brunopaveinasp2](https://github.com/brunopaveinasp2) |
| Davi Goulart | [@davigoularts](https://github.com/davigoularts) |
| José Luiz | [@josegiassi](https://github.com/josegiassi) |

---

## Sobre o Projeto

Sistema de gestão comercial para o segmento de Varejo, modelado como um CRM (Customer Relationship Management). Centraliza dados de clientes, vendas, produtos, movimentações de estoque e atendimentos.

---

## Estrutura do Repositório

```
Trabalho_BDD2/
├── Banco_de_Dados/             # Script do banco de dados sepado por etapas
│   ├── Consultas baseadas em regra de negócio/
│   ├── DDL/                    # Estrutura de tabelas do banco
│   ├── Functions/              
│   ├── Indexs/                 
│   ├── Povoamento-inserts/     # Inserts 
│   ├── Procedures/             
│   ├── Triggers/               # Automações
│   └── views/                  # Consultas para dashboards
├── Estrutura_BDD2.sql          # Banco de dados completo
├── DICIONARIO DE DADOS.xlsx
├── Modelo ER Fisico.pdf
└── PROJETO CRM - VAREJO.docx
```

---

## Como Executar

**Pré-requisitos:** PostgreSQL 13+ e pgAdmin 4.

**1. Clone o repositório**
```bash
git clone https://github.com/ArthurSSantin/Trabalho_BDD2.git
cd Trabalho_BDD2
```

**2. Crie o banco de dados**
```sql
CREATE DATABASE crm_varejo;
```

**3. Execute o script**
```bash
psql -U postgres -d crm_varejo -f Estrutura_BDD2.sql
```

Ou pelo pgAdmin 4: abra o Query Tool, carregue o arquivo `Estrutura_BDD2.sql` e execute.

---

## Tecnologias

**Banco de dados:** PostgreSQL / plpgsql

**Gerenciamento:** pgAdmin4

**Versionamento:** Git / GitHub

**Modelagem:** dbdiagram.io / Excel / Word
