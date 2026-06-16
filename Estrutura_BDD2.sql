-------------------------
-- Tabela de vendedores.
-------------------------

CREATE TABLE vendedor ( -- Cadastro de vendedores, que irá realizar as vendas e movimentações de estoque. 
    id_vendedor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL, 
    email VARCHAR(100) UNIQUE NOT NULL, 
    telefone VARCHAR(20) );
 
------------------------
-- Tabelas de clientes. 
------------------------

CREATE TABLE cliente ( -- Cadastro de clientes, que irá realizar as compras e receber os atendimentos.
     id_cliente SERIAL PRIMARY KEY, 
     nome VARCHAR(150) NOT NULL, 
     cpf_cnpj VARCHAR(18) UNIQUE NOT NULL, 
     email VARCHAR(100), 
     telefone VARCHAR(20), 
     data_nascimento DATE ); 

-----------------------
-- Tabela de endereco.
-----------------------

CREATE TABLE endereco ( 
    id_endereco SERIAL PRIMARY KEY, 
    id_cliente INTEGER NOT NULL REFERENCES cliente(id_cliente) ON DELETE CASCADE, -- public é o nome do schema, cliente é a tabela e id_cliente é a coluna que referencia a chave primaria da tabela cliente, ON DELETE CASCADE significa que se um cliente for deletado, os endereços relacionados a ele também serão deletados automaticamente
    rua VARCHAR(150) NOT NULL, 
    numero VARCHAR(10), 
    complemento VARCHAR(60), 
    bairro VARCHAR(100), 
    cidade VARCHAR(100) NOT NULL, 
    estado CHAR(2) NOT NULL, 
    cep VARCHAR(10) NOT NULL ); 

------------------------
-- Tabela de categorias
------------------------

CREATE TABLE categoria ( 
    id_categoria SERIAL PRIMARY KEY, 
    nome VARCHAR(80) NOT NULL UNIQUE ); -- Nome da categoria do produto, só pode haver uma categoria com o mesmo nome.

-----------------------
-- Tabela de produtos.
-----------------------

CREATE TABLE produto ( 
    id_produto SERIAL PRIMARY KEY, 
    id_categoria INTEGER REFERENCES categoria(id_categoria) ON DELETE SET NULL, -- define a categoria do produto, ao ser deletado a categoria do produto é setada como NULL, isso é útil para manter o histórico de vendas e movimentações relacionadas ao produto mesmo que a categoria seja removida do sistema.
    nome VARCHAR(100) NOT NULL, -- Nome do produto.
    descricao TEXT, -- Descriçao do produto, nao é obrigatoria.
    preco NUMERIC(12,2) NOT NULL CHECK (preco >= 0), -- O CHECK restringe os valores para que nao possam aver preços negativos.
    custo NUMERIC(12,2) CHECK (custo >= 0), -- da mesma forma, o custo do produto nao pode ser negativo.
    codigo_produto VARCHAR(50) UNIQUE, -- tambem conhecido como SKU, ele ajuda a identificar o produto adicionando referencia a ele, como por exemplo: "CAMISA-PRETA-G" ou "CELULAR-XYZ-128GB"
    estoque_disponivel INTEGER NOT NULL DEFAULT 0 CHECK (estoque_disponivel >= 0), -- CHECK garante que o estoque disponivel nunca seja negativo.
    estoque_minimo INTEGER NOT NULL DEFAULT 0 CHECK (estoque_minimo >= 0), -- O CHECK garante que o estoque minimo nunca seja negativo.
    ativo BOOLEAN NOT NULL DEFAULT TRUE ); -- Esse campo serve para indicar se o produto está ativo ou inativo no sistema, isso é útil para controlar a disponibilidade do produto sem precisar deletá-lo do banco de dados, caso um produto seja descontinuado ou temporariamente indisponível, podemos simplesmente marcar como inativo, mantendo o histórico de vendas e movimentações relacionadas a ele.

-------------------------------------
--Tabela de movimentação de estoque.
-------------------------------------

CREATE TABLE movimentacao_estoque ( 
    id_movimentacao SERIAL PRIMARY KEY,
    id_produto INTEGER NOT NULL REFERENCES produto(id_produto),  -- Mostra qual produto foi movimentado.
    id_vendedor INTEGER REFERENCES vendedor(id_vendedor) ON DELETE SET NULL, -- Aqui é mostrado quem realizou a movimentaçao.
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('entrada', 'saida', 'ajuste', 'devolucao')), -- Aqui é definido qual foi o tipo de movimentaçao realizado.
    quantidade INTEGER NOT NULL ); 

-----------------------
-- Tabela de vendas.
-----------------------

CREATE TABLE venda ( 
    id_venda SERIAL PRIMARY KEY, 
    id_cliente INTEGER REFERENCES cliente(id_cliente) ON DELETE SET NULL,  -- Permite vendas sem um cliente específico, como vendas avulsas ou para clientes que ainda não estão cadastrados, o ON DELETE SET NULL garante que se um cliente for deletado, o campo id_cliente na tabela venda será setado como NULL.
    id_vendedor INTEGER NOT NULL REFERENCES vendedor(id_vendedor) ON DELETE RESTRICT, -- Registra quem realizou a venda, e o ON DELETE RESTRICT garante que um vendedor não possa ser deletado se ele tiver vendas associadas.
    data_venda DATE NOT NULL DEFAULT CURRENT_DATE, -- Aqui mostra a data em qe a venda foi efetuada, na hora de registrar a venda a data nao precisa ser informada, pois o DEFAULT CURRENT_DATE já preenche automaticamente com a data atual do sistema, isso facilita o processo de registro da venda e garante que a data seja sempre precisa. 
    status VARCHAR(20) NOT NULL DEFAULT 'concluida' CHECK (status IN ('orcamento', 'aguardando_pagamento', 'concluida', 'cancelada', 'devolvida')), -- Aqui é definido o status da venda, que pode ser 'orcamento' (quando a venda ainda está sendo negociada e não foi finalizada), 'aguardando_pagamento' (quando a venda foi concluída, mas o pagamento ainda não foi recebido), 'concluida' (quando a venda foi finalizada e o pagamento recebido), 'cancelada' (quando a venda foi cancelada antes de ser concluída) ou 'devolvida' (quando a venda foi concluída, mas o cliente solicitou a devolução do produto).
    desconto NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (desconto >= 0), observacao TEXT ); -- Aqui é possivel adicionar um desconto na hora da venda, o CHECK garante que o valor do desconto seja sempre positivo ou 0, se for 0 nao havera desconto.

-------------------------------
-- Tabela de venda do produto.
-------------------------------

CREATE TABLE produto_venda ( 
    id_produto_venda SERIAL PRIMARY KEY,
    id_venda INTEGER NOT NULL REFERENCES venda(id_venda) ON DELETE CASCADE, -- ON DELETE CASCADE serve para caso uma venda seja deletada, todos os itens relacionados a essa venda tambem sejam deletados automaticamente.
    id_produto INTEGER NOT NULL REFERENCES produto(id_produto) ON DELETE RESTRICT, -- ON DELETE RESTRICT garante que o item a venda nao possa ser deletado se tiver um produto associado.
    quantidade INTEGER NOT NULL CHECK (quantidade > 0), -- O CHECK obriga a quantidade de itens a venda ser sempre maior que . 
    valor_unitario NUMERIC(12,2) NOT NULL CHECK (valor_unitario >= 0), -- Impossibilita de um item ter um valor negativo com o CHECK.
    desconto_item NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (desconto_item >= 0) ); -- Impossibilita de um item ter um desconto negativo com o CHECK.

----------------------------------------------
-- Tabela de oportunidades (Funil de vendas).
----------------------------------------------

CREATE TABLE oportunidade ( -- Oportunidade de venda, ou seja, um potencial negócio que ainda não foi fechado, mas que tem o potencial de se tornar uma venda no futuro.
    id_oportunidade SERIAL PRIMARY KEY, 
    id_cliente INTEGER NOT NULL REFERENCES cliente(id_cliente) ON DELETE CASCADE, -- É o id do cliente que pode vir a se tornar uma venda no futuro, o ON DELETE CASCADE garante que se um cliente for deletado, todas as oportunidades relacionadas a ele também sejam deletadas automaticamente.
    id_vendedor INTEGER NOT NULL REFERENCES vendedor(id_vendedor) ON DELETE RESTRICT, -- É o id do vendedor responsável por essa oportunidade, o ON DELETE RESTRICT garante que um vendedor não possa ser deletado se ele tiver oportunidades associadas.
    titulo VARCHAR(150) NOT NULL, -- Uma brece descriçao da oportunidade.
    valor_estimado NUMERIC(12,2) CHECK (valor_estimado >= 0), -- Nao pode ser negativo.
    etapa VARCHAR(30) NOT NULL DEFAULT 'prospeccao' CHECK (etapa IN ('prospeccao', 'qualificacao', 'proposta', 'negociacao', 'fechado_ganho', 'fechado_perdido')), -- Define em qual etapa do funil de vendas esta a oportunidade. (na etapa de prospecção é onde esta o LEAD, onde o cliente se torna um potencial comprador.)
    motivo_perda TEXT, -- Motivo pelo qual a oportunidade foi perdida.
    data_fechamento DATE ); -- Data estimada para o fechamento da oportunidade, dando margem para o planejamento das ações de vendas e acompanhamento do progresso da oportunidade ao longo do tempo.

--------------------------------------------
-- Tabela de atendimento (Funil de vendas).
--------------------------------------------

CREATE TABLE atendimento ( 
    id_atendimento SERIAL PRIMARY KEY, -- ID do atendimento gerado automaticamente pelo banco de dados.
    id_cliente INTEGER NOT NULL REFERENCES cliente(id_cliente) ON DELETE CASCADE, -- ID di cliente que recebe o atendimento.
    id_vendedor INTEGER NOT NULL REFERENCES vendedor(id_vendedor) ON DELETE RESTRICT, -- ID do vendedor que realizou o atendimento.
    id_oportunidade INTEGER REFERENCES oportunidade(id_oportunidade) ON DELETE SET NULL, -- ID da oportunidade relacionada ao atendimento.
    tipo_contato VARCHAR(30) NOT NULL CHECK (tipo_contato IN ('ligacao', 'email', 'whatsapp', 'presencial', 'outro')), -- Tipo de contato realizado.
    assunto VARCHAR(150), -- Assunto tratado no atendimento.
    observacao TEXT, 
    duracao_min INTEGER CHECK (duracao_min >= 0) ); -- Duraçao do atendimento em minutos, nao pode ser negativa.

------------------------
-- Tabela de pagamento.
------------------------

CREATE TABLE pagamento (
    id_pagamento SERIAL PRIMARY KEY, -- ID do pagamento gerado automaticamente pelo banco de dados.
    id_venda INTEGER NOT NULL REFERENCES venda(id_venda) ON DELETE CASCADE, -- ID da venda relacionada ao pagamento.
    valor NUMERIC(12,2) NOT NULL CHECK (valor >= 0), -- Valor pago, nao pode ser negativo.
    data_pagamento DATE NOT NULL, -- Data em que o pagamento foi realizado.
    forma_pagamento VARCHAR(30) NOT NULL CHECK (forma_pagamento IN ('cartao_credito', 'cartao_debito', 'pix', 'boleto', 'outro')), -- forma de pagamento.
    observacao TEXT, -- Observações sobre o pagamento.
    id_vendedor INTEGER REFERENCES vendedor(id_vendedor) ON DELETE SET NULL ); -- ID do vendedor responsável pelo pagamento.

 
-----------------------------------
-- Povoamento
-----------------------------------

------------------------
-- Vendedores
------------------------

INSERT INTO vendedor (nome, email, telefone) VALUES
('João Silva', 'Joaosilva@gmail.com', '11999999999'),
('Maria Souza', 'mariasouza@gmail.com', '11888888888'),
('Pedro Santos', 'pedrosantos@gmail.com', '11777777777'),
('Ana Costa', 'anacosta@gmail.com', '11666666666');

------------------------
-- Clientes
------------------------ 

INSERT INTO cliente (nome, cpf_cnpj, email, telefone, data_nascimento) VALUES
('Carlos Oliveira', '123.456.789-00', 'carlosovileira@gmail.com', '11977777777', '1985-05-15'),
('Fernanda Lima', '987.654.321-00', 'fernandalima@gmail.com', '11888888888', '1990-12-10'),
('Ricardo Alves', '111.222.333-44', 'ricardoalves@gmail.com', '11555555555', '1988-08-20'),
('Mariana Pereira', '555.666.777-88', 'marianapereira@gmail.com', '11444444444', '1992-03-25'),
('Lucas Fernandes', '999.888.777-66', 'lucasfernandes@gmail.com', '11333333333', '1987-07-15'),
('Sofia Rodrigues', '444.555.666-77', 'sofiarodrigues@gmail.com', '11222222222', '1995-11-30'),
('Gustavo Martins', '222.333.444-55', 'gustavomartins@gmail.com', '11111111111', '1989-09-09'),
('Isabela Costa', '777.888.999-00', 'isabelacosta@gmail.com', '11000000000', '1993-06-20'),
('Felipe Almeida', '333.444.555-66', 'felipealmeida@gmail.com', '11999999999', '1990-01-15'),
('Larissa Santos', '666.777.888-99', 'larissasantos@gmail.com', '11888888888', '1992-09-10');

------------------------
-- Endereços
------------------------

INSERT INTO endereco (id_cliente, rua, numero, complemento, bairro, cidade, estado, cep) VALUES
(1, 'Rua das Flores', '123', 'Apto 101', 'Jardim Primavera', 'São Paulo', 'SP', '01234-567'),
(2, 'Avenida Central', '456', NULL, 'Centro', 'Rio de Janeiro', 'RJ', '12345-678'),
(3, 'Rua do Comércio', '789', 'Sala 202', 'Centro', 'Belo Horizonte', 'MG', '34567-890'),
(4, 'Praça da Liberdade', '101', NULL, 'Liberdade', 'Salvador', 'BA', '45678-901'),
(5, 'Travessa das Flores', '202', 'Apto 303', 'Jardim das Flores', 'Curitiba', 'PR', '56789-012'),
(6, 'Rua dos Pinheiros', '303', NULL, 'Pinheiros', 'Porto Alegre', 'RS', '67890-123'),
(7, 'Avenida dos Estados', '404', 'Sala 404', 'Centro', 'Fortaleza', 'CE', '78901-234'),
(8, 'Rua do Sol', '505', NULL, 'Sol Nascente', 'Recife', 'PE', '89012-345'),
(9, 'Praça da Paz', '606', NULL, 'Paz e Amor', 'Manaus', 'AM', '90123-456'),
(10, 'Avenida das Estrelas', '707', NULL, 'Estrelas Brilhantes', 'Brasília', 'DF', '01234-567');

------------------------
-- Categorias
------------------------

INSERT INTO categoria (nome) VALUES
('Eletrônicos'),
('Roupas'),
('Alimentos'),
('Livros'),
('Móveis');

------------------------
-- Produtos
------------------------

INSERT INTO produto (id_categoria, nome, descricao, preco, custo, codigo_produto, estoque_disponivel, estoque_minimo, ativo) VALUES
(1, 'Smartphone XYZ', 'Smartphone com 128GB de armazenamento e câmera de alta resolução.', 1999.99, 1500.00, 'CELULAR-XYZ-128GB', 50, 10, TRUE),
(2, 'Camisa Polo', 'Camisa polo de algodão de alta qualidade.', 79.90, 40.00, 'CAMISA-POLO-G', 100, 20, TRUE),
(3, 'Chocolate Amargo', 'Chocolate amargo com 70% cacau.', 15.50, 8.00, 'CHOCOLATE-AMARGO-70', 200, 30, TRUE),
(4, 'Livro de Ficção', 'Livro de ficção científica best-seller.', 39.90, 20.00, 'LIVRO-FICCAO-001', 150, 25, TRUE),
(5, 'Sofá de Couro', 'Sofá de couro legítimo para sala de estar.', 2999.99, 2500.00, 'SOFA-COURO-001', 20, 5, TRUE),
(1, 'Notebook ABC', 'Notebook com processador i7 e 16GB de RAM.', 3499.99, 3000.00, 'NOTEBOOK-ABC-I7', 30, 5, TRUE),
(2, 'Calça Jeans', 'Calça jeans masculina de alta qualidade.', 129.90, 60.00, 'CALCA-JEANS-42', 80, 15, TRUE),
(3, 'Café Gourmet', 'Café gourmet em grãos com sabor intenso.', 25.00, 12.00, 'CAFE-GOURMET-500G', 150, 20, TRUE),
(4, 'Livro de Autoajuda', 'Livro de autoajuda para desenvolvimento pessoal.', 29.90, 15.00, 'LIVRO-AUTOAJUDA-001', 120, 20, TRUE),
(5, 'Mesa de Jantar', 'Mesa de jantar para seis pessoas em madeira maciça.', 1999.99, 1500.00, 'MESA-JANTAR-001', 10, 2, TRUE),
(1, 'Fone de Ouvido Bluetooth', 'Fone de ouvido sem fio com cancelamento de ruído.', 299.99, 200.00, 'FONE-BLUETOOTH-001', 40, 10, TRUE),
(2, 'Vestido Floral', 'Vestido floral feminino para ocasiões especiais.', 149.90, 80.00, 'VESTIDO-FLORAL-M', 60, 10, TRUE),
(3, 'Azeite Extra Virgem', 'Azeite extra virgem de alta qualidade.', 35.00, 18.00, 'AZEITE-EXTRA-VIRGEM-500ML', 100, 15, TRUE),
(4, 'Livro de Culinária', 'Livro de receitas culinárias para chefs amadores.', 49.90, 25.00, 'LIVRO-CULINARIA-001', 80, 15, TRUE),
(5, 'Cadeira de Escritório', 'Cadeira ergonômica para escritório com ajuste de altura.', 499.99, 350.00, 'CADEIRA-ESCRITORIO-001', 15, 3, TRUE),
(1, 'Tablet DEF', 'Tablet com tela de 10 polegadas e 64GB de armazenamento.', 1499.99, 1200.00, 'TABLET-DEF-10', 25, 5, TRUE),
(2, 'Jaqueta de Couro', 'Jaqueta de couro masculina para um estilo moderno.', 399.90, 200.00, 'JAQUETA-COURO-M', 30, 5, TRUE),
(3, 'Vinho Tinto Reserva', 'Vinho tinto reserva com sabor encorpado.', 120.00, 60.00, 'VINHO-RESERVA-750ML', 80, 10, TRUE),
(4, 'Livro de História', 'Livro de história mundial para estudantes.', 59.90, 30.00, 'LIVRO-HISTORIA-001', 100, 20, TRUE),
(5, 'Armário de Cozinha', 'Armário de cozinha em MDF com portas de vidro.', 2499.99, 2000.00, 'ARMARIO-COZINHA-001', 10, 2, TRUE),
(1, 'Smartwatch GHI', 'Smartwatch com monitoramento de saúde e notificações.', 499.99, 350.00, 'SMARTWATCH-GHI', 30, 5, TRUE),
(2, 'Saia Plissada', 'Saia plissada feminina para um look elegante.', 89.90, 40.00, 'SAIA-PLISSADA-P', 50, 10, TRUE),
(3, 'Mel Orgânico', 'Mel orgânico puro de alta qualidade.', 20.00, 10.00, 'MEL-ORGANICO-500G', 120, 20, TRUE),
(4, 'Livro de Romance', 'Livro de romance para amantes de histórias emocionantes.', 34.90, 18.00, 'LIVRO-ROMANCE-001', 90, 15, TRUE),
(5, 'Rack para TV', 'Rack para TV em madeira com design moderno.', 899.99, 700.00, 'RACK-TV-001', 8, 2, TRUE);

--------------------------
-- Indices 
--------------------------

-----------------------------
-- Indices da tabela produto.
-----------------------------

CREATE INDEX idx_produto_nome ON produto (nome); -- Indice que busca produtos pelo nome.
CREATE INDEX idx_produto_categoria ON produto (id_categoria); -- Indice que busca produtos por categoria.

----------------------------
-- Indices da tabela venda.
----------------------------

CREATE INDEX idx_venda_cliente ON venda (id_cliente); -- Indice que busca vendas por cliente.
CREATE INDEX idx_venda_vendedor ON venda (id_vendedor); -- Indice que busca vendas por vendedor.

-----------------------------------
-- Indices da tabela produto_venda.
-----------------------------------

CREATE INDEX idx_produto_venda_venda ON produto_venda (id_venda); -- Indice que busca itens de venda por id_venda.
CREATE INDEX idx_produto_venda_produto ON produto_venda (id_produto); -- Indice que busca itens de venda por id_produto.

-----------------------------
-- Indices da tabela oportunidade.
-----------------------------

CREATE INDEX idx_oportunidade_cliente ON oportunidade (id_cliente); -- Indice que busca oportunidades por cliente.
CREATE INDEX idx_oportunidade_vendedor ON oportunidade (id_vendedor); -- Indice que busca oportunidades por vendedor.

------------------------------
-- Indices da tabela atendimento.
------------------------------
CREATE INDEX idx_atendimento_cliente ON atendimento (id_cliente); -- Indice que busca atendimentos por cliente.
CREATE INDEX idx_atendimento_vendedor ON atendimento (id_vendedor); -- Indice que busca atendimentos por vendedor.
CREATE INDEX idx_atendimento_oportunidade ON atendimento (id_oportunidade); -- Indice que busca atendimentos por oportunidade.

------------------------------
-- Indices da tabela pagamento.
-------------------------------

CREATE INDEX idx_pagamento_venda ON pagamento (id_venda); -- Indice que busca pagamentos por venda.
CREATE INDEX idx_pagamento_vendedor ON pagamento (id_vendedor); -- Indice que busca pagamentos por vendedor.


-------------------------------------------
-- Consultas baseadas em regra de negócio.
-------------------------------------------

----------------------------------------------------------------------------------
-- 1. Quais oportunidades (leads) ainda nao tiveram nenhum atendimento realizado?
----------------------------------------------------------------------------------
SELECT o.id_oportunidade, o.titulo, c.nome AS cliente
FROM oportunidade o
LEFT JOIN atendimento a ON o.id_oportunidade = a.id_oportunidade
JOIN cliente c ON o.id_cliente = c.id_cliente
WHERE a.id_atendimento IS NULL;

----------------------------------------------------------------------------------
-- 2. Quais clientes realizaram compras, mas nao passaram pelo funil de vendas?
----------------------------------------------------------------------------------
SELECT c.id_cliente, c.nome, c.email
FROM cliente c
JOIN venda v ON c.id_cliente = v.id_cliente
LEFT JOIN oportunidade o ON c.id_cliente = o.id_cliente
WHERE o.id_oportunidade IS NULL;

----------------------------------------------------------------------------------
-- 3. Quais produtos estao com o estoque abaixo do nivel minimo de reposicao?
----------------------------------------------------------------------------------

SELECT nome, estoque_disponivel, estoque_minimo
FROM produto
WHERE estoque_disponivel < estoque_minimo 
AND ativo = TRUE;

-----------------------------------------------------------------------------------
-- 4. Qual é o valor total de vendas por vendedor?
-----------------------------------------------------------------------------------
SELECT v.nome AS vendedor, SUM(pv.quantidade * pv.valor_unitario) AS total_vendido
FROM vendedor v
INNER JOIN venda ven ON v.id_vendedor = ven.id_vendedor
INNER JOIN produto_venda pv ON ven.id_venda = pv.id_venda
WHERE ven.status = 'concluida'
GROUP BY v.nome
ORDER BY total_vendido DESC;

---------------------------------------------------------------------------------------
-- 5. Eficiencia do Funil de Vendas - quantos potenciais clientes efetuaram uma compra  
---------------------------------------------------------------------------------------

SELECT 
    COUNT(CASE WHEN etapa = 'fechado_ganho' THEN 1 END) * 100.0 / COUNT(*) AS taxa_conversao_percentual
FROM oportunidade;

---------------------------------------------------------------------------------------------------
-- 6. Clientes com Oportunidade Perdida - quais clientes que nao fecharam a venda.
---------------------------------------------------------------------------------------------------
SELECT c.id_cliente, c.nome, c.email
FROM cliente c
JOIN oportunidade o ON c.id_cliente = o.id_cliente
WHERE o.etapa = 'fechado_perdido';

----------------------------------------------------------------------------------------
-- 7. Qual é o faturamento total por cada forma de pagamento?
----------------------------------------------------------------------------------------
SELECT forma_pagamento, SUM(valor) AS faturamento_total
FROM pagamento
GROUP BY forma_pagamento
ORDER BY faturamento_total DESC;

---------------------------------------------------------------------------------------------------
-- 8. Qual é a taxa de conversao do funil de vendas? - Quantos clientes fecharam.
---------------------------------------------------------------------------------------------------
SELECT 
    (COUNT(CASE WHEN etapa = 'fechado_ganho' THEN 1 END)::NUMERIC / NULLIF(COUNT(*), 0)) * 100 AS taxa_conversao_percentual
FROM oportunidade;
