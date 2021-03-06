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
  
-- -----------------------------------------------------------------------------
-- VIEW: Exibir A lista de Modulos de um Usuário
-- -----------------------------------------------------------------------------
CREATE VIEW security.vw_usuario_modulos AS 
SELECT DISTINCT 
  mod.id,
  uxr.id_user,
  mod.codigo_modulo,
  mod.sigla,
  mod.nome,
  mod.ordem_menu,
  mod.id_area,
  mod.id_status,
  mod.id_modulo_pai
FROM         security.modulos         mod
  INNER JOIN security.roles_x_modulos rxm ON mod.id = rxm.id_modulo
  INNER JOIN security.roles           rol ON rxm.id_role = rol.id_role
  INNER JOIN security.users_x_roles   uxr ON rol.id_role = uxr.id_role
WHERE mod.id_status = 1 -- Modulo Ativo
  AND rol.id_status = 1 -- Regras
  AND uxr.id_status = 1;-- Regras do usuario

-- -----------------------------------------------------------------------------
-- VIEW: Exibir A lista de Elementos de Acesso de um Usuário
-- -----------------------------------------------------------------------------
DROP VIEW security.vw_usuario_elementos_modulo;

CREATE VIEW security.vw_usuario_elementos_modulo AS
SELECT DISTINCT 
  emo.id, 
  uxr.id_user, 
  emo.codigo_acesso, 
  emo.nome_externo,
  emo.nome_interno, 
  length(emo.ordem_menu) / 3 AS hierarquia,
  emo.id_elemento_pai, 
  emo.id_status, 
  emo.id_modulo, 
  emo.id_tipo_elemento,
  tea.sigla      AS sigla_tipo_elemento, 
  mod.ordem_menu AS ordem_menu_modulo,
  emo.ordem_menu AS ordem_menu_elemento, 
  mod.nome       AS nome_modulo,
  mod.id_status  AS id_status_modulo
FROM security.elementos_modulo           emo
  JOIN security.tipo_elemento            tea ON tea.id = emo.id_tipo_elemento
  JOIN security.modulos                  mod ON mod.id = emo.id_modulo
  JOIN security.roles_x_elementos_modulo rxe ON emo.id = rxe.id_elemento
  JOIN security.roles                    rol ON rxe.id_role = rol.id_role
  JOIN security.users_x_roles            uxr ON rol.id_role = uxr.id_role
WHERE  emo.id_status = 1  -- Elemento ativo
  AND  rol.id_status = 1  -- Regras ativo 
  AND  rxe.id_status = 1  -- Regras do Elementos ativo
  AND  uxr.id_status = 1  -- regras do usuario ativa
 AND (emo.id_tipo_elemento  = 1 OR   -- 1=Menu
       (emo.id_tipo_elemento = 2 AND  -- 2=Formulario
        emo.ordem_menu <> '...'       -- '...' Formularios que não são do menu 
       )
     ) 
ORDER BY  emo.id_modulo, emo.ordem_menu, emo.id;

-- =============================================================================
-- FIM: Relação de VIEW´s de Users
-- =============================================================================

-- =============================================================================
-- INICIO: Relação de VIEW´s de usuarios
-- =============================================================================
-- VIEW: Dados do usuario - Relação de usuarios Cadastrados (VoDadosUsuario)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_dados_usuarios AS
SELECT 
  -- Dados do usuario 
  usr.matricula,
  usr.nome_referencia,
  usr.nome_completo,
  usr.observacao,
  -- Status de Acesso do usuario
  sta.id        AS id_status_acesso,
  sta.sigla     AS sigla_status_acesso,
  sta.nome      AS nome_status_acesso,
  sta.tipo      AS tipo_status_acesso,
  sta.descricao AS descricao_status_acesso,
  sta.cor       AS cor_status_acesso,
  -- Tipo de Menu do usuario
  tpm.id        AS id_tipo_menu,
  tpm.sigla     AS sigla_tipo_menu,
  tpm.nome      AS nome_tipo_menu,
  tpm.descricao AS descricao_tipo_menu,
  tpm.ativo     AS ativo_tipo_menu,
  -- Tipo de Skin do usuario
  tps.id        AS id_tipo_skin,
  tps.sigla     AS sigla_tipo_skin,
  tps.nome      AS nome_tipo_skin,
  tps.descricao AS descricao_tipo_skin,
  -- Tipo de usuario
  tpu.id        AS id_tipo_usuario,
  tpu.sigla     AS sigla_tipo_usuario,
  tpu.nome      AS nome_tipo_usuario,
  tpu.descricao AS descricao_tipo_usuario,  
  -- dados do Cadastro
  uhc.data_hora     AS cadastro_data_hora,
  uhc.matricula     AS cadastro_realizado_por_matricula,
  uhc.nome_completo AS cadastro_realizado_por_nome,
  uhc.observacao    AS cadastro_observacao,     
  -- dados do Encerramento da Conta do Usuario
  uhe.data_hora     AS encerramento_data_hora,
  uhe.matricula     AS encerramento_realizado_por_matricula,
  uhe.nome_completo AS encerramento_realizado_por_nome,
  uhe.observacao    AS encerramento_observacao  
FROM         security.users         usr
  INNER JOIN security.status_acesso sta ON sta.id = usr.id_status
  INNER JOIN security.tipo_menu     tpm ON tpm.id = usr.id_tipo_menu
  INNER JOIN security.tipo_skin     tps ON tps.id = usr.id_tipo_skin
  INNER JOIN security.tipo_usuario  tpu ON tpu.id = usr.id_tipo_usuario
  LEFT JOIN (SELECT his.id_user,
                    to_char(his.data_hora,'dd/MM/yyyy HH:mm') AS data_hora,
                    his.matricula,
                    uhi.nome_completo,
                    his.observacao
               FROM security.users_historicos his INNER JOIN
                    security.users            uhi ON uhi.matricula = his.matricula
              WHERE his.id_tipo_historico=1 -- 1- Historico cadastro
             )                      uhc ON uhc.id_user = usr.matricula
  LEFT JOIN (SELECT his.id_user,
                    to_char(his.data_hora,'dd/MM/yyyy HH:mm') AS data_hora,
                    his.id_tipo_historico,
                    his.matricula,
                    uhi.nome_completo,
                    his.observacao
               FROM security.users_historicos his INNER JOIN
                    security.users            uhi ON uhi.matricula = his.matricula
              WHERE his.id_tipo_historico=4 -- 4- Historico de Encerramento
             ) uhe ON uhe.id_user = usr.matricula;

-- VIEW: Ficha do Usuarios              (VoUser)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_users AS
SELECT 
  usr.matricula, 
  usr.nome_completo, 
  usr.nome_referencia,
  usr.id_status,
  usr.id_tipo_menu,
  usr.id_tipo_usuario,
  usr.id_tipo_skin,
  sta.nome AS status,
  tme.nome AS tipo_menu,
  tus.nome AS tipo_usuario,
  tsk.nome AS tipo_skin
FROM security.users usr
  INNER JOIN security.status_acesso sta ON sta.id = usr.id_status
  INNER JOIN security.tipo_menu     tme ON tme.id = usr.id_tipo_menu
  INNER JOIN security.tipo_usuario  tus ON tus.id = usr.id_tipo_usuario
  INNER JOIN security.tipo_skin     tsk ON tsk.id = usr.id_tipo_skin;

-- VIEW: Ficha do Usuarios - Relação de Histórico (VoUserXHistorico)
-- -----------------------------------------------------------------------------
CREATE VIEW security.vw_users_x_historicos AS 
SELECT 
  uxh.id,
  uxh.id_user,
  uxh.id_tipo_historico,
  thu.descricao AS tipo_historico,
  uxh.data_hora,
  uxh.matricula,
  uxh.observacao
FROM 
  security.users_historicos     uxh INNER JOIN
  security.tipo_historico_users thu ON thu.id = uxh.id_tipo_historico;

-- VIEW: Ficha do Usuarios - Relação de Modulos (VoUserXModulo)
-- -----------------------------------------------------------------------------
CREATE VIEW security.vw_users_x_modulos AS     
SELECT DISTINCT
  (TRIM(mod.codigo_modulo) || TRIM(uxr.id_user)) AS id,    
  uxr.id_user   AS matricula,
  mod.id_area   AS id_area_atuacao,
  atu.nome      AS area_atuacao,
  mod.sigla     AS sigla_modulo,
  mod.nome      AS nome_modulo,
  sta.id        AS id_status,
  sta.nome      AS status_modulo,
  mod.codigo_modulo
FROM         security.users_x_roles   uxr
  INNER JOIN security.roles           rol ON rol.id_role = uxr.id_role
  INNER JOIN security.roles_x_modulos rxm ON rxm.id_role = rol.id_role
  INNER JOIN security.modulos         mod ON mod.id = rxm.id_modulo
  INNER JOIN security.status_acesso   sta ON sta.id = mod.id_status
  INNER JOIN security.area_atuacao    atu ON atu.id = mod.id_area
ORDER BY 
  (TRIM(mod.codigo_modulo) || TRIM(uxr.id_user)),
  uxr.id_user, mod.id_area, atu.nome, mod.sigla, mod.nome, sta.nome, sta.id;

-- VIEW: Ficha do Usuarios - Relação de Regras (VoUserXRole)
-- -----------------------------------------------------------------------------
CREATE VIEW security.vw_users_x_roles AS 
SELECT 
  uxr.id,
  uxr.id_user   AS matricula,
  rol.role_name AS nome_regra,
  rol.descricao AS descricao_regra,
  sta.id        AS id_status,
  sta.nome      AS status_regra,
  rol.id_role
FROM         security.users_x_roles   uxr
  INNER JOIN security.roles           rol ON rol.id_role = uxr.id_role
  INNER JOIN security.status_acesso   sta ON sta.id = uxr.id_status;

-- VIEW: Ficha do Usuarios - Relação de Elementos de Acesso (VoUserXElemento)
-- -----------------------------------------------------------------------------
CREATE VIEW security.vw_users_x_elementos AS
SELECT DISTINCT 
  btrim(ele.codigo_acesso::text) || btrim(uxr.id_user::text) AS id,
  uxr.id_user       AS matricula, 
  mod.id            AS id_modulo, 
  mod.nome          AS modulo, 
  tel.id            AS id_tipo_elemento, 
  tel.nome          AS tipo_elemento,
  ele.codigo_acesso AS codigo, 
  ele.nome_interno, 
  ele.nome_externo,
  sta.id            AS id_status, 
  sta.nome          AS status_elemento,
  mod.ordem_menu    AS ordem_menu_modulo, 
  ele.ordem_menu    AS ordem_menu_elemento,
  ele.id            AS id_elemento, 
  ele.id_elemento_pai
FROM security.users_x_roles               uxr
   JOIN security.roles                    rol ON rol.id_role = uxr.id_role
   JOIN security.roles_x_elementos_modulo rxe ON rxe.id_role = rol.id_role
   JOIN security.elementos_modulo         ele ON ele.id = rxe.id_elemento
   JOIN security.tipo_elemento            tel ON tel.id = ele.id_tipo_elemento
   JOIN security.modulos                  mod ON mod.id = ele.id_modulo
   JOIN security.status_acesso            sta ON sta.id = ele.id_status
ORDER BY mod.ordem_menu, 
         ele.ordem_menu, 
         uxr.id_user, 
         mod.nome, 
         tel.nome,
         ele.codigo_acesso, 
         ele.nome_interno, 
         ele.nome_externo, 
         sta.nome, btrim(ele.codigo_acesso::text) || btrim(uxr.id_user::text), sta.id;

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES, TRIGGER, TRUNCATE  ON security.vw_users_x_elementos TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES, TRIGGER, TRUNCATE  ON security.vw_users_x_elementos TO der;

-- =============================================================================
-- FIM: Relação de VIEW´s do Users
-- =============================================================================

-- =============================================================================
-- INICIO: Relação de VIEW´s do Modulos
-- =============================================================================

--------------------------------------------------------------------------------
-- VIEW....: security.vw_modulos_x_roles
-- CLASSE..: VoModuloXRole.java
-- Objetivo: Ficha do Módulo (Relação de Regras do Modulo)
--------------------------------------------------------------------------------
DROP VIEW security.vw_modulos_x_roles;

CREATE OR REPLACE VIEW security.vw_modulos_x_roles AS 
SELECT 
  rxm.id,
  rxm.id_modulo,
  rxm.id_role,
  rol.role_name AS nome_regra,
  rol.descricao AS descricao_regra, 
  sta.id        AS id_status,
  sta.nome      AS status_regra
FROM security.roles_x_modulos     rxm 
INNER JOIN security.roles         rol ON rol.id_role = rxm.id_role
INNER JOIN security.status_acesso sta ON sta.id      = rol.id_status;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_modulos_x_users
-- CLASSE..: VoModuloXUser.java
-- Objetivo: Ficha do Módulo (Relação de Usuarios do Modulo)
--------------------------------------------------------------------------------
DROP VIEW security.vw_modulos_x_users;

CREATE OR REPLACE VIEW security.vw_modulos_x_users AS
SELECT DISTINCT
 (TRIM(mod.codigo_modulo::text) || TRIM(usr.matricula::text)) AS id,
  rxm.id_modulo,
  usr.matricula,
  usr.nome_completo,
  usr.nome_referencia,
  sta.id         AS id_status,
  sta.nome       AS status
FROM         security.modulos         mod
  INNER JOIN security.roles_x_modulos rxm ON rxm.id_modulo = mod.id
  INNER JOIN security.roles           rol ON rol.id_role   = rxm.id_role
  INNER JOIN security.users_x_roles   uxr ON uxr.id_role   = rol.id_role
  INNER JOIN security.users           usr ON usr.matricula = uxr.id_user
  INNER JOIN security.status_acesso   sta ON sta.id        = usr.id_status;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_modulos_x_elementos_acesso
-- CLASSE..: VoModuloXElementoAcesso.java
-- Objetivo: Ficha do Módulo (Relação de Elementos do Módulo)
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_modulos_x_elementos_acesso AS
SELECT 
  emo.id, 
  emo.id_modulo, 
  tel.nome       AS tipo_elemento, 
  emo.codigo_acesso,
  emo.nome_interno, 
  emo.nome_externo, 
  sta.id         AS id_status, 
  sta.nome       AS status,
  emo.ordem_menu AS ordem, 
  emo.id_elemento_pai, 
  tel.id         AS id_tipo_elemento, 
  mod.nome       AS nome_modulo
FROM security.elementos_modulo emo
   JOIN security.status_acesso sta ON sta.id = emo.id_status
   JOIN security.tipo_elemento tel ON tel.id = emo.id_tipo_elemento
   JOIN security.modulos       mod ON mod.id = emo.id_modulo
WHERE emo.id_tipo_elemento = 1 -- Menu 
   OR emo.id_tipo_elemento = 2; -- Formulario

--------------------------------------------------------------------------------
-- VIEW....: security.vw_modulos_x_manutencoes
-- CLASSE..: VoModuloXManutencao.java
-- Objetivo: Ficha do Módulo (Relação de Manutenções do Módulo)
--------------------------------------------------------------------------------
DROP VIEW security.vw_modulos_x_manutencoes;

CREATE OR REPLACE VIEW security.vw_modulos_x_manutencoes AS
SELECT 
  msi.id, 
  msi.id_modulo, 
  msi.codigo,
  msi.descricao,
  msi.solicitado_por,
  pti.nome_referencia AS responsavel,
  tpm.sigla           AS tipo,
  msi.data_inicio_real,
  msi.data_fim_real
FROM        security.manutencoes_sistema       msi 
 INNER JOIN security.tipo_manutencao_sistema   tpm ON tpm.id = msi.id_tipo
 INNER JOIN security.profissionais_ti          pti ON pti.id = msi.id_responsavel
WHERE msi.id_status = 5 -- Somente Manutenções concluidas

-- =============================================================================
-- FIM: Relação de VIEW´s do Modulos
-- =============================================================================

-- -----------------------------------------------------------------------------
-- VIEW: Exibir a lista de elementos de um Modulo
-- -----------------------------------------------------------------------------
DROP VIEW security.vw_lista_elementos_modulo;

CREATE VIEW security.vw_lista_elementos_modulo AS 
SELECT
  emo.id,
  emo.id_modulo,
  emo.codigo_acesso,
  emo.nome_interno,
  emo.nome_externo,
  sac.nome AS status,
  tem.nome AS tipo_elemento,
  eap.codigo_acesso AS pai
FROM         security.elementos_modulo        emo
  INNER JOIN security.status_acesso           sac ON sac.id = emo.id_status
  INNER JOIN security.tipo_elemento           tem ON tem.id = emo.id_tipo_elemento
  LEFT  JOIN security.elementos_modulo        eap ON eap.id = emo.id_elemento_pai;

-- =============================================================================
-- Relação de VIEW´s das REGRAS
-- =============================================================================
-- VIEW: Relacao de Regras (VoDadosRegra)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_dados_roles  AS  
SELECT 
  -- dados role
  rol.id_role,
  rol.role_name,
  rol.descricao,
  rol.data_inicio,
  rol.data_fim,
  rop.role_name    AS nome_role_pai,
  -- status acesso da role
  sta.id           AS id_status_acesso,
  sta.sigla        AS sigla_status_acesso,
  sta.nome         AS nome_status_acesso,
  sta.tipo         AS tipo_status_acesso,
  sta.descricao    AS descricao_status_acesso, 
  sta.cor          AS cor_status_acesso,
  -- status acesso da role
  tra.id           AS id_tipo_regra,
  tra.sigla        AS sigla_tipo_regra,
  tra.nome         AS nome_tipo_regra,
  tra.descricao    AS descricao_tipo_regra, 
  tra.cor          AS cor_tipo_regra  
FROM security.roles rol
INNER JOIN security.status_acesso     sta ON sta.id = rol.id_status
INNER JOIN security.tipo_regra_acesso tra ON tra.id = rol.id_tipo_regra
LEFT  JOIN (SELECT pai.id_role, pai.role_name
              FROM security.roles pai
           ) rop ON rop.id_role = rol.id_role_pai
ORDER BY rol.role_name

--------------------------------------------------------------------------------
-- VIEW....: security.vw_roles
-- CLASSE..: VoRole.java
-- Objetivo: Ficha da Regra de Acesso
--------------------------------------------------------------------------------
DROP VIEW security.vw_roles;

CREATE OR REPLACE VIEW security.vw_roles AS
SELECT
  rol.id_role,
  rol.role_name,
  rol.descricao,
  rol.data_inicio,
  rol.data_fim,
  rop.role_name  AS role_name_pai,
  sta.id         AS id_status,
  sta.nome       AS nome_status_acesso,
  tra.nome       AS nome_tipo_regra
FROM         security.roles             rol
  INNER JOIN security.status_acesso     sta ON sta.id = rol.id_status
  INNER JOIN security.tipo_regra_acesso tra ON tra.id = rol.id_tipo_regra
  LEFT  JOIN (SELECT pai.id_role, pai.role_name
                FROM security.roles pai
              )                         rop ON rop.id_role = rol.id_role_pai
ORDER BY rol.role_name;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_roles_x_modulos
-- CLASSE..: VoRoleXModulo.java
-- Objetivo: Ficha da Regra de Acesso (Relação de Módulos)
--------------------------------------------------------------------------------
DROP VIEW security.vw_roles_x_modulos;

CREATE OR REPLACE VIEW security.vw_roles_x_modulos AS               
SELECT
  rxm.id,
  rol.id_role,
  mod.id_area       AS id_area_atuacao,
  atu.nome          AS area_atuacao, 
  mod.codigo_modulo,
  mod.sigla         AS sigla_modulo,
  mod.nome          AS nome_modulo,
  sta.id            AS id_status,
  sta.nome          AS status_modulo
FROM         security.roles           rol
  INNER JOIN security.roles_x_modulos rxm ON rxm.id_role = rol.id_role
  INNER JOIN security.modulos         mod ON mod.id = rxm.id_modulo
  INNER JOIN security.status_acesso   sta ON sta.id = mod.id_status
  INNER JOIN security.area_atuacao    atu ON atu.id = mod.id_area
WHERE mod.id_status < 3   -- Somente Módulos ativos ou temporariamente inativo
ORDER BY rxm.id;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_roles_x_elementos_modulo
-- CLASSE..: VoRoleXElemento.java
-- Objetivo: Ficha da Regra de Acesso (Relação de Elementos)
--------------------------------------------------------------------------------
DROP VIEW security.vw_roles_x_elementos_modulo;

CREATE VIEW security.vw_roles_x_elementos_modulo AS
SELECT 
  rxe.id, 
  rxe.id_elemento, 
  rol.id_role, 
  mod.id            AS id_modulo,
  mod.sigla         AS modulo, 
  mod.nome          AS nome_modulo, 
  tel.id            AS id_tipo_elemento, 
  tel.nome          AS tipo_elemento,
  emo.codigo_acesso AS codigo, 
  emo.nome_interno, 
  emo.nome_externo,
  sta.id         AS id_status, 
  sta.nome       AS status_elemento,
  mod.ordem_menu AS ordem_menu_modulo, 
  emo.ordem_menu AS ordem_menu_elemento,
  emo.id_elemento_pai
FROM security.roles                      rol
  JOIN security.roles_x_elementos_modulo rxe ON rxe.id_role = rol.id_role
  JOIN security.elementos_modulo         emo ON emo.id = rxe.id_elemento
  JOIN security.tipo_elemento            tel ON tel.id = emo.id_tipo_elemento
  JOIN security.modulos                  mod ON mod.id = emo.id_modulo
  JOIN security.status_acesso            sta ON sta.id = emo.id_status
WHERE mod.id_status < 3  -- Somente elementos de Módulos ativos ou temporariamente inativo
ORDER BY mod.ordem_menu, emo.ordem_menu;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_roles_x_users
-- CLASSE..: VoRoleXUser.java
-- Objetivo: Ficha da Regra de Acesso (Relação de Usuários)
--------------------------------------------------------------------------------
5
-- =============================================================================
-- FIM: Relação de VIEW´s das REGRAS
-- =============================================================================

-- =============================================================================
-- INICIO: Relação de VIEW´s dos ELEMENTOS MODULOS
-- =============================================================================
-- VIEW: Relacao de Elementos dos Modulos (VoDadosElementosModulos)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_dados_elementos_modulos AS
SELECT
emo.id,
emo.codigo_acesso,
emo.nome_externo,
emo.nome_interno,
emo.objetivo,
pai.nome_externo     AS nome_externo_pai,
emo.ordem_menu       AS ordem_menu_elemento,
mod.ordem_menu       AS ordem_menu_modulo,
mod.nome             AS modulo,
tpe.id               AS id_tipo_elemento,
tpe.sigla            AS sigla_tipo_elemento,
tpe.nome             AS nome_tipo_elemento,
tpe.descricao        AS descricao_tipo_elemento,
sta.id               AS id_status_acesso,
sta.sigla            AS sigla_status_acesso,
sta.nome             AS status_acesso,
sta.descricao        AS descricao_status_acesso,
sta.tipo             AS tipo_status_acesso
FROM security.elementos_modulo    emo
INNER JOIN security.tipo_elemento tpe ON tpe.id = emo.id_tipo_elemento
INNER JOIN security.modulos       mod ON mod.id = emo.id_modulo
INNER JOIN security.status_acesso sta ON sta.id = emo.id_status
LEFT JOIN(
         SELECT
         ele.id,
         ele.nome_externo,
         ele.nome_interno
         FROM security.elementos_modulo ele
         )                       pai ON pai.id = emo.id_elemento_pai  
ORDER BY mod.ordem_menu, emo.ordem_menu;          

--------------------------------------------------------------------------------
-- VIEW....: security.vw_elementos_modulo
-- CLASSE..: VoElementosModulo.java
-- Objetivo: Ficha do Elemento
--------------------------------------------------------------------------------
DROP VIEW security.vw_elementos_modulo;

CREATE OR REPLACE VIEW security.vw_elementos_modulo AS
SELECT
  emo.id,
  emo.id_elemento_pai, 
  emo.codigo_acesso,
  emo.nome_externo,
  emo.nome_interno,
  emo.objetivo,
  pai.nome_externo     AS nome_externo_pai,
  mod.nome             AS modulo,
  tpe.nome             AS tipo_elemento,
  sta.id               AS id_status,
  sta.nome             AS status_acesso
FROM security.elementos_modulo    emo
INNER JOIN security.tipo_elemento tpe ON tpe.id = emo.id_tipo_elemento
INNER JOIN security.modulos       mod ON mod.id = emo.id_modulo
INNER JOIN security.status_acesso sta ON sta.id = emo.id_status
LEFT  JOIN (SELECT ele.id, ele.nome_externo, ele.nome_interno
              FROM security.elementos_modulo ele
           )                       pai ON pai.id = emo.id_elemento_pai;   

--------------------------------------------------------------------------------
-- VIEW....: security.vw_elementos_modulo_x_role
-- CLASSE..: VoElementosModuloXRole.java
-- Objetivo: Ficha do Elemento (Relação de Regras)
--------------------------------------------------------------------------------
DROP VIEW security.vw_elementos_modulo_x_role;

CREATE OR REPLACE VIEW security.vw_elementos_modulo_x_role AS
SELECT 
  rxe.id, 
  rxe.id_elemento, 
  rxe.id_role, 
  rol.role_name AS nome_regra,
  rol.descricao AS descricao_regra, 
  sta.id        AS id_status,
  sta.nome      AS status_regra
FROM security.roles_x_elementos_modulo rxe 
  INNER JOIN security.roles            rol ON rol.id_role = rxe.id_role
  INNER JOIN security.status_acesso    sta ON sta.id      = rol.id_status;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_elementos_modulo_x_usuario
-- CLASSE..: VoElementosModuloXUsuario.java
-- Objetivo: Ficha do Elemento (Relação de Usuários)
--------------------------------------------------------------------------------
DROP VIEW security.vw_elementos_modulo_x_usuario;

CREATE OR REPLACE VIEW security.vw_elementos_modulo_x_usuario AS
SELECT DISTINCT 
  rxe.id_elemento, 
  usr.matricula, 
  usr.nome_completo,
  usr.nome_referencia, 
  sta.id   AS id_status,
  sta.nome AS status
FROM security.roles_x_elementos_modulo rxe
  INNER JOIN security.roles            rol ON rol.id_role = rxe.id_role
  INNER JOIN security.users_x_roles    uxr ON uxr.id_role = rol.id_role 
  INNER JOIN security.users            usr ON usr.matricula = uxr.id_user 
  INNER JOIN security.status_acesso    sta ON sta.id = usr.id_status
ORDER BY usr.matricula;
-- =============================================================================
-- FIM: Relação de VIEW´s das ELEMENTOS MODULOS
-- =============================================================================

-- =============================================================================
-- INICIO: Relação de VIEW´s dos PROFISSIONAIS TI
-- =============================================================================
-- VIEW: Relacao de Profissionais TI (VoDadosProfissionaisTi)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_dados_profissionais_ti AS
SELECT
  prt.id,
  prt.nome_completo,
  prt.nome_referencia,
  prt.email,
  prt.fone_celular,
  prt.fone_residencial,
  prt.fone_comercial,
  prt.observacao,
  art.id		AS id_area_ti,
  art.nome		AS nome_area_ti,
  art.sigla		AS sigla_area_ti,
  art.descricao		AS descricao_area_ti
FROM 
  security.profissionais_ti prt INNER JOIN 
  security.area_ti          art ON prt.id_area = art.id;
--WHERE prt.id <> ALL (ARRAY[0, 6, 13, 17, 19, 21])


--------------------------------------------------------------------------------
-- VIEW....: security.vw_profissionais_ti 
-- CLASSE..: VoProfissionaisTi.java
-- Objetivo: Compor a ficha do profissional da TI
--------------------------------------------------------------------------------
DROP VIEW security.vw_profissionais_ti ;

CREATE OR REPLACE VIEW security.vw_profissionais_ti AS
SELECT 
  prt.id, 
  prt.nome_completo, 
  prt.nome_referencia, 
  prt.email,
  prt.fone_celular, 
  prt.fone_residencial, 
  prt.fone_comercial, 
  prt.observacao, 
  prt.matricula,
  art.nome AS area_ti
FROM 
  security.profissionais_ti prt INNER JOIN 
  security.area_ti          art ON prt.id_area = art.id;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_profissionais_ti_x_modulos 
-- CLASSE..: VoProfissionaisTiXModulos.java
-- Objetivo: Compor a ficha do profissional da TI
--------------------------------------------------------------------------------
DROP VIEW security.vw_profissionais_ti_x_modulos;

CREATE OR REPLACE VIEW security.vw_profissionais_ti_x_modulos AS
SELECT
  mpt.id,
  mpt.data_inicio,
  mpt.observacao,
  prt.id       AS id_profissional_ti,
  mod.id_area  AS id_area_atuacao,
  mod.sigla    AS sigla_modulo,
  mod.nome     AS nome_modulo,
  atu.nome     AS area_atuacao, 
  mod.codigo_modulo
FROM       security.modulos_x_profissionais_ti mpt
  INNER JOIN security.profissionais_ti prt ON prt.id = mpt.id_profissional_ti
  INNER JOIN security.modulos          mod ON mod.id = mpt.id_modulo
  INNER JOIN security.area_atuacao     atu ON atu.id = mod.id_area
WHERE    mpt.data_fim ISNULL 
ORDER BY mpt.id;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_profissionais_ti_x_projetos
-- CLASSE..: VoProfissionaisTiXProjetos.java
-- Objetivo: Compor a ficha do profissional da TI
--------------------------------------------------------------------------------
DROP VIEW security.vw_profissionais_ti_x_projetos

CREATE VIEW security.vw_profissionais_ti_x_projetos AS 
SELECT pjt.id,
       pjt.id_responsavel AS id_profissional_ti,
       pjt.codigo,
       pjt.sigla,
       pjt.nome,
       spj.nome  AS status,
       tpj.nome  AS tipo,
       apj.nome  AS area       
FROM       security.projetos       pjt 
INNER JOIN security.status_projeto spj ON spj.id = pjt.id_status
INNER JOIN security.tipo_projeto   tpj ON tpj.id = pjt.id_tipo
INNER JOIN security.area_ti        apj ON apj.id = pjt.id_area_ti;

-- =============================================================================
-- FIM: Relação de VIEW´s das PROFISSIONAIS TI
-- =============================================================================

CREATE VIEW security.vw_modulos_x_profissionais_ti  AS 
SELECT 
  mxp.id_modulo,
  mxp.id,
  ati.nome            AS area_ti,
  pro.nome_completo,
  pro.nome_referencia,
  pro.fone_celular,
  pro.fone_comercial,
  pro.fone_residencial,
  pro.email,
  mxp.data_inicio,
  mxp.data_fim,
  mxp.observacao
FROM security.modulos_x_profissionais_ti mxp 
  INNER JOIN security.profissionais_ti   pro ON pro.id = mxp.id_profissional_ti
  INNER JOIN security.area_ti            ati ON ati.id = pro.id_area;



-- =============================================================================
-- INICIO: VIEWS para ser utilizando em relacionalemento otimizados
-- =============================================================================
--------------------------------------------------------------------------------
-- VIEW: Lista de Projetos
--------------------------------------------------------------------------------
CREATE VIEW security.vw_lista_projetos AS 
SELECT pjt.id,
       pjt.codigo,
       pjt.sigla AS descricao
FROM   security.projetos pjt;

--------------------------------------------------------------------------------
-- VIEW: Lista de Manutenções sistema
--------------------------------------------------------------------------------
DROP VIEW security.vw_lista_manutencoes_sistema; 

CREATE VIEW security.vw_lista_manutencoes_sistema AS 
SELECT man.id,
       man.codigo,
       man.descricao
FROM   security.manutencoes_sistema man; 

--------------------------------------------------------------------------------
-- VIEW: Lista de Profissionais TI
--------------------------------------------------------------------------------
CREATE VIEW security.vw_lista_profissionais_ti AS 
SELECT pro.id,
       pro.nome_referencia  AS descricao
FROM   security.profissionais_ti pro; 

--------------------------------------------------------------------------------
-- VIEW: Lista de Casos de Uso
--------------------------------------------------------------------------------
CREATE VIEW security.vw_lista_casos_de_uso AS 
SELECT cdu.id,
       cdu.nome  AS descricao
FROM   security.casos_de_uso cdu; 

--------------------------------------------------------------------------------
-- VIEW: Lista de Módulos
-- Acrescentando nome do módulo
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_lista_modulos AS
SELECT 
  mod.id, 
  mod.sigla AS descricao, 
  mod.id_status, 
  mod.nome
FROM security.modulos mod;
--------------------------------------------------------------------------------
-- VIEW: Lista de Usuários
--------------------------------------------------------------------------------
CREATE VIEW security.vw_lista_users AS 
SELECT usr.matricula      AS id,
       usr.nome_completo  AS descricao
FROM   security.users usr; 
-- =============================================================================
-- FIM: VIEWS para ser utilizando em relacionalemento otimizados
-- =============================================================================



--------------------------------------------------------------------------------
-- VIEW....: security.vw_projetos                       
-- CLASSE..: VoProjeto.java
-- Objetivo: Usar na formação da Ficha do Projeto
--------------------------------------------------------------------------------
DROP VIEW security.vw_projetos;

CREATE VIEW security.vw_projetos AS 
SELECT
  pro.id,
  -- dados do Projeto
  pro.codigo,
  pro.nome,
  pro.sigla,
  pro.descricao,
  pro.interessado,
  pro.observacao,
  -- Datas Previsto e Real
  pro.data_inicio_previsto,
  pro.data_fim_previsto,
  pro.data_fim_previsto_atual,
  pro.data_inicio_real,
  pro.data_fim_real,
  -- Dias e Prazos
  pro.prazo_inicial,   -- PZI
  pro.dias_ajustados,  -- DAJ
  pro.prazo_inicial + 
  pro.dias_ajustados   AS prazo_total,     -- PZT 
  pro.dias_paralisado, -- DPA
  -- ---------------------------------------------------------------------------
  COALESCE((pro.data_inicio_real  - pro.data_inicio_previsto),0)
                       AS dias_ajuste_inicial,-- DAI
  -- ---------------------------------------------------------------------------
  (pro.dias_ajustados - pro.dias_paralisado - 
   COALESCE((pro.data_inicio_real - pro.data_inicio_previsto),0))
                       AS dias_ajuste_usuario,-- DAU
    -- ---------------------------------------------------------------------------
  CASE WHEN (pro.data_inicio_real ISNULL)                 
    THEN 0                                                -- Se Projeto Não Iniciou
    ELSE CASE WHEN (pro.data_fim_real ISNULL)             -- + Incui dia de hoje 
      THEN (CURRENT_DATE - pro.data_inicio_real + 1)      -- Se já iniciou e não concluiu
      ELSE (pro.data_fim_real - pro.data_inicio_real + 1) -- Se Já concluir
    END
  END                  AS dias_corridos,      -- DCO
  -- ---------------------------------------------------------------------------
  CASE WHEN pro.id_status = 4 OR pro.id_status = 5        -- Se 4-Em Execucao OU 5-Paralisado         
    THEN pro.data_fim_previsto_atual - CURRENT_DATE
    ELSE 0
  END                  AS dias_disponiveis,   -- DDI
  -- ---------------------------------------------------------------------------  
  (pro.prazo_inicial + pro.dias_ajustados) -
  COALESCE((pro.data_inicio_real - pro.data_inicio_previsto),0)
                       AS prazo_real,                           
  -- Execucao Projeto
  pro.observacao_progresso,
  pro.percentual_executado,   
  -- Classificação do Projeto
  ati.nome             AS area_ti_projeto,
  tpr.nome             AS tipo_projeto,
  spr.nome             AS status_projeto,
  ppr.nome             AS prioridade_projeto,
  ppa.sigla            AS projeto_pai,
  mod.sigla            AS modulo,
  -- dados do Gerente do Projeto
  gpr.nome_completo    AS gerente,
  gpr.fone_celular     AS gerente_celular,
  gpr.fone_comercial   AS gerente_comercial,
  gpr.email            AS gerente_email,
  -- dados do Responsavel do Projeto
  res.nome_completo    AS responsavel,
  res.fone_celular     AS responsavel_celular,
  res.fone_comercial   AS responsavel_comercial,
  res.email            AS responsavel_email
FROM         security.projetos           pro
  INNER JOIN security.area_ti            ati ON ati.id=pro.id_area_ti
  INNER JOIN security.tipo_projeto       tpr ON tpr.id=pro.id_tipo
  INNER JOIN security.status_projeto     spr ON spr.id=pro.id_status
  INNER JOIN security.profissionais_ti   res ON res.id=pro.id_responsavel
  INNER JOIN security.profissionais_ti   gpr ON gpr.id=pro.id_gerente
  INNER JOIN security.prioridade_projeto ppr ON ppr.id=pro.id_prioridade
  LEFT  JOIN security.projetos           ppa ON ppa.id=pro.id_projeto_pai
  LEFT  JOIN security.modulos            mod ON mod.id=pro.id_modulo;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_projetos_historicos     
-- CLASSE..: VoProjetoHistoricos.java
-- Objetivo: Usar na formação da Ficha do Projeto
--------------------------------------------------------------------------------
CREATE VIEW security.vw_projetos_historicos AS 
SELECT 
  pjh.id_projeto,
  pjh.id,
  pjh.matricula       AS usuario_matricula,
  usr.nome_referencia AS usuario_nome,
  pjh.data_hora,
  thp.descricao AS tipo_historico,
  pjh.observacao
FROM         security.projetos_historicos     pjh
  INNER JOIN security.tipo_historico_projetos thp ON thp.id        = pjh.id_tipo_historico
  INNER JOIN security.users                   usr ON usr.matricula = pjh.matricula;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_projetos_progresso_execucao    
-- CLASSE..: VoProjetoProgressoExecucao.java
-- Objetivo: Usar na formação da Ficha do Projeto
--------------------------------------------------------------------------------
CREATE VIEW security.vw_projetos_progresso_execucao AS 
SELECT 
  ppe.id_projeto,
  ppe.id,
  ppe.data_historico,
  ppe.percentual_executado,
  ppe.observacao_progresso
FROM  security.projetos_progresso_execucao  ppe;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_projetos_paralisacoes
-- CLASSE..: VoProjetoParalisacoes.java
-- Objetivo: Usar na formação da Ficha do Projeto
--------------------------------------------------------------------------------
CREATE VIEW security.vw_projetos_paralisacoes AS 
SELECT 
  ppa.id_projeto,
  ppa.id,
  'P' || trim(to_char(ppa.id,'00000')) AS codigo,
  ppa.motivo,
  ppa.data_paralisacao,
  ppa.data_reinicio,
  CASE WHEN ppa.data_reinicio IS NULL 
    THEN 'now'::text::date - ppa.data_paralisacao
    ELSE ppa.dias_parado
  END AS dias_parado
FROM  security.projetos_paralisacoes ppa;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_projetos_ajustes_prazo   
-- CLASSE..: VoProjetoAjustePrazo.java
-- Objetivo: Usar na formação da Ficha do Projeto
--------------------------------------------------------------------------------
CREATE VIEW security.vw_projetos_ajustes_prazo AS 
SELECT 
  pap.id_projeto,
  pap.id,
  pap.data_ajuste,
  pap.motivo,
  pap.fim_previsto_anterior,
  pap.dias_ajustados,
  pap.novo_fim_previsto
FROM  security.projetos_ajustes_prazo  pap;


--------------------------------------------------------------------------------
-- VIEW....: security.vw_dados_projetos            
-- CLASSE..: VoDadosProjeto.java
-- Objetivo: Usar em rotinas de consultas e relatórios e exportação
--------------------------------------------------------------------------------
DROP VIEW security.vw_dados_projetos;

CREATE VIEW security.vw_dados_projetos AS 
SELECT
  pro.id,
  -- dados do Projeto
  pro.codigo            AS projeto_codigo,
  pro.nome              AS projeto_nome,
  pro.sigla             AS projeto_sigla,
  pro.descricao         AS projeto_descricao,
  -- Envolvidos no projeto
  pro.interessado       AS projeto_interessado,
  -- Responsavel do Projeto
  pro.id_responsavel    AS responsavel_id,
  res.nome_completo     AS responsavel_nome_completo,
  res.nome_referencia   AS responsavel_nome_referencia,
  res.fone_celular      AS responsavel_fone_celular,
  res.fone_comercial    AS responsavel_fone_comercial,
  res.fone_residencial  AS responsavel_fone_residencial,
  res.email             AS responsavel_email,
  -- Gerente do Projeto
  pro.id_gerente        AS gerente_id,
  gpr.nome_completo     AS gerente_nome_completo,
  gpr.nome_referencia   AS gerente_nome_referencia,
  gpr.fone_celular      AS gerente_fone_celular,
  gpr.fone_comercial    AS gerente_fone_comercial,
  gpr.fone_residencial  AS gerente_fone_residencial,
  gpr.email             AS gerente_email,
  -- Datas Previsto e Real  
  pro.data_inicio_previsto    AS projeto_data_inicio_previsto,
  pro.data_fim_previsto       AS projeto_data_fim_previsto,
  pro.data_fim_previsto_atual AS projeto_data_fim_previsto_atual,
  pro.data_inicio_real        AS projeto_data_inicio_real,
  pro.data_fim_real           AS projeto_data_fim_real,
  -- Dias e Prazos
  pro.prazo_inicial           AS projeto_prazo_inicial,   -- PZI
  pro.dias_ajustados          AS projeto_dias_ajustados,  -- DAJ
  pro.prazo_inicial + 
  pro.dias_ajustados          AS projeto_prazo_total,     -- PZT 
  pro.dias_paralisado         AS projeto_dias_paralisado, -- DPA
  -- ---------------------------------------------------------------------------
  COALESCE((pro.data_inicio_real  - pro.data_inicio_previsto),0)
                              AS projeto_dias_ajuste_inicial,-- DAI
  -- ---------------------------------------------------------------------------
  (pro.dias_ajustados - pro.dias_paralisado - 
   COALESCE((pro.data_inicio_real - pro.data_inicio_previsto),0))
                             AS projeto_dias_ajuste_usuario,-- DAU
  -- ---------------------------------------------------------------------------
  CASE WHEN (pro.data_inicio_real ISNULL)                 
    THEN 0                                                -- Se Projeto Não Iniciou
    ELSE CASE WHEN (pro.data_fim_real ISNULL)             -- + Incui dia de hoje 
      THEN (CURRENT_DATE - pro.data_inicio_real + 1)      -- Se já iniciou e não concluiu
      ELSE (pro.data_fim_real - pro.data_inicio_real + 1) -- Se Já concluir
    END
  END                      AS projeto_dias_corridos,      -- DCO
  -- ---------------------------------------------------------------------------
  CASE WHEN pro.id_status = 4 OR pro.id_status = 5        -- Se 4-Em Execucao OU 5-Paralisado         
    THEN pro.data_fim_previsto_atual - CURRENT_DATE
    ELSE 0
  END                      AS projeto_dias_disponiveis,   -- DDI
  -- ---------------------------------------------------------------------------  
  (pro.prazo_inicial + pro.dias_ajustados) -
  COALESCE((pro.data_inicio_real - pro.data_inicio_previsto),0)
                           AS projeto_prazo_real,
  -- Execução do projeto
   CASE WHEN (pro.data_inicio_real ISNULL)                 
    THEN 0                                                -- Se Projeto Não Iniciou
    ELSE CASE WHEN (pro.data_fim_real ISNULL)             -- + Incui dia de hoje 
      THEN round(((CURRENT_DATE - pro.data_inicio_real + 1)::NUMERIC /
                 ((pro.prazo_inicial + pro.dias_ajustados) -
                 COALESCE((pro.data_inicio_real - pro.data_inicio_previsto),0))::NUMERIC) * 100,0)
      ELSE round(((pro.data_fim_real - pro.data_inicio_real + 1)::NUMERIC /
                 ((pro.prazo_inicial + pro.dias_ajustados) -
                 COALESCE((pro.data_inicio_real - pro.data_inicio_previsto),0))::NUMERIC) * 100,0)
    END
  END                      AS projeto_percentual_estimado,
  pro.percentual_executado AS projeto_percentual_executado,
  pro.observacao_progresso AS projeto_observacao_progresso,
  -- Area de Ti do Projeto
  pro.id_area_ti       AS area_ti_id,
  ati.nome             AS area_ti_nome,
  ati.sigla            AS area_ti_sigla,
  ati.cor              AS area_ti_cor,
  -- Tipo do Projeto
  pro.id_tipo          AS tipo_id,
  tpr.nome             AS tipo_nome,
  tpr.sigla            AS tipo_sigla,
  -- Status do Projeto
  pro.id_status        AS status_id,
  pro.id_status || ' - ' || 
  spr.nome             AS status_nome,
  spr.sigla            AS status_sigla,
  spr.cor              AS status_cor,
  -- Prioridade do Projeto
  pro.id_prioridade    AS prioridade_id,
  ppr.nome             AS prioridade_nome,
  ppr.sigla            AS prioridade_sigla,
  ppr.cor              AS prioridade_cor,
  -- Projeto PAI
  pro.id_projeto_pai   AS projeto_pai_id,
  ppa.codigo           AS projeto_pai_codigo,
  ppa.nome             AS projeto_pai_nome,
  ppa.sigla            AS projeto_pai_sigla,
  -- Módulo do SIGDER do Projeto
  pro.id_modulo        AS modulo_id,
  mod.codigo_modulo    AS modulo_codigo,
  mod.nome             AS modulo_nome,
  mod.sigla            AS modulo_sigla
FROM         security.projetos           pro
  INNER JOIN security.area_ti            ati ON ati.id=pro.id_area_ti
  INNER JOIN security.tipo_projeto       tpr ON tpr.id=pro.id_tipo
  INNER JOIN security.status_projeto     spr ON spr.id=pro.id_status
  INNER JOIN security.profissionais_ti   res ON res.id=pro.id_responsavel
  INNER JOIN security.profissionais_ti   gpr ON gpr.id=pro.id_gerente
  INNER JOIN security.prioridade_projeto ppr ON ppr.id=pro.id_prioridade
  LEFT  JOIN security.projetos           ppa ON ppa.id=pro.id_projeto_pai
  LEFT  JOIN security.modulos            mod ON mod.id=pro.id_modulo;

-- /////////////////////////////////////////////////////////////////////////////
--------------------------------------------------------------------------------
-- VIEW: Lista de Atividades
--------------------------------------------------------------------------------
DROP VIEW security.vw_lista_atividades;

CREATE VIEW security.vw_lista_atividades AS 
SELECT atv.id,
       atv.descricao,
       atv.id_tipo_atividade,
       atv.id_projeto,
       atv.id_manutencao_sistema,
       atv.id_status       
FROM   security.atividades atv;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_lista_atividades_projeto
-- CLASSE..: VoListaAtividadesProjeto.java
-- Objetivo: Exibir a lista de atividade tipo Projeto
--------------------------------------------------------------------------------
DROP VIEW security.vw_lista_atividades_projeto;

CREATE VIEW security.vw_lista_atividades_projeto AS 
SELECT atv.id,
       atv.codigo,
       atv.descricao,
       atv.id_projeto,
       COALESCE(pro.qtd_prof, 0) AS qtd_profissionais
FROM   security.atividades atv LEFT JOIN 
      (SELECT axp.id_atividade, count(axp.id) AS qtd_prof
         FROM security.atividades_x_profissionais_ti axp
     GROUP BY axp.id_atividade
      )                    pro ON atv.id = pro.id_atividade
WHERE NOT atv.id_projeto ISNULL; 


--------------------------------------------------------------------------------
-- VIEW....: security.vw_lista_atividades_manutencao
-- CLASSE..: VoListaAtividadesManutencao.java
-- Objetivo: Exibir a lista de atividade tipo Manutencao
--------------------------------------------------------------------------------
DROP VIEW security.vw_lista_atividades_manutencao;

CREATE VIEW security.vw_lista_atividades_manutencao AS 
SELECT atv.id,
       atv.codigo,
       atv.descricao,
       atv.id_manutencao_sistema  AS id_manutencao,
       COALESCE(pro.qtd_prof, 0)  AS qtd_profissionais
FROM   security.atividades atv LEFT JOIN 
      (SELECT axp.id_atividade, count(axp.id) AS qtd_prof
         FROM security.atividades_x_profissionais_ti axp
     GROUP BY axp.id_atividade
      )                    pro ON atv.id = pro.id_atividade      
WHERE NOT atv.id_manutencao_sistema ISNULL;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_projetos_atividades
-- CLASSE..: VoProjetoAtividades.java
-- Objetivo: Usar na formação da Ficha do Projeto
--------------------------------------------------------------------------------
DROP VIEW security.vw_projetos_atividades;

CREATE VIEW security.vw_projetos_atividades AS 
SELECT 
  atv.id_projeto,
  atv.id,
  atv.codigo,
  atv.descricao,
  atv.data_inicio_previsto,
  atv.data_fim_previsto,
  atv.data_inicio_real,
  atv.data_fim_real,
  atv.horas_prevista,
  atv.horas_real,
  atv.quantidade,
  atv.quantidade_executada,  
  COALESCE(pro.qtd_prof, 0) AS qtd_profissionais,
  sta.sigla                 AS status
FROM security.atividades               atv 
  INNER JOIN security.status_atividade sta ON sta.id = atv.id_status
  LEFT  JOIN 
    (SELECT axp.id_atividade, count(axp.id) AS qtd_prof
       FROM security.atividades_x_profissionais_ti axp
   GROUP BY axp.id_atividade
     ) pro ON atv.id = pro.id_atividade
WHERE NOT atv.id_projeto IS NULL;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_projetos_x_profissionais_ti
-- CLASSE..: VoProjetoXProfissionais.java
-- Objetivo: Usar na formação da Ficha do Projeto
--------------------------------------------------------------------------------
DROP VIEW security.vw_projetos_x_profissionais_ti;

CREATE VIEW security.vw_projetos_x_profissionais_ti AS
SELECT 
  pxp.id,
  pxp.id_projeto,
  pxp.id_profissional,
  prt.nome_completo,
  prt.nome_referencia,
  prt.email,
  prt.fone_celular,
  prt.fone_comercial,
  art.nome	AS area,
  pro.qtd_atividades
FROM       security.projetos_x_profissionais_ti pxp
INNER JOIN security.profissionais_ti            prt on prt.id      = pxp.id_profissional
INNER JOIN security.area_ti                     art ON prt.id_area = art.id
LEFT  JOIN (SELECT pxp.id AS id_proj_x_prof,count(axp.id) as qtd_atividades
              FROM security.atividades_x_profissionais_ti axp 
        INNER JOIN security.atividades                    atv ON atv.id              = axp.id_atividade
        INNER JOIN security.projetos_x_profissionais_ti   pxp ON pxp.id_projeto      = atv.id_projeto
                                                             AND pxp.id_profissional = axp.id_profissional
          GROUP BY pxp.id
           )                                              pro ON pxp.id = pro.id_proj_x_prof
ORDER BY pxp.id_projeto, pxp.id_profissional;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_projetos_interrupcoes
-- CLASSE..: VoProjetoInterrupcoes.java
-- Objetivo: Usar na formação da Ficha do projeto
--------------------------------------------------------------------------------
DROP VIEW security.vw_projetos_interrupcoes;

CREATE VIEW security.vw_projetos_interrupcoes AS 
SELECT 
  prj.id,
  prj.id_projeto,
  prj.motivo,
  prj.data_interrupcao,
  prj.horas_interrompidas,
  pro.nome_referencia AS profissional,
  atv.codigo          AS atividade
FROM  security.projetos_interrupcoes    prj
  INNER JOIN security.profissionais_ti  pro ON pro.id = prj.id_profissional
  LEFT  JOIN security.atividades        atv ON atv.id = prj.id_atividade;


-- =============================================================================
-- INICIO: VIEWS Controle de Manutenção
-- =============================================================================
--------------------------------------------------------------------------------
-- VIEW....: security.vw_dados_manutencoes_sistema
-- CLASSE..: VoDadosManutencoesSistema.java
-- Objetivo: Usar em rotinas de consultas e relatórios e exportação
--------------------------------------------------------------------------------
DROP VIEW security.vw_dados_manutencoes_sistema;

CREATE OR REPLACE VIEW security.vw_dados_manutencoes_sistema AS
SELECT 
  msi.id,
  -- Dados da Manutenção
  msi.codigo               AS manutencao_codigo,
  msi.descricao            AS manutencao_descricao,
  msi.solicitado_por       AS manutencao_solicitado_por,
  msi.observacao           AS manutencao_observacao,
  msi.data_inicio_previsto AS manutencao_data_inicio_previsto,
  msi.data_fim_previsto    AS manutencao_data_fim_previsto,
  msi.data_inicio_real     AS manutencao_data_inicio_real,
  msi.data_fim_real        AS manutencao_data_fim_real,
  msi.data_fim_previsto - msi.data_inicio_previsto + 1 
                           AS manutencao_prazo_previsto,
  CASE WHEN msi.data_inicio_real IS NULL 
    THEN 0
    ELSE CASE WHEN msi.data_fim_real IS NULL 
           THEN 'now'::text::date - msi.data_inicio_real + 1
           ELSE msi.data_fim_real - msi.data_inicio_real + 1
         END
  END                      AS manutencao_dias_corridos,
  CASE WHEN msi.data_inicio_real IS NULL OR msi.data_fim_real IS NULL 
    THEN 0
    ELSE msi.data_fim_real - msi.data_inicio_real + 1
  END                      AS manutencao_prazo_real,
  msi.observacao_progresso AS manutencao_observacao_progresso,
  msi.percentual_executado AS manutencao_percentual_executado,
  -- Tipo de Manutencao
  msi.id_tipo         AS tipo_id,
  tms.sigla           AS tipo_sigla,
  tms.nome            AS tipo_nome,
  -- Status da Manutencao
  msi.id_status       AS status_id,
  sms.sigla           AS status_sigla,
  sms.nome            AS status_nome,
  -- Módulo em que a manutenção foi realizada
  msi.id_modulo       AS modulo_id,
  mod.codigo_modulo   AS modulo_codigo,
  mod.sigla           AS modulo_sigla,
  mod.nome            AS modulo_nome,
  -- Resposanvel Pela Manutenção
  msi.id_responsavel  AS responsavel_id,
  res.nome_completo   AS responsavel_nome_completo,
  res.nome_referencia AS responsavel_nome_referencia,
  res.fone_celular    AS responsavel_celular,
  res.fone_comercial  AS responsavel_comercial,
  res.email           AS responsavel_email
FROM         security.manutencoes_sistema       msi
  INNER JOIN security.tipo_manutencao_sistema   tms ON tms.id = msi.id_tipo
  INNER JOIN security.status_manutencao_sistema sms ON sms.id = msi.id_status
  INNER JOIN security.profissionais_ti          res ON res.id = msi.id_responsavel
  INNER JOIN security.modulos                   mod ON mod.id = msi.id_modulo;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_manutencoes_sistema               
-- CLASSE..: VoManutencaoSistema.java
-- Objetivo: Usar na formação da Ficha da Manutencao de Sistema
--------------------------------------------------------------------------------
DROP VIEW security.vw_manutencoes_sistema;

CREATE VIEW security.vw_manutencoes_sistema AS 
SELECT
  msi.id,
  -- dados do Projeto
  msi.codigo,
  msi.descricao,
  msi.solicitado_por,
  msi.observacao,
  -- Datas Previsto e Real
  msi.data_inicio_previsto,
  msi.data_fim_previsto,
  msi.data_inicio_real,
  msi.data_fim_real,
  -- Dias e Prazos
  (msi.data_fim_previsto - msi.data_inicio_previsto) + 1 -- inclui dia do inicio
                       AS  prazo_previsto, 
  -- ---------------------------------------------------------------------------
  CASE WHEN (msi.data_inicio_real ISNULL)                 
    THEN 0                                                -- Se Projeto Não Iniciou
    ELSE CASE WHEN (msi.data_fim_real ISNULL)             -- + Incui dia de hoje 
      THEN (CURRENT_DATE - msi.data_inicio_real + 1)      -- Se já iniciou e não concluiu
      ELSE (msi.data_fim_real - msi.data_inicio_real + 1) -- Se Já concluir
    END
  END                  AS dias_corridos,      -- DCO
  -- ---------------------------------------------------------------------------  
  CASE WHEN (msi.data_inicio_real ISNULL)  OR (msi.data_fim_real ISNULL) 
    THEN 0
    ELSE (msi.data_fim_real - msi.data_inicio_real) + 1
  END                   AS prazo_real,                           
  -- Execucao Projeto
  msi.observacao_progresso,
  msi.percentual_executado,   
  -- Classificação do Projeto
  tms.nome             AS tipo_manutencao,
  sms.nome             AS status_manutencao,
  mod.sigla            AS modulo,
  -- dados do Responsavel do Projeto
  res.nome_completo    AS responsavel,
  res.fone_celular     AS responsavel_celular,
  res.fone_comercial   AS responsavel_comercial,
  res.email            AS responsavel_email
FROM         security.manutencoes_sistema       msi
  INNER JOIN security.tipo_manutencao_sistema   tms ON tms.id=msi.id_tipo
  INNER JOIN security.status_manutencao_sistema sms ON sms.id=msi.id_status
  INNER JOIN security.profissionais_ti          res ON res.id=msi.id_responsavel
  INNER JOIN security.modulos                   mod ON mod.id=msi.id_modulo;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_manutencoes_sistema_historicos     
-- CLASSE..: VoManutencaoSistemaHistoricos.java
-- Objetivo: Usar na formação da Ficha da Manutencao de Sistema
--------------------------------------------------------------------------------
DROP VIEW security.vw_manutencoes_sistema_historicos;

CREATE VIEW security.vw_manutencoes_sistema_historicos AS 
SELECT 
  msh.id_manutencao,
  msh.id,
  msh.matricula       AS usuario_matricula,
  usr.nome_referencia AS usuario_nome,
  msh.data_hora,
  thp.descricao AS tipo_historico,
  msh.observacao
FROM         security.manutencoes_sistema_historicos msh
  INNER JOIN security.tipo_historico_manutencao_sis  thp ON thp.id = msh.id_tipo_historico
  INNER JOIN security.users                          usr ON usr.matricula = msh.matricula;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_manutencoes_sistema_paralisacoes
-- CLASSE..: VoManutencaoSistemaParalisacoes.java
-- Objetivo: Usar na formação da Ficha da Manutencao de Sistema
--------------------------------------------------------------------------------
DROP VIEW security.vw_manutencoes_sistema_paralisacoes;

CREATE VIEW security.vw_manutencoes_sistema_paralisacoes AS 
SELECT 
  msp.id_manutencao,
  msp.id,
  'M' || trim(to_char(msp.id,'00000')) AS codigo,
  msp.motivo,
  msp.data_paralisacao,
  msp.data_reinicio,
  CASE WHEN msp.data_reinicio IS NULL 
    THEN 'now'::text::date - msp.data_paralisacao
    ELSE msp.dias_parado
  END AS dias_parado
FROM  security.manutencoes_sistema_paralisacoes msp;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_manutencoes_sistema_interrupcoes
-- CLASSE..: VoManutencaoSistemaInterrupcoes.java
-- Objetivo: Usar na formação da Ficha da Manutencao de Sistema
--------------------------------------------------------------------------------
DROP VIEW security.vw_manutencoes_sistema_interrupcoes;

CREATE VIEW security.vw_manutencoes_sistema_interrupcoes AS 
SELECT 
  msi.id,
  msi.id_manutencao,
  msi.motivo,
  msi.data_interrupcao,
  msi.horas_interrompidas,
  pro.nome_referencia AS profissional,
  atv.codigo          AS atividade
FROM  security.manutencoes_sistema_interrupcoes msi
  INNER JOIN security.profissionais_ti          pro ON pro.id = msi.id_profissional
  LEFT  JOIN security.atividades                atv ON atv.id = msi.id_atividade;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_manutencoes_sistema_atividades
-- CLASSE..: VoManutencaoSistemaAtividades.java
-- Objetivo: Usar na formação da Ficha da Manutencao de Sistema
--------------------------------------------------------------------------------
DROP VIEW security.vw_manutencoes_sistema_atividades;

CREATE VIEW security.vw_manutencoes_sistema_atividades AS 
SELECT 
  atv.id_manutencao_sistema AS id_manutencao,
  atv.id,
  atv.codigo,
  atv.descricao,
  atv.data_inicio_previsto,
  atv.data_fim_previsto,
  atv.data_inicio_real,
  atv.data_fim_real,
  atv.horas_prevista,
  atv.horas_real,
  atv.quantidade,
  atv.quantidade_executada,
  COALESCE(pro.qtd_prof, 0) AS qtd_profissionais,
  sta.sigla                 AS status
FROM  security.atividades  atv
  INNER JOIN security.status_atividade sta ON sta.id = atv.id_status
  LEFT  JOIN 
    (SELECT axp.id_atividade, count(axp.id) AS qtd_prof
       FROM security.atividades_x_profissionais_ti axp
   GROUP BY axp.id_atividade
     ) pro ON atv.id = pro.id_atividade
WHERE NOT atv.id_manutencao_sistema ISNULL;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_manutencoes_sistema_x_profissionais_ti
-- CLASSE..: VoManutencaoSistemaXProfissionaisTi.java
-- Objetivo: Usar na formação da Ficha da Manutencao de Sistema
--------------------------------------------------------------------------------
DROP VIEW security.vw_manutencoes_sistema_x_profissionais_ti;

CREATE VIEW security.vw_manutencoes_sistema_x_profissionais_ti AS
SELECT 
  mxp.id,
  mxp.id_manutencao,
  mxp.id_profissional,
  prt.nome_completo,
  prt.nome_referencia,
  prt.email,
  prt.fone_celular,
  prt.fone_comercial,
  art.nome	AS area,
  pro.qtd_atividades
FROM       security.manutencoes_sistema_x_profissionais_ti mxp
INNER JOIN security.profissionais_ti  prt on prt.id      = mxp.id_profissional
INNER JOIN security.area_ti           art ON prt.id_area = art.id
LEFT  JOIN (SELECT mxp.id AS id_proj_x_prof,count(axp.id) as qtd_atividades
              FROM security.atividades_x_profissionais_ti          axp 
        INNER JOIN security.atividades                             atv ON atv.id              = axp.id_atividade
        INNER JOIN security.manutencoes_sistema_x_profissionais_ti mxp ON mxp.id_manutencao   = atv.id_manutencao_sistema
                                                             AND mxp.id_profissional = axp.id_profissional
          GROUP BY mxp.id
           )                                              pro ON mxp.id = pro.id_proj_x_prof
ORDER BY mxp.id_manutencao, mxp.id_profissional;
-- =============================================================================
-- FIM: VIEWS Controle de Manutenção
-- =============================================================================

--------------------------------------------------------------------------------
-- VIEW....: security.vw_atividades_quadro_kanban
-- CLASSE..: VoAtividadesQuadroKanban.java
-- Objetivo: Usar Consultas e relat[orios do quadro kanban
--------------------------------------------------------------------------------
DROP VIEW security.vw_atividades_quadro_kanban;

CREATE OR REPLACE VIEW security.vw_atividades_quadro_kanban AS
SELECT  
  axp.id,
  pro.id                   AS prof_id,
  pro.nome_referencia      AS prof_nome,
  tpa.id                   AS tipo_ativ_id,
  tpa.nome                 AS tipo_ativ_nome,
  CASE 
    WHEN tpa.id = 1 THEN prj.codigo -- Projeto   
    WHEN tpa.id = 2 THEN man.codigo -- Manutenção
    WHEN tpa.id = 3 THEN atv.codigo -- Diversas
  END                      AS tipo_ativ_codigo,
  sta.id                   AS stat_ativ_id,
  sta.nome                 AS stat_ativ_nome,
  atv.codigo               AS ativ_codigo,  
  atv.descricao            AS ativ_descricao, 
  atv.data_inicio_previsto AS ativ_ini_prev,  
  atv.data_fim_previsto    AS ativ_fim_prev,
  atv.data_inicio_real     AS ativ_ini_real,
  atv.data_fim_real        AS ativ_fim_real, 
  atv.quantidade           AS ativ_qtd_prev,
  atv.quantidade_executada AS ativ_qtd_real,
  atv.horas_prevista       AS ativ_hrs_prev,
  atv.horas_real           AS ativ_hrs_real,   
  qpe.qtd_prof             AS ativ_qtd_prof,
  CASE WHEN atv.data_inicio_real ISNULL 
    THEN to_char(atv.data_inicio_previsto,'yyyyMM')
    ELSE to_char(atv.data_inicio_real    ,'yyyyMM')
  END                      AS ativ_ano_mes_ini,
  CASE WHEN atv.data_fim_real ISNULL 
    THEN to_char(atv.data_fim_previsto,'yyyyMM')
    ELSE to_char(atv.data_fim_real    ,'yyyyMM')
  END                      AS ativ_ano_mes_fim,
  CASE WHEN atv.id_status=1 THEN true ELSE false END AS ativ_a_iniciar,
  CASE WHEN atv.id_status=2 THEN true ELSE false END AS ativ_iniciada,
  CASE WHEN atv.id_status=3 THEN true ELSE false END AS ativ_concluida,
  CASE WHEN atv.id_status=4 THEN true ELSE false END AS ativ_cancelada,  
  axp.observacao           AS ativ_x_prof_obs
FROM         security.atividades_x_profissionais_ti axp
  INNER JOIN security.profissionais_ti              pro ON pro.id = axp.id_profissional
  INNER JOIN security.atividades                    atv ON atv.id = axp.id_atividade
  INNER JOIN security.status_atividade              sta ON sta.id = atv.id_status
  INNER JOIN security.tipo_atividade                tpa ON tpa.id = atv.id_tipo_atividade
  LEFT  JOIN security.projetos                      prj ON prj.id = atv.id_projeto
  LEFT  JOIN security.manutencoes_sistema           man ON man.id = atv.id_manutencao_sistema
  LEFT JOIN 
      (SELECT axp.id_atividade, count(axp.id) AS qtd_prof
         FROM security.atividades_x_profissionais_ti axp
     GROUP BY axp.id_atividade
      )                    qpe ON atv.id = qpe.id_atividade
WHERE (atv.id_tipo_atividade=1 and prj.id_status=4) OR -- Atividade de Projeto em Execução
      (atv.id_tipo_atividade=2 and man.id_status=2) OR -- Atividade de Manutenção em Execucao
      (atv.id_tipo_atividade=3)                        -- Atividade Diversas 


--------------------------------------------------------------------------------
-- VIEW....: security.vw_mapa_anual_projetos
-- CLASSE..: VoMapaAnualProjetos.java
-- Objetivo: Exibir mapa anual de projetos 
--------------------------------------------------------------------------------
DROP VIEW security.vw_mapa_anual_projetos;
CREATE OR REPLACE VIEW security.vw_mapa_anual_projetos AS
SELECT  
   -- Dados do Projeto
   prj.id,
   prj.codigo,
   prj.nome,
   prj.sigla,    
   EXTRACT(YEAR FROM CURRENT_DATE)  AS ano_mapa,
   -- Datas Prevista / Real
   prj.data_inicio_previsto AS data_ini_prev,
   prj.data_fim_previsto    AS data_fim_prev,
   prj.data_inicio_real     AS data_ini_real,
   prj.data_fim_real        AS data_fim_real,
   -- Classificação
   prj.id_status            AS status_id,
   spr.cor                  AS status_cor,  
   spr.sigla                AS status_sigla,
   spr.nome                 AS status_nome, 
   ati.sigla                AS area_ti_sigla,
   ati.nome                 AS area_ti_nome,
   tpr.sigla                AS tipo_sigla,
   tpr.nome                 AS tipo_nome,
   ppr.sigla                AS prioridade_sigla,
   ppr.nome                 AS prioridade_nome,
   -- E X E C U Ç Ã O
   res.nome_referencia      AS responsavel,
   gpr.nome_referencia      AS gerente,
   prj.percentual_executado AS percentual_executado,
   prj.observacao_progresso AS observacao_progresso,  
   -- --------------------------------------------------------------------------
   -- Dados para montar a barra: P R E V I S T O
   -- --------------------------------------------------------------------------
   -- J A N E I R O
   CASE        WHEN mes.mes_ini_prev < 1 AND mes.mes_fim_prev > 1 THEN 1 -- Começa Antes  E  Termina Depois
     ELSE CASE WHEN mes.mes_ini_prev = 1 AND mes.mes_fim_prev = 1 THEN 2 -- Começa no Mês E  Termina no Mês
     ELSE CASE WHEN mes.mes_ini_prev = 1 AND mes.mes_fim_prev > 1 AND mes.dia_ini_prev <= 15 THEN 3 -- Começa no Mês Até     o dia 15 e Termina Depois
     ELSE CASE WHEN mes.mes_ini_prev = 1 AND mes.mes_fim_prev > 1 AND mes.dia_ini_prev >  15 THEN 4 -- Começa no Mês Depois do dia 15 e Termina Depois
     ELSE CASE WHEN mes.mes_ini_prev < 1 AND mes.mes_fim_prev = 1 AND mes.dia_fim_prev >  15 THEN 5 -- Começa Antes e Termina no Mês Depois do dia 15
     ELSE CASE WHEN mes.mes_ini_prev < 1 AND mes.mes_fim_prev = 1 AND mes.dia_fim_prev <= 15 THEN 6 -- Começa Antes e Termina no Mês Até     o dia 15
     ELSE 0 END END END END END                                                -- Termina Antes OU Começa Depois
   END AS mes_jan_prev,   
   -- F E V E R E I R O
   CASE        WHEN mes.mes_ini_prev < 2 AND mes.mes_fim_prev > 2 THEN 1
     ELSE CASE WHEN mes.mes_ini_prev = 2 AND mes.mes_fim_prev = 2 THEN 2
     ELSE CASE WHEN mes.mes_ini_prev = 2 AND mes.mes_fim_prev > 2 AND mes.dia_ini_prev <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_prev = 2 AND mes.mes_fim_prev > 2 AND mes.dia_ini_prev >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_prev < 2 AND mes.mes_fim_prev = 2 AND mes.dia_fim_prev >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_prev < 2 AND mes.mes_fim_prev = 2 AND mes.dia_fim_prev <= 15 THEN 6 
     ELSE 0 END END END END END                                             
   END AS mes_fev_prev,   
   -- M A R Ç O
   CASE        WHEN mes.mes_ini_prev < 3 AND mes.mes_fim_prev > 3 THEN 1
     ELSE CASE WHEN mes.mes_ini_prev = 3 AND mes.mes_fim_prev = 3 THEN 2
     ELSE CASE WHEN mes.mes_ini_prev = 3 AND mes.mes_fim_prev > 3 AND mes.dia_ini_prev <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_prev = 3 AND mes.mes_fim_prev > 3 AND mes.dia_ini_prev >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_prev < 3 AND mes.mes_fim_prev = 3 AND mes.dia_fim_prev >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_prev < 3 AND mes.mes_fim_prev = 3 AND mes.dia_fim_prev <= 15 THEN 6 
     ELSE 0 END END END END END                                       
   END AS mes_mar_prev,
   -- A B R I L
   CASE        WHEN mes.mes_ini_prev < 4 AND mes.mes_fim_prev > 4 THEN 1
     ELSE CASE WHEN mes.mes_ini_prev = 4 AND mes.mes_fim_prev = 4 THEN 2
     ELSE CASE WHEN mes.mes_ini_prev = 4 AND mes.mes_fim_prev > 4 AND mes.dia_ini_prev <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_prev = 4 AND mes.mes_fim_prev > 4 AND mes.dia_ini_prev >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_prev < 4 AND mes.mes_fim_prev = 4 AND mes.dia_fim_prev >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_prev < 4 AND mes.mes_fim_prev = 4 AND mes.dia_fim_prev <= 15 THEN 6 
     ELSE 0 END END END END END                                  
   END AS mes_abr_prev,   
   -- M A I O
   CASE        WHEN mes.mes_ini_prev < 5 AND mes.mes_fim_prev > 5 THEN 1
     ELSE CASE WHEN mes.mes_ini_prev = 5 AND mes.mes_fim_prev = 5 THEN 2
     ELSE CASE WHEN mes.mes_ini_prev = 5 AND mes.mes_fim_prev > 5 AND mes.dia_ini_prev <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_prev = 5 AND mes.mes_fim_prev > 5 AND mes.dia_ini_prev >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_prev < 5 AND mes.mes_fim_prev = 5 AND mes.dia_fim_prev >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_prev < 5 AND mes.mes_fim_prev = 5 AND mes.dia_fim_prev <= 15 THEN 6 
     ELSE 0 END END END END END
   END AS mes_mai_prev,
   -- J U N H O
   CASE        WHEN mes.mes_ini_prev < 6 AND mes.mes_fim_prev > 6 THEN 1
     ELSE CASE WHEN mes.mes_ini_prev = 6 AND mes.mes_fim_prev = 6 THEN 2
     ELSE CASE WHEN mes.mes_ini_prev = 6 AND mes.mes_fim_prev > 6 AND mes.dia_ini_prev <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_prev = 6 AND mes.mes_fim_prev > 6 AND mes.dia_ini_prev >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_prev < 6 AND mes.mes_fim_prev = 6 AND mes.dia_fim_prev >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_prev < 6 AND mes.mes_fim_prev = 6 AND mes.dia_fim_prev <= 15 THEN 6 
     ELSE 0 END END END END END                               
   END AS mes_jun_prev,
   -- J U L H O
   CASE        WHEN mes.mes_ini_prev < 7 AND mes.mes_fim_prev > 7 THEN 1
     ELSE CASE WHEN mes.mes_ini_prev = 7 AND mes.mes_fim_prev = 7 THEN 2
     ELSE CASE WHEN mes.mes_ini_prev = 7 AND mes.mes_fim_prev > 7 AND mes.dia_ini_prev <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_prev = 7 AND mes.mes_fim_prev > 7 AND mes.dia_ini_prev >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_prev < 7 AND mes.mes_fim_prev = 7 AND mes.dia_fim_prev >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_prev < 7 AND mes.mes_fim_prev = 7 AND mes.dia_fim_prev <= 15 THEN 6 
     ELSE 0 END END END END END                                   
   END AS mes_jul_prev,
   -- A G O S T O
   CASE        WHEN mes.mes_ini_prev < 8 AND mes.mes_fim_prev > 8 THEN 1
     ELSE CASE WHEN mes.mes_ini_prev = 8 AND mes.mes_fim_prev = 8 THEN 2
     ELSE CASE WHEN mes.mes_ini_prev = 8 AND mes.mes_fim_prev > 8 AND mes.dia_ini_prev <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_prev = 8 AND mes.mes_fim_prev > 8 AND mes.dia_ini_prev >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_prev < 8 AND mes.mes_fim_prev = 8 AND mes.dia_fim_prev >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_prev < 8 AND mes.mes_fim_prev = 8 AND mes.dia_fim_prev <= 15 THEN 6 
     ELSE 0 END END END END END                                       
   END AS mes_ago_prev,
   -- S E T E M B R O
   CASE        WHEN mes.mes_ini_prev < 9 AND mes.mes_fim_prev > 9 THEN 1
     ELSE CASE WHEN mes.mes_ini_prev = 9 AND mes.mes_fim_prev = 9 THEN 2
     ELSE CASE WHEN mes.mes_ini_prev = 9 AND mes.mes_fim_prev > 9 AND mes.dia_ini_prev <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_prev = 9 AND mes.mes_fim_prev > 9 AND mes.dia_ini_prev >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_prev < 9 AND mes.mes_fim_prev = 9 AND mes.dia_fim_prev >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_prev < 9 AND mes.mes_fim_prev = 9 AND mes.dia_fim_prev <= 15 THEN 6 
     ELSE 0 END END END END END                                    
   END AS mes_set_prev,
   -- O U T U B R O
   CASE        WHEN mes.mes_ini_prev < 10 AND mes.mes_fim_prev > 10 THEN 1
     ELSE CASE WHEN mes.mes_ini_prev = 10 AND mes.mes_fim_prev = 10 THEN 2
     ELSE CASE WHEN mes.mes_ini_prev = 10 AND mes.mes_fim_prev > 10 AND mes.dia_ini_prev <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_prev = 10 AND mes.mes_fim_prev > 10 AND mes.dia_ini_prev >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_prev < 10 AND mes.mes_fim_prev = 10 AND mes.dia_fim_prev >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_prev < 10 AND mes.mes_fim_prev = 10 AND mes.dia_fim_prev <= 15 THEN 6 
     ELSE 0 END END END END END                                     
   END AS mes_out_prev,   
   -- N O V E M B R O
   CASE        WHEN mes.mes_ini_prev < 11 AND mes.mes_fim_prev > 11 THEN 1
     ELSE CASE WHEN mes.mes_ini_prev = 11 AND mes.mes_fim_prev = 11 THEN 2
     ELSE CASE WHEN mes.mes_ini_prev = 11 AND mes.mes_fim_prev > 11 AND mes.dia_ini_prev <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_prev = 11 AND mes.mes_fim_prev > 11 AND mes.dia_ini_prev >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_prev < 11 AND mes.mes_fim_prev = 11 AND mes.dia_fim_prev >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_prev < 11 AND mes.mes_fim_prev = 11 AND mes.dia_fim_prev <= 15 THEN 6 
     ELSE 0 END END END END END                                       
   END AS mes_nov_prev,
   -- D E Z E M B R O
   CASE        WHEN mes.mes_ini_prev < 12 AND mes.mes_fim_prev > 12 THEN 1
     ELSE CASE WHEN mes.mes_ini_prev = 12 AND mes.mes_fim_prev = 12 THEN 2
     ELSE CASE WHEN mes.mes_ini_prev = 12 AND mes.mes_fim_prev > 12 AND mes.dia_ini_prev <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_prev = 12 AND mes.mes_fim_prev > 12 AND mes.dia_ini_prev >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_prev < 12 AND mes.mes_fim_prev = 12 AND mes.dia_fim_prev >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_prev < 12 AND mes.mes_fim_prev = 12 AND mes.dia_fim_prev <= 15 THEN 6 
     ELSE 0 END END END END END                                    
   END AS mes_dez_prev,
   -- --------------------------------------------------------------------------
   -- Dados para montar a barra: R E A L I Z A D O
   -- --------------------------------------------------------------------------
   -- J A N E I R O
   CASE        WHEN mes.mes_ini_real < 1 AND mes.mes_fim_real > 1 THEN 1 -- Começa Antes  E  Termina Depois
     ELSE CASE WHEN mes.mes_ini_real = 1 AND mes.mes_fim_real = 1 THEN 2 -- Começa no Mês E  Termina no Mês
     ELSE CASE WHEN mes.mes_ini_real = 1 AND mes.mes_fim_real > 1 AND mes.dia_ini_real <= 15 THEN 3 -- Começa no Mês Até     o dia 15 e Termina Depois
     ELSE CASE WHEN mes.mes_ini_real = 1 AND mes.mes_fim_real > 1 AND mes.dia_ini_real >  15 THEN 4 -- Começa no Mês Depois do dia 15 e Termina Depois
     ELSE CASE WHEN mes.mes_ini_real < 1 AND mes.mes_fim_real = 1 AND mes.dia_fim_real >  15 THEN 5 -- Começa Antes e Termina no Mês Depois do dia 15
     ELSE CASE WHEN mes.mes_ini_real < 1 AND mes.mes_fim_real = 1 AND mes.dia_fim_real <= 15 THEN 6 -- Começa Antes e Termina no Mês Até     o dia 15
     ELSE 0 END END END END END                                                -- Termina Antes OU Começa Depois
   END AS mes_jan_real,   
   -- F E V E R E I R O
   CASE        WHEN mes.mes_ini_real < 2 AND mes.mes_fim_real > 2 THEN 1
     ELSE CASE WHEN mes.mes_ini_real = 2 AND mes.mes_fim_real = 2 THEN 2
     ELSE CASE WHEN mes.mes_ini_real = 2 AND mes.mes_fim_real > 2 AND mes.dia_ini_real <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_real = 2 AND mes.mes_fim_real > 2 AND mes.dia_ini_real >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_real < 2 AND mes.mes_fim_real = 2 AND mes.dia_fim_real >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_real < 2 AND mes.mes_fim_real = 2 AND mes.dia_fim_real <= 15 THEN 6 
     ELSE 0 END END END END END                                             
   END AS mes_fev_real,   
   -- M A R Ç O
   CASE        WHEN mes.mes_ini_real < 3 AND mes.mes_fim_real > 3 THEN 1
     ELSE CASE WHEN mes.mes_ini_real = 3 AND mes.mes_fim_real = 3 THEN 2
     ELSE CASE WHEN mes.mes_ini_real = 3 AND mes.mes_fim_real > 3 AND mes.dia_ini_real <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_real = 3 AND mes.mes_fim_real > 3 AND mes.dia_ini_real >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_real < 3 AND mes.mes_fim_real = 3 AND mes.dia_fim_real >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_real < 3 AND mes.mes_fim_real = 3 AND mes.dia_fim_real <= 15 THEN 6 
     ELSE 0 END END END END END                                       
   END AS mes_mar_real,
   -- A B R I L
   CASE        WHEN mes.mes_ini_real < 4 AND mes.mes_fim_real > 4 THEN 1
     ELSE CASE WHEN mes.mes_ini_real = 4 AND mes.mes_fim_real = 4 THEN 2
     ELSE CASE WHEN mes.mes_ini_real = 4 AND mes.mes_fim_real > 4 AND mes.dia_ini_real <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_real = 4 AND mes.mes_fim_real > 4 AND mes.dia_ini_real >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_real < 4 AND mes.mes_fim_real = 4 AND mes.dia_fim_real >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_real < 4 AND mes.mes_fim_real = 4 AND mes.dia_fim_real <= 15 THEN 6 
     ELSE 0 END END END END END                                  
   END AS mes_abr_real,   
   -- M A I O
   CASE        WHEN mes.mes_ini_real < 5 AND mes.mes_fim_real > 5 THEN 1
     ELSE CASE WHEN mes.mes_ini_real = 5 AND mes.mes_fim_real = 5 THEN 2
     ELSE CASE WHEN mes.mes_ini_real = 5 AND mes.mes_fim_real > 5 AND mes.dia_ini_real <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_real = 5 AND mes.mes_fim_real > 5 AND mes.dia_ini_real >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_real < 5 AND mes.mes_fim_real = 5 AND mes.dia_fim_real >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_real < 5 AND mes.mes_fim_real = 5 AND mes.dia_fim_real <= 15 THEN 6 
     ELSE 0 END END END END END
   END AS mes_mai_real,
   -- J U N H O
   CASE        WHEN mes.mes_ini_real < 6 AND mes.mes_fim_real > 6 THEN 1
     ELSE CASE WHEN mes.mes_ini_real = 6 AND mes.mes_fim_real = 6 THEN 2
     ELSE CASE WHEN mes.mes_ini_real = 6 AND mes.mes_fim_real > 6 AND mes.dia_ini_real <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_real = 6 AND mes.mes_fim_real > 6 AND mes.dia_ini_real >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_real < 6 AND mes.mes_fim_real = 6 AND mes.dia_fim_real >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_real < 6 AND mes.mes_fim_real = 6 AND mes.dia_fim_real <= 15 THEN 6 
     ELSE 0 END END END END END                               
   END AS mes_jun_real,
   -- J U L H O
   CASE        WHEN mes.mes_ini_real < 7 AND mes.mes_fim_real > 7 THEN 1
     ELSE CASE WHEN mes.mes_ini_real = 7 AND mes.mes_fim_real = 7 THEN 2
     ELSE CASE WHEN mes.mes_ini_real = 7 AND mes.mes_fim_real > 7 AND mes.dia_ini_real <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_real = 7 AND mes.mes_fim_real > 7 AND mes.dia_ini_real >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_real < 7 AND mes.mes_fim_real = 7 AND mes.dia_fim_real >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_real < 7 AND mes.mes_fim_real = 7 AND mes.dia_fim_real <= 15 THEN 6 
     ELSE 0 END END END END END                                   
   END AS mes_jul_real,
   -- A G O S T O
   CASE        WHEN mes.mes_ini_real < 8 AND mes.mes_fim_real > 8 THEN 1
     ELSE CASE WHEN mes.mes_ini_real = 8 AND mes.mes_fim_real = 8 THEN 2
     ELSE CASE WHEN mes.mes_ini_real = 8 AND mes.mes_fim_real > 8 AND mes.dia_ini_real <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_real = 8 AND mes.mes_fim_real > 8 AND mes.dia_ini_real >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_real < 8 AND mes.mes_fim_real = 8 AND mes.dia_fim_real >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_real < 8 AND mes.mes_fim_real = 8 AND mes.dia_fim_real <= 15 THEN 6 
     ELSE 0 END END END END END                                       
   END AS mes_ago_real,
   -- S E T E M B R O
   CASE        WHEN mes.mes_ini_real < 9 AND mes.mes_fim_real > 9 THEN 1
     ELSE CASE WHEN mes.mes_ini_real = 9 AND mes.mes_fim_real = 9 THEN 2
     ELSE CASE WHEN mes.mes_ini_real = 9 AND mes.mes_fim_real > 9 AND mes.dia_ini_real <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_real = 9 AND mes.mes_fim_real > 9 AND mes.dia_ini_real >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_real < 9 AND mes.mes_fim_real = 9 AND mes.dia_fim_real >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_real < 9 AND mes.mes_fim_real = 9 AND mes.dia_fim_real <= 15 THEN 6 
     ELSE 0 END END END END END                                    
   END AS mes_set_real,
   -- O U T U B R O
   CASE        WHEN mes.mes_ini_real < 10 AND mes.mes_fim_real > 10 THEN 1
     ELSE CASE WHEN mes.mes_ini_real = 10 AND mes.mes_fim_real = 10 THEN 2
     ELSE CASE WHEN mes.mes_ini_real = 10 AND mes.mes_fim_real > 10 AND mes.dia_ini_real <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_real = 10 AND mes.mes_fim_real > 10 AND mes.dia_ini_real >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_real < 10 AND mes.mes_fim_real = 10 AND mes.dia_fim_real >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_real < 10 AND mes.mes_fim_real = 10 AND mes.dia_fim_real <= 15 THEN 6 
     ELSE 0 END END END END END                                     
   END AS mes_out_real,   
   -- N O V E M B R O
   CASE        WHEN mes.mes_ini_real < 11 AND mes.mes_fim_real > 11 THEN 1
     ELSE CASE WHEN mes.mes_ini_real = 11 AND mes.mes_fim_real = 11 THEN 2
     ELSE CASE WHEN mes.mes_ini_real = 11 AND mes.mes_fim_real > 11 AND mes.dia_ini_real <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_real = 11 AND mes.mes_fim_real > 11 AND mes.dia_ini_real >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_real < 11 AND mes.mes_fim_real = 11 AND mes.dia_fim_real >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_real < 11 AND mes.mes_fim_real = 11 AND mes.dia_fim_real <= 15 THEN 6 
     ELSE 0 END END END END END                                       
   END AS mes_nov_real,
   -- D E Z E M B R O
   CASE        WHEN mes.mes_ini_real < 12 AND mes.mes_fim_real > 12 THEN 1
     ELSE CASE WHEN mes.mes_ini_real = 12 AND mes.mes_fim_real = 12 THEN 2
     ELSE CASE WHEN mes.mes_ini_real = 12 AND mes.mes_fim_real > 12 AND mes.dia_ini_real <= 15 THEN 3 
     ELSE CASE WHEN mes.mes_ini_real = 12 AND mes.mes_fim_real > 12 AND mes.dia_ini_real >  15 THEN 4 
     ELSE CASE WHEN mes.mes_ini_real < 12 AND mes.mes_fim_real = 12 AND mes.dia_fim_real >  15 THEN 5 
     ELSE CASE WHEN mes.mes_ini_real < 12 AND mes.mes_fim_real = 12 AND mes.dia_fim_real <= 15 THEN 6 
     ELSE 0 END END END END END                                    
   END AS mes_dez_real
FROM        security.projetos           prj 
 INNER JOIN security.area_ti            ati ON ati.id = prj.id_area_ti
 INNER JOIN security.tipo_projeto       tpr ON tpr.id = prj.id_tipo
 INNER JOIN security.status_projeto     spr ON spr.id = prj.id_status
 INNER JOIN security.profissionais_ti   res ON res.id = prj.id_responsavel
 INNER JOIN security.profissionais_ti   gpr ON gpr.id = prj.id_gerente
 INNER JOIN security.prioridade_projeto ppr ON ppr.id = prj.id_prioridade
 -- Prepara Dados para montagem da Barra Previsto / Real
 -- ----------------------------------------------------------------------------
 INNER JOIN (SELECT pro.id, 
                    -- Define DIA PREVISTO
                    EXTRACT(DAY FROM pro.data_inicio_previsto)         AS dia_ini_prev,
                    EXTRACT(DAY FROM pro.data_fim_previsto)            AS dia_fim_prev,
                    -- Define DIA INICIO REAL
                    CASE WHEN pro.data_inicio_real        ISNULL
                      THEN 0 
                      ELSE EXTRACT(DAY FROM pro.data_inicio_real)
                    END AS dia_ini_real,           
                    -- Define Dia FINAL REAL
                    CASE WHEN pro.data_fim_real           ISNULL
                      THEN CASE WHEN pro.data_inicio_real ISNULL 
                             THEN 0 
                             ELSE EXTRACT(DAY FROM CURRENT_DATE) 
                           END     
                      ELSE EXTRACT(DAY FROM pro.data_fim_real)
                    END AS dia_fim_real,  
                    -- ---------------------------------------------------------
                    -- Define MES INICIAL Previsto
                    CASE WHEN EXTRACT(YEAR FROM pro.data_inicio_previsto)        < EXTRACT(YEAR FROM CURRENT_DATE) 
                      THEN 0                                                       -- Mes Ano Anterior
                      ELSE CASE WHEN EXTRACT(YEAR FROM pro.data_inicio_previsto) > EXTRACT(YEAR FROM CURRENT_DATE)   
                             THEN 13                                               -- Mes Ano Posterior
                             ELSE EXTRACT(MONTH FROM pro.data_inicio_previsto)     -- Mes Ano Atual
                           END  
                    END AS mes_ini_prev,
                    -- Define MES FINAL Previsto
                    CASE WHEN EXTRACT(YEAR FROM pro.data_fim_previsto)        < EXTRACT(YEAR FROM CURRENT_DATE) 
                      THEN 0                                                    -- Mes Ano Anterior
                      ELSE CASE WHEN EXTRACT(YEAR FROM pro.data_fim_previsto) > EXTRACT(YEAR FROM CURRENT_DATE)   
                             THEN 13                                            -- Mes Ano Posterior
                             ELSE EXTRACT(MONTH FROM pro.data_fim_previsto)     -- Mes Ano Atual
                           END  
                    END AS mes_fim_prev,   
                    -- ---------------------------------------------------------
                  
                    -- Define MES INICIAL Real
                    CASE WHEN pro.data_inicio_real ISNULL                             -- Se Projeto não Iniciou 
                      THEN 13                                                         -- Mes Ano Posterior
                      ELSE CASE WHEN EXTRACT(YEAR FROM pro.data_inicio_real)        < EXTRACT(YEAR FROM CURRENT_DATE) -- Ja Iniciou
                             THEN 0                                                   -- Mes Ano Anterior
                             ELSE CASE WHEN EXTRACT(YEAR FROM pro.data_inicio_real) > EXTRACT(YEAR FROM CURRENT_DATE) -- Ja Iniciou
                                    THEN 13                                           -- Mes Ano Posterior
                                    ELSE EXTRACT(MONTH FROM pro.data_inicio_real)     -- Mes Ano Atual
                                  END
                           END
                    END AS mes_ini_real,
                    -- Define MES FINAL Real                    
                    CASE WHEN pro.data_fim_real           ISNULL                   -- Se Projeto não Finalizou 
                      THEN CASE WHEN pro.data_inicio_real ISNULL                   --    Nem Iniciou 
                             THEN 13                                               --        Mes Ano Posterior
                             ELSE EXTRACT(MONTH FROM CURRENT_DATE)                 --        Mes Ano Atual 
                           END                                                     -- Se Projeto Já Finalizou
                      ELSE CASE WHEN EXTRACT(YEAR FROM pro.data_fim_real)        < EXTRACT(YEAR FROM CURRENT_DATE) 
                             THEN 0                                                -- Mes Ano Anterior
                             ELSE CASE WHEN EXTRACT(YEAR FROM pro.data_fim_real) > EXTRACT(YEAR FROM CURRENT_DATE)   
                                    THEN 13                                        -- Mes Ano Posterior
                                    ELSE EXTRACT(MONTH FROM pro.data_fim_real)     -- Mes Ano Atual
                                  END  
                           END
                    END AS mes_fim_real  
               FROM security.projetos pro
            ) mes ON mes.id = prj.id
 WHERE prj.id_status NOT IN (1,6) -- Excluir Projetos (Aguardando Concepção - Cancelado)
   AND (EXTRACT(YEAR FROM prj.data_inicio_previsto)   = EXTRACT(YEAR FROM CURRENT_DATE)
    OR  EXTRACT(YEAR FROM prj.data_fim_previsto)      = EXTRACT(YEAR FROM CURRENT_DATE)
    OR  EXTRACT(YEAR FROM prj.data_fim_previsto_atual)= EXTRACT(YEAR FROM CURRENT_DATE)
    OR  EXTRACT(YEAR FROM prj.data_inicio_real)       = EXTRACT(YEAR FROM CURRENT_DATE)
    OR  EXTRACT(YEAR FROM prj.data_fim_real)          = EXTRACT(YEAR FROM CURRENT_DATE));

--------------------------------------------------------------------------------
-- VIEW....: security.vw_lista_paralisacoes
-- CLASSE..: VoListaParalisacoes.java
-- Objetivo: Exibir Uma lista de paralisações (Projeto / Manutenções / Atividades)
--------------------------------------------------------------------------------
DROP VIEW security.vw_lista_paralisacoes;

CREATE OR REPLACE VIEW security.vw_lista_paralisacoes AS
SELECT  
   -- Dados do Projeto
   'P' || TRIM(to_char(prj.id,'0000')) As id,
   'Projeto'               AS tipo,
   prj.codigo,
   prj.nome,
   prj.sigla,  
   ati.nome                 AS area_ti, 
   res.nome_referencia      AS responsavel,
   ppa.motivo               AS motivo_paralisacao,
   to_char(prj.data_inicio_real,'dd/MM/yyyy') AS data_inicio_execucao,
   to_char(ppa.data_paralisacao,'dd/MM/yyyy') AS data_ultima_paralisacao,
   (CURRENT_DATE - ppa.data_paralisacao) 
                            AS dias_parado,
   prj.dias_paralisado      AS dias_outras_paralisacoes,   
   (CURRENT_DATE - ppa.data_paralisacao) + prj.dias_paralisado 
                            AS total_dias_parado,
   prj.percentual_executado AS percentual_executado,
   prj.observacao_progresso AS observacao_progresso
FROM        security.projetos              prj 
 INNER JOIN security.area_ti               ati ON ati.id = prj.id_area_ti
 INNER JOIN security.profissionais_ti      res ON res.id = prj.id_responsavel
 INNER JOIN security.projetos_paralisacoes ppa ON ppa.id = prj.id_paralisacao
WHERE prj.id_status = 5 -- Projetos (Paralisados)

 UNION ALl
 
SELECT  
   -- Dados da Manutenção
   'M' || TRIM(to_char(msi.id,'0000')) As id,
   'Manutenção'             AS tipo,
   msi.codigo,
   msi.descricao            AS nome,
   mdl.sigla,   
   ati.nome                 AS area_ti,
   res.nome_referencia      AS responsavel,
   mpa.motivo               AS motivo_paralisacao,
   to_char(msi.data_inicio_real,'dd/MM/yyyy') AS data_inicio_execucao,
   to_char(mpa.data_paralisacao,'dd/MM/yyyy') AS data_ultima_paralisacao,
   (CURRENT_DATE - mpa.data_paralisacao) 
                            AS dias_parado,
   mps.dias_paralisado      AS dias_outras_paralisacoes,   
   (CURRENT_DATE - mpa.data_paralisacao) + mps.dias_paralisado 
                            AS total_dias_parado,
   msi.percentual_executado AS percentual_executado,
   msi.observacao_progresso AS observacao_progresso
FROM        security.manutencoes_sistema              msi 
 INNER JOIN security.modulos                          mdl ON mdl.id = msi.id_modulo
 INNER JOIN security.profissionais_ti                 res ON res.id = msi.id_responsavel
 INNER JOIN security.manutencoes_sistema_paralisacoes mpa ON mpa.id = msi.id_paralisacao
 LEFT  JOIN (SELECT par.id_manutencao, 
                    sum(par.dias_parado) AS dias_paralisado 
               FROM security.manutencoes_sistema_paralisacoes par
           GROUP BY par.id_manutencao
            )                                         mps ON msi.id = mps.id_manutencao,
 security.area_ti ati
WHERE msi.id_status = 3  -- Manutenções (Paralisados)
  AND ati.id        = 2; -- Area de Desenvolvimento

-- -----------------------------------------------------------------------------
-- VIEW....: security.vw_reunioes
-- CLASSE..: VoReuniao.java
-- Objetivo: Usar na formação da Ficha de Reunião
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_reunioes AS
SELECT 
  reu.id, 
  reu.codigo, 
  reu.assunto, 
  reu.data_hora_prevista,
  reu.id_atividade, 
  reu.id_manutencao, 
  reu.id_projeto, 
  reu.id_reuniao_pai,
  reu.id_secretario,
  reu.id_status,
  reu.id_tipo,
  reu.data_hora_real,
  reu.duracao,
  reu.local_reuniao,
  reu.pauta,
  reu.controlar_convidados,
  reu.controlar_presentes,
  reu.observacao,
  sta.sigla     AS sigla_status,
  sta.nome      AS nome_status,
  sec.nome_referencia AS nome_referencia_secretario,
  sec.nome_completo   AS nome_completo_secretario, 
  tpr.sigla     AS sigla_tipo,
  tpr.nome      AS nome_tipo, 
  tpr.descricao AS descricao_tipo,
  pro.codigo    AS codigo_projeto, 
  pro.descricao AS descricao_projeto,
  pro.sigla     AS nome_projeto, 
  pro.nome      AS sigla_projeto,
  man.codigo    AS codigo_manut, 
  man.descricao AS descricao_manut,
  atv.codigo    AS codigo_atv, 
  atv.descricao AS descricao_atv,
  rpa.codigo    AS codigo_reu_pai
FROM   security.reunioes         reu
  JOIN security.status_reuniao   sta ON sta.id = reu.id_status
  JOIN security.profissionais_ti sec ON sec.id = reu.id_secretario
  JOIN security.tipo_reuniao     tpr ON tpr.id = reu.id_tipo
  LEFT JOIN security.projetos    pro ON pro.id = reu.id_projeto
  LEFT JOIN security.manutencoes_sistema man ON man.id = reu.id_manutencao
  LEFT JOIN security.atividades  atv ON atv.id = reu.id_atividade
  LEFT JOIN security.reunioes    rpa ON rpa.id = reu.id_reuniao_pai;

-- -----------------------------------------------------------------------------
-- VIEW....: security.vw_reunioes_historicos
-- CLASSE..: VoReuniaoHistoricos.java
-- Objetivo: Usar na formação do histórico da  Reunião
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_reunioes_historicos AS
SELECT 
  reh.id_reuniao, 
  reh.id, 
  reh.matricula       AS usuario_matricula,
  usr.nome_referencia AS usuario_nome, 
  reh.data_hora, 
  reh.observacao,
  thr.descricao       AS tipo_historico
FROM   security.reunioes_historicos     reh
  JOIN security.tipo_historico_reunioes thr ON thr.id = reh.id_tipo_historico
  JOIN security.users                   usr ON usr.matricula = reh.matricula;

-- -----------------------------------------------------------------------------
-- VIEW....: security.vw_reunioes_participantes
-- CLASSE..: VoReuniaoParticipantes.java
-- Objetivo: Usar na formação dos Participantes da  Reunião
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_reunioes_participantes AS
SELECT 
  rxp.id, 
  rxp.id_reuniao, 
  rxp.matricula, 
  rxp.nome, 
  rxp.presente,
  rxp.convidado
FROM security.reunioes_participantes rxp
ORDER BY rxp.id_reuniao, rxp.id;

-- -----------------------------------------------------------------------------
-- VIEW....: security.vw_reunioes_x_profissionais
-- CLASSE..: VoReuniaoXProfissionais.java
-- Objetivo: Usar na formação dos Profissionais da  Reunião
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_reunioes_x_profissionais AS
SELECT 
  rxp.id, 
  rxp.id_reuniao, 
  rxp.id_profissional, 
  prt.nome_completo,
  prt.nome_referencia, 
  prt.email, 
  prt.fone_celular, 
  prt.fone_comercial,
  art.nome AS area, 
  rxp.observacao
FROM   security.reunioes_x_profissionais rxp
  JOIN security.profissionais_ti         prt ON prt.id = rxp.id_profissional
  JOIN security.area_ti                  art ON art.id = prt.id_area
ORDER BY rxp.id_reuniao, rxp.id_profissional;

-- -----------------------------------------------------------------------------
-- VIEW....: security.vw_reunioes_relatos
-- CLASSE..: VoReuniaoRelatos.java
-- Objetivo: Usar na formação dos Relatos da  Reunião
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_reunioes_relatos AS
SELECT 
  rel.id, 
  rel.id_reuniao, 
  rel.relato
FROM security.reunioes_relatos rel
ORDER BY rel.id_reuniao, rel.id;

-- -----------------------------------------------------------------------------
-- VIEW....: security.vw_reunioes_acoes_pos_reuniao
-- CLASSE..: VoReuniaoAcoes.java
-- Objetivo: Usar na formação das Ações da  Reunião
-- -----------------------------------------------------------------------------
DROP VIEW  security.vw_reunioes_acoes_pos_reuniao;

CREATE OR REPLACE VIEW security.vw_reunioes_acoes_pos_reuniao AS
SELECT 
  aco.id, 
  aco.id_reuniao, 
  aco.acao, 
  aco.data_retorno, 
  aco.id_responsavel,
  prt.nome_referencia AS responsavel
FROM   security.reunioes_acoes_pos_reuniao aco
  JOIN security.profissionais_ti           prt ON prt.id = aco.id_responsavel
ORDER BY aco.id_reuniao, aco.id;

-- -----------------------------------------------------------------------------
-- VIEW....: security.vw_lista_reunioes
-- CLASSE..: VoListaReuniao.java
-- Objetivo: Usar na formação da sugestão pata buscar reuniões
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_lista_reunioes AS
SELECT 
  reu.id, 
  reu.codigo, 
  reu.assunto
FROM security.reunioes reu;
-- -----------------------------------------------------------------------------
-- VIEW....: security.vw_modulos_situacao
-- CLASSE..: VoModuloSituacao.java
-- Objetivo: Usar no relatório da situação dos módulos
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_modulos_situacao 
AS
SELECT 
  mro.id_modulo, 
  mro.id, mro.nome AS nome_rotina,
  mro.observacao   AS observacao_rotina, 
  mro.descricao    AS descricao_rotina,
  fde.id           AS id_fase_desenvolvimento, 
  fde.nome         AS nome_fase_desenvolvimento,
  mod.codigo_modulo, 
  mod.sigla        AS sigla_modulo, 
  mod.nome         AS nome_modulo,
  atu.id           AS id_area_atuacao, 
  atu.nome         AS nome_area_atuacao,
  sta.id           AS id_status_acesso, 
  sta.nome         AS nome_status_acesso
FROM        security.modulos_rotinas      mro
 INNER JOIN security.modulos              mod ON mod.id = mro.id_modulo
 INNER JOIN security.fase_desenvolvimento fde ON fde.id = mro.id_fase
 INNER JOIN security.area_atuacao         atu ON atu.id = mod.id_area
 INNER JOIN security.status_acesso        sta ON sta.id = mod.id_status
ORDER BY mod.codigo_modulo, mro.nome;

-- -----------------------------------------------------------------------------
-- VIEW....: security.vw_lista_atividades_avulsas 
-- CLASSE..: VoListaAtividadesAvulsas.java
-- Objetivo: Usar no relatório da Atividade Avulsa
-- -----------------------------------------------------------------------------
DROP VIEW security.vw_lista_atividades_avulsas;

CREATE OR REPLACE VIEW security.vw_lista_atividades_avulsas AS
SELECT
  atv.id, 
  atv.codigo, 
  atv.descricao, 
  atv.data_inicio_previsto,
  atv.data_fim_previsto, 
  atv.data_inicio_real, 
  atv.data_fim_real,
  atv.quantidade, 
  atv.quantidade_executada, 
  atv.horas_prevista,
  atv.horas_real, 
  atv.id_status, 
  sta.nome  AS status_nome,
  sta.sigla AS status_sigla, 
  art.id    AS id_area_ti, 
  art.nome  AS area_ti_nome,
  art.sigla AS area_ti_sigla,
  prf.id_profissional,
  pro.nome_referencia AS profissional_nome_ref, 
  atv.id_criador,
  use.nome_referencia AS criador_nome, 
  atv.id_prioridade,
  pri.nome            AS prioridade_nome, 
  pri.sigla           AS prioridade_sigla,
  COALESCE(qpr.qtd_prof,0) AS qtd_profissionais
FROM   security.atividades                    atv
  INNER JOIN security.status_atividade              sta ON sta.id = atv.id_status
  INNER JOIN security.area_ti                       art ON art.id = atv.id_area_ti
  INNER JOIN security.atividades_x_profissionais_ti prf ON prf.id_atividade = atv.id
  INNER JOIN security.profissionais_ti              pro ON pro.id = prf.id_profissional
  INNER JOIN security.users                         use ON use.matricula = atv.id_criador
  INNER JOIN security.prioridade_atividade          pri ON pri.id = atv.id_prioridade
  LEFT  JOIN (SELECT axp.id_atividade, 
                     count(axp.id) AS qtd_prof
                FROM security.atividades_x_profissionais_ti axp
            GROUP BY axp.id_atividade
             ) qpr ON atv.id = qpr.id_atividade
WHERE atv.id_tipo_atividade = 3; -- 3 = Atividade avulsa


--------------------------------------------------------------------------------
-- VIEW....: security.vw_atividades_historicos
-- CLASSE..: VoAtividadesHistoricos.java
-- Objetivo: Usar em listagens de Historico da Atividade
--------------------------------------------------------------------------------
DROP VIEW security.vw_atividades_historicos;

CREATE OR REPLACE VIEW security.vw_atividades_historicos AS
SELECT 
  ath.id_atividade, 
  ath.id, 
  ath.matricula       AS usuario_matricula,
  usr.nome_referencia AS usuario_nome, 
  ath.data_hora,
  tha.descricao       AS tipo_historico, 
  ath.observacao
FROM security.atividades_historicos             ath
  INNER JOIN security.tipo_historico_atividades tha ON tha.id        = ath.id_tipo_historico
  INNER JOIN security.users                     usr ON usr.matricula = ath.matricula;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_atividades_x_profissionais
-- CLASSE..: VoAtividadesXProfissionais.java
-- Objetivo: Usar em listagens de Atividade X Profissionais 
--------------------------------------------------------------------------------
DROP VIEW security.vw_atividades_x_profissionais;

CREATE OR REPLACE VIEW security.vw_atividades_x_profissionais AS
SELECT  
  -- Dados Atividade X profissional
  axp.id,
  atv.id_projeto,
  atv.id_manutencao_sistema AS id_manutencao,
  axp.id_profissional       AS id_profissional, 
  axp.id_atividade          AS id_atividade,
  pxp.id                    AS id_projeto_x_profissionais,
  mxp.id                    AS id_manutencao_x_profissionais,
  axp.observacao            AS obs_atv_x_pro,
  --  Dados do Profissional
  pro.nome_completo         AS profissional_nome,
  pro.nome_referencia       AS profissional_nome_ref,
  pro.email                 AS profissional_email,
  pro.fone_celular          AS profissional_fone_celular,
  pro.fone_comercial        AS profissional_fone_comercial,
  art.nome                  AS profissional_area_atuacao,
  -- Dados da Atividade
  atv.codigo                AS atividade_codigo,  
  atv.descricao             AS atividade_descricao, 
  atv.id_status             AS atividade_status_id,
  sta.sigla                 AS atividade_status_sigla,
  sta.nome                  AS atividade_status_nome,
  atv.data_inicio_previsto  AS atividade_ini_prev,  
  atv.data_fim_previsto     AS atividade_fim_prev,
  atv.data_inicio_real      AS atividade_ini_real,
  atv.data_fim_real         AS atividade_fim_real,
  atv.quantidade            AS atividade_qtd_prev,
  atv.quantidade_executada  AS atividade_qtd_real,
  atv.horas_prevista        AS atividade_hrs_prev,
  atv.horas_real            AS atividade_hrs_real,
  atv.id_tipo_atividade     AS atividade_tipo_id,
  tpa.sigla                 AS atividade_tipo_sigla,
  tpa.nome                  AS atividade_tipo_nome
FROM         security.atividades_x_profissionais_ti axp
  INNER JOIN security.profissionais_ti              pro ON pro.id = axp.id_profissional
  INNER JOIN security.area_ti                       art ON art.id = pro.id_area 
  INNER JOIN security.atividades                    atv ON atv.id = axp.id_atividade
  INNER JOIN security.status_atividade              sta ON sta.id = atv.id_status
  INNER JOIN security.tipo_atividade                tpa ON tpa.id = atv.id_tipo_atividade
  LEFT  JOIN security.projetos_x_profissionais_ti   pxp ON pxp.id_projeto = atv.id_projeto
                                                       AND pxp.id_profissional = axp.id_profissional
  LEFT  JOIN security.manutencoes_sistema_x_profissionais_ti mxp ON mxp.id_manutencao = atv.id_manutencao_sistema
                                                                AND mxp.id_profissional = axp.id_profissional;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--------------------------------------------------------------------------------
-- VIEW....: security.vw_projetos_reunioes
-- CLASSE..: VoProjetoReunioes.java
-- Objetivo: Usar na formação da Ficha do Projeto
--------------------------------------------------------------------------------
CREATE VIEW security.vw_projetos_reunioes AS 
SELECT 
  reu.id, 
  reu.id_projeto, 
  tre.sigla As tipo,
  sre.sigla AS status,
  reu.codigo,
  reu.local_reuniao, 
  reu.assunto, 
  reu.data_hora_prevista, 
  reu.data_hora_real, 
  reu.duracao
FROM security.reunioes reu
  INNER JOIN security.tipo_reuniao   tre ON tre.id = reu.id_tipo
  INNER JOIN security.status_reuniao sre ON sre.id = reu.id_status
WHERE reu.id_projeto  NOTNULL;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_modulos_x_versoes
-- CLASSE..: VoModuloXVersao.java
-- Objetivo: Ficha do Módulo (Relação de Versões do Módulo)
--------------------------------------------------------------------------------
DROP VIEW security.vw_modulos_x_versoes ;

CREATE OR REPLACE VIEW security.vw_modulos_x_versoes AS
SELECT 
  vmo.id, 
  vmo.id_modulo, 
  vmo.codigo_versao       AS versao_modulo,
  vsi.codigo_versao       AS versao_sistema, 
  vmo.id_status           AS id_status,
  svm.nome                AS status,
  vmo.data_inclusao, 
  vmo.data_desenvolvimento, 
  vmo.data_liberacao, 
  res.nome_referencia     AS responsavel,
  vmo.observacoes_usuario AS observacao,
  vmo.observacoes_tecnicas
FROM security.versoes_modulos vmo 
  INNER JOIN security.status_versao_modulo svm ON svm.id = vmo.id_status
  LEFT  JOIN security.profissionais_ti     res ON res.id = vmo.id_responsavel 
  LEFT  JOIN security.versoes_sistema      vsi ON vsi.id = vmo.id_versao_sistema
ORDER BY vmo.id;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_modulos_x_projetos
-- CLASSE..: VoModuloXProjeto.java
-- Objetivo: Ficha da Módulo
--------------------------------------------------------------------------------
DROP VIEW security.vw_modulos_x_projetos;

CREATE OR REPLACE VIEW security.vw_modulos_x_projetos AS
SELECT 
  prj.id, 
  prj.id_modulo, 
  prj.codigo, 
  prj.nome,
  prj.sigla,
  prj.interessado,
  pti.nome_referencia AS responsavel,
  prj.data_inicio_real,
  prj.data_fim_real
FROM security.projetos prj 
  INNER JOIN security.profissionais_ti pti ON pti.id = prj.id_responsavel
WHERE NOT id_modulo ISNULL;


--------------------------------------------------------------------------------
-- VIEW....: security.vw_lista_versoes_sistema
-- CLASSE..: VoListaVersoesSistema.java
-- Objetivo: Para Uso em Combo
--------------------------------------------------------------------------------
DROP VIEW security.vw_lista_versoes_sistema;

CREATE OR REPLACE VIEW security.vw_lista_versoes_sistema AS
SELECT vsi.id,
       vsi.codigo_versao
  FROM security.versoes_sistema  vsi 
  ORDER BY vsi.id desc;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_versoes_sistema
-- CLASSE..: VoVersaoSistema.java
-- Objetivo: Ficha da Versão do SIGDER
--------------------------------------------------------------------------------
DROP VIEW security.vw_versoes_sistema;

CREATE OR REPLACE VIEW security.vw_versoes_sistema AS
SELECT vsi.id,
       vsi.codigo_versao,
       vsi.data_liberacao,
       vsi.data_publicacao,
       vsi.observacoes_tecnicas,
       vsi.observacoes_usuario,
       pti.nome_referencia AS publicado_por,
       vsi.versao_fechada
  FROM security.versoes_sistema  vsi LEFT JOIN
       security.profissionais_ti pti ON pti.id = vsi.id_publicado_por;
       
--------------------------------------------------------------------------------
-- VIEW....: security.vw_versoes_modulo
-- CLASSE..: VoVersaoModulo.java
-- Objetivo: Ficha da Versão de Um Módulo do SIGDER
--------------------------------------------------------------------------------
DROP VIEW security.vw_versoes_modulo;

CREATE OR REPLACE VIEW security.vw_versoes_modulo AS
SELECT vmo.id,
       vmo.id_versao_sistema,
       vmo.id_modulo,
       vmo.id_responsavel,
       vsi.codigo_versao   AS versao_sistema,
       mod.codigo_modulo   AS modulo_codigo,
       mod.descricao       AS modulo_descricao,
       mod.sigla           AS modulo_sigla,
       mod.id_status       AS modulo_id_status,
       vmo.codigo_versao   AS versao_modulo,
       svm.nome            As status,
       pti.nome_referencia AS responsavel,
       vmo.data_inclusao,
       vmo.data_desenvolvimento,
       vmo.data_liberacao,
       vmo.observacoes_tecnicas,
       vmo.observacoes_usuario
  FROM security.versoes_modulos           vmo 
 INNER JOIN security.modulos              mod ON mod.id = vmo.id_modulo
 INNER JOIN security.status_versao_modulo svm ON svm.id = vmo.id_status
  LEFT JOIN security.profissionais_ti     pti ON pti.id = vmo.id_responsavel
  LEFT JOIN security.versoes_sistema      vsi ON vsi.id = vmo.id_versao_sistema
 ORDER BY vmo.id_versao_sistema, mod.codigo_modulo; 
 

--------------------------------------------------------------------------------
-- VIEW....: security.vw_versoes_modulos_x_manutencoes
-- CLASSE..: VoVersaoModuloXManutencao.java
-- Objetivo: Ficha da Versão do Módulo (Lista de Manutenções)
--------------------------------------------------------------------------------
DROP VIEW security.vw_versoes_modulos_x_manutencoes;

CREATE OR REPLACE VIEW security.vw_versoes_modulos_x_manutencoes AS
SELECT 
  msi.id, 
  msi.id_modulo, 
  msi.id_modulo_versao,
  msi.id_status AS id_status_manutencao,
  msi.codigo,
  msi.descricao,
  msi.solicitado_por,
  sms.nome AS status
FROM security.manutencoes_sistema       msi INNER JOIN
     security.status_manutencao_sistema sms ON sms.id = msi.id_status
WHERE (msi.id_status <> 1 -- 1 - A Iniciar
  AND  msi.id_status <> 4 -- 4 - Cancelada
  AND  msi.id_modulo_versao ISNULL) -- Manutenções ainda não associadas a nenhuma versão
   OR (NOT msi.id_modulo_versao ISNULL);

--------------------------------------------------------------------------------
-- VIEW....: security.vw_versoes_modulos_x_projetos
-- CLASSE..: VoVersaoModuloXProjeto.java
-- Objetivo: Ficha da Versão do Módulo (Lista de Projetos)
--------------------------------------------------------------------------------
DROP VIEW security.vw_versoes_modulos_x_projetos;

CREATE OR REPLACE VIEW security.vw_versoes_modulos_x_projetos AS
SELECT 
  vmp.id,
  vmp.id_projeto,
  prj.id_modulo, 
  vmp.id_versao_modulo,
  prj.id_status, 
  prj.codigo, 
  prj.nome,
  prj.sigla, 
  spr.nome AS status,
  vmp.observacoes
FROM security.versoes_modulos_x_projetos vmp 
  INNER JOIN security.projetos           prj ON prj.id = vmp.id_projeto
  INNER JOIN security.status_projeto     spr ON spr.id = prj.id_status;



--------------------------------------------------------------------------------
-- VIEW....: security.vw_modulos
-- CLASSE..: VoModulo.java
-- Objetivo: Usar p/ gerar Ficha de um Módulo
--------------------------------------------------------------------------------
DROP VIEW security.vw_modulos;

CREATE OR REPLACE VIEW security.vw_modulos AS
SELECT
  mod.id,
  mod.codigo_modulo,
  mod.sigla,
  mod.nome,
  mod.descricao,
  mod.id_area         AS id_area_atuacao,
  mod.id_fase         AS id_fase_desenvolvimento,
  atu.nome            AS area_atuacao,
  fde.nome            AS fase_desenvolvimento,
  pro.nome_referencia AS responsavel,
  sta.id              AS id_status,
  sta.nome            AS status,
  mod.data_inicio,
  mod.data_fim,
  mod.ordem_menu,
  mod.id_modulo_pai,
  mpa.sigla     AS modulo_pai,
  -- Dados da Versão do Módulo
  uvp.versao_ultima_publicada,
  vpu.data_liberacao  AS versao_data_liberacao,
  vpu.data_publicacao AS versao_data_publicacao,
  res.nome_referencia AS versao_responsavel,
  vpu.observacoes     AS versao_observacoes,
  vpu.versao_sistema  AS versao_sigder,  
  uvg.versao_ultima_gerada
FROM         security.modulos              mod
  INNER JOIN security.area_atuacao         atu ON atu.id = mod.id_area
  INNER JOIN security.fase_desenvolvimento fde ON fde.id = mod.id_fase
  LEFT  JOIN security.profissionais_ti     pro ON pro.id = mod.id_responsavel
  INNER JOIN security.status_acesso        sta ON sta.id = mod.id_status
  LEFT  JOIN security.modulos              mpa ON mpa.id = mod.id_modulo_pai
  -- Verifica ultima Versão Publicada
  LEFT  JOIN (SELECT ver.id_modulo, 
                     max(ver.codigo_versao) AS versao_ultima_publicada
                FROM security.versoes_modulos ver 
               WHERE ver.id_status=4 -- 4 - Publicada
            GROUP BY ver.id_modulo, id_status
             ) uvp ON mod.id = uvp.id_modulo
  -- Verifica ultima Versao Gerada (pode ser diferente ou não da Pulicada)           
  LEFT  JOIN (SELECT ver.id_modulo, 
                     max(ver.codigo_versao) AS versao_ultima_gerada
                FROM security.versoes_modulos ver 
               WHERE ver.id_status>=3 -- (3 e 4 - Aguardando publicação ou publicada)
            GROUP BY ver.id_modulo
             ) uvg ON mod.id = uvg.id_modulo
  -- Pega dados da Ultima Versão Publicada           
  LEFT  JOIN (SELECT vmo.id_modulo, 
                     vmo.codigo_versao       AS versao_modulo, 
                     vmo.observacoes_usuario AS observacoes,
                     vmo.data_liberacao,                     
                     vsi.data_publicacao,
                     vmo.id_responsavel,
                     vsi.codigo_versao AS versao_sistema
                FROM security.versoes_modulos vmo 
          INNER JOIN security.versoes_sistema vsi ON vsi.id = vmo.id_versao_sistema
             ) vpu ON mod.id = vpu.id_modulo AND vpu.versao_modulo = uvp.versao_ultima_publicada
  -- Pega dados do responsavel pela ultima versão publicada
  LEFT  JOIN security.profissionais_ti res  ON res.id =vpu.id_responsavel;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_modulos_rotinas
-- CLASSE..: VoModuloRotinas.java
-- Objetivo: Usar p/ gerar Ficha de um Módulo
--------------------------------------------------------------------------------
DROP VIEW security.vw_modulos_rotinas;

CREATE OR REPLACE VIEW security.vw_modulos_rotinas AS
SELECT 
  mro.id_modulo,
  mro.id,
  fde.id              AS id_fase_desenvolvimento, 
  fde.nome            AS fase_desenvolvimento, 
  pro.nome_referencia AS responsavel,
  mro.nome            AS nome_rotina,
  mro.descricao       AS descricao_rotina
FROM       security.modulos_rotinas      mro 
INNER JOIN security.fase_desenvolvimento fde ON fde.id = mro.id_fase
INNER JOIN security.profissionais_ti     pro ON pro.id = mro.id_responsavel;

--------------------------------------------------------------------------------
-- VIEW....: security.vw_dados_modulos
-- CLASSE..: VoDadosModulo.java
-- Objetivo: Usar p/ gerar consultas e relatórios de módulos
--------------------------------------------------------------------------------
DROP VIEW security.vw_dados_modulos;

CREATE OR REPLACE VIEW security.vw_dados_modulos AS
SELECT   
  mod.id,
  -- Dados do Modulo
  mod.codigo_modulo, 
  mod.nome      AS nome_modulo, 
  mod.sigla     AS sigla_modulo,
  mod.descricao AS descricao_modulo,
  mod.ordem_menu, 
  -- Dados da Area de atuação
  mod.id_area   AS id_area_atuacao,
  atu.sigla     AS sigla_area_atuacao, 
  atu.nome      AS nome_area_atuacao,
  atu.descricao AS descricao_area_atuacao,
  atu.cor       AS cor_area_atuacao,
  -- Dados da Fase de Desenvolvimento
  mod.id_fase   AS id_fase_desenvolvimento,
  fad.sigla     AS sigla_fase_desenvolvimento, 
  fad.nome      AS nome_fase_desenvolvimento,
  fad.descricao AS descricao_fase_desenvolvimento,
  fad.cor       AS cor_fase_desenvolvimento,
  -- Dados do Status Desenvolvimento 
  mod.id_status AS id_status_acesso,
  sta.sigla     AS sigla_status_acesso,
  sta.nome      AS nome_status_acesso,
  sta.descricao AS descricao_status_acesso,
  sta.cor       AS cor_status_acesso,
  -- Dados do Resposanvel pelo Modulo
  pro.nome_completo  As nome_responsavel,
  -- Dados do Módulo Pai  
  mod.id_modulo_pai,
  mop.nome AS nome_modulo_pai
FROM       security.modulos              mod 
INNER JOIN security.area_atuacao         atu ON atu.id = mod.id_area
INNER JOIN security.status_acesso        sta ON sta.id = mod.id_status
INNER JOIN security.fase_desenvolvimento fad ON fad.id = mod.id_fase
INNER JOIN security.profissionais_ti     pro ON pro.id = mod.id_responsavel
LEFT  JOIN security.modulos              mop ON mop.id = mod.id_modulo_pai;


--------------------------------------------------------------------------------
-- VIEW....: security.vw_dados_rotinas_modulos
-- CLASSE..: VoDadosRotinaModulo.java
-- Objetivo: Usar p/ gerar consultas e relatórios das rotinas dos módulos
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW security.vw_dados_rotinas_modulos AS
SELECT 
  rot.id,
  -- Dados do Módulos
  rot.id_modulo       AS modulo_id,             
  mod.sigla           AS modulo_sigla, 
  mod.nome            AS modulo_nome, 
  -- Dados da Rotina
  rot.nome            AS rotina_nome, 
  rot.descricao       AS rotina_descricao,
  rot.id_responsavel  AS rotina_responsavel_id,
  prr.nome_referencia AS rotina_responsavel,
  -- Fase de Desenvolvimento da Rotina
  rot.id_fase         AS rotina_fase_id, 
  fde.sigla           AS rotina_fase_sigla, 
  fde.nome            AS rotina_fase_nome,
  -- Agente Beneficiado pela rotina
  rot.id_agente_beneficiado  AS agente_benef_id, 
  abf.sigla                  AS agente_benef_sigla, 
  abf.nome                   AS agente_benef_nome, 
  -- Agente responsável pela rotina
  rot.id_agente_responsavel  AS agente_resp_id, 
  arp.sigla                  AS agente_resp_sigla, 
  arp.nome                   AS agente_resp_nome, 
  rot.obs_agente_responsavel AS agente_resp_obs
FROM       security.modulos_rotinas      AS rot
INNER JOIN security.modulos              AS mod ON mod.id = rot.id_modulo
INNER JOIN security.profissionais_ti     AS prr ON prr.id = rot.id_responsavel -- Responsável pela Rotina 
INNER JOIN security.fase_desenvolvimento AS fde ON fde.id = rot.id_fase
INNER JOIN security.agente_sistema       AS abf ON abf.id = rot.id_agente_beneficiado 
INNER JOIN security.agente_sistema       AS arp ON arp.id = rot.id_agente_responsavel
WHERE mod.id_status=1;

CREATE OR REPLACE VIEW security.vw_users_x_roles AS 
SELECT 
  uxr.id,
  uxr.id_user   AS matricula,
  rol.role_name AS nome_regra,
  rol.descricao AS descricao_regra,
  sta.id        AS id_status,
  sta.nome      AS status_regra,
  rol.id_role,
  sta.cor AS cor_status
FROM         security.users_x_roles   uxr
  INNER JOIN security.roles           rol ON rol.id_role = uxr.id_role
  INNER JOIN security.status_acesso   sta ON sta.id = uxr.id_status;

-- /////////////////////////////////////////////////////////////////////////////
--
-- ALTERAÇÕES FEITA NO SCRIPT APÓS  A CRIAÇÃO DO BANCO DE PRODUÇÃO
--
-- /////////////////////////////////////////////////////////////////////////////