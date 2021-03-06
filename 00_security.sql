-- =======================================
-- Script do pacote DER_CE_CORPORATIVO
-- ---------------------------------------
-- Host      : 172.25.144.14
-- Database  : der
-- Version   : PostgreSQL 8.3.4
-- =======================================

CREATE SCHEMA security AUTHORIZATION der;

-- =============================================================================
-- C R I A Ç Ã O   D A S   S E Q U E N C E
-- =============================================================================
CREATE SEQUENCE security.sq_modulos                    INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_modulos_rotinas            INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_elementos_modulo           INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_roles_x_elementos_modulo   INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_roles_x_modulos            INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_users_historicos           INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

CREATE SEQUENCE security.sq_profissionais_ti           INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_modulos_x_profissionais_ti INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_versoes_sistema            INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_versoes_modulos            INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_versoes_modulos_x_projetos INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
-- =============================================================================
-- C R I A Ç Ã O   D A S   T A B E L A S
-- =============================================================================
-- Tabelas para classificação de módulos
-- -----------------------------------------------------------------------------
CREATE TABLE security.status_acesso ( 
   id        integer      NOT NULL,
   sigla     varchar(3)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   tipo      VARCHAR(50)  NOT NULL,
   cor       varchar(8)   NOT NULL,
   icone     varchar(50)   NOT NULL
);

CREATE TABLE security.area_atuacao ( 
   id        integer      NOT NULL,
   sigla     varchar(3)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL
);

CREATE TABLE security.fase_desenvolvimento ( 
   id        integer      NOT NULL,
   sigla     varchar(3)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL
);

-- Tabela de agente do sistema
CREATE TABLE security.agente_sistema ( 
   id              integer      NOT NULL,   
   sigla           varchar(10)  NOT NULL,
   nome            varchar(100) NOT NULL,
   descricao       varchar(255) NOT NULL
);

CREATE TABLE security.modulos ( 
   id             integer NOT NULL DEFAULT 
                  nextval('security.sq_modulos'),
   codigo_modulo  varchar(3)   NOT NULL,
   nome           varchar(150) NOT NULL,
   sigla          varchar(15)  NOT NULL,
   descricao      varchar(500),
   ordem_menu     integer      NOT NULL DEFAULT 0,     -- Ordem para exibição em menu
   data_inicio    date         NOT NULL DEFAULT now(), -- Data de inclusão
   data_fim       date,  
   id_status      integer      NOT NULL DEFAULT 1, -- 1 - Ativo
   id_area        integer      NOT NULL,           -- Area de Atua;'ao do Modulo
   id_fase        integer      NOT NULL DEFAULT 0, -- Fase de desenvolvimento do Modulo
   id_responsavel integer      NOT NULL DEFAULT 0, -- Responsavel pelo Módulo
   id_modulo_pai  integer
);

COMMENT ON COLUMN security.modulos.codigo_modulo  IS 'Lei de Formação: AMM Onde A->area de atual MM->Sequencial do modulo 01, 02...e ';
COMMENT ON COLUMN security.modulos.nome           IS 'Nome do Módulo';
COMMENT ON COLUMN security.modulos.sigla          IS 'Sigla do Módulo';
COMMENT ON COLUMN security.modulos.descricao      IS 'Descrição do Módulo';
COMMENT ON COLUMN security.modulos.ordem_menu     IS 'Ordem para exibição em menu';
COMMENT ON COLUMN security.modulos.data_inicio    IS 'Data de Inicio da liberação do acesso ao modulo';
COMMENT ON COLUMN security.modulos.data_fim       IS 'Data de término do acesso ao modulo';
COMMENT ON COLUMN security.modulos.id_status      IS '1-Ativo 2-Temporariamente Inativo 3-Inativo';
COMMENT ON COLUMN security.modulos.id_area        IS 'Area de atuação do modulo';
COMMENT ON COLUMN security.modulos.id_fase        IS 'Fase de desencolvimento que o módulo se encontra';
COMMENT ON COLUMN security.modulos.id_responsavel IS 'Pessoa Responsavel pelo Módulo';
COMMENT ON COLUMN security.modulos.id_modulo_pai  IS 'Módulo pai deste';
 
CREATE TABLE security.modulos_rotinas ( 
   id_modulo              integer      NOT NULL,
   id                     integer      NOT NULL DEFAULT 
                          nextval('security.sq_modulos_rotinas'),
   nome                   varchar(100) NOT NULL,
   descricao              varchar(255) NOT NULL,
   id_fase                integer      NOT NULL DEFAULT 0,
   id_responsavel         integer      NOT NULL DEFAULT 0, -- Responsavel técnico pelo Módulo
   id_agente_beneficiado  integer      NOT NULL DEFAULT 0, -- Agente Beneficiado Pela Rotina
   id_agente_responsavel  integer      NOT NULL DEFAULT 0, -- Agente Responsavel pela Alimentação da rotina
   obs_agente_responsavel varchar(255)  
   observacao             varchar(500)  
);

COMMENT ON COLUMN security.modulos_rotinas.id_responsavel         IS 'id do Profissional técnico responsável  pela manutenção da rotina.';
COMMENT ON COLUMN security.modulos_rotinas.id_agente_beneficiado  IS 'id do Agente (Pessoa/Setor/Secretaria/Instituição ...) que é beneficiado com as informações alimentadas na rotina.';
COMMENT ON COLUMN security.modulos_rotinas.id_agente_responsavel  IS 'id do Agente (Pessoa/Setor/Secretaria/Instituição ...) que é responsavel pela alimentação dos dados da rotina.';
COMMENT ON COLUMN security.modulos_rotinas.obs_agente_responsavel IS 'Observações adicionais (Nome/Telefone/email ou outra informação relevante) referente ao agente responsavel pela rotina.';

-- Tabelas para classificação de Elementos do módulos
-- -----------------------------------------------------------------------------
CREATE TABLE security.tipo_elemento ( 
   id        integer      NOT NULL,
   sigla     varchar(10)  NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL
);

CREATE TABLE security.elementos_modulo ( 
   id_modulo        integer      NOT NULL,
   id               integer NOT NULL DEFAULT 
                    nextval('security.sq_elementos_modulo'),
   codigo_acesso    varchar(7),
   nome_interno     varchar(150) NOT NULL,
   nome_externo     varchar(255) NOT NULL,
   objetivo         varchar(500),
   ordem_menu       varchar(20) -- Ordem de classificação para exibição em menu
   id_status        integer      NOT NULL DEFAULT 1, -- 1 - Ativo
   id_tipo_elemento integer      NOT NULL,           -- Menu / Form / Botão / Rotina
   id_elemento_pai  integer,
);

COMMENT ON COLUMN security.elementos_modulo.codigo_acesso    IS 'Lei de Formação: TMMMEEE Onde T-> Tipo Elemento(M,F,L,B,R) MMM-> codigo modulo EEE-> Sequencial do Elemento no Modulo';
COMMENT ON COLUMN security.elementos_modulo.nome_interno     IS 'Nome a ser utilizado para acionar o elemento';
COMMENT ON COLUMN security.elementos_modulo.nome_externo     IS 'Nome a ser utilizado para exibição do elemento';
COMMENT ON COLUMN security.elementos_modulo.objetivo         IS 'para que o elemento será utilizado';
COMMENT ON COLUMN security.elementos_modulo.ordem_menu       IS 'Ordem de classificação para exibição em menu';
COMMENT ON COLUMN security.elementos_modulo.id_status        IS '1-Ativo 2-Temporariamente Inativo 3-Inativo';
COMMENT ON COLUMN security.elementos_modulo.id_tipo_elemento IS '1-Form 2-Link 3-Botão 4-Relatório ...';
COMMENT ON COLUMN security.elementos_modulo.id_modulo        IS 'Id do modulo ou Módulo que o elemento pertence';
COMMENT ON COLUMN security.elementos_modulo.id_elemento_pai  IS 'Id de outro Elemento pai di elmento atual';

CREATE TABLE security.tipo_regra_acesso ( 
   id        integer      NOT NULL,
   sigla     varchar(10)  NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL
);

-- Tabelas para classificação Regras de acesso
-- -----------------------------------------------------------------------------
CREATE TABLE security.roles (
  id_role       INTEGER      NOT NULL, 
  conditional   BOOLEAN      NOT NULL, 
  role_name     VARCHAR(100), 
  descricao     VARCHAR(255) NOT NULL, 
  data_inicio   DATE         NOT NULL DEFAULT now(), 
  data_fim      DATE, 
  id_tipo_regra INTEGER      NOT NULL DEFAULT 0, -- Sistema / usuario / Modulo / Setor
  id_status     INTEGER      NOT NULL DEFAULT 1, 
  id_role_pai   INTEGER
) WITHOUT OIDS;

COMMENT ON COLUMN security.roles.conditional  IS 'campo Não utilizado';
COMMENT ON COLUMN security.roles.role_name    IS 'Nome Interno da role';
COMMENT ON COLUMN security.roles.descricao    IS 'Nome para exibição';
COMMENT ON COLUMN security.roles.id_status    IS '1-Ativo 2-Temporariamente Inativo 3-Inativo';
COMMENT ON COLUMN security.roles.id_role_pai  IS 'Id da Regra pai desta';
COMMENT ON COLUMN security.roles.data_inicio  IS 'Data de Inicio da liberação do acesso a role';
COMMENT ON COLUMN security.roles.data_fim     IS 'Data de término da liberação do acesso a role';

CREATE TABLE security.roles_x_elementos_modulo ( 
   id          integer NOT NULL DEFAULT 
               nextval('security.sq_roles_x_elementos_modulo'),
   id_role     integer NOT NULL,
   id_elemento integer NOT NULL,
   id_status   integer NOT NULL DEFAULT 1,  -- 1 - Ativo
   data_inicio date    NOT NULL DEFAULT now(),
   data_fim    date  
);

CREATE TABLE security.roles_x_modulos ( 
   id          integer NOT NULL DEFAULT 
               nextval('security.sq_roles_x_modulos'),
   id_role     integer NOT NULL,
   id_modulo   integer NOT NULL
);

CREATE TABLE security.roles_x_groups (
    id_role  integer NOT NULL,
    id_group integer NOT NULL
) WITHOUT OIDS;

-- Tabelas para classificação de Usuarios
-- -----------------------------------------------------------------------------
CREATE TABLE security.tipo_historico_users ( 
   id        integer     NOT NULL,
   descricao varchar(50) NOT NULL
);

CREATE TABLE security.tipo_menu ( 
   id        integer      NOT NULL,
   sigla     varchar(10)  NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   ativo     integer      NOT NULL DEFAULT 1
);

CREATE TABLE security.tipo_skin ( 
   id        integer      NOT NULL,
   sigla     varchar(15)  NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL
);

CREATE TABLE security.tipo_usuario ( 
   id        integer      NOT NULL,
   sigla     varchar(10)  NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL
);

CREATE TABLE security.users (
  matricula       VARCHAR(14) NOT NULL, 
  id_situacao     BOOLEAN, 
  nome_completo   VARCHAR(50) NOT NULL, 
  nome_referencia VARCHAR(20), 
  senha           VARCHAR(25), 
  id_status       INTEGER NOT NULL DEFAULT 1, 
  id_tipo_menu    INTEGER NOT NULL DEFAULT 1, 
  id_tipo_usuario INTEGER NOT NULL DEFAULT 0, 
  id_tipo_skin    INTEGER NOT NULL DEFAULT 1, 
  observacao      VARCHAR(255)
) WITHOUT OIDS;

CREATE TABLE security.users_historicos (
  id_user           VARCHAR(14)  NOT NULL,
  id                INTEGER      DEFAULT
                    nextval('security.sq_users_historicos')    NOT NULL,
  data_hora         TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  id_tipo_historico INTEGER      NOT NULL,
  matricula         VARCHAR(14)  NOT NULL,
  observacao        VARCHAR(255) NOT NULL
) WITHOUT OIDS;

CREATE TABLE security.users_x_roles (
  id          INTEGER     NOT NULL DEFAULT 
              nextval(('security.sq_users_x_roles')) , 
  id_user     VARCHAR(14) NOT NULL, 
  id_role     INTEGER     NOT NULL, 
  id_status   INTEGER     NOT NULL DEFAULT 1, 
  data_inicio DATE        NOT NULL DEFAULT now(), 
  data_fim    DATE
) WITHOUT OIDS;


-- INICIO: Controle de Profissional
-- -----------------------------------------------------------------------------
CREATE TABLE security.area_ti ( 
   id        integer      NOT NULL,
   sigla     varchar(3)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL
);

CREATE TABLE security.profissionais_ti ( 
   id               integer NOT NULL DEFAULT 
                    nextval('security.sq_profissionais_ti'),
   id_area          integer      NOT NULL,
   nome_completo    varchar(100) NOT NULL,
   nome_referencia  varchar(30)  NOT NULL,
   email            varchar(100) NOT NULL,
   fone_residencial varchar(15),
   fone_celular     varchar(15),
   fone_comercial   varchar(15), 
   matricula        VARCHAR(14),
   observacao       varchar(255)
);
ALTER TABLE security.profissionais_ti ADD UNIQUE (matricula);

CREATE TABLE security.modulos_x_profissionais_ti ( 
   id                 integer NOT NULL DEFAULT 
                      nextval('security.sq_modulos_x_profissionais_ti'),
   id_modulo          integer  NOT NULL,
   id_profissional_ti integer  NOT NULL,
   data_inicio        date     NOT NULL,
   data_fim           date,
   observacao        varchar(255) 
);

-- INICIO: Tabela para controle de Versão
-- -----------------------------------------------------------------------------
CREATE TABLE security.status_versao_modulo ( 
   id        integer      NOT NULL,
   sigla     varchar(3)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL,
   tipo      varchar(50)  NOT NULL
);

CREATE TABLE security.versoes_sistema ( 
   id              integer NOT NULL DEFAULT 
                   nextval('security.sq_versoes_sistema'),
   codigo_versao   varchar(20) NOT NULL,
   data_liberacao  date,
   data_publicacao date,
   observacoes_tecnicas varchar(1000),
   observacoes_usuario  varchar(1000),
   id_publicado_por     integer,
   versao_fechada       BOOLEAN DEFAULT false NOT NULL
);
COMMENT ON COLUMN security.versoes_sistema.versao_fechada IS 'Indica que a versão foi publicada e fechada não podendendo mais haver alteração na mesma';

CREATE TABLE security.versoes_modulos ( 
   id                   integer NOT NULL DEFAULT 
                        nextval('security.sq_versoes_modulos'),
   id_modulo            integer NOT NULL,
   id_responsavel       integer NOT NULL,
   id_status            integer NOT NULL DEFAULT 1, -- 1 - Versão prevista
   id_versao_sistema    integer, 
   id_responsavel       integer NOT NULL,
   codigo_versao        varchar(20) NOT NULL,
   data_liberacao       date,
   data_inclusao        date    NOT NULL DEFAULT now(),
   data_desenvolvimento date,
   observacoes_tecnicas varchar(1000),
   observacoes_usuario  varchar(1000)
); 
-- Insere comentario descritivos sobre os campos da tabela
COMMENT ON COLUMN security.versoes_modulos.id_modulo            IS 'Id do Módulo ao qual está associado a versão.';
COMMENT ON COLUMN security.versoes_modulos.id_status            IS 'Id do Status da Versão. Ver tabela: "status_versao_modulo".';
COMMENT ON COLUMN security.versoes_modulos.id_versao_sistema    IS 'id da versão do Sigder Associado. Informar ao liberar para publicar.';
COMMENT ON COLUMN security.versoes_modulos.id_responsavel       IS 'id do Profissional Responsavel Pela Versão do Sistema.';
COMMENT ON COLUMN security.versoes_modulos.codigo_versao        IS 'Código da Versão do Módulo. Informar ao liberar para publicar.';
COMMENT ON COLUMN security.versoes_modulos.data_inclusao        IS 'Data em que a Versão do Módulo foi criada.';
COMMENT ON COLUMN security.versoes_modulos.data_desenvolvimento IS 'Data em que o desenvolvimento da versão do módulo foi iniciado.';
COMMENT ON COLUMN security.versoes_modulos.data_liberacao       IS 'Data em que a Versão do Módulo foi liberada para ser publicada.';
COMMENT ON COLUMN security.versoes_modulos.observacoes_tecnicas IS 'Observações de natureza tecnica para o desenvolvedor.';
COMMENT ON COLUMN security.versoes_modulos.observacoes_usuario  IS 'Observações para o usuário final. alteração realiza; rotina criada; etc...';

CREATE TABLE security.versoes_modulos_x_projetos ( 
   id               integer NOT NULL DEFAULT 
                    nextval('security.sq_versoes_modulos_x_projetos'),
   id_versao_modulo integer NOT NULL,
   id_projeto       integer NOT NULL, 
   observacoes      varchar(1000)
);
-- =============================================================================
-- P R I M A R Y   K E Y ´ s  
-- =============================================================================
-- Tabelas para classificação de Modulos
-- -----------------------------------------------------------------------------
ALTER TABLE security.agente_sistema           ADD CONSTRAINT pk_agente_sistema           PRIMARY KEY (id);
ALTER TABLE security.status_acesso            ADD CONSTRAINT pk_status_acesso            PRIMARY KEY (id);
ALTER TABLE security.fase_desenvolvimento     ADD CONSTRAINT pk_fase_desenvolvimento     PRIMARY KEY (id);
ALTER TABLE security.area_atuacao             ADD CONSTRAINT pk_area_atuacao             PRIMARY KEY (id);
ALTER TABLE security.modulos                  ADD CONSTRAINT pk_modulos                  PRIMARY KEY (id);
ALTER TABLE security.modulos_rotinas          ADD CONSTRAINT pk_modulos_rotinas          PRIMARY KEY (id);
-- Tabelas para classificação de Elementos do Modulo
-- -----------------------------------------------------------------------------
ALTER TABLE security.tipo_elemento            ADD CONSTRAINT pk_tipo_elemento            PRIMARY KEY (id);      
ALTER TABLE security.escopo_elemento          ADD CONSTRAINT pk_escopo_elemento          PRIMARY KEY (id);
ALTER TABLE security.esforco_desenvolvimento  ADD CONSTRAINT pk_esforco_desenvolvimento  PRIMARY KEY (id);
ALTER TABLE security.nivel_elemento           ADD CONSTRAINT pk_nivel_elemento           PRIMARY KEY (id);
ALTER TABLE security.elementos_modulo         ADD CONSTRAINT pk_elementos_modulo         PRIMARY KEY (id);
-- Tabelas para classificação de Regras
-- -----------------------------------------------------------------------------
ALTER TABLE security.tipo_regra_acesso        ADD CONSTRAINT pk_tipo_regra_acesso        PRIMARY KEY (id);
ALTER TABLE security.roles                    ADD CONSTRAINT pk_roles                    PRIMARY KEY (id_role);
ALTER TABLE security.roles_x_elementos_modulo ADD CONSTRAINT pk_roles_x_elementos_modulo PRIMARY KEY (id);
ALTER TABLE security.roles_x_modulos          ADD CONSTRAINT pk_roles_x_modulos          PRIMARY KEY (id);
ALTER TABLE security.roles_x_groups           ADD CONSTRAINT pk_roles_x_groups           PRIMARY KEY (id_role, id_group);
-- Tabelas para classificação de Usuarios
-- -----------------------------------------------------------------------------
ALTER TABLE security.tipo_skin                ADD CONSTRAINT pk_tipo_skin                PRIMARY KEY (id);
ALTER TABLE security.tipo_menu                ADD CONSTRAINT pk_tipo_menu                PRIMARY KEY (id);
ALTER TABLE security.tipo_usuario             ADD CONSTRAINT pk_tipo_usuario             PRIMARY KEY (id);
ALTER TABLE security.tipo_historico_users     ADD CONSTRAINT pk_tipo_historico_users     PRIMARY KEY (id);
ALTER TABLE security.users                    ADD CONSTRAINT pk_users                    PRIMARY KEY (matricula);
ALTER TABLE security.users_historicos         ADD CONSTRAINT pk_users_historicos         PRIMARY KEY (id);
ALTER TABLE security.users_x_roles            ADD CONSTRAINT pk_users_x_roles            PRIMARY KEY (id);
-- Tabelas Profissionais de TI
-- -----------------------------------------------------------------------------
ALTER TABLE security.area_ti                    ADD CONSTRAINT pk_area_ti       PRIMARY KEY (id);      
ALTER TABLE security.profissionais_ti           ADD CONSTRAINT pk_profissionais_ti           PRIMARY KEY (id);      
ALTER TABLE security.modulos_x_profissionais_ti ADD CONSTRAINT pk_modulos_x_profissionais_ti PRIMARY KEY (id);      
-- Tabelas Controle de Versão
-- -----------------------------------------------------------------------------
ALTER TABLE security.status_versao_modulo        ADD CONSTRAINT pk_status_versao_modulo        PRIMARY KEY (id);
ALTER TABLE security.versoes_sistema             ADD CONSTRAINT pk_versoes_sistema             PRIMARY KEY (id);
ALTER TABLE security.versoes_modulos             ADD CONSTRAINT pk_versoes_modulos             PRIMARY KEY (id);
ALTER TABLE security.versoes_modulos_x_projetos  ADD CONSTRAINT pk_versoes_modulos_x_projetos  PRIMARY KEY (id);

CREATE UNIQUE INDEX ak_versoes_sistema_codigo_versao     ON security.versoes_sistema          USING btree (codigo_versao);
CREATE UNIQUE INDEX ak_versoes_modulos_id_modulo_versao  ON security.versoes_modulos          USING btree (id_modulo, codigo_versao);
CREATE UNIQUE INDEX ak_versoes_modulos_id_modulo_sistema ON security.versoes_modulos          USING btree (id_modulo, id_versao_sistema);
CREATE UNIQUE INDEX ak_roles_x_elementos_modulo          ON security.roles_x_elementos_modulo USING btree (id_role, id_elemento);
-- =============================================================================
-- F O R E I G N   K E Y ´ s   d o   p a c o t e   S E C U R I T Y
-- =============================================================================

--  FOREIGN KEY da tabela 'security.users'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.users
  ADD CONSTRAINT fk_status_acesso FOREIGN KEY (id_status) 
      REFERENCES security.status_acesso (id);

ALTER TABLE ONLY security.users
  ADD CONSTRAINT fk_tipo_menu     FOREIGN KEY (id_tipo_menu) 
      REFERENCES security.tipo_menu (id);

ALTER TABLE ONLY security.users
  ADD CONSTRAINT fk_tipo_usuario  FOREIGN KEY (id_tipo_usuario) 
      REFERENCES security.tipo_usuario (id);

ALTER TABLE ONLY security.users
  ADD CONSTRAINT fk_tipo_skin     FOREIGN KEY (id_tipo_skin) 
      REFERENCES security.tipo_skin (id);

--  FOREIGN KEY da tabela 'security.roles'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.roles
  ADD CONSTRAINT fk_status_acesso FOREIGN KEY (id_status) 
      REFERENCES security.status_acesso (id);

ALTER TABLE ONLY security.roles
  ADD CONSTRAINT fk_role_pai      FOREIGN KEY (id_role_pai) 
      REFERENCES security.roles (id_role);

ALTER TABLE ONLY security.roles
  ADD CONSTRAINT fk_tipo_regra_acesso  FOREIGN KEY (id_tipo_regra) 
      REFERENCES security.tipo_regra_acesso (id); 

--  FOREIGN KEY da tabela 'security.users_x_roles'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.users_x_roles 
 ADD  CONSTRAINT fk_roles FOREIGN KEY (id_role) 
      REFERENCES security.roles(id_role);

ALTER TABLE ONLY security.users_x_roles 
 ADD  CONSTRAINT fk_users FOREIGN KEY (id_user) 
      REFERENCES security.users(matricula);

--  FOREIGN KEY da tabela 'security.modulos'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.modulos 
  ADD CONSTRAINT fk_status_acesso   FOREIGN KEY (id_status) 
      REFERENCES security.status_acesso (id);

ALTER TABLE ONLY security.modulos
  ADD CONSTRAINT fk_fase_desenvolvimento FOREIGN KEY (id_fase) 
      REFERENCES security.fase_desenvolvimento (id);

ALTER TABLE ONLY security.modulos
  ADD CONSTRAINT fk_area_atuacao    FOREIGN KEY (id_area) 
      REFERENCES security.area_atuacao (id);

ALTER TABLE ONLY security.modulos
  ADD CONSTRAINT fk_responsavel    FOREIGN KEY (id_responsavel) 
      REFERENCES security.profissionais_ti (id);
      
ALTER TABLE ONLY security.modulos
  ADD CONSTRAINT fk_modulo_pai      FOREIGN KEY (id_modulo_pai) 
      REFERENCES security.modulos (id);

--  FOREIGN KEY da tabela 'security.modulos_rotinas'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.modulos_rotinas
  ADD CONSTRAINT fk_modulos          FOREIGN KEY (id_modulo) 
      REFERENCES security.modulos (id); 

ALTER TABLE ONLY security.modulos_rotinas
  ADD CONSTRAINT fk_fase_desenvolvimento FOREIGN KEY (id_fase) 
      REFERENCES security.fase_desenvolvimento (id);
      
ALTER TABLE ONLY security.modulos_rotinas
  ADD CONSTRAINT fk_responsavel    FOREIGN KEY (id_responsavel) 
      REFERENCES security.profissionais_ti (id);

ALTER TABLE ONLY security.modulos_rotinas
  ADD CONSTRAINT fk_agente_beneficiado   FOREIGN KEY (id_agente_beneficiado) 
      REFERENCES security.agente_sistema (id);

ALTER TABLE ONLY security.modulos_rotinas
  ADD CONSTRAINT fk_agente_responsavel   FOREIGN KEY (id_agente_responsavel) 
      REFERENCES security.agente_sistema (id);

--  FOREIGN KEY da tabela 'security.elementos_modulo '
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.elementos_modulo 
  ADD CONSTRAINT fk_status_acesso   FOREIGN KEY (id_status) 
      REFERENCES security.status_acesso (id);

ALTER TABLE ONLY security.elementos_modulo 
  ADD CONSTRAINT fk_modulos         FOREIGN KEY (id_modulo) 
      REFERENCES security.modulos (id);

ALTER TABLE ONLY security.elementos_modulo 
  ADD CONSTRAINT fk_tipo_elemento   FOREIGN KEY (id_tipo_elemento) 
      REFERENCES security.tipo_elemento (id);

ALTER TABLE ONLY security.elementos_modulo
  ADD CONSTRAINT fk_escopo_elemento FOREIGN KEY (id_escopo) 
      REFERENCES security.escopo_elemento (id);

ALTER TABLE ONLY security.elementos_modulo
  ADD CONSTRAINT fk_esforco_desenvolvimento FOREIGN KEY (id_esforco) 
      REFERENCES security.esforco_desenvolvimento (id);

ALTER TABLE ONLY security.elementos_modulo
  ADD CONSTRAINT fk_nivel_elemento  FOREIGN KEY (id_nivel) 
      REFERENCES security.nivel_elemento (id);

ALTER TABLE ONLY security.elementos_modulo 
  ADD CONSTRAINT fk_elemento_pai    FOREIGN KEY (id_elemento_pai) 
      REFERENCES security.elementos_modulo (id);

--  FOREIGN KEY da tabela 'security.roles_x_elementos_modulo'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.roles_x_elementos_modulo 
  ADD CONSTRAINT fk_roles            FOREIGN KEY (id_role) 
      REFERENCES security.roles (id_role);

ALTER TABLE ONLY security.roles_x_elementos_modulo 
  ADD CONSTRAINT fk_elementos_modulo FOREIGN KEY (id_elemento) 
      REFERENCES security.elementos_modulo (id);

ALTER TABLE ONLY security.roles_x_elementos_modulo 
  ADD CONSTRAINT fk_status_acesso    FOREIGN KEY (id_status) 
      REFERENCES security.status_acesso (id);

--  FOREIGN KEY da tabela 'security.roles_x_modulos'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.roles_x_modulos
  ADD CONSTRAINT fk_roles            FOREIGN KEY (id_role) 
      REFERENCES security.roles (id_role);
      
ALTER TABLE ONLY security.roles_x_modulos
  ADD CONSTRAINT fk_modulos          FOREIGN KEY (id_modulo) 
      REFERENCES security.modulos (id);

--  FOREIGN KEY da tabela 'security.users_historicos'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.users_historicos
  ADD CONSTRAINT fk_users            FOREIGN KEY (id_user) 
      REFERENCES security.users (matricula);

 ALTER TABLE ONLY security.users_historicos
  ADD CONSTRAINT fk_tipo_historico_users FOREIGN KEY (id_tipo_historico) 
      REFERENCES security.tipo_historico_users (id);     

ALTER TABLE ONLY security.profissionais_ti
  ADD CONSTRAINT fk_area_ti              FOREIGN KEY (id_area) 
      REFERENCES security.area_ti (id);

--  FOREIGN KEY da tabela 'modulos_x_profissionais_ti'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.modulos_x_profissionais_ti
  ADD CONSTRAINT fk_modulos              FOREIGN KEY (id_modulo) 
      REFERENCES security.modulos (id);
      
ALTER TABLE ONLY security.modulos_x_profissionais_ti
  ADD CONSTRAINT fk_profissionais_ti     FOREIGN KEY (id_profissional_ti) 
      REFERENCES security.profissionais_ti (id);

--  FOREIGN KEY da tabela 'versoes_sistema'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.versoes_sistema
  ADD CONSTRAINT fk_profissionais_ti     FOREIGN KEY (id_publicado_por) 
      REFERENCES security.profissionais_ti (id);

--  FOREIGN KEY da tabela 'versoes_modulos'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.versoes_modulos 
  ADD CONSTRAINT fk_modulos              FOREIGN KEY (id_modulo) 
      REFERENCES security.modulos (id);

ALTER TABLE ONLY security.versoes_modulos 
  ADD CONSTRAINT fk_status_versao_modulo FOREIGN KEY (id_status) 
      REFERENCES security.status_versao_modulo (id);

ALTER TABLE ONLY security.versoes_modulos 
  ADD CONSTRAINT fk_versao_sistema FOREIGN KEY (id_versao_sistema) 
      REFERENCES security.versoes_sistema (id);

ALTER TABLE ONLY security.versoes_modulos 
  ADD CONSTRAINT fk_profissionais_ti     FOREIGN KEY (id_responsavel) 
      REFERENCES security.profissionais_ti (id);

--  FOREIGN KEY da tabela 'versoes_modulos_x_projetos'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.versoes_modulos_x_projetos
  ADD CONSTRAINT fk_versoes_modulos FOREIGN KEY (id_versao_modulo) 
      REFERENCES security.versoes_modulos (id);
      
ALTER TABLE ONLY security.versoes_modulos_x_projetos
  ADD CONSTRAINT fk_projetos FOREIGN KEY (id_projeto) 
      REFERENCES security.projetos (id);

-- =============================================================================
-- C R I A Ç Ã O   D A S   V I E W S
-- =============================================================================
      
-- =============================================================================
-- INICIO: Insert´s das Tabelas Dicionarios
-- =============================================================================
-- INSERTS da tabela: security.tipo_historico_users
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_historico_users (id, descricao) VALUES ( 1,'Usuario foi Cadastrado');
INSERT INTO security.tipo_historico_users (id, descricao) VALUES ( 2,'Status Alterado para [Ativo]');
INSERT INTO security.tipo_historico_users (id, descricao) VALUES ( 3,'Status Alterado para [Temporariamente Inativo]');
INSERT INTO security.tipo_historico_users (id, descricao) VALUES ( 4,'Status Alterado para [Inativo]');
INSERT INTO security.tipo_historico_users (id, descricao) VALUES ( 5,'Dados do Perfil Alterado');
INSERT INTO security.tipo_historico_users (id, descricao) VALUES ( 6,'Regra Concedida ao Usuario');
INSERT INTO security.tipo_historico_users (id, descricao) VALUES ( 7,'Regra Retirada Temporariamente do Usuário');
INSERT INTO security.tipo_historico_users (id, descricao) VALUES ( 8,'Regra Retirada do Usuário');
INSERT INTO security.tipo_historico_users (id, descricao) VALUES ( 9,'Regra Reativada para o Usuário');
INSERT INTO security.tipo_historico_users (id, descricao) VALUES (10,'Regra Concedida Automaticamente ao Usuário');

-- INSERTS da tabela: security.tipo_skin
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_skin (id, sigla, nome, descricao) VALUES (1,'wine'       ,'Wine'       ,' ');
INSERT INTO security.tipo_skin (id, sigla, nome, descricao) VALUES (2,'blueSky'    ,'BlueSky'    ,' ');
INSERT INTO security.tipo_skin (id, sigla, nome, descricao) VALUES (3,'classic'    ,'Classic'    ,' ');
INSERT INTO security.tipo_skin (id, sigla, nome, descricao) VALUES (4,'ruby'       ,'Ruby'       ,' ');
INSERT INTO security.tipo_skin (id, sigla, nome, descricao) VALUES (5,'deepMarine' ,'DeepMarine' ,' ');
INSERT INTO security.tipo_skin (id, sigla, nome, descricao) VALUES (6,'emeraldTown','EmeraldTown',' ');
INSERT INTO security.tipo_skin (id, sigla, nome, descricao) VALUES (7,'japanCherry','Sakura'     ,' ');
INSERT INTO security.tipo_skin (id, sigla, nome, descricao) VALUES (8,'plain'      ,'Plain'      ,' ');
INSERT INTO security.tipo_skin (id, sigla, nome, descricao) VALUES (9,'DEFAULT'    ,'Default'    ,' ');
-- INSERTS da tabela: security.tipo_usuario
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_usuario (id, sigla, nome, descricao) VALUES (0,'NINF' ,'Não Informado'       ,'Usuário Ainda não identifica com um tipo');
INSERT INTO security.tipo_usuario (id, sigla, nome, descricao) VALUES (1,'FUNC' ,'Funcionario'         ,'Usuário Pessoa fisica que possui vinculo empregaticio com o DER. (Servidor-Terceirizado-Estagiario-Temporario)');
INSERT INTO security.tipo_usuario (id, sigla, nome, descricao) VALUES (2,'PROF' ,'Profissional Liberal','Usuário Pessoa fisica que não possui vinculo empregaticio com o DER, mas presta serviços autonomo ao mesmo.');
INSERT INTO security.tipo_usuario (id, sigla, nome, descricao) VALUES (3,'CTTD' ,'Empresa Contratada'  ,'Usuario Juridico representado por Empresa que presta serviço ao DER');
INSERT INTO security.tipo_usuario (id, sigla, nome, descricao) VALUES (4,'CTTT' ,'Empresa Contratante' ,'Usuario Juridico representado por Empresa que utiliza serviço do DER');
-- INSERTS da tabela: security.tipo_menu
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_menu (id, sigla, nome, descricao) VALUES (1,'PADRAO'   ,'Menu Padrão'        ,'Menu utilizado no momento');
INSERT INTO security.tipo_menu (id, sigla, nome, descricao) VALUES (2,'DROPDOWN' ,'Menu DropDown'      ,'Exibe as opções em forma de Menu DropDraw');
INSERT INTO security.tipo_menu (id, sigla, nome, descricao) VALUES (3,'ICONE'    ,'Menu Icone'         ,'Exibe os modulos em forma de Icone e as opções em forma de lista de serviços');
INSERT INTO security.tipo_menu (id, sigla, nome, descricao) VALUES (4,'TREEVIEW' ,'Menu Tree View'     ,'Exibe as opções em forma de arvore 1o nivel - modulos');
INSERT INTO security.tipo_menu (id, sigla, nome, descricao) VALUES (5,'LISTA'    ,'Menu Lista Serviços','Exibe as opções em forma de lista de serviços Sem agrupamento por modulo');
-- INSERTS da tabela: security.status_acesso
-- -----------------------------------------------------------------------------
INSERT INTO security.status_acesso (id, cor, sigla, nome, tipo, descricao)   VALUES (1,'#09ed2b','ATI','Ativo'                  ,'ATIVO'                  ,'Acesso Liberado para uso');
INSERT INTO security.status_acesso (id, cor, sigla, nome, tipo, descricao)   VALUES (2,'#f2cb09','TIN','Temporariamente Inativo','TEMPORARIAMENTE_INATIVO','Acesso temporariamente desativado para uso');
INSERT INTO security.status_acesso (id, cor, sigla, nome, tipo, descricao)   VALUES (3,'#f50a0a','INA','Inativo'                ,'INATIVO'                ,'Acesso definitivamente desativado para uso');
-- INSERTS da tabela: security.fase_desenvolvimento
-- -----------------------------------------------------------------------------
INSERT INTO security.fase_desenvolvimento (id, cor, sigla, nome, descricao)  VALUES (0,'#000000','NAO','Não Informada'    ,'Fase de desenvolvimento Não Informado.');
INSERT INTO security.fase_desenvolvimento (id, cor, sigla, nome, descricao)  VALUES (1,'#000000','CON','Concepção'        ,'Fase de Inicial de Levantamento de Requisitos.');
INSERT INTO security.fase_desenvolvimento (id, cor, sigla, nome, descricao)  VALUES (2,'#000000','PLA','Planejamento'     ,'Fase de Planejamento do projeto.');
INSERT INTO security.fase_desenvolvimento (id, cor, sigla, nome, descricao)  VALUES (3,'#000000','ANA','Analise'          ,'Fase de Analise do módulo.');
INSERT INTO security.fase_desenvolvimento (id, cor, sigla, nome, descricao)  VALUES (4,'#000000','DES','Desenvolvimento'  ,'Fase de Desenvolvimento e codificação.');
INSERT INTO security.fase_desenvolvimento (id, cor, sigla, nome, descricao)  VALUES (5,'#000000','IMP','Implantação'      ,'Fase de Implantação do módulo.');
INSERT INTO security.fase_desenvolvimento (id, cor, sigla, nome, descricao)  VALUES (6,'#000000','USO','Em Uso/Manutenção','Módulo em uso e manutenção.');
-- INSERTS da tabela: security.area_atuacao
-- -----------------------------------------------------------------------------
INSERT INTO security.area_atuacao (id, cor, sigla, nome, descricao)  VALUES (1,'#000000','COR','Corporativo'   ,'Dados de uso geral para aplicações nas diversas áreas');
INSERT INTO security.area_atuacao (id, cor, sigla, nome, descricao)  VALUES (2,'#000000','FIM','Area Fim'      ,'Aplicações para dar suporte a area de atuação da instituição');
INSERT INTO security.area_atuacao (id, cor, sigla, nome, descricao)  VALUES (3,'#000000','APO','Area de Apoio' ,'Modulos de modulos para dar suporte as ´reas de apoio a instituição');
INSERT INTO security.area_atuacao (id, cor, sigla, nome, descricao)  VALUES (4,'#000000','INF','Informática'   ,'Modulos para supri gerenciamento de tecnologia de Informação');
INSERT INTO security.area_atuacao (id, cor, sigla, nome, descricao)  VALUES (5,'#000000','AUD','Auditoria'     ,'Modulos para gerar auditoria dos dados registrados no SIGDER');
INSERT INTO security.area_atuacao (id, cor, sigla, nome, descricao)  VALUES (6,'#000000','PUB','Público'       ,'Modulos disponibilizar informações direcionada a população');
-- INSERTS da tabela: security.tipo_elemento
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_elemento (id, cor, sigla, nome, descricao) VALUES (1,'#000000','MENUS','Menus'           ,'Menus de acesso Formados de grupos e sub grupos');
INSERT INTO security.tipo_elemento (id, cor, sigla, nome, descricao) VALUES (2,'#000000','FORMS','Formularios'     ,'Formularios chamados a partir de outras paginas');
INSERT INTO security.tipo_elemento (id, cor, sigla, nome, descricao) VALUES (3,'#000000','LINKS','Link´s de acesso','Link´s de acesso a funcionalidades do modulos');
INSERT INTO security.tipo_elemento (id, cor, sigla, nome, descricao) VALUES (4,'#000000','BOTAO','Botões de ação'  ,'Botões que acionam funcionalidades do modulo');
INSERT INTO security.tipo_elemento (id, cor, sigla, nome, descricao) VALUES (5,'#000000','RELAT','Relatórios'      ,'Relatórios Emitidos pelo modulo');
INSERT INTO security.tipo_elemento (id, cor, sigla, nome, descricao) VALUES (6,'#000000','VIEWS','View´s em BD'    ,'Viewé criadas em Banco de Dados');
INSERT INTO security.tipo_elemento (id, cor, sigla, nome, descricao) VALUES (7,'#000000','TRIGG','Trigger em BD'   ,'Trigger em Banco de Dados');
INSERT INTO security.tipo_elemento (id, cor, sigla, nome, descricao) VALUES (8,'#000000','CLASS','Classe Java'     ,'Classe java de relevancia para o projeto');
INSERT INTO security.tipo_elemento (id, cor, sigla, nome, descricao) VALUES (9,'#000000','ARQUI','Arquivo Externo' ,'Arquivo externo ao sistema contendo nformações relevantes');

-- INSERTS da tabela: security.area_ti 
-- -----------------------------------------------------------------------------
INSERT INTO security.area_ti (id, cor, sigla, nome, descricao) VALUES (1,'#000000','GER','Gerencia'       ,'Profissional que trabalha na como Gerente de TI');
INSERT INTO security.area_ti (id, cor, sigla, nome, descricao) VALUES (2,'#000000','DES','Desenvolvimento','Programadores /  Analistas / Testadores / levantador de requisito ...');
INSERT INTO security.area_ti (id, cor, sigla, nome, descricao) VALUES (3,'#000000','SUP','Suporte'        ,'Profissional da área de infra estrutura de TI');
INSERT INTO security.area_ti (id, cor, sigla, nome, descricao) VALUES (4,'#000000','ATE','Atendimento'    ,'Profissional da área de atendimento ao usuário');

-- INSERTS da tabela: security.status_versao_modulo
-- -----------------------------------------------------------------------------
INSERT INTO security.status_versao_modulo (id, cor, sigla, nome, tipo, descricao) VALUES (1,'#000000','PRE','Prevista'             ,'PREVISTA'             ,'Alterações já definida para o modulos mais ainda não começou o desenvolvimento');
INSERT INTO security.status_versao_modulo (id, cor, sigla, nome, tipo, descricao) VALUES (2,'#000000','DES','Em Desenvolimento'    ,'EM_DESENVOLVIMENTO'   ,'Alterações em processo de desenvolvimento');
INSERT INTO security.status_versao_modulo (id, cor, sigla, nome, tipo, descricao) VALUES (3,'#000000','APU','Aguardando Publicação','AGUARDANDO_PUBLICACAO','Alterações já desenvolvidas mais ainda não publicadas');
INSERT INTO security.status_versao_modulo (id, cor, sigla, nome, tipo, descricao) VALUES (4,'#000000','PUB','Publicada'            ,'PUBLICADA'            ,'Alterações desenvolvidas e publicadas');

-- INSERTS da tabela: security.tipo_regra
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_regra_acesso (id, cor, sigla, nome, descricao) VALUES (0,'#000000','NAOINFOR','Não Informado'   ,'Regra Sem tipo definido');
INSERT INTO security.tipo_regra_acesso (id, cor, sigla, nome, descricao) VALUES (1,'#000000','SISTEMA' ,'Regra de Sistema','Regra de acesso para todo o sistema. Ex. SISTEMA.AUDITORIA');
INSERT INTO security.tipo_regra_acesso (id, cor, sigla, nome, descricao) VALUES (2,'#000000','USUARIO' ,'Regra de Usuário','Regra de acesso para tipo de Usuarios Ex. USUARIO.FUNCIONARIO');
INSERT INTO security.tipo_regra_acesso (id, cor, sigla, nome, descricao) VALUES (3,'#000000','MODULO'  ,'Regra de Módulo' ,'Regra de acesso para módulos especificos. Ex. SERVICO_TI.ATENDIMENTO');
INSERT INTO security.tipo_regra_acesso (id, cor, sigla, nome, descricao) VALUES (4,'#000000','SETOR'   ,'Regra de Setor'  ,'Regra de acesso para um setor da instituição. Ex. FINANCEIRO.GESTOR');

-- =============================================================================
-- FIM: Insert´s das Tabelas Dicionarios
-- =============================================================================

-- =============================================================================
-- INICIO: Alteracoes da Tabela: 'security.users'
-- =============================================================================

-- Atualizar tipo_usuario = funcionario
-- -----------------------------------------------------------------------------
UPDATE security.users usd
   SET id_tipo_usuario = 1 -- 1=Funcionario
  FROM (SELECT fun.matricula
          FROM der_ce_coorporativo.funcionarios fun INNER JOIN
              (SELECT SUBSTRING(usu.matricula,1,8) AS matricula
                 FROM security.users  usu
                WHERE length(usu.matricula)<=8
              ) usr ON usr.matricula = fun.matricula
       ) uso
 WHERE usd.matricula = uso.matricula;
  
-- Atualizaar tipo_usuario = contratada
-- -----------------------------------------------------------------------------
UPDATE security.users usd
   SET id_tipo_usuario = 3 -- 3=Contratada
  FROM (SELECT pju.cnpj
          FROM der_ce_coorporativo.pessoas_juridicas pju INNER JOIN
              (SELECT SUBSTRING(usu.matricula,1,14) AS matricula
                 FROM security.users  usu
                WHERE length(usu.matricula)=14
              ) usr ON usr.matricula = pju.cnpj
       ) uso
 WHERE usd.matricula = uso.cnpj;

-- =============================================================================
-- FIM: Alteracoes da Tabela: 'security.users'
-- =============================================================================

-- =============================================================================
-- INICIO: Tabela para controle de Caso de USO
-- =============================================================================
-- Criar Sequences das tabelas de Caso de USO
-- -----------------------------------------------------------------------------
CREATE SEQUENCE security.sq_casos_de_uso                   INCREMENT 1  MINVALUE 1  MAXVALUE 2147483647  START 1 CACHE 1;
CREATE SEQUENCE security.sq_casos_de_uso_x_elementos       INCREMENT 1  MINVALUE 1  MAXVALUE 2147483647  START 1 CACHE 1;
CREATE SEQUENCE security.sq_versoes_modulos_x_casos_de_uso INCREMENT 1  MINVALUE 1  MAXVALUE 2147483647  START 1 CACHE 1;

-- Criar Tabelas de Caso de USO
-- -----------------------------------------------------------------------------
CREATE TABLE security.cdu_nivel ( 
   id        integer      NOT NULL,
   sigla     varchar(10)  NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL
);

CREATE TABLE security.cdu_escopo ( 
   id        integer      NOT NULL,
   sigla     varchar(10)  NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL
);

CREATE TABLE security.cdu_esforco ( 
   id        integer      NOT NULL,
   sigla     varchar(10)  NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL
);

CREATE TABLE security.casos_de_uso ( 
   id_modulo        integer NOT NULL,
   id               integer NOT NULL DEFAULT 
                    nextval('security.sq_casos_de_uso'),
   codigo           varchar(8)   NOT NULL, -- UCMMMSSS -=- Onde: UC-UseCase MMM-Modulo -- SSS-Sequencial
   nome             varchar(150) NOT NULL,
   descricao        varchar(500),
   id_escopo        integer NOT NULL DEFAULT 0, -- 0 - Não Informado
   id_nivel         integer NOT NULL DEFAULT 0, -- 0 - Não Informado
   id_esforco       integer NOT NULL DEFAULT 0  -- 0 - Não Informado
);

COMMENT ON COLUMN security.casos_de_uso.codigo        IS 'UCMMMSSS -=- Onde: UC-UseCase MMM-Modulo -- SSS-Sequencial';
COMMENT ON COLUMN security.casos_de_uso.nome          IS 'Nome do caso de uso';
COMMENT ON COLUMN security.casos_de_uso.descricao     IS 'Breve descrição do caso de uso';
COMMENT ON COLUMN security.casos_de_uso.id_modulo     IS 'Módulo ao qual o caso de uso pertence';
COMMENT ON COLUMN security.casos_de_uso.id_nivel      IS 'Define o Nivel organizacional que o caso de uso atua';
COMMENT ON COLUMN security.casos_de_uso.id_escopo     IS 'Define a Abrangencia de atuação do caso de uso';
COMMENT ON COLUMN security.casos_de_uso.id_esforco    IS 'Define a complexidade do caso de uso';

CREATE TABLE security.casos_de_uso_especificacoes ( 
   id_caso_de_uso      integer       NOT NULL,
   pre_condicao        varchar(255)  NOT NULL,
   pos_condicao        varchar(255)  NOT NULL,
   fluxo_principal     varchar(1000) NOT NULL,
   fluxos_alternativos varchar(2000)
);

CREATE TABLE security.casos_de_uso_x_elementos ( 
   id               integer NOT NULL DEFAULT 
                    nextval('security.sq_casos_de_uso_x_elementos'),
   id_caso_de_uso   integer NOT NULL,
   id_elemento      integer NOT NULL
);

CREATE TABLE security.versoes_modulos_x_casos_de_uso ( 
   id                   integer NOT NULL DEFAULT 
                        nextval('security.sq_versoes_modulos_x_casos_de_uso'),
   id_versao_modulo     integer NOT NULL,
   id_caso_de_uso       integer NOT NULL
);

ALTER TABLE security.cdu_nivel    ADD CONSTRAINT pk_cdu_nivel    PRIMARY KEY (id);
ALTER TABLE security.cdu_escopo   ADD CONSTRAINT pk_cdu_escopo   PRIMARY KEY (id);
ALTER TABLE security.cdu_esforco  ADD CONSTRAINT pk_cdu_esforco  PRIMARY KEY (id);
ALTER TABLE security.casos_de_uso ADD CONSTRAINT pk_casos_de_uso PRIMARY KEY (id);
ALTER TABLE security.casos_de_uso_especificacoes    ADD CONSTRAINT pk_casos_de_uso_especificacoes    PRIMARY KEY (id_caso_de_uso);
ALTER TABLE security.casos_de_uso_x_elementos       ADD CONSTRAINT pk_casos_de_uso_x_elementos       PRIMARY KEY (id);
ALTER TABLE security.versoes_modulos_x_casos_de_uso ADD CONSTRAINT pk_versoes_modulos_x_casos_de_uso PRIMARY KEY (id);

ALTER TABLE ONLY security.casos_de_uso
  ADD CONSTRAINT fk_cdu_nivel  FOREIGN KEY (id_nivel) 
      REFERENCES security.cdu_nivel (id);

ALTER TABLE ONLY security.casos_de_uso
  ADD CONSTRAINT fk_modulos  FOREIGN KEY (id_modulo) 
      REFERENCES security.modulos (id);

ALTER TABLE ONLY security.casos_de_uso
  ADD CONSTRAINT fk_cdu_escopo FOREIGN KEY (id_escopo) 
      REFERENCES security.cdu_escopo (id);

ALTER TABLE ONLY security.casos_de_uso
  ADD CONSTRAINT fk_cdu_esforco FOREIGN KEY (id_esforco) 
      REFERENCES security.cdu_esforco (id);


ALTER TABLE ONLY security.casos_de_uso_especificacoes
  ADD CONSTRAINT fk_casos_de_uso FOREIGN KEY (id_caso_de_uso) 
      REFERENCES security.casos_de_uso (id);

ALTER TABLE ONLY security.casos_de_uso_x_elementos
  ADD CONSTRAINT fk_casos_de_uso  FOREIGN KEY (id_caso_de_uso) 
      REFERENCES security.casos_de_uso (id);

ALTER TABLE ONLY security.casos_de_uso_x_elementos
  ADD CONSTRAINT fk_elementos_modulo FOREIGN KEY (id_elemento) 
      REFERENCES security.elementos_modulo (id);

ALTER TABLE ONLY security.versoes_modulos_x_casos_de_uso
  ADD CONSTRAINT fk_casos_de_uso  FOREIGN KEY (id_caso_de_uso) 
      REFERENCES security.casos_de_uso (id);

ALTER TABLE ONLY security.versoes_modulos_x_casos_de_uso
  ADD CONSTRAINT fk_versoes_modulos FOREIGN KEY (id_versao_modulo) 
      REFERENCES security.versoes_modulos (id);

-- INSERTS da tabela: security.nivel
-- -----------------------------------------------------------------------------
INSERT INTO security.cdu_nivel (id, cor, sigla, nome, descricao)   VALUES (0,'#000000','NIN','Não Informado','Classificação não Informada!');
INSERT INTO security.cdu_nivel (id, cor, sigla, nome, descricao)   VALUES (1,'#000000','OPE','Operacional'  ,'Caso de Uso com Enfase de utilização no nivel Operacional');
INSERT INTO security.cdu_nivel (id, cor, sigla, nome, descricao)   VALUES (2,'#000000','GER','Gerencial'    ,'Caso de Uso com Enfase de utilização no nivel Gerencial');
INSERT INTO security.cdu_nivel (id, cor, sigla, nome, descricao)   VALUES (3,'#000000','EST','Estratégico'  ,'Caso de Uso com Enfase de utilização no nivel Estratégico');
-- INSERTS da tabela: security.cdu_escopo
-- -----------------------------------------------------------------------------
INSERT INTO security.cdu_escopo (id, cor, sigla, nome, descricao)  VALUES (0,'#000000','NIN','Não Informado','Classificação não Informada!');
INSERT INTO security.cdu_escopo (id, cor, sigla, nome, descricao)  VALUES (1,'#000000','SET','Setorial'     ,'Enfase em atender necessidades de abrangencia setorial');
INSERT INTO security.cdu_escopo (id, cor, sigla, nome, descricao)  VALUES (2,'#000000','DER','DER'          ,'Enfase em atender necessidades de abrangencia corporativas do DER');
INSERT INTO security.cdu_escopo (id, cor, sigla, nome, descricao)  VALUES (3,'#000000','GOV','Governo'      ,'Enfase em atender necessidades de abrangencia governamental (Secretarias, prefeituras...)');
INSERT INTO security.cdu_escopo (id, cor, sigla, nome, descricao)  VALUES (4,'#000000','EMP','Empresas'     ,'Enfase em atender necessidades das Empresas contratatadas');
INSERT INTO security.cdu_escopo (id, cor, sigla, nome, descricao)  VALUES (5,'#000000','POP','População'    ,'Enfase em atender necessidades da população em geral)');
-- INSERTS da tabela: security.cdu_esforco
-- -----------------------------------------------------------------------------
INSERT INTO security.cdu_esforco (id, cor, sigla, nome, descricao) VALUES (0,'#000000','NIN','Não Informado','Classificação não Informada!');
INSERT INTO security.cdu_esforco (id, cor, sigla, nome, descricao) VALUES (1,'#000000','MIN','Mínimo'       ,'Desenvolvimento até 4 horas. (Sem Complexidade)');
INSERT INTO security.cdu_esforco (id, cor, sigla, nome, descricao) VALUES (2,'#000000','BAI','Baixo'        ,'Desenvolvimento até 2 dias.  (Pouca Complexidade)');
INSERT INTO security.cdu_esforco (id, cor, sigla, nome, descricao) VALUES (3,'#000000','MED','Médio'        ,'Desenvolvimento até 1 Semana.(Complexidade Razoavel)');
INSERT INTO security.cdu_esforco (id, cor, sigla, nome, descricao) VALUES (4,'#000000','ALT','Alto'         ,'Desenvolvimento até 2 Semana.(Alta Complexidade)');
INSERT INTO security.cdu_esforco (id, cor, sigla, nome, descricao) VALUES (5,'#000000','MAX','Máximo'       ,'Desenvolvimento até 1 Mês.   (Extremamente Complexo)');
INSERT INTO security.cdu_esforco (id, cor, sigla, nome, descricao) VALUES (6,'#000000','SPI','SPIKE'        ,'Sem definição de tempo.      (Sem Parametro Anterior)');

-- =============================================================================
-- FIM: Tabela para controle de Caso de USO
-- =============================================================================


-- =============================================================================
-- INICIO: Controle de Projetos
-- =============================================================================
DROP TABLE security.projetos_interrupcoes;
DROP TABLE security.projetos_historicos;
DROP TABLE security.projetos;
DROP TABLE security.tipo_historico_projetos;
DROP TABLE security.tipo_projeto_x_area_ti;
DROP TABLE security.status_projeto;
DROP TABLE security.tipo_projeto;

DROP SEQUENCE security.sq_projetos;
DROP SEQUENCE security.sq_projetos_historicos;
DROP SEQUENCE security.sq_tipo_projeto_x_area_ti;
DROP SEQUENCE security.sq_projetos_progresso_execucao;
DROP SEQUENCE security.sq_projetos_paralisacoes;
DROP SEQUENCE security.sq_projetos_interrupcoes;


-- Criar Sequences das tabelas de Controle de projetos
-- -----------------------------------------------------------------------------
CREATE SEQUENCE security.sq_tipo_projeto_x_area_ti      INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_projetos                    INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_projetos_historicos         INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_projetos_progresso_execucao INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_projetos_paralisacoes       INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_projetos_ajustes_prazo      INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_projetos_interrupcoes       INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

-- Criação das Tabelas para controle de De Projetos
-- -----------------------------------------------------------------------------
CREATE TABLE security.tipo_historico_projetos ( 
   id        integer     NOT NULL,
   descricao varchar(50) NOT NULL
);
CREATE TABLE security.tipo_projeto ( 
   id        integer      NOT NULL,
   sigla     varchar(4)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL
);
CREATE TABLE security.tipo_projeto_x_area_ti ( 
   id              integer NOT NULL DEFAULT 
                   nextval('security.sq_tipo_projeto_x_area_ti'),  
   id_tipo_projeto integer NOT NULL,
   id_area_ti      integer NOT NULL
);
CREATE TABLE security.status_projeto ( 
   id        integer      NOT NULL,
   sigla     varchar(4)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL,
   tipo      VARCHAR(50)  NOT NULL
);
CREATE TABLE security.prioridade_projeto ( 
   id        integer      NOT NULL,
   sigla     varchar(5)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL
);

CREATE TABLE security.projetos ( 
   id          integer NOT NULL DEFAULT 
               nextval('security.sq_projetos'),   
   codigo      varchar(6)   NOT NULL, -- ATTSSS - A-Area TT-Tipo Projeto SSS-Sequencial
   nome        varchar(100) NOT NULL,
   sigla       varchar(15)  NOT NULL,
   descricao   varchar(255) NOT NULL,
   interessado varchar(100) NOT NULL,
   descricao   varchar(500),
   data_inicio_previsto    date         NOT NULL,
   data_fim_previsto       date         NOT NULL,
   data_fim_previsto_atual date         NOT NULL,
   data_inicio_real        date,
   data_fim_real           date,
   prazo_inicial        integer      NOT NULL DEFAULT 0,
   dias_ajustados       integer      NOT NULL DEFAULT 0,
   dias_paralisado      integer      NOT NULL DEFAULT 0,
   observacao_progresso varchar(255),
   percentual_executado integer      NOT NULL DEFAULT 0,
   id_area_ti           integer      NOT NULL, -- 1 - Ger 2 - Des 3 - Sup 4 - Ate
   id_tipo              integer      NOT NULL, -- Ver Tabela
   id_status            integer      NOT NULL DEFAULT 1, -- 1 - A Iniciar
   id_prioridade        integer      NOT NULL DEFAULT 0, -- 1 - Nao Informada
   id_gerente           integer      NOT NULL DEFAULT 0, -- 1 - Nao Informado
   id_responsavel       integer      NOT NULL DEFAULT 0, -- 1 - Nao Informado
   id_modulo            integer,     -- Somente para projetos de desenvolvimento
   id_projeto_pai       integer,     -- Quando o projeto for subprojeto de um projeto maior
   id_paralisacao       integer      -- Ultima Paralisação cao exista
);

COMMENT ON COLUMN security.projetos.codigo               IS 'ATTSSS - A-Area TT-Tipo Projeto SSS-Sequencial';
COMMENT ON COLUMN security.projetos.nome                 IS 'Nome de identificação do projeto';
COMMENT ON COLUMN security.projetos.sigla                IS 'Sigla de identificação do projeto';
COMMENT ON COLUMN security.projetos.descricao            IS 'Breve descrição sob os objetivos do projeto';
COMMENT ON COLUMN security.projetos.interessado          IS 'Pessoa, Setor, Instituição que será beneficiado pelo Projeto';
COMMENT ON COLUMN security.projetos.data_inicio_previsto IS 'Data prevista para o projeto ter inicio';
COMMENT ON COLUMN security.projetos.data_fim_previsto    IS 'Data prevista para o projeto ser concluido';
COMMENT ON COLUMN security.projetos.data_fim_previsto_atual IS 'Ultima data prevista para o Fim do projeto';
COMMENT ON COLUMN security.projetos.data_inicio_real     IS 'Data real em que o projeto teve seu inicio';
COMMENT ON COLUMN security.projetos.data_fim_real        IS 'data real em que o projeto foi concluido';
COMMENT ON COLUMN security.projetos.prazo_inicial        IS 'Qtd de Dias estimado antes do projeto Iniciar ';
COMMENT ON COLUMN security.projetos.dias_ajustados       IS 'Somatorio de dias acrescido ou retirados do prazo total do projetos ';
COMMENT ON COLUMN security.projetos.dias_paralisado      IS 'Somatorio de dias paralizados';
COMMENT ON COLUMN security.projetos.observacao_progresso IS 'Observação livre para projetos em execução';
COMMENT ON COLUMN security.projetos.percentual_executado IS 'Percentual estimado da execução do projeto';
COMMENT ON COLUMN security.projetos.id_prioridade        IS 'Prioridade do projeto para o DER. ver tabela: prioridade_projeto';
COMMENT ON COLUMN security.projetos.id_area_ti           IS 'Área da TI do projeto. ver tabela: area_ti';
COMMENT ON COLUMN security.projetos.id_tipo              IS 'Tipo de Projeto. ver tabela: tipo_projeto';
COMMENT ON COLUMN security.projetos.id_status            IS 'Status do projeto. ver tabela: status_projeto';
COMMENT ON COLUMN security.projetos.id_gerente           IS 'Gerente do projeto. ver tabela: profissionais_ti'
COMMENT ON COLUMN security.projetos.id_responsavel       IS 'Responsavel direto pelo projeto. ver tabela: profissionais_ti';
COMMENT ON COLUMN security.projetos.id_modulo            IS 'Módulo do SIGDER a que o projeto se refere. ver tabela: modulos';
COMMENT ON COLUMN security.projetos.id_projeto_pai       IS 'Projeto de origem';
COMMENT ON COLUMN security.projetos.id_paralisacao       IS 'Id da ultima Paralisação registrada caso exista';

CREATE TABLE security.projetos_historicos (
  id_projeto        integer      NOT NULL,
  id                integer      DEFAULT
                    nextval('security.sq_projetos_historicos')   NOT NULL,
  data_hora         timestamp    WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  id_tipo_historico integer      NOT NULL,
  matricula         varchar(14)  NOT NULL,
  observacao        varchar(255) NOT NULL
) WITHOUT OIDS;

CREATE TABLE security.projetos_ajustes_prazo ( 
   id_projeto            integer      NOT NULL,
   id                    integer      NOT NULL DEFAULT 
                         nextval('security.sq_projetos_ajustes_prazo'),  
   motivo                varchar(255) NOT NULL,
   data_ajuste           date         NOT NULL DEFAULT now(),
   fim_previsto_anterior date         NOT NULL,
   dias_ajustados        integer      NOT NULL,
   novo_fim_previsto     date         NOT NULL,
   id_paralisacao        integer
);


CREATE TABLE security.projetos_progresso_execucao (
  id_projeto           INTEGER   NOT NULL, 
  id                   INTEGER   NOT NULL 
                       DEFAULT nextval('security.sq_projetos_progresso_execucao'), 
  data_historico       TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL, 
  percentual_executado INTEGER   NOT NULL DEFAULT 0, 
  observacao_progresso VARCHAR(255) 
) WITHOUT OIDS;

CREATE TABLE security.projetos_paralisacoes ( 
   id_projeto       integer      NOT NULL,
   id               integer      NOT NULL DEFAULT 
                    nextval('security.sq_projetos_paralisacoes'),  
   motivo           varchar(255) NOT NULL,
   data_paralisacao date         NOT NULL,
   data_reinicio    date,
   dias_parado      integer
);

CREATE TABLE security.projetos_interrupcoes ( 
   id_projeto          integer      NOT NULL,
   id                  integer      NOT NULL DEFAULT 
                       nextval('security.sq_projetos_interrupcoes'),  
   motivo              varchar(255) NOT NULL,
   data_interrupcao    date         NOT NULL,
   horas_interrompidas integer      NOT NULL DEFAULT 1,
   id_profissional     integer      NOT NULL, -- Profissional que está sendo interrompido
   id_atividade        integer                -- Atividade que está sendo interrompida
);

COMMENT ON COLUMN security.projetos_interrupcoes.motivo              IS 'Motivo pelo qual a Manutenção foi interrompida';
COMMENT ON COLUMN security.projetos_interrupcoes.data_interrupcao    IS 'Data em que a Manutenção foi interrompida';
COMMENT ON COLUMN security.projetos_interrupcoes.horas_interrompidas IS 'Qtd de Horas que a manutenção foi interrompida';
COMMENT ON COLUMN security.projetos_interrupcoes.id_profissional     IS 'Profissional que foi interrompido';
COMMENT ON COLUMN security.projetos_interrupcoes.id_atividade        IS 'Atividade do projeto que foi interrompida';


-- Criação das PRIMARY KEY das Tabelas de Controle de projetos
-- -----------------------------------------------------------------------------
ALTER TABLE security.tipo_historico_projetos     ADD CONSTRAINT pk_tipo_historico_projetos     PRIMARY KEY (id);
ALTER TABLE security.tipo_projeto                ADD CONSTRAINT pk_tipo_projeto                PRIMARY KEY (id);
ALTER TABLE security.tipo_projeto_x_area_ti      ADD CONSTRAINT pk_tipo_projeto_x_area_ti      PRIMARY KEY (id);
ALTER TABLE security.status_projeto              ADD CONSTRAINT pk_status_projeto              PRIMARY KEY (id);
ALTER TABLE security.prioridade_projeto          ADD CONSTRAINT pk_prioridade_projeto          PRIMARY KEY (id);
ALTER TABLE security.projetos                    ADD CONSTRAINT pk_projetos                    PRIMARY KEY (id);
ALTER TABLE security.projetos_historicos         ADD CONSTRAINT pk_projetos_historicos         PRIMARY KEY (id);
ALTER TABLE security.projetos_paralisacoes       ADD CONSTRAINT pk_projetos_paralisacoes       PRIMARY KEY (id);
ALTER TABLE security.projetos_progresso_execucao ADD CONSTRAINT pk_projetos_progresso_execucao PRIMARY KEY (id);
ALTER TABLE security.projetos_ajustes_prazo      ADD CONSTRAINT pk_projetos_ajustes_prazo      PRIMARY KEY (id);
ALTER TABLE security.projetos_interrupcoes       ADD CONSTRAINT pk_projetos_interrupcoes       PRIMARY KEY (id);
-- Criação das FOREIGN KEY´S das Tabelas de Controle de projetos
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.tipo_projeto_x_area_ti
  ADD CONSTRAINT fk_area_ti          FOREIGN KEY (id_area_ti) 
      REFERENCES security.area_ti (id); 
ALTER TABLE ONLY security.tipo_projeto_x_area_ti
  ADD CONSTRAINT fk_tipo_projeto     FOREIGN KEY (id_tipo_projeto) 
      REFERENCES security.tipo_projeto (id); 
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.projetos
  ADD CONSTRAINT fk_area_ti            FOREIGN KEY (id_area_ti) 
      REFERENCES security.area_ti (id); 
ALTER TABLE ONLY security.projetos
  ADD CONSTRAINT fk_tipo_projeto       FOREIGN KEY (id_tipo) 
      REFERENCES security.tipo_projeto (id); 
ALTER TABLE ONLY security.projetos
  ADD CONSTRAINT fk_status_projeto     FOREIGN KEY (id_status) 
      REFERENCES security.status_projeto (id); 
ALTER TABLE ONLY security.projetos
  ADD CONSTRAINT fk_prioridade_projeto FOREIGN KEY (id_prioridade) 
      REFERENCES security.prioridade_projeto (id); 
ALTER TABLE ONLY security.projetos
  ADD CONSTRAINT fk_responsavel   FOREIGN KEY (id_responsavel) 
      REFERENCES security.profissionais_ti (id); 
ALTER TABLE ONLY security.projetos
  ADD CONSTRAINT fk_gerente       FOREIGN KEY (id_gerente) 
      REFERENCES security.profissionais_ti (id); 
ALTER TABLE ONLY security.projetos
  ADD CONSTRAINT fk_modulos            FOREIGN KEY (id_modulo) 
      REFERENCES security.modulos (id); 
ALTER TABLE ONLY security.projetos
  ADD CONSTRAINT fk_projeto_pai        FOREIGN KEY (id_projeto_pai) 
      REFERENCES security.projetos (id); 
ALTER TABLE ONLY security.projetos
  ADD CONSTRAINT fk_paralisacao        FOREIGN KEY (id_paralisacao) 
      REFERENCES security.projetos_paralisacoes (id); 
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.projetos_historicos
  ADD CONSTRAINT fk_projeto          FOREIGN KEY (id_projeto) 
      REFERENCES security.projetos (id); 
ALTER TABLE ONLY security.projetos_historicos
  ADD CONSTRAINT fk_tipo_historico   FOREIGN KEY (id_tipo_historico) 
      REFERENCES security.tipo_historico_projetos (id); 
ALTER TABLE ONLY security.projetos_historicos
  ADD CONSTRAINT fk_matricula        FOREIGN KEY (matricula) 
      REFERENCES security.users (matricula); 
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.projetos_ajustes_prazo
  ADD CONSTRAINT fk_projeto             FOREIGN KEY (id_projeto) 
      REFERENCES security.projetos (id); 
ALTER TABLE ONLY security.projetos_ajustes_prazo
  ADD CONSTRAINT fk_projeto_paralisacao FOREIGN KEY (id_paralisacao) 
      REFERENCES security.projetos_paralisacoes (id); 
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.projetos_paralisacoes
  ADD CONSTRAINT fk_projeto      FOREIGN KEY (id_projeto) 
      REFERENCES security.projetos (id); 
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.projetos_progresso_execucao
  ADD CONSTRAINT fk_projeto      FOREIGN KEY (id_projeto) 
      REFERENCES security.projetos (id); 

-- FOREIGN KEY da tabela: security.projetos_interrupcoes
ALTER TABLE ONLY security.projetos_interrupcoes
  ADD CONSTRAINT fk_projetos FOREIGN KEY (id_projeto) 
      REFERENCES security.projetos (id); 
      
ALTER TABLE ONLY security.projetos_interrupcoes
  ADD CONSTRAINT fk_profissionais_ti    FOREIGN KEY (id_profissional) 
      REFERENCES security.profissionais_ti (id); 
      
ALTER TABLE ONLY security.projetos_interrupcoes
  ADD CONSTRAINT fk_atividades          FOREIGN KEY (id_atividade) 
      REFERENCES security.atividades (id); 

-- INSERTS da tabela: security.status_projeto
-- -----------------------------------------------------------------------------
INSERT INTO security.status_projeto(id, cor, sigla, nome, tipo, descricao) VALUES (1,'#000000','ACON','Aguardando Concepção','AGUARDANDO_CONCEPCAO' ,'Projeto Incluido em fase de concepção!');
INSERT INTO security.status_projeto(id, cor, sigla, nome, tipo, descricao) VALUES (2,'#000000','AAPR','Aguardando Aprovação','AGUARDANDO_APROVACAO' ,'Projeto Apresentado para gestor e aguardando aprovação!');
INSERT INTO security.status_projeto(id, cor, sigla, nome, tipo, descricao) VALUES (3,'#000000','AINI','Aguardando Iniciar'  ,'AGUARDANDO_INICIAR'   ,'Projeto Aprovado pelo gestor e Aguardando Inicio!');
INSERT INTO security.status_projeto(id, cor, sigla, nome, tipo, descricao) VALUES (4,'#000000','EXEC','Em Execução'         ,'EM_EXECUCAO'          ,'Projeto Em execução!');
INSERT INTO security.status_projeto(id, cor, sigla, nome, tipo, descricao) VALUES (5,'#000000','PARA','Paralisado'          ,'PARALISADO'           ,'Projeto Paralisado temporriamente!');
INSERT INTO security.status_projeto(id, cor, sigla, nome, tipo, descricao) VALUES (6,'#000000','CANC','Cancelado'           ,'CANCELADO'            ,'Projeto Cancelado sem execução ou com execução parcial!');
INSERT INTO security.status_projeto(id, cor, sigla, nome, tipo, descricao) VALUES (7,'#000000','CONC','Concluido'           ,'CONCLUIDO'            ,'Projeto Concluido 100%!');

-- INSERTS da tabela: security.tipo_historico_projetos
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_historico_projetos (id, descricao) VALUES (1,'Projeto Cadastrado.');
INSERT INTO security.tipo_historico_projetos (id, descricao) VALUES (2,'Projeto Apresentado.');
INSERT INTO security.tipo_historico_projetos (id, descricao) VALUES (3,'Projeto Aprovado.');
INSERT INTO security.tipo_historico_projetos (id, descricao) VALUES (4,'Projeto Paralisado.');
INSERT INTO security.tipo_historico_projetos (id, descricao) VALUES (5,'Projeto Cancelado.');
INSERT INTO security.tipo_historico_projetos (id, descricao) VALUES (6,'Execução do Projeto Iniciada.');
INSERT INTO security.tipo_historico_projetos (id, descricao) VALUES (7,'Projeto Concluido.'); 
INSERT INTO security.tipo_historico_projetos (id, descricao) VALUES (8,'Acompanhamento do Projeto Registrado.'); 
INSERT INTO security.tipo_historico_projetos (id, descricao) VALUES (9,'Projeto Retorna ao Modo de Concepção.'); 

-- INSERTS da tabela: security.tipo_projeto
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_projeto (id, sigla, nome, descricao) VALUES (1,'DESE','Desenvolvimento'      ,'Desenvolvimento de Sistemas');
INSERT INTO security.tipo_projeto (id, sigla, nome, descricao) VALUES (2,'TREI','Treinamento'          ,'Treinamento de usuario');
INSERT INTO security.tipo_projeto (id, sigla, nome, descricao) VALUES (3,'MIGR','Migração'             ,'Migração de software (SO - Escritório...) para plataforma livre');
INSERT INTO security.tipo_projeto (id, sigla, nome, descricao) VALUES (4,'MELH','Melhoria de Processos','');
INSERT INTO security.tipo_projeto (id, sigla, nome, descricao) VALUES (5,'AQUI','Aquisição'            ,'Aquisição de produtos e Serviços');

-- INSERTS da tabela: security.prioridade_projeto
-- -----------------------------------------------------------------------------
INSERT INTO security.prioridade_projeto(id, cor, sigla, nome, descricao) VALUES (0,'#000000','NINFO','Não Informado'   ,'Projetos sem Prioridade Definida');
INSERT INTO security.prioridade_projeto(id, cor, sigla, nome, descricao) VALUES (1,'#000000','ALTA' ,'Prioridade Alta' ,'Projetos com Prioridade Definida como Alta');
INSERT INTO security.prioridade_projeto(id, cor, sigla, nome, descricao) VALUES (2,'#000000','MÉDIA','Prioridade Média','Projetos com Prioridade Definida como Média');
INSERT INTO security.prioridade_projeto(id, cor, sigla, nome, descricao) VALUES (3,'#000000','BAIXA','Prioridade Baixa','Projetos com Prioridade Definida como Baixa');
-- =============================================================================
-- FIM: Controle de Projetos
-- =============================================================================

-- =============================================================================
-- INICIO: Controle de Manutenção de sistemas
-- =============================================================================  
DROP TABLE security.manutencoes_sistema_historicos;
DROP TABLE security.manutencoes_sistema_paralisacoes;
DROP TABLE security.manutencoes_sistema;
DROP TABLE security.status_manutencao_sistema;
DROP TABLE security.tipo_manutencao_sistema;
DROP TABLE security.tipo_historico_manutencao_sis;

DROP SEQUENCE security.sq_manutencoes_sistema;
DROP SEQUENCE security.sq_manutencoes_sistema_historicos;
DROP SEQUENCE security.sq_manutencoes_sistema_paralisacoes;
DROP SEQUENCE security.sq_manutencoes_sistema_interrupcoes;

-- Criar Sequences das tabelas de Controle de Manutenção de sistemas
-- -----------------------------------------------------------------------------
CREATE SEQUENCE security.sq_manutencoes_sistema              INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_manutencoes_sistema_historicos   INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_manutencoes_sistema_paralisacoes INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_manutencoes_sistema_interrupcoes INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

-- Criação das Tabelas para Controle de Manutenção de sistemas
-- -----------------------------------------------------------------------------
CREATE TABLE security.tipo_historico_manutencao_sis ( 
   id        integer     NOT NULL,
   descricao varchar(50) NOT NULL
);

CREATE TABLE security.status_manutencao_sistema( 
   id        integer      NOT NULL,
   sigla     varchar(4)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL,
   tipo      varchar(50)  NOT NULL
);

CREATE TABLE security.tipo_manutencao_sistema ( 
   id              integer      NOT NULL,   
   sigla           varchar(10)  NOT NULL,
   nome            varchar(50)  NOT NULL,
   descricao       varchar(255) NOT NULL
);

CREATE TABLE security.manutencoes_sistema ( 
   id_modulo            integer NOT NULL,
   id                   integer NOT NULL DEFAULT 
                        nextval('security.sq_manutencoes_sistema'), 
   codigo               varchar(6)   NOT NULL, -- MMMSSS - MMM-Codigo Módulo  SSS-Sequencial Manutenção
   descricao            varchar(255) NOT NULL,
   solicitado_por       varchar(100) NOT NULL,
   data_inicio_previsto date         NOT NULL,
   data_fim_previsto    date         NOT NULL,
   data_inicio_real     date,
   data_fim_real        date,
   id_tipo              integer      NOT NULL,
   id_responsavel       integer      NOT NULL,
   id_paralisacao       integer,
   id_modulo_versao     integer,
   id_status            integer      NOT NULL DEFAULT 1,
   percentual_executado integer      NOT NULL DEFAULT 0,
   observacao_progresso varchar(255),
   observacao           varchar(500)
);
COMMENT ON COLUMN security.manutencoes_sistema.codigo               IS 'MMMSSS Onde: MMM = Código do Módulo e SSS = Sequencial Gerado';
COMMENT ON COLUMN security.manutencoes_sistema.descricao            IS 'Resumo sobre as ações realizada pela manutenção';
COMMENT ON COLUMN security.manutencoes_sistema.solicitado_por       IS 'Nome de quem solicitou a manutenção';
COMMENT ON COLUMN security.manutencoes_sistema.id_tipo              IS 'Ver tabela tipo de Manutenção';
COMMENT ON COLUMN security.manutencoes_sistema.id_responsavel       IS 'Pessoa que reponde pela manutenção';
COMMENT ON COLUMN security.manutencoes_sistema.id_status            IS '1-A iniciar 2-Iniciada 3-Paralisada 4-Cancelada 5-Concluida';
COMMENT ON COLUMN security.manutencoes_sistema.id_paralisacao       IS 'Id da ultima Paralisação registrada caso exista';
COMMENT ON COLUMN security.manutencoes_sistema.id_modulo_versao     IS 'Versão do Módulo em que a manutenção foi implantada ao sigder';
COMMENT ON COLUMN security.manutencoes_sistema.percentual_executado IS 'Percentual estimado da execução da manutenção do sistema';
COMMENT ON COLUMN security.manutencoes_sistema.observacao_progresso IS 'Observação sobre a execução da manutenção do sistema';
COMMENT ON COLUMN security.manutencoes_sistema.observacao           IS 'Observações adicionais sobre a manutenção';

CREATE TABLE security.manutencoes_sistema_historicos(
  id_manutencao     integer      NOT NULL,
  id                integer      NOT NULL DEFAULT
                    nextval('security.sq_manutencoes_sistema_historicos'),
  data_hora         timestamp    WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  id_tipo_historico integer      NOT NULL,
  matricula         varchar(14)  NOT NULL,
  observacao        varchar(255) NOT NULL
) WITHOUT OIDS;

CREATE TABLE security.manutencoes_sistema_paralisacoes ( 
   id_manutencao   integer      NOT NULL,
   id               integer      NOT NULL DEFAULT 
                    nextval('security.sq_manutencoes_sistema_paralisacoes'),  
   motivo           varchar(255) NOT NULL,
   data_paralisacao date         NOT NULL,
   data_reinicio    date,
   dias_parado      integer
);

CREATE TABLE security.manutencoes_sistema_interrupcoes ( 
   id_manutencao       integer      NOT NULL,
   id                  integer      NOT NULL DEFAULT 
                       nextval('security.sq_manutencoes_sistema_interrupcoes'),  
   motivo              varchar(255) NOT NULL,
   data_interrupcao    date         NOT NULL,
   horas_interrompidas integer      NOT NULL DEFAULT 1,
   id_profissional     integer      NOT NULL, -- Profissional que está sendo interrompido
   id_atividade        integer                -- Atividade que está sendo interrompida   
);
COMMENT ON COLUMN security.manutencoes_sistema_interrupcoes.motivo              IS 'Motivo pelo qual a Manutenção foi interrompida';
COMMENT ON COLUMN security.manutencoes_sistema_interrupcoes.data_interrupcao    IS 'Data em que a Manutenção foi interrompida';
COMMENT ON COLUMN security.manutencoes_sistema_interrupcoes.horas_interrompidas IS 'Qtd de Horas que a manutenção foi interrompida';
COMMENT ON COLUMN security.manutencoes_sistema_interrupcoes.id_profissional     IS 'Profissional que foi interrompido';
COMMENT ON COLUMN security.manutencoes_sistema_interrupcoes.id_atividade        IS 'Atividade da manutenção que foi interrompida';

-- Criação das PRIMARY KEY das Tabelas de Controle de Manutenção de sistemas
-- -----------------------------------------------------------------------------
ALTER TABLE security.tipo_manutencao_sistema          ADD CONSTRAINT pk_tipo_manutencao_sistema          PRIMARY KEY (id);
ALTER TABLE security.status_manutencao_sistema        ADD CONSTRAINT pk_status_manutencao_sistema        PRIMARY KEY (id);
ALTER TABLE security.tipo_historico_manutencao_sis    ADD CONSTRAINT pk_tipo_historico_manutencao_sis    PRIMARY KEY (id);
ALTER TABLE security.manutencoes_sistema              ADD CONSTRAINT pk_manutencoes_sistema              PRIMARY KEY (id);
ALTER TABLE security.manutencoes_sistema_historicos   ADD CONSTRAINT pk_manutencoes_sistema_historicos   PRIMARY KEY (id);
ALTER TABLE security.manutencoes_sistema_paralisacoes ADD CONSTRAINT pk_manutencoes_sistema_paralisacoes PRIMARY KEY (id);
ALTER TABLE security.manutencoes_sistema_interrupcoes ADD CONSTRAINT pk_manutencoes_sistema_interrupcoes PRIMARY KEY (id);

-- Criação das FOREIGN KEY´S das Tabelas para Manutenção de sistemas
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.manutencoes_sistema
  ADD CONSTRAINT fk_modulos                FOREIGN KEY (id_modulo) 
      REFERENCES security.modulos (id); 

ALTER TABLE ONLY security.manutencoes_sistema
  ADD CONSTRAINT fk_tipo_manutencao_sistema FOREIGN KEY (id_tipo) 
      REFERENCES security.tipo_manutencao_sistema (id); 
      
ALTER TABLE ONLY security.manutencoes_sistema
  ADD CONSTRAINT fk_responsavel             FOREIGN KEY (id_responsavel) 
      REFERENCES security.profissionais_ti (id); 

ALTER TABLE ONLY security.manutencoes_sistema
  ADD CONSTRAINT fk_status           FOREIGN KEY (id_status) 
      REFERENCES security.status_manutencao_sistema (id); 
      
ALTER TABLE ONLY security.manutencoes_sistema
  ADD CONSTRAINT fk_paralisacao      FOREIGN KEY (id_paralisacao) 
      REFERENCES security.manutencoes_sistema_paralisacoes (id); 

-- FOREIGN KEY da tabela: security.manutencoes_sistema_historicos
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.manutencoes_sistema_historicos
  ADD CONSTRAINT fk_manutencoes_sistema FOREIGN KEY (id_manutencao) 
      REFERENCES security.manutencoes_sistema (id); 

ALTER TABLE ONLY security.manutencoes_sistema_historicos
  ADD CONSTRAINT fk_tipo_historico      FOREIGN KEY (id_tipo_historico) 
      REFERENCES security.tipo_historico_manutencao_sis (id); 

ALTER TABLE ONLY security.manutencoes_sistema_historicos
  ADD CONSTRAINT fk_matricula           FOREIGN KEY (matricula) 
      REFERENCES security.users (matricula); 
      
-- FOREIGN KEY da tabela: security.manutencoes_sistema_paralisacoes
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.manutencoes_sistema_paralisacoes
  ADD CONSTRAINT fk_manutencoes_sistema FOREIGN KEY (id_manutencao) 
      REFERENCES security.manutencoes_sistema (id); 

-- FOREIGN KEY da tabela: security.manutencoes_sistema_interrupcoes
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.manutencoes_sistema_interrupcoes
  ADD CONSTRAINT fk_manutencoes_sistema FOREIGN KEY (id_manutencao) 
      REFERENCES security.manutencoes_sistema (id); 
      
ALTER TABLE ONLY security.manutencoes_sistema_interrupcoes
  ADD CONSTRAINT fk_profissionais_ti    FOREIGN KEY (id_profissional) 
      REFERENCES security.profissionais_ti (id); 
      
ALTER TABLE ONLY security.manutencoes_sistema_interrupcoes
  ADD CONSTRAINT fk_atividades          FOREIGN KEY (id_atividade) 
      REFERENCES security.atividades (id); 

-- INSERTS da tabela: security.tipo_manutencao_sistema
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_manutencao_sistema (id, sigla, nome, descricao) VALUES (1,'CORR','Corretiva'  ,'Modificação reativa para corrigir problemas identificados!');
INSERT INTO security.tipo_manutencao_sistema (id, sigla, nome, descricao) VALUES (2,'PREV','Preventiva' ,'Modificação realizada para detectar e corrigir faltas latentes no produto antes delas se tornarem faltas efetivas!');
INSERT INTO security.tipo_manutencao_sistema (id, sigla, nome, descricao) VALUES (3,'MELH','Melhorias'  ,'Modificação realizada para melhor performance ou a manutenibilidade!');
INSERT INTO security.tipo_manutencao_sistema (id, sigla, nome, descricao) VALUES (4,'ADAP','Adaptativas','Modificação realizada para manter o software usável num ambiente de mudança!');

-- INSERTS da tabela: security.status_manutencao_sistema
-- -----------------------------------------------------------------------------
INSERT INTO security.status_manutencao_sistema(id, cor, sigla, nome, tipo, descricao) VALUES (1,'#000000','AINI','A Iniciar'  ,'A_INICIAR'  ,'Manutenção ainda não Iniciada!');
INSERT INTO security.status_manutencao_sistema(id, cor, sigla, nome, tipo, descricao) VALUES (2,'#000000','INIC','Em Execução','EM_EXECUCAO','Execução da Manutenção Em andamento!');
INSERT INTO security.status_manutencao_sistema(id, cor, sigla, nome, tipo, descricao) VALUES (3,'#000000','PARA','Paralisada' ,'PARALISADA' ,'Execução da Manutenção Paralisada!');
INSERT INTO security.status_manutencao_sistema(id, cor, sigla, nome, tipo, descricao) VALUES (4,'#000000','CANC','Cancelada'  ,'CANCELADA'  ,'Execução da Manutenção Cancelada!');
INSERT INTO security.status_manutencao_sistema(id, cor, sigla, nome, tipo, descricao) VALUES (5,'#000000','CONC','Concluida'  ,'CONCLUIDA'  ,'Execução da Manutenção Concluida!');

-- INSERTS da tabela: security.tipo_historico_manutencao_sis
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_historico_manutencao_sis (id, descricao) VALUES (1,'Manutenção de Sistema Cadastrada.');
INSERT INTO security.tipo_historico_manutencao_sis (id, descricao) VALUES (2,'Manutenção de Sistema Iniciada.');
INSERT INTO security.tipo_historico_manutencao_sis (id, descricao) VALUES (3,'Manutenção de Sistema Paralisada.');
INSERT INTO security.tipo_historico_manutencao_sis (id, descricao) VALUES (4,'Manutenção de Sistema Cancelada.');
INSERT INTO security.tipo_historico_manutencao_sis (id, descricao) VALUES (5,'Manutenção de Sistema Concluida.');
INSERT INTO security.tipo_historico_manutencao_sis (id, descricao) VALUES (6,'Manutenção de Sistema Reiniciada.');
-- =============================================================================
-- FIM: Controle de Manutenção de sistemas
-- =============================================================================

-- =============================================================================
-- INICIO: Controle de Atividades
-- =============================================================================
DROP TABLE security.atividades_historicos;
DROP TABLE security.atividades_projeto;
DROP TABLE security.atividades_manutencao;
DROP TABLE security.atividades_progresso_execucao;
DROP TABLE security.atividades_recursos_materiais;
DROP TABLE security.atividades_x_profissionais_ti;
DROP TABLE security.atividades;

DROP TABLE security.status_atividade;
DROP TABLE security.tipo_atividade;
DROP TABLE security.tipo_acompanhamento_atividade;
DROP TABLE security.tipo_recurso_material;
DROP TABLE security.tipo_historico_atividades;
DROP TABLE security.prioridade_atividade; 

DROP SEQUENCE security.sq_atividades;
DROP SEQUENCE security.sq_atividades_progresso_execucao;
DROP SEQUENCE security.sq_atividades_x_profissionais_ti;
DROP SEQUENCE security.sq_atividades_recursos_materiais;
DROP SEQUENCE security.sq_atividades_historicos;

-- Criar Sequences das tabelas de Controle de atividades
-- -----------------------------------------------------------------------------
CREATE SEQUENCE security.sq_atividades                    INCREMENT 1  MINVALUE 1  MAXVALUE 2147483647  START 1 CACHE 1;
CREATE SEQUENCE security.sq_atividades_progresso_execucao INCREMENT 1  MINVALUE 1  MAXVALUE 2147483647  START 1 CACHE 1;
CREATE SEQUENCE security.sq_atividades_x_profissionais_ti INCREMENT 1  MINVALUE 1  MAXVALUE 2147483647  START 1 CACHE 1;
CREATE SEQUENCE security.sq_atividades_recursos_materiais INCREMENT 1  MINVALUE 1  MAXVALUE 2147483647  START 1 CACHE 1;
CREATE SEQUENCE security.sq_atividades_historicos         INCREMENT 1  MINVALUE 1  MAXVALUE 2147483647  START 1 CACHE 1;

-- Criação das Tabelas para controle de De Atividades
-- -----------------------------------------------------------------------------
CREATE TABLE security.prioridade_atividade ( 
   id        integer      NOT NULL,
   sigla     varchar(5)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL
);
CREATE TABLE security.tipo_historico_atividades ( 
   id        integer     NOT NULL,
   descricao varchar(50) NOT NULL
);
CREATE TABLE security.status_atividade ( 
   id        integer      NOT NULL,
   sigla     varchar(4)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   cor       varchar(8)   NOT NULL,
   tipo      varchar(50)  NOT NULL
);
CREATE TABLE security.tipo_atividade ( 
   id        integer      NOT NULL,
   sigla     varchar(4)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL
);
CREATE TABLE security.tipo_acompanhamento_atividade ( 
   id        integer      NOT NULL,
   sigla     varchar(4)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL
);
CREATE TABLE security.tipo_recurso_material ( 
   id        integer      NOT NULL,
   sigla     varchar(4)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL
);

CREATE TABLE security.atividades ( 
   id                      integer      NOT NULL DEFAULT 
                           nextval('security.sq_atividades'), 
   codigo                  varchar(10)  NOT NULL, -- P999999SSSS
   descricao               varchar(150) NOT NULL,
   data_inicio_previsto    date         NOT NULL,
   data_fim_previsto       date         NOT NULL,
   data_inicio_real        date,   -- Quando informado gerar Progresso com 0%
   data_fim_real           date, 
   horas_pervista          integer      NOT NULL DEFAULT 1, 
   horas_real              integer, 
   id_tipo_atividade       integer      NOT NULL, -- 1-Projeto 2-Manutenção 3-avulsa
   id_status               integer      NOT NULL DEFAULT 1, 
   id_tipo_acompanhamento  integer      NOT NULL DEFAULT 0, 
   -- Obrigatorio se id_tipo_acompanhamento > 0
   quantidade              integer       NOT NULL DEFAULT 1, 
   quantidade_executada    integer       NOT NULL DEFAULT 0, 
   percentual_executado    integer       NOT NULL DEFAULT 0,
   id_atividade_pai        integer,
   -- Atributos de Atividade de Projeto
   id_projeto              integer, 
   id_fase_desenvolvimento integer,
   -- Atributos de atividade de Manutenção
   id_manutencao_sistema   integer,
   id_caso_de_uso          integer,
   -- Atributos de atividade diversa
   id_area_ti              integer,
   id_criador              varchar(14),
   -- Atributos de Prioridade da Atividade
   id_prioridade           integer      NOT NULL DEFAULT 0, -- 1 - Nao Informada
);

COMMENT ON COLUMN security.atividades.descricao               IS 'Ação que a atividade deve realizar';
COMMENT ON COLUMN security.atividades.data_inicio_previsto    IS 'Data em que se pretende iniciar a execução da atividade';
COMMENT ON COLUMN security.atividades.data_fim_previsto       IS 'Data em que se pretende concluir a termino da atividade';
COMMENT ON COLUMN security.atividades.data_inicio_real        IS 'Data em que efetivamente se iniciou a execução da atividade';
COMMENT ON COLUMN security.atividades.data_fim_real           IS 'Data em que efetivamente se concluiu o término da atividade';
COMMENT ON COLUMN security.atividades.horas_prevista          IS 'Horas prevista para ser utiliada na execução da atividade';
COMMENT ON COLUMN security.atividades.horas_real              IS 'Horas efetivamente utiliadas na execução da atividade';
COMMENT ON COLUMN security.atividades.id_tipo_atividade       IS '1-Projeto 2-Manutenção 3-avulsa';
COMMENT ON COLUMN security.atividades.id_status               IS '1-A iniciar 2-Iniciada 3-Paralisada 4-Cancelada 5-Concluida';
COMMENT ON COLUMN security.atividades.id_tipo_acompanhamento  IS '0-Sem Histórico 1-Por % 2 Por Quantidade';
COMMENT ON COLUMN security.atividades.id_atividade_pai        IS '';
COMMENT ON COLUMN security.atividades.id_projeto              IS '';
COMMENT ON COLUMN security.atividades.id_fase_desenvolvimento IS '';
COMMENT ON COLUMN security.atividades.id_manutencao_sistema   IS '';
COMMENT ON COLUMN security.atividades.id_caso_de_uso          IS '';
COMMENT ON COLUMN security.atividades.id_area_ti              IS '';
COMMENT ON COLUMN security.atividades.id_criador              IS '';
COMMENT ON COLUMN security.atividades.id_prioridade           IS 'Prioridade do projeto para o DER. ver tabela: prioridade_atividade';

-- Gerar o conteudo desta tabela na trigger AFTER UPDATE da tabela atividades
CREATE TABLE security.atividades_progresso_execucao ( 
   id                   integer   NOT NULL DEFAULT 
                        nextval('security.sq_atividades_progresso_execucao'),  
   id_atividade         integer   NOT NULL,
   data_historico       timestamp NOT NULL DEFAULT now(),
   quantidade_executada integer, 
   percentual_executado integer   
);

CREATE TABLE security.atividades_x_profissionais_ti ( 
   id              integer NOT NULL DEFAULT 
                   nextval('security.sq_atividades_x_profissionais_ti'),  
   id_atividade    integer NOT NULL,
   id_profissional integer NOT NULL,
   observacao      varchar(255) 
);

CREATE TABLE security.atividades_recursos_materiais ( 
   id              integer NOT NULL DEFAULT 
                   nextval('security.sq_atividades_recursos_materiais'),
   id_atividade    integer NOT NULL,
   id_tipo_recurso integer NOT NULL, -- 1-Equipamento 2-Local
   descricao       varchar(100),
   observacao      varchar(255)
);

CREATE TABLE security.atividades_historicos (
  id_atividade      integer      NOT NULL,
  id                integer      DEFAULT
                    nextval('security.sq_atividades_historicos') NOT NULL,
  data_hora         timestamp    WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  id_tipo_historico integer      NOT NULL,
  matricula         varchar(14)  NOT NULL,
  observacao        varchar(255) NOT NULL
) WITHOUT OIDS;


-- Criação das PRIMARY KEY das Tabelas para controle de De Atividades
-- -----------------------------------------------------------------------------
ALTER TABLE security.prioridade_atividade          ADD CONSTRAINT pk_prioridade_atividade          PRIMARY KEY (id);
ALTER TABLE security.status_atividade              ADD CONSTRAINT pk_status_atividade              PRIMARY KEY (id);
ALTER TABLE security.tipo_atividade                ADD CONSTRAINT pk_tipo_atividade                PRIMARY KEY (id);
ALTER TABLE security.tipo_recurso_material         ADD CONSTRAINT pk_tipo_recurso_material         PRIMARY KEY (id);
ALTER TABLE security.tipo_acompanhamento_atividade ADD CONSTRAINT pk_tipo_acompanhamento_atividade PRIMARY KEY (id);
ALTER TABLE security.atividades                    ADD CONSTRAINT pk_atividades                    PRIMARY KEY (id);
ALTER TABLE security.atividades_progresso_execucao ADD CONSTRAINT pk_atividades_progresso_execucao PRIMARY KEY (id);
ALTER TABLE security.atividades_x_profissionais_ti ADD CONSTRAINT pk_atividades_x_profissionais_ti PRIMARY KEY (id);
ALTER TABLE security.atividades_recursos_materiais ADD CONSTRAINT pk_atividades_recursos_materiais PRIMARY KEY (id);
ALTER TABLE security.tipo_historico_atividades     ADD CONSTRAINT pk_tipo_historico_atividades     PRIMARY KEY (id);
ALTER TABLE security.atividades_historicos         ADD CONSTRAINT pk_atividades_historicos         PRIMARY KEY (id);

-- -----------------------------------------------------------------------------
-- Criação das FOREIGN KEY´S das Tabelas para controle de De Atividades
-- -----------------------------------------------------------------------------
-- FOREIGN KEY da tabela: security.atividades
ALTER TABLE ONLY security.atividades
  ADD CONSTRAINT fk_status_atividade              FOREIGN KEY (id_status) 
      REFERENCES security.status_atividade (id); 

ALTER TABLE ONLY security.atividades
  ADD CONSTRAINT fk_tipo_atividade                FOREIGN KEY (id_tipo_atividade) 
      REFERENCES security.tipo_atividade (id);

ALTER TABLE ONLY security.atividades
  ADD CONSTRAINT fk_tipo_acompanhamento_atividade FOREIGN KEY (id_tipo_acompanhamento) 
      REFERENCES security.tipo_acompanhamento_atividade (id);

ALTER TABLE ONLY security.atividades 
  ADD CONSTRAINT fk_atividade_pai                 FOREIGN KEY (id_atividade_pai) 
      REFERENCES security.atividades (id); 

-- FOREIGN KEY da tabela: security.atividades_projeto
ALTER TABLE ONLY security.atividades
  ADD CONSTRAINT fk_projetos             FOREIGN KEY (id_projeto) 
      REFERENCES security.projetos (id);  

ALTER TABLE ONLY security.atividades
  ADD CONSTRAINT fk_fase_projeto_sistema FOREIGN KEY (id_fase_desenvolvimento) 
      REFERENCES security.fase_desenvolvimento (id); 

-- FOREIGN KEY da tabela: security.atividades_manutencao 
ALTER TABLE ONLY security.atividades 
  ADD CONSTRAINT fk_manutencoes_sistema   FOREIGN KEY (id_manutencao_sistema) 
      REFERENCES security.manutencoes_sistema (id);    

-- FOREIGN KEY da tabela: security.atividades_diversa
ALTER TABLE ONLY security.atividades
  ADD CONSTRAINT fk_area_ti            FOREIGN KEY (id_area_ti) 
      REFERENCES security.area_ti (id); 

-- FOREIGN KEY da tabela: security.atividades_progresso_execucao
ALTER TABLE ONLY security.atividades_progresso_execucao
  ADD CONSTRAINT fk_atividades            FOREIGN KEY (id_atividade) 
      REFERENCES security.atividades (id);

-- FOREIGN KEY da tabela: security.atividades_x_profissionais_ti
ALTER TABLE ONLY security.atividades_x_profissionais_ti
  ADD CONSTRAINT fk_atividades            FOREIGN KEY (id_atividade) 
      REFERENCES security.atividades (id);

ALTER TABLE ONLY security.atividades_x_profissionais_ti
  ADD CONSTRAINT fk_profissionais         FOREIGN KEY (id_profissional) 
      REFERENCES security.profissionais_ti (id);

-- FOREIGN KEY da tabela: security.atividades_recursos_materiais
ALTER TABLE ONLY security.atividades_recursos_materiais
  ADD CONSTRAINT fk_atividades            FOREIGN KEY (id_atividade) 
      REFERENCES security.atividades (id);

ALTER TABLE ONLY security.atividades_recursos_materiais
  ADD CONSTRAINT fk_tipo_recurso_material FOREIGN KEY (id_tipo_recurso) 
      REFERENCES security.tipo_recurso_material (id);

-- FOREIGN KEY da tabela: security.atividades_historicos
ALTER TABLE ONLY security.atividades_historicos
  ADD CONSTRAINT fk_atividades     FOREIGN KEY (id_atividade) 
      REFERENCES security.atividades (id); 

ALTER TABLE ONLY security.atividades_historicos
  ADD CONSTRAINT fk_tipo_historico FOREIGN KEY (id_tipo_historico) 
      REFERENCES security.tipo_historico_atividades (id); 

ALTER TABLE ONLY security.atividades_historicos
  ADD CONSTRAINT fk_matricula      FOREIGN KEY (matricula) 
      REFERENCES security.users (matricula); 
    

-- INSERTS da tabela: security.prioridade_atividade
-- -----------------------------------------------------------------------------
INSERT INTO security.prioridade_atividade(id, cor, sigla, nome, descricao) VALUES (0,'#000000','NINFO','Não Informado'   ,'Atividades sem Prioridade Definida');
INSERT INTO security.prioridade_atividade(id, cor, sigla, nome, descricao) VALUES (1,'#000000','ALTA' ,'Prioridade Alta' ,'Atividades com Prioridade Definida como Alta');
INSERT INTO security.prioridade_atividade(id, cor, sigla, nome, descricao) VALUES (2,'#000000','MÉDIA','Prioridade Média','Atividades com Prioridade Definida como Média');
INSERT INTO security.prioridade_atividade(id, cor, sigla, nome, descricao) VALUES (3,'#000000','BAIXA','Prioridade Baixa','Atividades com Prioridade Definida como Baixa');

-- INSERTS da tabela: security.tipo_atividade
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_atividade(id, sigla, nome, descricao) VALUES (1,'PROJ','Projeto'    ,'Atividades Vincluladas a um projeto!');
INSERT INTO security.tipo_atividade(id, sigla, nome, descricao) VALUES (2,'MANU','Manutenção' ,'Atividades Vincluladas a um processo de manutenção de sistema!');
INSERT INTO security.tipo_atividade(id, sigla, nome, descricao) VALUES (3,'DIVE','Diversa'    ,'Atividades diversas relalizadas na GETIC!');
-- INSERTS da tabela: security.tipo_acompanhamento_atividade
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_acompanhamento_atividade(id, sigla, nome, descricao) VALUES (1,'SACO','Sem Acompanhamento','Para Atividades que não necessitem de acompanhamento!');
INSERT INTO security.tipo_acompanhamento_atividade(id, sigla, nome, descricao) VALUES (2,'PERC','Por Percentual'    ,'Controla Percental executado das Atividades!');
INSERT INTO security.tipo_acompanhamento_atividade(id, sigla, nome, descricao) VALUES (3,'QUAN','Por Quantidade'    ,'Controla Quantidade exxecutada das atividades!');
INSERT INTO security.tipo_acompanhamento_atividade(id, sigla, nome, descricao) VALUES (4,'PRAZ','Por Prazo limite'  ,'Controla prazo restante para termino da execução!');
-- INSERTS da tabela: security.status_atividade
-- -----------------------------------------------------------------------------
INSERT INTO security.status_atividade(id, cor, sigla, nome, tipo, descricao) VALUES (1,'#000000','AINI','A Iniciar' ,'A_INICIAR' ,'Execução da Atividade ainda não Iniciada!');
INSERT INTO security.status_atividade(id, cor, sigla, nome, tipo, descricao) VALUES (2,'#000000','INIC','Iniciada'  ,'INICIADA'  ,'Execução da Atividade Em andamento!');
INSERT INTO security.status_atividade(id, cor, sigla, nome, tipo, descricao) VALUES (3,'#000000','CONC','Concluída' ,'CONCLUIDA' ,'Execução da Atividade Concluida!');
INSERT INTO security.status_atividade(id, cor, sigla, nome, tipo, descricao) VALUES (4,'#000000','CANC','Cancelada' ,'CANCELADA' ,'Execução da Atividade Cancelada!');
-- INSERTS da tabela: security.tipo_historico_atividades
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_historico_atividades (id, descricao) VALUES (1,'Atividade Cadastrada.');
INSERT INTO security.tipo_historico_atividades (id, descricao) VALUES (2,'Atividade Iniciada.');
INSERT INTO security.tipo_historico_atividades (id, descricao) VALUES (3,'Atividade Concluida.');
INSERT INTO security.tipo_historico_atividades (id, descricao) VALUES (4,'Atividade Cancelada.');
INSERT INTO security.tipo_historico_atividades (id, descricao) VALUES (5,'Atividade Reiniciada.');
-- =============================================================================
-- FIM: Controle de Atividades
-- =============================================================================

-- =============================================================================
-- INICIO: Controle de Reuniões
-- =============================================================================
-- Criar Sequences das tabelas deControle de Reuniões
-- -----------------------------------------------------------------------------
CREATE SEQUENCE security.sq_reunioes                   INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_reunioes_historicos        INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_reunioes_participantes     INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_reunioes_x_profissionais   INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_reunioes_acoes_pos_reuniao INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_reunioes_relatos           INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

-- Criação das Tabelas para Controle de Reuniões
-- -----------------------------------------------------------------------------
CREATE TABLE security.tipo_historico_reunioes ( 
   id        integer     NOT NULL,
   descricao varchar(50) NOT NULL
);

CREATE TABLE security.tipo_reuniao ( 
   id              integer      NOT NULL,   
   sigla           varchar(10)  NOT NULL,
   nome            varchar(50)  NOT NULL,
   descricao       varchar(255) NOT NULL
);

CREATE TABLE security.status_reuniao ( 
   id        integer      NOT NULL,
   sigla     varchar(5)   NOT NULL,
   nome      varchar(50)  NOT NULL,
   descricao varchar(255) NOT NULL,
   tipo      VARCHAR(50)  NOT NULL,
   cor       varchar(8)   NOT NULL
);

CREATE TABLE security.reunioes ( 
   id                   integer      NOT NULL DEFAULT 
                        nextval('security.sq_reunioes'),   
   codigo               varchar(10)   NOT NULL, -- RAAAAMMSSS 
   assunto              VARCHAR(255)  NOT NULL,
   pauta                varchar(1000) NOT NULL,
   observacao           varchar(255),
   local_reuniao        varchar(100),
   data_hora_prevista   timestamp,
   data_hora_real       timestamp, 
   duracao              numeric(5,2) DEFAULT 0, -- Em horas
   id_status            integer NOT NULL,
   id_tipo              integer NOT NULL,
   id_secretario        integer NOT NULL, -- Profissional Responsavel pela reunião
   id_reuniao_pai       integer,                -- reunião de origem
   controlar_convidados boolean NOT NULL DEFAULT false,
   controlar_presentes  boolean NOT NULL DEFAULT false,
   id_projeto           integer,            
   id_manutencao        integer,
   id_atividade         integer,
   tipo_inclusao        INTEGER NOT NULL;
);
-- Coloca comentarios nas colunas da tabela reuniões
COMMENT ON COLUMN security.reunioes.codigo               IS 'RAAAAMMSSS - onde: R-Reunião AAAA-Ano MM-Mes SSS-Sequencial.';
COMMENT ON COLUMN security.reunioes.assunto              IS 'Tema ou motivo da Reunião.';
COMMENT ON COLUMN security.reunioes.pauta                IS 'Principais tópicos da reunião.';
COMMENT ON COLUMN security.reunioes.local_reuniao        IS 'Local onde a reunião será/foi realizada.';
COMMENT ON COLUMN security.reunioes.observacao           IS 'Campo Livre apara informações adicionais.';
COMMENT ON COLUMN security.reunioes.data_hora_prevista   IS 'Data e Hora que está agendada a Reunião.';
COMMENT ON COLUMN security.reunioes.data_hora_real       IS 'Data e Hora em que foi realizada a reunião.';
COMMENT ON COLUMN security.reunioes.duracao              IS 'Tempo em horas previsto para durar a reunião.';
COMMENT ON COLUMN security.reunioes.id_status            IS '1-Aguardando Agendar 2-Agendada 3-Cancelada 4-Realizada.';
COMMENT ON COLUMN security.reunioes.id_tipo              IS 'Ver tabela: Tipo de Reunião.';
COMMENT ON COLUMN security.reunioes.id_secretario        IS 'Profissional Responsavel em organizar/registrar reunião.';
COMMENT ON COLUMN security.reunioes.id_reuniao_pai       IS 'Id da reunião que deu origem a esta reunião.';
COMMENT ON COLUMN security.reunioes.controlar_convidados IS 'Flag p/ indicar se havera controle de Convidados.';
COMMENT ON COLUMN security.reunioes.controlar_presentes  IS 'Flag p/ indicar se havera controle de frequencia.';
COMMENT ON COLUMN security.reunioes.id_projeto           IS 'Projeto para o qual a reunião foi realizada.';
COMMENT ON COLUMN security.reunioes.id_manutencao        IS 'Manutenção de Sistema para a qual a reunião foi realizada.';
COMMENT ON COLUMN security.reunioes.id_atividade         IS 'Atividade para a qual a reunião foi realizada.';
COMMENT ON COLUMN security.reunioes.tipo_inclusao        IS '1-Sem Agendamento 2-Agendado 3-RealizadaO.';

CREATE TABLE security.reunioes_historicos (
  id_reuniao        integer      NOT NULL,
  id                integer      NOT NULL DEFAULT
                    nextval('security.sq_reunioes_historicos'),
  data_hora         timestamp    NOT NULL DEFAULT now(),
  id_tipo_historico integer      NOT NULL,
  matricula         varchar(14)  NOT NULL,
  observacao        varchar(255) NOT NULL
) WITHOUT OIDS;

CREATE TABLE security.reunioes_x_profissionais (
  id_reuniao      integer NOT NULL,
  id              integer NOT NULL DEFAULT
                  nextval('security.sq_reunioes_x_profissionais'),
  id_profissional integer NOT NULL,
  observacao      varchar(255)
) WITHOUT OIDS;

CREATE TABLE security.reunioes_participantes (
  id_reuniao integer      NOT NULL,
  id         integer      NOT NULL DEFAULT
             nextval('security.sq_reunioes_participantes'),
  matricula  varchar(14),  
  nome       varchar(255) NOT NULL,
  convidado  boolean      NOT NULL DEFAULT false,
  presente   boolean      NOT NULL DEFAULT false
) WITHOUT OIDS;

CREATE TABLE security.reunioes_acoes_pos_reuniao (
  id_reuniao     integer      NOT NULL,
  id             integer      NOT NULL DEFAULT
                 nextval('security.sq_reunioes_acoes_pos_reuniao'),
  acao           varchar(500) NOT NULL,
  data_retorno   date         NOT NULL,
  id_responsavel integer      NOT NULL
) WITHOUT OIDS;

CREATE TABLE security.reunioes_relatos (
  id_reuniao     integer      NOT NULL,
  id             integer      NOT NULL DEFAULT
                 nextval('security.sq_reunioes_relatos'),
  relato         varchar(1000) NOT NULL
) WITHOUT OIDS;

-- Criação das PRIMARY KEY das Tabelas de Controle de Reuniões
-- -----------------------------------------------------------------------------
ALTER TABLE security.status_reuniao             ADD CONSTRAINT pk_status_reuniao             PRIMARY KEY (id);
ALTER TABLE security.tipo_reuniao               ADD CONSTRAINT pk_tipo_reuniao               PRIMARY KEY (id);
ALTER TABLE security.tipo_historico_reunioes    ADD CONSTRAINT pk_tipo_historico_reunioes    PRIMARY KEY (id);
ALTER TABLE security.reunioes                   ADD CONSTRAINT pk_reunioes                   PRIMARY KEY (id);
ALTER TABLE security.reunioes_historicos        ADD CONSTRAINT pk_reunioes_historicos        PRIMARY KEY (id);
ALTER TABLE security.reunioes_participantes     ADD CONSTRAINT pk_reunioes_participantes     PRIMARY KEY (id); 
ALTER TABLE security.reunioes_x_profissionais   ADD CONSTRAINT pk_reunioes_x_profissionais   PRIMARY KEY (id);
ALTER TABLE security.reunioes_acoes_pos_reuniao ADD CONSTRAINT pk_reunioes_acoes_pos_reuniao PRIMARY KEY (id); 
ALTER TABLE security.reunioes_relatos           ADD CONSTRAINT pk_reunioes_relatos           PRIMARY KEY (id); 

-- FOREIGN KEY da tabela: security.reuniões
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.reunioes
  ADD CONSTRAINT fk_status_reuniao FOREIGN KEY (id_status) 
      REFERENCES security.status_reuniao(id); 
ALTER TABLE ONLY security.reunioes
  ADD CONSTRAINT fk_tipo_reuniao   FOREIGN KEY (id_tipo) 
      REFERENCES security.tipo_reuniao(id); 
ALTER TABLE ONLY security.reunioes
  ADD CONSTRAINT fk_secretario     FOREIGN KEY (id_secretario) 
      REFERENCES security.profissionais_ti(id); 
ALTER TABLE ONLY security.reunioes
  ADD CONSTRAINT fk_reunioes_pai   FOREIGN KEY (id_reuniao_pai) 
      REFERENCES security.reunioes(id); 
ALTER TABLE ONLY security.reunioes  
  ADD CONSTRAINT fk_projeto        FOREIGN KEY (id_projeto)
      REFERENCES security.projetos(id);
ALTER TABLE ONLY security.reunioes 
  ADD CONSTRAINT fk_manutencao     FOREIGN KEY (id_manutencao)
      REFERENCES security.manutencoes_sistema(id);
ALTER TABLE ONLY security.reunioes 
  ADD CONSTRAINT fk_atividade      FOREIGN KEY (id_atividade)
      REFERENCES security.atividades(id);

-- FOREIGN KEY da tabela: security.atividades_historicos
ALTER TABLE ONLY security.reunioes_historicos
  ADD CONSTRAINT fk_reunioes       FOREIGN KEY (id_reuniao) 
      REFERENCES security.reunioes (id); 
ALTER TABLE ONLY security.reunioes_historicos
  ADD CONSTRAINT fk_tipo_historico FOREIGN KEY (id_tipo_historico) 
      REFERENCES security.tipo_historico_reunioes (id); 
ALTER TABLE ONLY security.reunioes_historicos
  ADD CONSTRAINT fk_matricula      FOREIGN KEY (matricula) 
      REFERENCES security.users (matricula); 
   
-- FOREIGN KEY da tabela: security.reunioes_x_profissionais
ALTER TABLE ONLY security.reunioes_x_profissionais
  ADD CONSTRAINT fk_reunioes       FOREIGN KEY (id_reuniao) 
      REFERENCES security.reunioes (id); 
ALTER TABLE ONLY security.reunioes_x_profissionais
  ADD CONSTRAINT fk_profissional   FOREIGN KEY (id_profissional) 
      REFERENCES security.profissionais_ti(id); 

-- FOREIGN KEY da tabela: security.reunioes_participantes
ALTER TABLE ONLY security.reunioes_participantes
  ADD CONSTRAINT fk_reunioes       FOREIGN KEY (id_reuniao) 
      REFERENCES security.reunioes (id); 

-- FOREIGN KEY da tabela: security.reunioes_acoes_pos_reuniao
ALTER TABLE ONLY security.reunioes_acoes_pos_reuniao
  ADD CONSTRAINT fk_reunioes       FOREIGN KEY (id_reuniao) 
      REFERENCES security.reunioes (id); 
ALTER TABLE ONLY security.reunioes_acoes_pos_reuniao
  ADD CONSTRAINT fk_profissionais  FOREIGN KEY (id_responsavel) 
      REFERENCES security.profissionais_ti(id); 

-- FOREIGN KEY da tabela: security.reunioes_relatos
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.reunioes_relatos
  ADD CONSTRAINT fk_reunioes       FOREIGN KEY (id_reuniao) 
      REFERENCES security.reunioes (id);  

-- INSERTS da tabela: security.
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_reuniao(id, sigla, nome, descricao) VALUES (0,'NINF'  ,'Não Informado'            ,'Tipo da reunião não informado.');
INSERT INTO security.tipo_reuniao(id, sigla, nome, descricao) VALUES (1,'GEREN' ,'Controle Gerencial'       ,'Reuniões de natureza gerencial interna do setor.');
INSERT INTO security.tipo_reuniao(id, sigla, nome, descricao) VALUES (2,'WKSHP' ,'Work Shop'                ,'Reuniões para apresentação de novas tecnologias.');
INSERT INTO security.tipo_reuniao(id, sigla, nome, descricao) VALUES (3,'TREIN' ,'Treinamento de Usuários'  ,'Reuniões para treinamento de usuário internos ou externos nas ferramentas de trabalho.');
INSERT INTO security.tipo_reuniao(id, sigla, nome, descricao) VALUES (4,'METOD' ,'Metodologias de Trabalho' ,'Reuniões para definição e manutenção de metodologias de trabalho.');
INSERT INTO security.tipo_reuniao(id, sigla, nome, descricao) VALUES (5,'DESEN' ,'Desenvolvimento Sistema'  ,'Reuniões para auxiliar no processo de desenvolvimento e mantutenção de sistema.');

-- INSERTS da tabela: security.status_reunião
-- -----------------------------------------------------------------------------
INSERT INTO security.status_reuniao(id, cor, sigla, nome, tipo, descricao) VALUES (1,'#000000','AGUA','Aguardando Agendar' ,'AGUARDANDO_AGENDAR' ,'Reunião registrada mais ainda não agendada com interressados ou sem data marcada!');
INSERT INTO security.status_reuniao(id, cor, sigla, nome, tipo, descricao) VALUES (2,'#000000','AGEN','Agendada'           ,'AGENDADA'           ,'Reunião registrada e agendada com inerressados com data marcada!');
INSERT INTO security.status_reuniao(id, cor, sigla, nome, tipo, descricao) VALUES (3,'#000000','CANC','Cancelada'          ,'CANCELADA'          ,'Reunião que teve seu agendamento cancelado!');
INSERT INTO security.status_reuniao(id, cor, sigla, nome, tipo, descricao) VALUES (4,'#000000','REAL','Realizada'          ,'REALIZADA'          ,'Reunião realizada!');
-- INSERTS da tabela: security.tipo_historico_reunioes
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_historico_reunioes (id, descricao) VALUES (1,'Reunião Cadastrada.');
INSERT INTO security.tipo_historico_reunioes (id, descricao) VALUES (2,'Reunião Agendada.');
INSERT INTO security.tipo_historico_reunioes (id, descricao) VALUES (3,'Reunião Reagendada.');
INSERT INTO security.tipo_historico_reunioes (id, descricao) VALUES (4,'Reunião Cancelada.');
INSERT INTO security.tipo_historico_reunioes (id, descricao) VALUES (5,'Reunião Realizada.');
-- =============================================================================
-- FIM: Controle de Reuniões
-- =============================================================================


-- Insert´s na tabela 'agente_sistema'
-- -----------------------------------------------------------------------------
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (0  ,'NAOINFO'   ,'Não Informado'       ,'Agente Não informado (Usar quando não se sabe ou não está definido quem é o agente).');
-- -----------------------------------------------------------------------------
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (100,'GOVERNO'   ,'Governador'          ,'O próprio governador é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (101,'POPULACAO' ,'População'           ,'A população é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (102,'CONTRATADA','Empresa: CONTRATADA' ,'Agentes externos ao DER que atuam na Empresa Contratada.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (103,'DNIT'      ,'Orgão: DNIT'         ,'Agentes externos ao DER que atuam no Orgão DNIT.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (104,'TCE'       ,'Orgão: TCE'          ,'Agentes externos ao DER que atuam no Orgão TCE.');
-- -----------------------------------------------------------------------------
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (200,'SEINFRA'   ,'Secretaria: SEINFRA' ,'Agentes externos ao DER que atuam na secretaria SEINFRA.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (201,'SEPLAG'    ,'Secretaria: SEPLAG'  ,'Agentes externos ao DER que atuam na secretaria SEPLAG.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (202,'SEFAZ'     ,'Secretaria: SEFAZ'   ,'Agentes externos ao DER que atuam na secretaria SEFAZ.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (203,'DETRAN'    ,'Secretaria: DETRAN'  ,'Agentes externos ao DER que atuam na secretaria DETRAN.');
-- -----------------------------------------------------------------------------
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (300,'DER'       ,'Instituição: DER'    ,'A instituição do DER é o agente do sistema.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (301,'DER-SEDE'  ,'Sede do DER'         ,'Somente a Sede do DER é o agente do sistema.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (302,'DER-DISTR' ,'Distrito Operacional','Somente os Distritos Operacionais do DER é o agente do sistema.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (303,'DER-GESTOR','Gestores do DER'     ,'Os gestores do DER é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (304,'DER-SECRET','Secretarias do DER'  ,'As secretarias do DER é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (305,'DER-FUNCIO','Funcionarios do DER' ,'Os funcionarios do DER é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (310,'SUPER'     ,'Superintendencia'    ,'A Superintendencia do DER na pessoa do superintendente é o  ela são os agentes.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (311,'SUPAD'     ,'Setor: SUPAD'        ,'O Setor: SUPAD - Superintendencia Adjunta, é o Agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (312,'PROJU'     ,'Assessoria: PROJU'   ,'A assessoria: PROJU - Procuradoria Juridica, é o agente');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (313,'ASCOM'     ,'Assessoria: ASCOM'   ,'A assessoria: ASCOM - Assessoria de comunicação, é o agente');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (320,'DIRAF'     ,'Diretoria: DIRAF'    ,'A diretoria: DIRAF - Diretoria Administrativa Financeira, é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (321,'GEFIN'     ,'Setor: GEFIN'        ,'O setor: GEFIN - Gerencia Financeira, é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (322,'GEREH'     ,'Setor: GEREH'        ,'O setor: GEGEH - Gerencia de Recursos Humanos, é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (323,'GESUP'     ,'Setor: GESUP'        ,'O setor: GESUP - Gerencia de Suprimentos, é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (330,'DIRER'     ,'Diretoria: DIRER'    ,'A diretoria: DIRER - Diretoria de Engenharia Rodoviaria, é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (331,'GAIAM'     ,'Setor: GAIAM'        ,'O setor: GAIAM - Gerencia de Analaise e Impacto Ambiental');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (340,'DIMAN'     ,'Diretoria: DIMAN'    ,'A diretoria: DIMAN - Diretoria Manutenção e Aeroportos, é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (350,'DIPLA'     ,'Diretoria: DIPLA'    ,'A diretoria: DIPLA-Diretoria de Planejamento, é o agente.');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (351,'GETIC'     ,'Setor: GETIC'        ,'O setor: GETIC - Gerencia de Tecnologia, é o agente');
INSERT INTO security.agente_sistema (id, sigla, nome, descricao) VALUES (360,'MEDICAO'   ,'Setor: MEDIÇÃO'      ,'O setor: MEDIÇÃO - Gerencia de Medição, é o agente');


-- /////////////////////////////////////////////////////////////////////////////
--
-- ALTERAÇÕES FEITA NO SCRIPT APÓS  A CRIAÇÃO DO BANCO DE PRODUÇÃO
--
-- /////////////////////////////////////////////////////////////////////////////


/*
-- =============================================================================
-- INICIO: Controle de Documentos Projetos de Desenvolvimento
-- =============================================================================
-- Tabelas para controle de Documentos de Desenvolvimento
-- -----------------------------------------------------------------------------
CREATE SEQUENCE security.sq_projetos_assinaturas INCREMENT 1  MINVALUE 1  MAXVALUE 2147483647  START 1 CACHE 1;

CREATE TABLE security.tipo_assinatura ( 
   id              integer      NOT NULL,   
   sigla           varchar(10)  NOT NULL,
   nome            varchar(50)  NOT NULL,
   descricao       varchar(255) NOT NULL
);
CREATE TABLE security.tipo_documento_desenvolvimento ( 
   id              integer      NOT NULL,   
   sigla           varchar(10)  NOT NULL,
   nome            varchar(50)  NOT NULL,
   descricao       varchar(255) NOT NULL
);
CREATE TABLE security.projetos_assinaturas ( 
   id                 integer NOT NULL DEFAULT 
                      nextval('security.sq_projetos_assinaturas'),   
   id_projeto         integer NOT NULL,
   id_tipo_assinatura integer NOT NULL,
   id_profissional    integer NOT NULL
);

-- INSERTS da tabela: security.tipo_assinatura
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_assinatura (id, sigla, nome, descricao) VALUES (1,'GERTI','Gerente da GETIC'      ,'Gerente responsavel pelo setor de tecnologia!');
INSERT INTO security.tipo_assinatura (id, sigla, nome, descricao) VALUES (2,'PRINT','Principal Interressado','Principal usuário interressado pelo Projeto!');
INSERT INTO security.tipo_assinatura (id, sigla, nome, descricao) VALUES (3,'GERPR','Gerente do Projeto'    ,'Gerente do Projeto responsavel pelo mesmo!');
INSERT INTO security.tipo_assinatura (id, sigla, nome, descricao) VALUES (4,'ANALI','Analista de Sistema'   ,'Analista de sistema responsavel pelo projeto!');

-- INSERTS da tabela: security.tipo_documento_desenvolvimento
-- -----------------------------------------------------------------------------
INSERT INTO security.tipo_documento_desenvolvimento (id, nome, descricao, id_fase_projeto_sistema) VALUES (1,'TAP','Termo de Abertura do projeto','1');
INSERT INTO security.tipo_documento_desenvolvimento (id, nome, descricao, id_fase_projeto_sistema) VALUES (1,'EUC','Especificação de Caso de Uso','1');
INSERT INTO security.tipo_documento_desenvolvimento (id, nome, descricao, id_fase_projeto_sistema) VALUES (1,'EUC','Especificação de Caso de Uso','1');
-- =============================================================================
-- FIM: Controle de Projetos
-- =============================================================================
*/