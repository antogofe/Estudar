-- =======================================
-- Script do pacote DER_CE_CORPORATIVO
-- ---------------------------------------
-- Host      : 172.25.144.14
-- Database  : der
-- Version   : PostgreSQL 8.3.4
-- =======================================

-- =============================================================================
-- C R I A Ç Ã O   D A S   V I E W S
-- =============================================================================
-- =============================================================================
-- INICIO: Relação de VIEW´s do Modulo
-- =============================================================================
  
-- VIEW: Exibir A lista de Modulos de um Usuário
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_log_acesso
AS
SELECT 
  log.id,
  log.matricula     AS login_usuario,
  usr.nome_completo AS nome_usuario,
  usr.id_tipo_usuario,
  tus.sigla         AS sigla_tipo_usuario,
  tus.nome          AS nome_tipo_usuario,
  to_char(log.hora_acesso,'YYYY-MM-DD HH:MI') AS dh_completa,
  to_char(log.hora_acesso,'YYYY') AS dh_ano,
  to_char(log.hora_acesso,'MM')   AS dh_mes,
  to_char(log.hora_acesso,'DD')   AS dh_dia,
  to_char(log.hora_acesso,'HH')   AS dh_hora,
  to_char(log.hora_acesso,'MI')   AS dh_minuto,
  to_char(log.hora_acesso,'D')    AS dia_da_semana,
  to_char(log.hora_acesso,'DDD')  AS dia_do_ano,
  to_char(log.hora_acesso,'W')    AS semana_do_mes,
  to_char(log.hora_acesso,'WW')   AS semana_do_ano,
  to_char(log.hora_acesso,'RM')   AS mes_em_romano,
  to_char(log.hora_acesso,'Q')    AS trimestre
FROM auditoria.log_acesso        log 
INNER JOIN security.users        usr ON usr.matricula = log.matricula
INNER JOIN security.tipo_usuario tus ON tus.id = usr.id_tipo_usuario