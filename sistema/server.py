"""
Sistema CRUD — Trabalho BDD II
Flask serve a API e o index.html na porta 3000.
"""

import os
from datetime import date, datetime
from decimal import Decimal

import psycopg2
import psycopg2.extras
from flask import Flask, jsonify, request, send_from_directory

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
app = Flask(__name__)

DB = {
    "user": "postgres",
    "host": "localhost",
    "database": "Trabalho_BDDII",
    "password": "123456",
    "port": 5432,
}


def serializar(valor):
    if isinstance(valor, dict):
        return {k: serializar(v) for k, v in valor.items()}
    if isinstance(valor, list):
        return [serializar(v) for v in valor]
    if isinstance(valor, (date, datetime)):
        return valor.isoformat()
    if isinstance(valor, Decimal):
        return float(valor)
    return valor


def executar(sql, params=None, um=False, commit=True):
    conn = psycopg2.connect(**DB)
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            if um:
                row = cur.fetchone()
            else:
                row = cur.fetchall()
            if commit:
                conn.commit()
            if um:
                return serializar(dict(row)) if row else None
            return serializar([dict(r) for r in row])
    except Exception as err:
        conn.rollback()
        print(err)
        raise
    finally:
        conn.close()


def corpo_json():
    return request.get_json(silent=True) or {}


# ── CLIENTES ────────────────────────────────────────────────────────────────

@app.get("/api/clientes")
def listar_clientes():
    try:
        return jsonify(executar("SELECT * FROM cliente ORDER BY id_cliente DESC"))
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.post("/api/clientes")
def criar_cliente():
    d = corpo_json()
    try:
        row = executar(
            """INSERT INTO cliente (nome, cpf_cnpj, email, telefone, data_nascimento)
               VALUES (%s, %s, %s, %s, %s) RETURNING *""",
            (
                d.get("nome"),
                d.get("cpf_cnpj"),
                d.get("email") or None,
                d.get("telefone") or None,
                d.get("data_nascimento") or None,
            ),
            um=True,
        )
        return jsonify(row), 201
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.put("/api/clientes/<int:id>")
def atualizar_cliente(id):
    d = corpo_json()
    try:
        row = executar(
            """UPDATE cliente
               SET nome = %s, cpf_cnpj = %s, email = %s, telefone = %s, data_nascimento = %s
               WHERE id_cliente = %s RETURNING *""",
            (
                d.get("nome"),
                d.get("cpf_cnpj"),
                d.get("email") or None,
                d.get("telefone") or None,
                d.get("data_nascimento") or None,
                id,
            ),
            um=True,
        )
        if not row:
            return jsonify(erro="Cliente não encontrado."), 404
        return jsonify(row)
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.delete("/api/clientes/<int:id>")
def excluir_cliente(id):
    try:
        row = executar(
            "DELETE FROM cliente WHERE id_cliente = %s RETURNING *",
            (id,),
            um=True,
        )
        if not row:
            return jsonify(erro="Cliente não encontrado."), 404
        return jsonify(mensagem="Cliente removido com sucesso.", cliente=row)
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


# ── PRODUTOS ──────────────────────────────────────────────────────────────

@app.get("/api/produtos")
def listar_produtos():
    try:
        return jsonify(executar("SELECT * FROM produto ORDER BY id_produto DESC"))
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.post("/api/produtos")
def criar_produto():
    d = corpo_json()
    try:
        row = executar(
            """INSERT INTO produto
               (id_categoria, nome, descricao, preco, custo, codigo_produto,
                estoque_disponivel, estoque_minimo, ativo)
               VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) RETURNING *""",
            (
                d.get("id_categoria") or None,
                d.get("nome"),
                d.get("descricao") or None,
                d.get("preco"),
                d.get("custo") or None,
                d.get("codigo_produto") or None,
                d.get("estoque_disponivel", 0),
                d.get("estoque_minimo", 0),
                d.get("ativo", True),
            ),
            um=True,
        )
        return jsonify(row), 201
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.put("/api/produtos/<int:id>")
def atualizar_produto(id):
    d = corpo_json()
    try:
        row = executar(
            """UPDATE produto
               SET id_categoria = %s, nome = %s, descricao = %s, preco = %s, custo = %s,
                   codigo_produto = %s, estoque_disponivel = %s, estoque_minimo = %s, ativo = %s
               WHERE id_produto = %s RETURNING *""",
            (
                d.get("id_categoria") or None,
                d.get("nome"),
                d.get("descricao") or None,
                d.get("preco"),
                d.get("custo") or None,
                d.get("codigo_produto") or None,
                d.get("estoque_disponivel", 0),
                d.get("estoque_minimo", 0),
                d.get("ativo", True),
                id,
            ),
            um=True,
        )
        if not row:
            return jsonify(erro="Produto não encontrado."), 404
        return jsonify(row)
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.delete("/api/produtos/<int:id>")
def excluir_produto(id):
    try:
        row = executar(
            "DELETE FROM produto WHERE id_produto = %s RETURNING *",
            (id,),
            um=True,
        )
        if not row:
            return jsonify(erro="Produto não encontrado."), 404
        return jsonify(mensagem="Produto removido com sucesso.", produto=row)
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


# ── VENDEDORES ──────────────────────────────────────────────────────────────

@app.get("/api/vendedores")
def listar_vendedores():
    try:
        return jsonify(executar("SELECT * FROM vendedor ORDER BY nome"))
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


# ── OPORTUNIDADES (CRM) ──────────────────────────────────────────────────────

@app.get("/api/oportunidades")
def listar_oportunidades():
    try:
        return jsonify(executar("""
            SELECT o.*, c.nome AS cliente_nome, v.nome AS vendedor_nome 
            FROM oportunidade o 
            JOIN cliente c ON o.id_cliente = c.id_cliente 
            JOIN vendedor v ON o.id_vendedor = v.id_vendedor 
            ORDER BY o.id_oportunidade DESC
        """))
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.post("/api/oportunidades")
def criar_oportunidade():
    d = corpo_json()
    try:
        row = executar(
            """INSERT INTO oportunidade 
               (id_cliente, id_vendedor, titulo, valor_estimado, etapa, motivo_perda, data_fechamento)
               VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING *""",
            (
                d.get("id_cliente"),
                d.get("id_vendedor"),
                d.get("titulo"),
                d.get("valor_estimado") or 0,
                d.get("etapa", "prospeccao"),
                d.get("motivo_perda") or None,
                d.get("data_fechamento") or None,
            ),
            um=True,
        )
        return jsonify(row), 201
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.put("/api/oportunidades/<int:id>")
def atualizar_oportunidade(id):
    d = corpo_json()
    try:
        row = executar(
            """UPDATE oportunidade
               SET id_cliente = %s, id_vendedor = %s, titulo = %s, valor_estimado = %s, 
                   etapa = %s, motivo_perda = %s, data_fechamento = %s
               WHERE id_oportunidade = %s RETURNING *""",
            (
                d.get("id_cliente"),
                d.get("id_vendedor"),
                d.get("titulo"),
                d.get("valor_estimado") or 0,
                d.get("etapa"),
                d.get("motivo_perda") or None,
                d.get("data_fechamento") or None,
                id,
            ),
            um=True,
        )
        if not row:
            return jsonify(erro="Oportunidade não encontrada."), 404
        return jsonify(row)
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.delete("/api/oportunidades/<int:id>")
def excluir_oportunidade(id):
    try:
        row = executar(
            "DELETE FROM oportunidade WHERE id_oportunidade = %s RETURNING *",
            (id,),
            um=True,
        )
        if not row:
            return jsonify(erro="Oportunidade não encontrada."), 404
        return jsonify(mensagem="Oportunidade removida com sucesso.", oportunidade=row)
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


# ── ATENDIMENTOS (CRM) ──────────────────────────────────────────────────────

@app.get("/api/atendimentos")
def listar_atendimentos():
    try:
        return jsonify(executar("""
            SELECT a.*, c.nome AS cliente_nome, v.nome AS vendedor_nome, o.titulo AS oportunidade_titulo 
            FROM atendimento a 
            JOIN cliente c ON a.id_cliente = c.id_cliente 
            JOIN vendedor v ON a.id_vendedor = v.id_vendedor 
            LEFT JOIN oportunidade o ON a.id_oportunidade = o.id_oportunidade 
            ORDER BY a.id_atendimento DESC
        """))
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.post("/api/atendimentos")
def criar_atendimento():
    d = corpo_json()
    try:
        row = executar(
            """INSERT INTO atendimento 
               (id_cliente, id_vendedor, id_oportunidade, tipo_contato, assunto, observacao, duracao_min)
               VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING *""",
            (
                d.get("id_cliente"),
                d.get("id_vendedor"),
                d.get("id_oportunidade") or None,
                d.get("tipo_contato"),
                d.get("assunto") or None,
                d.get("observacao") or None,
                d.get("duracao_min") or 0,
            ),
            um=True,
        )
        return jsonify(row), 201
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.put("/api/atendimentos/<int:id>")
def atualizar_atendimento(id):
    d = corpo_json()
    try:
        row = executar(
            """UPDATE atendimento
               SET id_cliente = %s, id_vendedor = %s, id_oportunidade = %s, 
                   tipo_contato = %s, assunto = %s, observacao = %s, duracao_min = %s
               WHERE id_atendimento = %s RETURNING *""",
            (
                d.get("id_cliente"),
                d.get("id_vendedor"),
                d.get("id_oportunidade") or None,
                d.get("tipo_contato"),
                d.get("assunto") or None,
                d.get("observacao") or None,
                d.get("duracao_min") or 0,
                id,
            ),
            um=True,
        )
        if not row:
            return jsonify(erro="Atendimento não encontrado."), 404
        return jsonify(row)
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.delete("/api/atendimentos/<int:id>")
def excluir_atendimento(id):
    try:
        row = executar(
            "DELETE FROM atendimento WHERE id_atendimento = %s RETURNING *",
            (id,),
            um=True,
        )
        if not row:
            return jsonify(erro="Atendimento não encontrado."), 404
        return jsonify(mensagem="Atendimento removido com sucesso.", atendimento=row)
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


# ── CLIENTE 360 (CRM DETAILS) ────────────────────────────────────────────────

@app.get("/api/clientes/<int:id>/detalhes")
def detalhes_cliente(id):
    try:
        # 1. Informações básicas do cliente
        cliente = executar("SELECT * FROM cliente WHERE id_cliente = %s", (id,), um=True)
        if not cliente:
            return jsonify(erro="Cliente não encontrado."), 404
            
        # 2. Endereços
        enderecos = executar("SELECT * FROM endereco WHERE id_cliente = %s ORDER BY id_endereco", (id,))
        
        # 3. Oportunidades com o nome do vendedor
        oportunidades = executar("""
            SELECT o.*, v.nome AS vendedor_nome 
            FROM oportunidade o 
            JOIN vendedor v ON o.id_vendedor = v.id_vendedor 
            WHERE o.id_cliente = %s 
            ORDER BY o.id_oportunidade DESC
        """, (id,))
        
        # 4. Atendimentos com o nome do vendedor e assunto da oportunidade
        atendimentos = executar("""
            SELECT a.*, v.nome AS vendedor_nome, o.titulo AS oportunidade_titulo 
            FROM atendimento a 
            JOIN vendedor v ON a.id_vendedor = v.id_vendedor 
            LEFT JOIN oportunidade o ON a.id_oportunidade = o.id_oportunidade
            WHERE a.id_cliente = %s 
            ORDER BY a.id_atendimento DESC
        """, (id,))
        
        # 5. Vendas realizadas com o nome do vendedor e o valor total calculado
        vendas = executar("""
            SELECT v.id_venda, v.data_venda, v.status, v.desconto, v.observacao, vd.nome AS vendedor_nome,
                   COALESCE(SUM((pv.quantidade * pv.valor_unitario) - pv.desconto_item), 0) AS valor_total
            FROM venda v 
            JOIN vendedor vd ON v.id_vendedor = vd.id_vendedor 
            LEFT JOIN produto_venda pv ON v.id_venda = pv.id_venda 
            WHERE v.id_cliente = %s 
            GROUP BY v.id_venda, vd.nome 
            ORDER BY v.data_venda DESC
        """, (id,))
        
        return jsonify(
            cliente=cliente,
            enderecos=enderecos,
            oportunidades=oportunidades,
            atendimentos=atendimentos,
            vendas=vendas
        )
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


# ── VIEWS ─────────────────────────────────────────────────────────────────


@app.get("/api/views/dashboard")
def view_dashboard():
    try:
        return jsonify(executar("SELECT * FROM vw_dashboard_vendas"))
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.get("/api/views/criticos")
def view_criticos():
    try:
        return jsonify(executar("SELECT * FROM vw_produtos_criticos"))
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


@app.get("/api/views/cliente360")
def view_cliente360():
    try:
        return jsonify(executar("SELECT * FROM vw_cliente_360"))
    except Exception as err:
        print(err)
        return jsonify(erro=str(err)), 500


# ── FRONTEND ──────────────────────────────────────────────────────────────

@app.get("/")
def pagina_inicial():
    return send_from_directory(BASE_DIR, "index.html")


if __name__ == "__main__":
    print("Servidor rodando em http://localhost:3000")
    app.run(host="0.0.0.0", port=3000, debug=False)
