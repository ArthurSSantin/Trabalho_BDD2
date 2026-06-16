CREATE TABLE vendedor ( -- Cadastro de vendedores, que irá realizar as vendas e movimentações de estoque. 
    id_vendedor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL, 
    email VARCHAR(100) UNIQUE NOT NULL, 
    telefone VARCHAR(20) );
 

CREATE TABLE cliente ( -- Cadastro de clientes, que irá realizar as compras e receber os atendimentos.
     id_cliente SERIAL PRIMARY KEY, 
     nome VARCHAR(150) NOT NULL, 
     cpf_cnpj VARCHAR(18) UNIQUE NOT NULL, 
     email VARCHAR(100), 
     telefone VARCHAR(20), 
     data_nascimento DATE ); 

 

CREATE TABLE endereco ( 
    id_endereco SERIAL PRIMARY KEY, 
    id_cliente INTEGER NOT NULL REFERENCES public.cliente(id_cliente) ON DELETE CASCADE, -- public é o nome do schema, cliente é a tabela e id_cliente é a coluna que referencia a chave primaria da tabela cliente, ON DELETE CASCADE significa que se um cliente for deletado, os endereços relacionados a ele também serão deletados automaticamente
    rua VARCHAR(150) NOT NULL, 
    numero VARCHAR(10), 
    complemento VARCHAR(60), 
    bairro VARCHAR(100), 
    cidade VARCHAR(100) NOT NULL, 
    estado CHAR(2) NOT NULL, 
    cep VARCHAR(10) NOT NULL ); 

 

CREATE TABLE categoria ( 
    id_categoria SERIAL PRIMARY KEY, 
    nome VARCHAR(80) NOT NULL UNIQUE ); -- Nome da categoria do produto, só pode haver uma categoria com o mesmo nome.

 

CREATE TABLE produto ( 
    id_produto SERIAL PRIMARY KEY, 
    id_categoria INTEGER REFERENCES public.categoria(id_categoria) ON DELETE SET NULL, -- define a categoria do produto, ao ser deletado a categoria do produto é setada como NULL, isso é útil para manter o histórico de vendas e movimentações relacionadas ao produto mesmo que a categoria seja removida do sistema.
    nome VARCHAR(100) NOT NULL, -- Nome do produto.
    descricao TEXT, -- Descriçao do produto, nao é obrigatoria.
    preco NUMERIC(12,2) NOT NULL CHECK (preco >= 0), -- O CHECK restringe os valores para que nao possam aver preços negativos.
    custo NUMERIC(12,2) CHECK (custo >= 0), -- da mesma forma, o custo do produto nao pode ser negativo.
    codigo_produto VARCHAR(50) UNIQUE, -- tambem conhecido como SKU, ele ajuda a identificar o produto adicionando referencia a ele, como por exemplo: "CAMISA-PRETA-G" ou "CELULAR-XYZ-128GB"
    estoque_disponivel INTEGER NOT NULL DEFAULT 0 CHECK (estoque_disponivel >= 0), -- CHECK garante que o estoque disponivel nunca seja negativo.
    estoque_minimo INTEGER NOT NULL DEFAULT 0 CHECK (estoque_minimo >= 0), -- O CHECK garante que o estoque minimo nunca seja negativo.
    ativo BOOLEAN NOT NULL DEFAULT TRUE ); -- Esse campo serve para indicar se o produto está ativo ou inativo no sistema, isso é útil para controlar a disponibilidade do produto sem precisar deletá-lo do banco de dados, caso um produto seja descontinuado ou temporariamente indisponível, podemos simplesmente marcar como inativo, mantendo o histórico de vendas e movimentações relacionadas a ele.

 

CREATE TABLE movimentacao_estoque ( 
    id_movimentacao SERIAL PRIMARY KEY,
    id_produto INTEGER NOT NULL REFERENCES public.produto(id_produto),  -- Mostra qual produto foi movimentado.
    id_vendedor INTEGER REFERENCES public.vendedor(id_vendedor) ON DELETE SET NULL, -- Aqui é mostrado quem realizou a movimentaçao.
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('entrada', 'saida', 'ajuste', 'devolucao')), -- Aqui é definido qual foi o tipo de movimentaçao realizado.
    quantidade INTEGER NOT NULL ); 

CREATE TABLE venda ( 
    id_venda SERIAL PRIMARY KEY, 
    id_cliente INTEGER REFERENCES public.cliente(id_cliente) ON DELETE SET NULL,  -- Permite vendas sem um cliente específico, como vendas avulsas ou para clientes que ainda não estão cadastrados, o ON DELETE SET NULL garante que se um cliente for deletado, o campo id_cliente na tabela venda será setado como NULL.
    id_vendedor INTEGER NOT NULL REFERENCES public.vendedor(id_vendedor) ON DELETE RESTRICT, -- Registra quem realizou a venda, e o ON DELETE RESTRICT garante que um vendedor não possa ser deletado se ele tiver vendas associadas.
    data_venda DATE NOT NULL DEFAULT CURRENT_DATE, -- Aqui mostra a data em qe a venda foi efetuada, na hora de registrar a venda a data nao precisa ser informada, pois o DEFAULT CURRENT_DATE já preenche automaticamente com a data atual do sistema, isso facilita o processo de registro da venda e garante que a data seja sempre precisa. 
    status VARCHAR(20) NOT NULL DEFAULT 'concluida' CHECK (status IN ('orcamento', 'aguardando_pagamento', 'concluida', 'cancelada', 'devolvida')), -- Aqui é definido o status da venda, que pode ser 'orcamento' (quando a venda ainda está sendo negociada e não foi finalizada), 'aguardando_pagamento' (quando a venda foi concluída, mas o pagamento ainda não foi recebido), 'concluida' (quando a venda foi finalizada e o pagamento recebido), 'cancelada' (quando a venda foi cancelada antes de ser concluída) ou 'devolvida' (quando a venda foi concluída, mas o cliente solicitou a devolução do produto).
    desconto NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (desconto >= 0), observacao TEXT ); -- Aqui é possivel adicionar um desconto na hora da venda, o CHECK garante que o valor do desconto seja sempre positivo ou 0, se for 0 nao havera desconto.

 

CREATE TABLE item_venda ( 
    id_item SERIAL PRIMARY KEY,
    id_venda INTEGER NOT NULL REFERENCES public.venda(id_venda) ON DELETE CASCADE, -- ON DELETE CASCADE serve para caso uma venda seja deletada, todos os itens relacionados a essa venda tambem sejam deletados automaticamente.
    id_produto INTEGER NOT NULL REFERENCES public.produto(id_produto) ON DELETE RESTRICT, -- ON DELETE RESTRICT garante que o item a venda nao possa ser deletado se tiver um produto associado.
    quantidade INTEGER NOT NULL CHECK (quantidade > 0), -- O CHECK obriga a quantidade de itens a venda ser sempre maior que . 
    valor_unitario NUMERIC(12,2) NOT NULL CHECK (valor_unitario >= 0), -- Impossibilita de um item ter um valor negativo com o CHECK.
    desconto_item NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (desconto_item >= 0) ); -- Impossibilita de um item ter um desconto negativo com o CHECK.

 

CREATE TABLE oportunidade ( -- Oportunidade de venda, ou seja, um potencial negócio que ainda não foi fechado, mas que tem o potencial de se tornar uma venda no futuro.
    id_oportunidade SERIAL PRIMARY KEY, 
    id_cliente INTEGER NOT NULL REFERENCES public.cliente(id_cliente) ON DELETE CASCADE, -- É o id do cliente que pode vir a se tornar uma venda no futuro, o ON DELETE CASCADE garante que se um cliente for deletado, todas as oportunidades relacionadas a ele também sejam deletadas automaticamente.
    id_vendedor INTEGER NOT NULL REFERENCES public.vendedor(id_vendedor) ON DELETE RESTRICT, -- É o id do vendedor responsável por essa oportunidade, o ON DELETE RESTRICT garante que um vendedor não possa ser deletado se ele tiver oportunidades associadas.
    titulo VARCHAR(150) NOT NULL, -- Uma brece descriçao da oportunidade.
    valor_estimado NUMERIC(12,2) CHECK (valor_estimado >= 0), -- Nao pode ser negativo.
    etapa VARCHAR(30) NOT NULL DEFAULT 'prospeccao' CHECK (etapa IN ('prospeccao', 'qualificacao', 'proposta', 'negociacao', 'fechado_ganho', 'fechado_perdido')), -- Define em qual etapa do funil de vendas esta a oportunidade.
    motivo_perda TEXT, -- Motivo pelo qual a oportunidade foi perdida.
    data_fechamento DATE ); -- Data estimada para o fechamento da oportunidade, dando margem para o planejamento das ações de vendas e acompanhamento do progresso da oportunidade ao longo do tempo.

 

CREATE TABLE atendimento ( 
    id_atendimento SERIAL PRIMARY KEY, -- ID do atendimento gerado automaticamente pelo banco de dados.
    id_cliente INTEGER NOT NULL REFERENCES public.cliente(id_cliente) ON DELETE CASCADE, -- ID di cliente que recebe o atendimento.
    id_vendedor INTEGER NOT NULL REFERENCES public.vendedor(id_vendedor) ON DELETE RESTRICT, -- ID do vendedor que realizou o atendimento.
    id_oportunidade INTEGER REFERENCES public.oportunidade(id_oportunidade) ON DELETE SET NULL, -- ID da oportunidade relacionada ao atendimento.
    tipo_contato VARCHAR(30) NOT NULL CHECK (tipo_contato IN ('ligacao', 'email', 'whatsapp', 'presencial', 'outro')), -- Tipo de contato realizado.
    assunto VARCHAR(150), -- Assunto tratado no atendimento.
    observacao TEXT, 
    duracao_min INTEGER CHECK (duracao_min >= 0) ); -- Duraçao do atendimento em minutos, nao pode ser negativa.

CREATE TABLE pagamento (
    id_pagamento SERIAL PRIMARY KEY, -- ID do pagamento gerado automaticamente pelo banco de dados.
    id_venda INTEGER NOT NULL REFERENCES public.venda(id_venda) ON DELETE CASCADE, -- ID da venda relacionada ao pagamento.
    valor NUMERIC(12,2) NOT NULL CHECK (valor >= 0), -- Valor pago, nao pode ser negativo.
    data_pagamento DATE NOT NULL, -- Data em que o pagamento foi realizado.
    forma_pagamento VARCHAR(30) NOT NULL CHECK (forma_pagamento IN ('cartao_credito', 'cartao_debito', 'pix', 'boleto', 'outro')), -- forma de pagamento.
    observacao TEXT, -- Observações sobre o pagamento.
    id_vendedor INTEGER REFERENCES public.vendedor(id_vendedor) ON DELETE SET NULL ); -- ID do vendedor responsável pelo pagamento.

 

 
