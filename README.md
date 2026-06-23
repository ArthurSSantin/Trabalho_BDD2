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

Sistema de gestão comercial para o segmento de Varejo, modelado como um CRM (Customer Relationship Management). Centraliza dados de clientes, vendas, produtos, movimentações de estoque, atendimentos e oportunidades.

A interface web (`sistema/`) permite **CRUD de Clientes, Produtos, Oportunidades (Funil de Vendas) e Atendimentos**, consulta às **views** do banco (`vw_dashboard_vendas`, `vw_produtos_criticos` e `vw_cliente_360`) e exibe o **Painel Cliente 360°** de forma interativa com o histórico completo de interações, compras, endereços e a etapa do funil do cliente.

---

## Estrutura do Repositório

```
Trabalho_BDD2/
├── Banco_de_Dados/             # Script do banco separado por etapas
│   ├── Consultas baseadas em regra de negócio/
│   ├── DDL/
│   ├── Functions/
│   ├── Indexs/
│   ├── Povoamento-inserts/
│   ├── Procedures/
│   ├── Triggers/
│   └── views/
├── documentacao/               # SQL completo, dicionário, ER, documento do projeto
├── sistema/                    # Aplicação web (Python + HTML)
│   ├── server.py               # Backend Flask + API REST
│   ├── index.html              # Frontend (Vanilla JS + CSS)
│   └── requirements.txt
└── README.md
```

---

## Como Executar

### Pré-requisitos

- **PostgreSQL 13+** (pgAdmin 4)
- **Python 3.10+**

### 1. Clone o repositório

```bash
git clone https://github.com/ArthurSSantin/Trabalho_BDD2.git
cd Trabalho_BDD2
```

### 2. Crie e popule o banco de dados

No pgAdmin ou psql:

```sql
CREATE DATABASE "Trabalho_BDDII";
```

Execute o script completo:

```bash
psql -U postgres -d Trabalho_BDDII -f documentacao/Estrutura_BDD2.sql
```

> Também é possível executar os scripts separados em `Banco_de_Dados/`.

**Credenciais padrão da aplicação** (configuradas em `sistema/server.py`):

| Campo    | Valor            |
|----------|------------------|
| user     | postgres         |
| password | 123456           |
| host     | localhost        |
| port     | 5432             |
| database | Trabalho_BDDII   |

### 3. Instale as dependências Python

```bash
cd sistema
pip install -r requirements.txt
```

### 4. Inicie o servidor

```bash
python server.py
```

Abra no navegador: **http://localhost:3000**

---

## API REST

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/clientes` | Lista clientes (id DESC) |
| POST | `/api/clientes` | Cadastra cliente |
| PUT | `/api/clientes/:id` | Atualiza cliente |
| DELETE | `/api/clientes/:id` | Remove cliente |
| GET | `/api/clientes/:id/detalhes` | Retorna os detalhes consolidados (Cliente 360) |
| GET | `/api/produtos` | Lista produtos |
| POST | `/api/produtos` | Cadastra produto |
| PUT | `/api/produtos/:id` | Atualiza produto |
| DELETE | `/api/produtos/:id` | Remove produto |
| GET | `/api/vendedores` | Lista vendedores (para CRM) |
| GET | `/api/oportunidades` | Lista todas as oportunidades |
| POST | `/api/oportunidades` | Cadastra nova oportunidade |
| PUT | `/api/oportunidades/:id` | Atualiza oportunidade / etapa |
| DELETE | `/api/oportunidades/:id` | Remove oportunidade |
| GET | `/api/atendimentos` | Lista atendimentos |
| POST | `/api/atendimentos` | Registra novo atendimento |
| PUT | `/api/atendimentos/:id` | Atualiza atendimento |
| DELETE | `/api/atendimentos/:id` | Remove atendimento |
| GET | `/api/views/dashboard` | `vw_dashboard_vendas` |
| GET | `/api/views/criticos` | `vw_produtos_criticos` |
| GET | `/api/views/cliente360` | `vw_cliente_360` (Consolidado de CRM) |

---

## Tecnologias

| Camada | Tecnologia |
|--------|------------|
| Banco de dados | PostgreSQL / plpgsql |
| Backend | Python · Flask · psycopg2 |
| Frontend | HTML · CSS · JavaScript (Vanilla) |
| Gerenciamento DB | pgAdmin 4 |
| Versionamento | Git / GitHub |
| Modelagem | dbdiagram.io / Excel / Word |
