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
('Ana Costa', 'anacosta@gmail.com', '11666666666'),
('Lucas Oliveira', 'lucasoliveira@gmail.com', '11555555555'),
('Fernanda Lima', 'fernandalima@gmail.com', '11444444444'),
('Ricardo Alves', 'ricardoalves@gmail.com', '11333333333'),
('Mariana Pereira', 'marianapereira@gmail.com', '11222222222'),
('Sofia Rodrigues', 'sofiarodrigues@gmail.com', '11111111111'),
('Gustavo Martins', 'gustavomartins@gmail.com', '11000000000');


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
('Móveis'),
('Beleza'),
('Esportes'),
('Brinquedos'),
('Automotivo'),
('Saúde');

------------------------
-- Produtos
------------------------

INSERT INTO produto (id_categoria, nome, descricao, preco, custo, codigo_produto, estoque_disponivel, estoque_minimo, ativo) VALUES
(1, 'Smartphone XYZ', 'Smartphone com tela de 6.5 polegadas, 128GB de armazenamento e câmera de 48MP.', 1999.99, 1500.00, 'CELULAR-XYZ-128GB', 50, 10, TRUE),
(2, 'Camisa Polo', 'Camisa polo masculina em algodão, disponível em várias cores e tamanhos.', 79.90, 40.00, 'CAMISA-POLO-MASCULINA', 200, 50, TRUE),
(3, 'Chocolate Premium', 'Chocolate premium com 70% de cacau, embalagem de 100g.', 15.50, 8.00, 'CHOCOLATE-PREMIUM-70', 100, 20, TRUE),
(4, 'Livro "Aprendendo SQL"', 'Livro didático sobre SQL para iniciantes e profissionais.', 59.90, 30.00, 'LIVRO-APRENDENDO-SQL', 150, 30, TRUE),
(5, 'Sofá Retrátil', 'Sofá retrátil de três lugares com revestimento em tecido cinza.', 2999.99, 2000.00, 'SOFA-RETRATIL-3LUGARES', 20, 5, TRUE),
(6, 'Kit de Maquiagem', 'Kit completo de maquiagem com base, blush e sombras.', 149.90, 80.00, 'KIT-MAQUIAGEM-COMPLETO', 75, 15, TRUE),
(7, 'Bola de Futebol Oficial', 'Bola de futebol oficial da FIFA para jogos profissionais.', 249.99, 120.00, 'BOLA-FUTEBOL-OFICIAL', 30, 10, TRUE),
(8, 'Boneca Barbie Fashionista', 'Boneca Barbie da linha Fashionista com roupas estilosas.', 89.90, 45.00, 'BONECA-BARBIE-FASHIONISTA', 60, 20, TRUE),
(9, 'Capa para Celular Samsung Galaxy S21', 'Capa protetora para Samsung Galaxy S21 com design moderno.', 39.90, 15.00, 'CAPA-CELULAR-S21', 120, 25, TRUE),
(10,'Suplemento Vitamínico', 'Suplemento vitamínico com vitaminas e minerais essenciais para a saúde.', 79.90, 40.00, 'SUPLEMENTO-VITAMINICO', 80, 20, TRUE),
(1, 'Notebook ABC', 'Notebook com processador Intel i7, 16GB de RAM e 512GB de SSD.', 3999.99, 3000.00, 'NOTEBOOK-ABC-I7', 40, 10, TRUE),
(2, 'Calça Jeans Feminina', 'Calça jeans feminina com modelagem skinny e lavagem escura.', 129.90, 60.00, 'CALCA-JEANS-FEMININA', 150, 30, TRUE),
(3, 'Café Gourmet', 'Café gourmet em grãos com sabor intenso e aroma marcante.', 29.90, 15.00, 'CAFE-GOURMET-250G', 200, 40, TRUE),
(4, 'Livro "Python para Todos"', 'Livro introdutório sobre Python para iniciantes e programadores.', 49.90, 25.00, 'LIVRO-PYTHON-PARA-TODOS', 120, 25, TRUE),
(5, 'Mesa de Jantar', 'Mesa de jantar retangular com tampo de vidro e estrutura metálica.', 1999.99, 1500.00, 'MESA-JANTAR-VIDRO', 15, 5, TRUE),
(6, 'Perfume Masculino', 'Perfume masculino com fragrância amadeirada e duradoura.', 199.90, 100.00, 'PERFUME-MASCULINO-AMADERADO', 50, 10, TRUE),
(7, 'Raquete de Tênis Profissional', 'Raquete de tênis profissional com tecnologia avançada para melhor desempenho.', 499.99, 250.00, 'RAQUETE-TENIS-PROFISSIONAL', 25, 5, TRUE),
(8, 'Jogo de Construção LEGO', 'Jogo de construção LEGO com peças coloridas para estimular a criatividade.', 149.90, 80.00, 'LEGO-JOGO-CONSTRUCAO', 100, 20, TRUE),
(9, 'Fone de Ouvido Bluetooth', 'Fone de ouvido Bluetooth com cancelamento de ruído e bateria de longa duração.', 299.90, 150.00, 'FONE-OUVIDO-BLUETOOTH', 40, 10, TRUE),
(10,'Máscara Facial Hidratante', 'Máscara facial hidratante com ingredientes naturais para pele seca.', 49.90, 20.00, 'MASCARA-FACIAL-HIDRATANTE', 70, 15, TRUE);

----------------------------
-- Movimentações de estoque
----------------------------

INSERT INTO movimentacao_estoque (id_produto, id_vendedor, tipo, quantidade) VALUES
(1, 1, 'entrada', 50),
(2, 2, 'entrada', 200),
(3, 3, 'entrada', 100),
(4, 4, 'entrada', 150),
(5, 5, 'entrada', 20),
(6, 6, 'entrada', 75),
(7, 7, 'entrada', 30),
(8, 8, 'entrada', 60),
(9, 9, 'entrada', 120),
(10,10,'entrada', 80),
(1, 1, 'saida', 5),
(2, 2, 'saida', 10),
(3, 3, 'saida', 15),
(4, 4, 'saida', 20),
(5, 5, 'saida', 2),
(6, 6, 'saida', 8),
(7, 7, 'saida', 3),
(8, 8, 'saida', 6),
(9, 9, 'saida', 12),
(10,10,'saida', 4),
(1, 1, 'ajuste', 2),
(2, 2, 'ajuste', 5),
(3, 3, 'ajuste', 3),
(4, 4, 'ajuste', 4),
(5, 5, 'ajuste', 1),
(6, 6, 'ajuste', 2),
(7, 7, 'ajuste', 1),
(8, 8, 'ajuste', 2),
(9, 9, 'ajuste', 3),
(10,10,'ajuste', 1),
(1, 1, 'devolucao', 1),
(2, 2, 'devolucao', 2),
(3, 3, 'devolucao', 1),
(4, 4, 'devolucao', 2),
(5, 5, 'devolucao', 1),
(6, 6, 'devolucao', 1),
(7, 7, 'devolucao', 1),
(8, 8, 'devolucao', 1),
(9, 9, 'devolucao', 2),
(10,10,'devolucao', 1);

----------
-- vendas
----------

INSERT INTO venda (id_cliente, id_vendedor, data_venda, status, desconto, observacao) VALUES
(1, 1, '2024-01-10', 'concluida', 0, 'Venda realizada com sucesso.'),
(2, 2, '2024-01-15', 'concluida', 10, 'Cliente solicitou desconto de 10 reais.'),
(3, 3, '2024-01-20', 'aguardando_pagamento', 0, 'Venda pendente de pagamento.'),
(4, 4, '2024-01-25', 'orcamento', 0, 'Venda em fase de orçamento.'),
(5, 5, '2024-02-01', 'concluida', 5, 'Desconto aplicado conforme negociação.'),
(6, 6, '2024-02-05', 'cancelada', 0, 'Venda cancelada pelo cliente.'),
(7, 7, '2024-02-10', 'devolvida', 0, 'Produto devolvido pelo cliente.'),
(8, 8, '2024-02-15', 'concluida', 0, 'Venda concluída sem observações.'),
(9, 9, '2024-02-20', 'aguardando_pagamento', 0, 'Pagamento ainda não confirmado.'),
(10,10,'2024-02-25','concluida', 15,'Desconto especial aplicado.');

-------------------------------------
-- Produtos vendidos (produto_venda)
-------------------------------------

INSERT INTO produto_venda (id_venda, id_produto, quantidade, valor_unitario, desconto_item) VALUES
(1, 1, 2, 1999.99, 0),
(1, 2, 1, 79.90, 0),
(2, 3, 5, 15.50, 0),
(2, 4, 2, 59.90, 0),
(3, 5, 1, 2999.99, 0),
(3, 6, 3, 149.90, 0),
(4, 7, 4, 249.99, 0),
(4, 8, 2, 89.90, 0),
(5, 9, 1, 39.90, 0),
(5,10 ,2 ,79.90 ,0 ),
(6 ,1 ,1 ,1999.99 ,0 ),
(6 ,2 ,2 ,79.90 ,0 ),
(7 ,3 ,3 ,15.50 ,0 ),
(7 ,4 ,1 ,59.90 ,0 ),
(8 ,5 ,2 ,2999.99 ,0 ),
(8 ,6 ,1 ,149.90 ,0 ),
(9 ,7 ,5 ,249.99 ,0 ),
(9 ,8 ,3 ,89.90 ,0 ),
(10 ,9 ,2 ,39.90 ,0 ),
(10 ,10 ,1 ,79.90 ,0 );

-----------------
-- Oportunidades
-----------------

INSERT INTO oportunidade (id_cliente, id_vendedor, titulo, valor_estimado, etapa, motivo_perda, data_fechamento) VALUES
(1, 1, 'Oportunidade de venda de Smartphone', 1999.99, 'prospeccao', NULL, NULL),
(2, 2, 'Oportunidade de venda de Camisa Polo', 79.90, 'qualificacao', NULL, NULL),
(3, 3, 'Oportunidade de venda de Chocolate Premium', 15.50, 'proposta', NULL, NULL),
(4, 4, 'Oportunidade de venda de Livro "Aprendendo SQL"', 59.90, 'negociacao', NULL, NULL),
(5, 5, 'Oportunidade de venda de Sofá Retrátil', 2999.99, 'fechado_ganho', NULL, '2024-02-01'),
(6, 6, 'Oportunidade de venda de Kit de Maquiagem', 149.90, 'fechado_perdido', 'Cliente não demonstrou interesse.', '2024-02-05'),
(7, 7, 'Oportunidade de venda de Bola de Futebol Oficial', 249.99, 'prospeccao', NULL, NULL),
(8, 8, 'Oportunidade de venda de Boneca Barbie Fashionista', 89.90, 'qualificacao', NULL, NULL),
(9, 9, 'Oportunidade de venda de Capa para Celular Samsung Galaxy S21', 39.90, 'proposta', NULL, NULL),
(10 ,10 ,'Oportunidade de venda de Suplemento Vitamínico' ,79.90 ,'negociacao' ,NULL ,NULL );

-----------------
-- Atendimentos
-----------------

INSERT INTO atendimento (id_cliente, id_vendedor, id_oportunidade, tipo_contato, assunto, observacao, duracao_min) VALUES
(1, 1, 1, 'ligacao', 'Informações sobre o Smartphone', 'Cliente interessado em detalhes do produto.', 15),
(2, 2, 2, 'email', 'Dúvidas sobre a Camisa Polo', 'Cliente solicitou informações sobre tamanhos disponíveis.', 10),
(3, 3, 3, 'whatsapp', 'Pedido de orçamento do Chocolate Premium', 'Cliente pediu orçamento para compra em grande quantidade.', 5),
(4, 4, 4, 'presencial', 'Apresentação do Livro "Aprendendo SQL"', 'Cliente visitou a loja para conhecer o livro.', 30),
(5, 5, 5, 'ligacao', 'Confirmação da compra do Sofá Retrátil', 'Cliente confirmou a compra e agendou entrega.', 20),
(6, 6, 6, 'email', 'Feedback sobre o Kit de Maquiagem', 'Cliente enviou feedback negativo sobre o produto.', 10),
(7, 7, 7, 'whatsapp', 'Informações sobre a Bola de Futebol Oficial', 'Cliente solicitou detalhes sobre o produto.', 8),
(8, 8, 8, 'presencial', 'Demonstração da Boneca Barbie Fashionista', 'Cliente visitou a loja para ver o produto.', 25),
(9, 9, 9, 'ligacao', 'Esclarecimento sobre a Capa para Celular Samsung Galaxy S21', 'Cliente pediu informações sobre compatibilidade.', 12),
(10 ,10 ,'10' ,'email' ,'Solicitação de informações sobre o Suplemento Vitamínico' ,'Cliente quer saber os benefícios do suplemento.' ,15 );

--------------
-- Pagamentos
--------------

INSERT INTO pagamento (id_venda, valor, data_pagamento, forma_pagamento, observacao, id_vendedor) VALUES
(1, 4079.88, '2024-01-10', 'cartao_credito', 'Pagamento realizado com sucesso.', 1),
(2, 129.90, '2024-01-15', 'pix', 'Pagamento confirmado via PIX.', 2),
(3, 2999.99, '2024-01-16', 'pix', 'Aguardando pagamento do cliente.', 3),
(4, 0.00, '2024-01-16', 'pix', 'Venda em fase de orçamento.', 4),
(5, 79.80, '2024-02-01', 'boleto', 'Pagamento realizado via boleto bancário.', 5),
(6, 0.00, '2024-02-15', 'pix', 'Venda cancelada pelo cliente.', 6),
(7, 249.99, '2024-02-10', 'cartao_debito', 'Produto devolvido e estornado.', 7),
(8, 2999.99, '2024-02-15', 'cartao_credito', 'Pagamento realizado com sucesso.', 8),
(9, 0.00, '2024-06-18', 'pix', 'Aguardando confirmação de pagamento.', 9),
(10 ,64.90 ,'2024-02-25' ,'pix' ,'Pagamento realizado com desconto especial.' ,10 );



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

---------
--Views
---------

-----------------------
-- Dashboard de vendas
-----------------------

CREATE VIEW vw_dashboard_vendas as
SELECT
    v.id_venda,
    c.nome AS cliente,
    vd.nome AS vendedor,
    v.data_venda,
    v.status,
    COALESCE(SUM(
        (pv.quantidade * pv.valor_unitario)
        - pv.desconto_item
    ),0) AS valor_total
FROM venda v
LEFT JOIN cliente c ON c.id_cliente = v.id_cliente
JOIN vendedor vd ON vd.id_vendedor = v.id_vendedor
LEFT JOIN produto_venda pv ON pv.id_venda = v.id_venda
GROUP BY
v.id_venda,
c.nome,
vd.nome,
v.data_venda,
v.status
order by valor_total DESC;

-------------------------
-- Ranking de vendedores
-------------------------

CREATE VIEW vw_ranking_vendedores AS
SELECT
    vd.id_vendedor,
    vd.nome AS vendedor,
    COUNT(DISTINCT v.id_venda) AS qtd_vendas,
    COALESCE(
        SUM(
            (pv.quantidade * pv.valor_unitario)
            - pv.desconto_item
        ),
        0
    ) AS valor_total_vendido
FROM vendedor vd
JOIN venda v
    ON vd.id_vendedor = v.id_vendedor
JOIN produto_venda pv
    ON v.id_venda = pv.id_venda
WHERE v.status = 'concluida'
GROUP BY
    vd.id_vendedor,
    vd.nome
ORDER BY valor_total_vendido DESC;

---------------------
-- Produtos críticos
---------------------

CREATE VIEW vw_produtos_criticos AS
SELECT
    id_produto,
    nome,
    estoque_disponivel,
    estoque_minimo
FROM produto
WHERE estoque_disponivel <= estoque_minimo;

-------------------
-- Cliente 360
-------------------

CREATE VIEW vw_cliente_360 AS
SELECT
    c.id_cliente,
    c.nome,
    COUNT(DISTINCT o.id_oportunidade) AS oportunidades,
    COUNT(DISTINCT a.id_atendimento) AS atendimentos,
    COUNT(DISTINCT v.id_venda) AS vendas
FROM cliente c
LEFT JOIN oportunidade o
    ON c.id_cliente = o.id_cliente
LEFT JOIN atendimento a
    ON c.id_cliente = a.id_cliente
LEFT JOIN venda v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome
order by vendas desc;

------------
--Functions
------------

-------------------
-- Total de vendas
-------------------

CREATE OR REPLACE FUNCTION fn_total_venda(
    p_id_venda INTEGER
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS
$$
DECLARE
    total NUMERIC;
BEGIN

    SELECT SUM(
        (quantidade * valor_unitario)
        - desconto_item
    )
    INTO total
    FROM produto_venda
    WHERE id_venda = p_id_venda;

    RETURN COALESCE(total,0);

END;
$$;

--chamar function
SELECT fn_total_venda(1);

--------------------------
-- Lucro total do estoque
--------------------------

CREATE OR REPLACE FUNCTION fn_lucro_total_estoque(
    p_produto INTEGER
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS
$$
DECLARE
    lucro NUMERIC;
BEGIN

    SELECT
        (preco - custo) * estoque_disponivel
    INTO lucro
    FROM produto
    WHERE id_produto = p_produto;

    RETURN COALESCE(lucro,0);

END;
$$;


--chamar function
SELECT fn_lucro_total_estoque(1);

------------------------
-- Total de atendimetos
------------------------

CREATE OR REPLACE FUNCTION fn_total_atendimentos_cliente(
    p_cliente INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS
$$
DECLARE
    total INTEGER;
BEGIN

    SELECT COUNT(*)
    INTO total
    FROM atendimento
    WHERE id_cliente = p_cliente;

    RETURN total;

END;
$$;

--chamar function
SELECT fn_total_atendimentos_cliente(1);


--------------
-- Procedures
--------------

---------------------------------------------------------
--Atualizar o estoque de um produto (Entrada de unidades)
---------------------------------------------------------

CREATE OR REPLACE PROCEDURE pr_atualizar_estoque(
    p_produto INTEGER,
    p_quantidade INTEGER
)
LANGUAGE plpgsql
AS
$$
BEGIN

    UPDATE produto
    SET estoque_disponivel =
        estoque_disponivel + p_quantidade
    WHERE id_produto = p_produto;

END;
$$;

--Rodar procedure
CALL pr_atualizar_estoque(1,-15);


---------------------------
-- Registro de atendimento
---------------------------

CREATE OR REPLACE PROCEDURE pr_registrar_atendimento(
    p_cliente INTEGER,
    p_vendedor INTEGER,
    p_oportunidade INTEGER,
    p_tipo_contato VARCHAR,
    p_assunto VARCHAR,
    p_observacao TEXT,
    p_duracao INTEGER
)
LANGUAGE plpgsql
AS
$$
BEGIN

    INSERT INTO atendimento(
        id_cliente,
        id_vendedor,
        id_oportunidade,
        tipo_contato,
        assunto,
        observacao,
        duracao_min
    )
    VALUES(
        p_cliente,
        p_vendedor,
        p_oportunidade,
        p_tipo_contato,
        p_assunto,
        p_observacao,
        p_duracao
    );

END;
$$;

--rodar procedure
CALL pr_registrar_atendimento(
    1,
    1,
    1,
    'whatsapp',
    'Contato pós-venda',
    'Cliente satisfeito com a compra',
    10
);

--------------------------------------------
-- REGISTRAR MOTIVO DA OPORTUNIDADE PERDIDA
--------------------------------------------

CREATE OR REPLACE PROCEDURE pr_fechar_oportunidade_perdida(
    p_oportunidade INTEGER,
    p_motivo TEXT
)
LANGUAGE plpgsql
AS
$$
BEGIN

    UPDATE oportunidade
    SET
        etapa = 'fechado_perdido',
        motivo_perda = p_motivo
    WHERE id_oportunidade = p_oportunidade;

END;
$$;


--Rodar procedure
CALL pr_fechar_oportunidade_perdida(
    2,
    'Cliente desistiu da compra'
);


------------
-- Triggers
------------

---------------------------------
-- Baixar estoque apos uma venda
---------------------------------

CREATE OR REPLACE FUNCTION fn_trigger_baixa_estoque()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
BEGIN

    UPDATE produto
    SET estoque_disponivel =
        estoque_disponivel - NEW.quantidade
    WHERE id_produto = NEW.id_produto;

    RETURN NEW;

END;
$$;


CREATE TRIGGER trg_baixa_estoque
AFTER INSERT ON produto_venda
FOR EACH ROW
EXECUTE FUNCTION fn_trigger_baixa_estoque();

---------------------------------------------
-- Valida se o estoque esta dentro do limite
---------------------------------------------

CREATE OR REPLACE FUNCTION fn_trigger_validar_estoque()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
    estoque_atual INTEGER;
BEGIN

    SELECT estoque_disponivel
    INTO estoque_atual
    FROM produto
    WHERE id_produto = NEW.id_produto;

    IF estoque_atual < NEW.quantidade THEN
        RAISE EXCEPTION
        'Estoque insuficiente para o produto %',
        NEW.id_produto;
    END IF;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_validar_estoque
BEFORE INSERT ON produto_venda
FOR EACH ROW
EXECUTE FUNCTION fn_trigger_validar_estoque();


---------------------------------------------
--Atualiza status de uma venda em aguardando
---------------------------------------------

CREATE OR REPLACE FUNCTION fn_trigger_pagamento_venda()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
BEGIN

    UPDATE venda
    SET status = 'concluida'
    WHERE id_venda = NEW.id_venda
    AND status = 'aguardando_pagamento';

    RETURN NEW;

END;
$$;


CREATE TRIGGER trg_pagamento_venda
AFTER INSERT ON pagamento
FOR EACH ROW
EXECUTE FUNCTION fn_trigger_pagamento_venda();
