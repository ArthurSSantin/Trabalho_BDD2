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


# ── FRONTEND ──────────────────────────────────────────────────────────────

@app.get("/")
def pagina_inicial():
    return send_from_directory(BASE_DIR, "index.html")


if __name__ == "__main__":
    print("Servidor rodando em http://localhost:3000")
    app.run(host="0.0.0.0", port=3000, debug=False)
