-- =======================================
-- Script do pacote DER_CE_CONTADOR_ACESSO
-- ---------------------------------------

CREATE SCHEMA der_ce_contador_acesso AUTHORIZATION postgres;

-- =============================================================================
-- C R I A Ç Ã O   D A S   S E Q U E N C E
-- =============================================================================
CREATE SEQUENCE der_ce_contador_acesso.sq_registro_acesso                    INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

-- =============================================================================
-- C R I A Ç Ã O   D A S   T A B E L A S
-- =============================================================================
-- Tabelas para classificação de módulos
-- -----------------------------------------------------------------------------
CREATE TABLE der_ce_contador_acesso.chave_sites (
  codigo              VARCHAR(20) NOT NULL,
  site                VARCHAR(70),  
  url                 VARCHAR(255),
  PRIMARY KEY(codigo)
) ;

CREATE TABLE der_ce_contador_acesso.registro_acesso (
  codigo                   INTEGER     DEFAULT nextval('der_ce_contador_acesso.sq_registro_acesso'::text::regclass) NOT NULL,
  chave_site               VARCHAR(20) NOT NULL,
  data_acesso              DATE,
  hora_acesso              TIME(0) WITHOUT TIME ZONE,
  PRIMARY KEY(codigo)
) ;
-- =============================================================================
-- F O R E I G N   K E Y ´ s   d o   p a c o t e   S E C U R I T Y
-- =============================================================================

--  FOREIGN KEY da tabela 'der_ce_contador_acesso.registro_acesso'
-- -----------------------------------------------------------------------------
ALTER TABLE der_ce_contador_acesso.registro_acesso
  ADD CONSTRAINT fk_registro_acesso_chave_site FOREIGN KEY (chave_site)
    REFERENCES der_ce_contador_acesso.chave_sites(codigo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

-- =============================================================================
-- C R I A Ç Ã O   D A S   V I E W S
-- =============================================================================

-- View der_ce_contador_acesso.vw_lista_acesso_mensal 
CREATE OR REPLACE VIEW der_ce_contador_acesso.vw_lista_acesso_mensal 
AS 
SELECT rea.codigo,
       rea.chave_site,
       rea.data_acesso,
       rea.hora_acesso       
    FROM der_ce_contador_acesso.registro_acesso rea
        WHERE rea.data_acesso >= (SELECT date_trunc('month',current_date)) and 
              rea.data_acesso <= (SELECT date_trunc('month',current_date) + INTERVAL'1 month' - INTERVAL'1 day');
         


-- /////////////////////////////////////////////////////////////////////////////
--
-- ALTERAÇÕES FEITA NO SCRIPT APÓS  A CRIAÇÃO DO BANCO DE PRODUÇÃO
--
-- /////////////////////////////////////////////////////////////////////////////
