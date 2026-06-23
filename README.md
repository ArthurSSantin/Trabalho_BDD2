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

A interface web (`sistema/`) permite **CRUD de Clientes e Produtos** e consulta às **views** do banco (`vw_dashboard_vendas` e `vw_produtos_criticos`).

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
| GET | `/api/produtos` | Lista produtos |
| POST | `/api/produtos` | Cadastra produto |
| PUT | `/api/produtos/:id` | Atualiza produto |
| DELETE | `/api/produtos/:id` | Remove produto |
| GET | `/api/views/dashboard` | `vw_dashboard_vendas` |
| GET | `/api/views/criticos` | `vw_produtos_criticos` |

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
