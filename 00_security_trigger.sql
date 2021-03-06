-- =======================================
-- Script do pacote DER_CE_CORPORATIVO
-- ---------------------------------------
-- Host      : 172.25.144.14
-- Database  : der
-- Version   : PostgreSQL 8.3.4
-- =======================================

-- =============================================================================
-- C R I A Ç Ã O   D A S   TRIGGER
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger BEFORE da tabela security.modulos
-- =============================================================================
-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Gera código do Modulo
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_gera_codigo_modulos(var_id_area_atuacao INTEGER)
RETURNS VARCHAR(3) AS
$body$
DECLARE
  cod_area_atuacao text;
  seq_modulo       text;
  codigo_gerado    text;
BEGIN
  -- Pega ultimo código de modulo gerado para area de atuação e adiciona 1
  SELECT   to_char(to_number(max(SUBSTRING(mod.codigo_modulo,2,2)),'00')+1,'00')
  INTO     seq_modulo
  FROM     security.modulos mod
  GROUP BY mod.id_area
  HAVING   mod.id_area = var_id_area_atuacao;
  -- Se não existir modulo gerado anteriormente
  IF NOT FOUND THEN
    seq_modulo = '01';
  END IF;
  -- Pega Código da Planilha Atual  
  cod_area_atuacao = to_char(var_id_area_atuacao,'0');
  -- gera novo código
  codigo_gerado = TRIM(cod_area_atuacao) || TRIM(seq_modulo);
  RETURN codigo_gerado;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- =============================================================================
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "modulos"
-- =============================================================================
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_modulos()
RETURNS SETOF trigger AS
$body$
BEGIN
  IF TG_OP = 'INSERT' THEN
     NEW.codigo_modulo  = security.fn_scy_gera_codigo_modulos(NEW.id_area);
     RETURN NEW;

  ELSEIF TG_OP = 'UPDATE' THEN
     -- nada definido por enquanto
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN
     -- nada definido por enquanto
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_modulos
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_modulos
BEFORE INSERT OR UPDATE OR DELETE ON security.modulos
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_modulos();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela security.modulos
-- =============================================================================
-- =============================================================================
-- INICIO: Trigger BEFORE da tabela security.elementos_modulo
-- =============================================================================

-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Gera código do elemento modulo
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_gera_codigo_elementos_modulo(var_id_modulo INTEGER, var_id_tipo_elemento INTEGER)
RETURNS VARCHAR(7) AS
$body$
DECLARE
  cod_modulo          text;
  cod_tipo_elemento   text;
  seq_elemento_modulo text;
  codigo_gerado       text;
BEGIN
  -- Define letra do tipo de elemento
  IF var_id_tipo_elemento     = 1 THEN -- Menu
     cod_tipo_elemento = 'M';  
  ELSEIF var_id_tipo_elemento = 2 THEN -- Formulario
     cod_tipo_elemento = 'F'; 
  ELSEIF var_id_tipo_elemento = 3 THEN -- Link
     cod_tipo_elemento = 'L'; 
  ELSEIF var_id_tipo_elemento = 4 THEN -- Botão
     cod_tipo_elemento = 'B'; 
  ELSEIF var_id_tipo_elemento = 5 THEN -- Relatorio
     cod_tipo_elemento = 'R';
  ELSEIF var_id_tipo_elemento = 6 THEN -- View
     cod_tipo_elemento = 'V';
  ELSEIF var_id_tipo_elemento = 7 THEN -- Trigger
     cod_tipo_elemento = 'T';
  ELSEIF var_id_tipo_elemento = 8 THEN -- Classe Java
     cod_tipo_elemento = 'C';
  ELSEIF var_id_tipo_elemento = 9 THEN -- Arquivo Externo
     cod_tipo_elemento = 'A';
  ELSE 
     cod_tipo_elemento = 'X'; -- Outro Não definido
  END IF;
  -- Pega ultimo código de elemento de acesso gerado para o modulo e adiciona 1
  SELECT   to_char(to_number(max(SUBSTRING(eac.codigo_acesso,5,3)),'000')+1,'000')
  INTO     seq_elemento_modulo
  FROM     security.elementos_modulo eac
  GROUP BY eac.id_modulo, SUBSTRING(eac.codigo_acesso,1,1)
  HAVING   eac.id_modulo = var_id_modulo
     AND   SUBSTRING(eac.codigo_acesso,1,1) = cod_tipo_elemento;
  -- Se não existir modulo gerado anteriormente
  IF NOT FOUND THEN
    seq_elemento_modulo = '001';
  END IF; 
  -- Pega Código do Modulo Atual
  SELECT mod.codigo_modulo
  INTO   cod_modulo
  FROM   security.modulos mod
  WHERE  mod.id = var_id_modulo;
  -- gera novo código
  codigo_gerado = TRIM(cod_tipo_elemento) || TRIM(cod_modulo) || TRIM(seq_elemento_modulo);
  RETURN codigo_gerado;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Calcula Id do elemento Pai
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_calcula_elemento_pai(var_id_modulo INTEGER, var_id_tipo_elemento INTEGER, var_ordem_filho text)
RETURNS INTEGER AS
$body$
DECLARE
  var_ordem_pai       text;
  var_id_elemento_pai INTEGER;
BEGIN
  -- Trata Elementos de Navegação (MENUS / FORMS)
  var_id_elemento_pai = NULL;
  IF (var_id_tipo_elemento = 1) OR  (var_id_tipo_elemento) = 2 THEN 
     IF (var_ordem_filho ISNULL) OR (length(var_ordem_filho) = 0) THEN 
        RAISE EXCEPTION 'Campo [Ordem] Não pode ser vazio!';
     ELSEIF (length(var_ordem_filho) % 3) > 0 THEN
        RAISE EXCEPTION 'Campo [Ordem] deve conter Qtd. digitos multiplos de 3!' ;
     ELSE     
        var_ordem_pai =  SUBSTRING(var_ordem_filho,1,length(var_ordem_filho)-3);

        SELECT  ele.id
          INTO var_id_elemento_pai
          FROM security.elementos_modulo ele
         WHERE ele.id_modulo = var_id_modulo
           AND ele.ordem_menu = var_ordem_pai;
	    
        IF NOT FOUND THEN
          var_id_elemento_pai = NULL;
        END IF;
     END IF;        
  END IF;
  RETURN var_id_elemento_pai;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "elementos_modulo"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_elementos_modulo()
RETURNS SETOF trigger AS
$body$
BEGIN
  IF TG_OP = 'INSERT' THEN
     NEW.codigo_acesso  = security.fn_scy_gera_codigo_elementos_modulo(NEW.id_modulo, NEW.id_tipo_elemento);
     NEW.id_elemento_pai = security.fn_scy_calcula_elemento_pai(NEW.id_modulo, NEW.id_tipo_elemento, NEW.ordem_menu);
     RETURN NEW;

  ELSEIF TG_OP = 'UPDATE' THEN
     NEW.id_elemento_pai = security.fn_scy_calcula_elemento_pai(NEW.id_modulo, NEW.id_tipo_elemento, NEW.ordem_menu);
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN
     -- nada definido por enquanto
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_elementos_modulo
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_elementos_modulo
BEFORE INSERT OR UPDATE OR DELETE ON security.elementos_modulo
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_elementos_modulo();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela security.elementos_modulo
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger AFTER da tabela security.roles_x_elementos_modulo
-- =============================================================================
-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Atualiza tabela: 'roles_x_modulos'
-- -----------------------------------------------------------------------------
CREATE OR REPLACE
FUNCTION security.fn_scy_atualiza_roles_x_modulos(var_id_role INTEGER, var_id_elemento INTEGER, var_acao text)
RETURNS void AS
$body$
DECLARE
  var_id_modulo INTEGER;
  var_registros INTEGER;
BEGIN
  -- pega id do modulo
  SELECT eac.id_modulo
    INTO var_id_modulo
    FROM security.elementos_modulo eac
   WHERE eac.id = var_id_elemento;
        
  -- Se AÇÂO for Exclusão
  IF var_acao = 'DELETE' THEN
  
     -- verifica se existe elemento associado ao módulo
     SELECT count(rxe.id)
       INTO var_registros
       FROM security.roles_x_elementos_modulo rxe INNER JOIN
            security.elementos_modulo         eac ON eac.id = rxe.id_elemento
      WHERE eac.id_modulo= var_id_modulo
        AND rxe.id_role  = var_id_role;
           
     var_registros = COALESCE(var_registros,0);
     
     -- Se não existir elemento exclui relação da regra com o modulo
     IF var_registros = 0 THEN
        DELETE FROM security.roles_x_modulos rxm
         WHERE rxm.id_role  = var_id_role
           AND rxm.id_modulo= var_id_modulo;
     END IF;
     
  -- Se AÇÂO for Inclusao
  ELSE     
  
     -- Verifica se modulo já possui regra associada
     SELECT count(rxm.id)
       INTO var_registros
       FROM security.roles_x_modulos rxm
      WHERE rxm.id_role  = var_id_role
        AND rxm.id_modulo= var_id_modulo;           
           
     var_registros = COALESCE(var_registros,0);
     
     -- Inclui regra ao modulo se não estiver associado
     IF var_registros = 0 THEN
        INSERT INTO security.roles_x_modulos (id_role, id_modulo) 
        VALUES (var_id_role, var_id_modulo);
     END IF;
     
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- =============================================================================
-- FUNÇÂO: Ações do tipo "AFTER" da tabela "roles_x_elementos_modulo"
-- =============================================================================
CREATE OR REPLACE FUNCTION security.fn_scy_tga_roles_x_elementos_modulo()
RETURNS trigger AS
$body$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM security.fn_scy_atualiza_roles_x_modulos(NEW.id_role, NEW.id_elemento,'INSERT');

  ELSEIF TG_OP = 'UPDATE' THEN
     -- nada definido por enquanto

  ELSEIF TG_OP = 'DELETE' THEN
    PERFORM security.fn_scy_atualiza_roles_x_modulos(OLD.id_role, OLD.id_elemento,'DELETE');

  END IF;
  RETURN NULL;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tga_roles_x_elementos_modulo
-- -----------------------------------------------------------------------------
CREATE TRIGGER                      tg_scy_tga_roles_x_elementos_modulo
AFTER INSERT OR UPDATE OR DELETE ON security.roles_x_elementos_modulo
FOR EACH ROW EXECUTE PROCEDURE      security.fn_scy_tga_roles_x_elementos_modulo();
-- =============================================================================
-- FIM: Trigger AFTER da tabela security.roles_x_elementos_modulo
-- =============================================================================

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "profissionais_ti"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_profissionais_ti()
RETURNS SETOF trigger AS
$body$
BEGIN
  IF TG_OP = 'INSERT' or TG_OP = 'UPDATE' THEN
     NEW.nome_completo   = upper(NEW.nome_completo);
     NEW.nome_referencia = upper(NEW.nome_referencia);
     NEW.email           = lower(NEW.email);
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN
     -- nada definido por enquanto
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_profissionais_ti
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_profissionais_ti
BEFORE INSERT OR UPDATE OR DELETE ON security.profissionais_ti
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_profissionais_ti();

-- =============================================================================
-- INICIO: Trigger AFTER da tabela security.users
-- =============================================================================
DROP TRIGGER  tg_scy_tga_users ON security.users;
DROP FUNCTION security.fn_scy_tga_users();
DROP FUNCTION security.fn_scy_inclui_regras_automaticas_users_x_roles(var_id_user varchar, var_id_tipo_usuario integer);

-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Grava Historico de Regra Automatica
-- -----------------------------------------------------------------------------
CREATE OR REPLACE
FUNCTION security.fn_scy_inclui_regra_automatica_usuario(var_id_user varchar(8), var_id_role INTEGER)
RETURNS void AS
$body$
DECLARE
  var_role_name VARCHAR(100);
BEGIN
  -- Inclui regra na tabela user_roles
  INSERT INTO security.users_x_roles (id_user, id_role) 
  VALUES (var_id_user, var_id_role);

  -- Pega o nome da regra para (var_id_role)
  SELECT rol.role_name
    INTO var_role_name
    FROM security.roles rol
   WHERE rol.id_role = var_id_role;

  -- Registra histórico de inclusão da regra
  INSERT INTO security.users_historicos  (id_user,id_tipo_historico, matricula, observacao)
  VALUES (var_id_user,10, 'SISTEMA',var_role_name);     
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Incluir regras autmatica conforme tipo de usuario
-- -----------------------------------------------------------------------------
CREATE OR REPLACE
FUNCTION security.fn_scy_verifica_regras_automaticas_usuario(var_id_user varchar(8), var_id_tipo_usuario INTEGER)
RETURNS void AS
$body$
DECLARE
  var_id_role   INTEGER;
  var_id        INTEGER;
  var_role_name VARCHAR(100);
BEGIN
  -- Verifica se regra: 70='USUARIO.GERAL' foi Registrada
  SELECT uxr.id
    INTO var_id
    FROM security.users_x_roles uxr 
   WHERE uxr.id_user = var_id_user 
     AND uxr.id_role = 70;  --  70='USUARIO.GERAL'
 
  -- Se Regra ainda não tiver sido incluida   
  IF NOT FOUND THEN
     PERFORM security.fn_scy_inclui_regra_automatica_usuario(var_id_user,70);
  END IF;

  -- Verifica qual a regra a ser incluida Conforme Tipo de usuario
  IF     var_id_tipo_usuario=1 THEN --  1=Funcionario
     var_id_role = 71;              -- 71='USUARIO.FUNCIONARIO'
  ELSEIF var_id_tipo_usuario=2 THEN --  2=Profissional
     var_id_role = 72;              -- 72='USUARIO.PROFISSIONAL'
  ELSEIF var_id_tipo_usuario=3 THEN --  3=Contratada
     var_id_role = 73;              -- 73='USUARIO.CONTRATADA'
  ELSEIF var_id_tipo_usuario=4 THEN --  4=Contratante
     var_id_role = 74;              -- 74='USUARIO.CONTRATANTE'
  ELSE   
     var_id_role = 0;               -- Para tipo Usuario Não identificado
  END IF;
 
  -- Se a regra for válida
  IF var_id_role > 0 THEN
     -- Verifica se regra já foi registrada
     SELECT uxr.id
       INTO var_id
       FROM security.users_x_roles uxr 
      WHERE uxr.id_user = var_id_user 
        AND uxr.id_role = var_id_role;
  
     -- Se Regra ainda não tiver sido incluida   
     IF NOT FOUND THEN
        PERFORM security.fn_scy_inclui_regra_automatica_usuario(var_id_user, var_id_role);
     END IF;
  END IF;     
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "AFTER" da tabela "users"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tga_users()
RETURNS trigger AS
$body$
BEGIN
  IF TG_OP = 'INSERT' THEN         
     PERFORM security.fn_scy_verifica_regras_automaticas_usuario(NEW.matricula, NEW.id_tipo_usuario);
  
  ELSEIF TG_OP = 'UPDATE' THEN
     PERFORM security.fn_scy_verifica_regras_automaticas_usuario(NEW.matricula, NEW.id_tipo_usuario);

  ELSEIF TG_OP = 'DELETE' THEN
     -- nada definido por enquanto

  END IF;
  RETURN NULL;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tga_users
-- -----------------------------------------------------------------------------
CREATE TRIGGER                      tg_scy_tga_users
AFTER INSERT OR UPDATE OR DELETE ON security.users
FOR EACH ROW EXECUTE PROCEDURE      security.fn_scy_tga_users();
-- =============================================================================
-- FIM: Trigger AFTER da tabela security.users
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger BEFORE da tabela security.users
-- =============================================================================
DROP TRIGGER  tg_scy_tgb_users ON security.users;
DROP FUNCTION security.fn_scy_tgb_users();

-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "users"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_users()
RETURNS SETOF trigger AS
$body$
BEGIN
  IF TG_OP = 'INSERT' or TG_OP = 'UPDATE' THEN
     NEW.nome_completo   = upper(NEW.nome_completo);
     NEW.nome_referencia = upper(NEW.nome_referencia);
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN
     -- nada definido por enquanto
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_users
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_users
BEFORE INSERT OR UPDATE OR DELETE ON security.users
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_users();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela security.users
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger BEFORE da tabela security.casos_de_uso
-- =============================================================================
DROP TRIGGER tg_scy_tgb_casos_de_uso ON security.casos_de_uso;
DROP FUNCTION security.fn_scy_tgb_casos_de_uso();
DROP FUNCTION security.fn_scy_gera_codigo_caso_de_uso(var_id_modulo INTEGER);

-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Gera código do Caso de Uso
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_gera_codigo_caso_de_uso(var_id_modulo INTEGER)
RETURNS VARCHAR(8) AS
$body$
DECLARE
  parte_fixa      text;
  cod_modulo      text;
  seq_caso_de_uso text;
  codigo_gerado   text;
BEGIN  
  -- Pega Código do módulo
  SELECT mod.codigo_modulo
    INTO cod_modulo
    FROM security.modulos mod
   WHERE mod.id = var_id_modulo;
   
  -- Monta Parte Fixa do Código 
  parte_fixa =  TRIM('UC') ||TRIM(cod_modulo);
  
  -- Pega ultimo código de caso de uso para o modulo indicado e adiciona 1
  SELECT to_char(to_number(max(SUBSTRING(cdu.codigo,6,3)),'000')+1,'000')
  INTO   seq_caso_de_uso
  FROM   security.casos_de_uso cdu 
  GROUP BY SUBSTRING(cdu.codigo,1,5)
  HAVING   SUBSTRING(cdu.codigo,1,5) = parte_fixa;
  
  -- Se não existir reuniao no Ano Mes vigente gerada anteriormente
  IF NOT FOUND THEN
    seq_caso_de_uso = '001';
  END IF;
  
  -- gera novo código
  codigo_gerado = TRIM(parte_fixa) || TRIM(seq_caso_de_uso);
  RETURN codigo_gerado;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "casos_de_uso"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_casos_de_uso()
RETURNS SETOF trigger AS
$body$
BEGIN
  IF TG_OP = 'INSERT' THEN
     NEW.codigo  = security.fn_scy_gera_codigo_caso_de_uso(NEW.id_modulo); 
     RETURN NEW;

  ELSEIF TG_OP = 'UPDATE' THEN
     -- nada definido por enquanto
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN
     -- nada definido por enquanto
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_casos_de_uso
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_casos_de_uso
BEFORE INSERT OR UPDATE OR DELETE ON security.casos_de_uso
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_casos_de_uso();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela security.casos_de_uso
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger BEFORE da tabela security.reunioes
-- =============================================================================
DROP TRIGGER tg_scy_tgb_reunioes ON security.reunioes;
DROP FUNCTION security.fn_scy_tgb_reunioes();
DROP FUNCTION security.fn_scy_gera_codigo_reuniao();

-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Gera código da reuniao
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_gera_codigo_reuniao()
RETURNS VARCHAR(10) AS
$body$
DECLARE
  ano_mes        text;
  cod_parte_fixa text;
  seq_reuniao    text;
  codigo_gerado  text;
BEGIN  
  -- Pega Ano Mes da data vigente  
  SELECT to_char(now(),'yyyyMM') INTO ano_mes;
  
  -- Calcula Parte Fixa do Código
  cod_parte_fixa = TRIM('R') || TRIM(ano_mes);
    
  -- Pega ultimo código da reuniao do ano Mês vigente e adiciona 1
  SELECT to_char(to_number(max(SUBSTRING(reu.codigo,8,3)),'000')+1,'000')
  INTO   seq_reuniao
  FROM   security.reunioes reu 
  GROUP BY SUBSTRING(reu.codigo,1,7)
  HAVING   SUBSTRING(reu.codigo,1,7) = cod_parte_fixa;
  
  -- Se não existir reuniao no Ano Mes vigente gerada anteriormente
  IF NOT FOUND THEN
    seq_reuniao = '001';
  END IF;
  
  -- gera novo código
  codigo_gerado = TRIM(cod_parte_fixa) || TRIM(seq_reuniao);
  RETURN codigo_gerado;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "reunioes"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_reunioes()
RETURNS SETOF trigger AS
$body$
BEGIN
  IF TG_OP = 'INSERT' THEN
     NEW.codigo  = security.fn_scy_gera_codigo_reuniao(); 
     RETURN NEW;

  ELSEIF TG_OP = 'UPDATE' THEN
     -- nada definido por enquanto
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN
     -- nada definido por enquanto
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_reunioes
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_reunioes
BEFORE INSERT OR UPDATE OR DELETE ON security.reunioes
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_reunioes();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela security.reunioes
-- =============================================================================

-- =============================================================================
-- INICIO: FUNCOES para a tabela PROJETO
-- =============================================================================
CREATE OR REPLACE FUNCTION security.fn_scy_projeto_em_execucao (var_id_projeto integer)
RETURNS boolean AS
$body$
DECLARE
  var_status_projeto      INTEGER;
  var_projeto_em_execucao BOOLEAN;
BEGIN 
  -- Recupera Status do Projeto
  SELECT pro.id_status          
    INTO var_status_projeto
    FROM security.projetos pro 
   WHERE pro.id = var_id_projeto;
  -- Verifica se está em execução
  var_projeto_em_execucao = false;       
  IF var_status_projeto = 4 THEN -- 4 - Em execução
     var_projeto_em_execucao = true;
  END IF;    
  RETURN var_projeto_em_execucao;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT
SECURITY INVOKER COST 100;
-- =============================================================================
-- FIM: FUNCOES para a tabela PROJETO
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger BEFORE da tabela security.projetos_paralisacoes
-- =============================================================================
DROP TRIGGER tg_scy_tgb_projetos_paralisacoes ON security.projetos_paralisacoes;
DROP FUNCTION security.fn_scy_tgb_projetos_paralisacoes();
-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "paralisacoes"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_projetos_paralisacoes()
RETURNS SETOF trigger AS
$body$
DECLARE
  var_data_inicio_real        DATE;
  var_id_paralisacao_anterior INTEGER;
BEGIN
  IF TG_OP = 'INSERT' THEN
     -- Só permite incluir Se projeto estiver com Status "Em execução"
     IF NOT security.fn_scy_projeto_em_execucao(NEW.id_projeto)  THEN        
        RAISE EXCEPTION 'Paralisação só pode ser realizado com projetos em Execução.';
     END IF;
     -- Só permite incluir Se Data Paralisação Maior Igual a Data Inicio Real do projeto
     SELECT pro.data_inicio_real   
       INTO var_data_inicio_real
       FROM SECURITY.projetos pro 
      WHERE pro.id = NEW.id_projeto;
       
     IF NEW.data_paralisacao < var_data_inicio_real THEN
        RAISE EXCEPTION 'Paralisação só pode ser realizado após Inicio do Projeto!';     
     END IF;
  END IF;
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
     IF NEW.data_reinicio ISNULL  THEN
        NEW.dias_parado = NULL;
     ELSE
        IF NEW.data_reinicio < NEW.data_paralisacao THEN
           RAISE EXCEPTION 'Data Reinicio inferior a data Paralisação!';
	    END IF;
        -- Calcula qtd dias parado entre paralização e reinicio
	    NEW.dias_parado = NEW.data_reinicio - NEW.data_paralisacao;        
     END IF;    
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN
     -- Recupera ID paralisação anterior     
     SELECT max(ppa.id)
       INTO var_id_paralisacao_anterior
       FROM security.projetos_paralisacoes ppa
      WHERE ppa.id_projeto = OLD.id_projeto
        AND ppa.id <> OLD.id;
     -- Atualiza qtd de dias paraliado na tabela Obras
     UPDATE security.projetos AS pro
        SET id_paralisacao = var_id_paralisacao_anterior
      WHERE pro.id = OLD.id_projeto;
     -- nada definido por enquanto
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_projetos_paralisacoes
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_projetos_paralisacoes
BEFORE INSERT OR UPDATE OR DELETE ON security.projetos_paralisacoes
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_projetos_paralisacoes();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela security.projetos_paralisacoes
-- =============================================================================


-- =============================================================================
-- INICIO: Trigger AFTER da tabela security.projetos_paralisacoes
-- =============================================================================
DROP TRIGGER  tg_scy_tga_projetos_paralisacoes ON security.projetos_paralisacoes;
DROP FUNCTION security.fn_scy_tga_projetos_paralisacoes();
-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "AFTER" da tabela "paralisacoes"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tga_projetos_paralisacoes()
RETURNS SETOF trigger AS
$body$
DECLARE
  var_dias_parado_anter INTEGER;
  var_dias_parado_atual INTEGER;
  var_id_ajuste_prazo   INTEGER;
  var_motivo_ajuste     text;
BEGIN  
  -- Processa ações de INCLUSÃO e ATUALIZAÇÂO
  -- -----------------------------------------
  IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE')  THEN
     -- Calcula qtd dias paralizado sem lançamentos atual
     SELECT sum(ppa.dias_parado)
       INTO var_dias_parado_anter
       FROM security.projetos_paralisacoes ppa
      WHERE ppa.id_projeto = NEW.id_projeto
        AND ppa.id <> NEW.id ;

     -- Atualiza Qtd dias paralizado na tabela Projeto   
     var_dias_parado_anter = (SELECT COALESCE(var_dias_parado_anter,0));
     var_dias_parado_atual = COALESCE(NEW.dias_parado,0);
     IF TG_OP = 'INSERT'  THEN        
        UPDATE security.projetos AS pro
           SET dias_paralisado = var_dias_parado_anter + var_dias_parado_atual,
               id_paralisacao  = NEW.id -- Id da ultima paralisacao registrada
         WHERE pro.id = NEW.id_projeto;
     ELSE 
        UPDATE security.projetos AS pro
           SET dias_paralisado = var_dias_parado_anter + var_dias_parado_atual
         WHERE pro.id = NEW.id_projeto;
     END IF;
     -- Verifica se Existe Ajuste de Prazo A ser Incluir/alterado
     SELECT pap.id INTO var_id_ajuste_prazo
       FROM security.projetos_ajustes_prazo pap  
      WHERE pap.id_paralisacao = NEW.id;
     -- Se não existir Ajuste d Paralisacao
     var_id_ajuste_prazo = (SELECT COALESCE(var_id_ajuste_prazo,0));
       -- Atualiza Ajuste de prazo  
     IF var_dias_parado_atual <> 0 THEN
        var_motivo_ajuste = 'Ajuste de prazo automático por causa da Paralisação: ' 
                            || 'P' || trim(to_char(NEW.id,'00000')) || ' de ' ||  
                            trim(to_char(abs(var_dias_parado_atual),'9999')) || ' dias.'; 
        IF var_id_ajuste_prazo = 0 THEN
           INSERT INTO security.projetos_ajustes_prazo
                  (id_projeto, motivo, dias_ajustados, id_paralisacao)                  
           VALUES (NEW.id_projeto,var_motivo_ajuste, var_dias_parado_atual, NEW.id);
        ELSE
           UPDATE security.projetos_ajustes_prazo
              SET dias_ajustados = var_dias_parado_atual,
                  motivo         = var_motivo_ajuste
            WHERE id_paralisacao = NEW.id;
        END IF;
     ELSE   
        IF var_id_ajuste_prazo > 0 THEN
           DELETE FROM security.projetos_ajustes_prazo  WHERE id = var_id_ajuste_prazo;
        END IF;
     END IF; 
  END IF;
     
  -- Processa ação de EXCLUSÂO
  -- -----------------------------------------
  IF TG_OP = 'DELETE'  THEN
     -- Calcula qtd dias paralizado sem lançamentos atual
     SELECT sum(ppa.dias_parado)
       INTO var_dias_parado_anter
       FROM security.projetos_paralisacoes ppa
      WHERE ppa.id_projeto = OLD.id_projeto
        AND ppa.id <> OLD.id ;
     -- Atualiza qtd de dias paraliado na tabela Obras
     var_dias_parado_anter = (SELECT COALESCE(var_dias_parado_anter,0));
     UPDATE security.projetos AS pro
        SET dias_paralisado = var_dias_parado_anter
      WHERE pro.id = OLD.id_projeto;
  END IF;  
  RETURN NEW;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tga_projetos_paralisacoes
-- -----------------------------------------------------------------------------
CREATE TRIGGER                      tg_scy_tga_projetos_paralisacoes
AFTER INSERT OR UPDATE OR DELETE ON security.projetos_paralisacoes
FOR EACH ROW EXECUTE PROCEDURE      security.fn_scy_tga_projetos_paralisacoes();
-- =============================================================================
-- FIM: Trigger AFTER da tabela security.projetos_paralisacoes
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger BEFORE da tabela security.projetos_ajustes_prazo
-- =============================================================================
DROP TRIGGER tg_scy_tgb_projetos_ajustes_prazo ON security.projetos_ajustes_prazo;
DROP FUNCTION security.fn_scy_tgb_projetos_ajustes_prazo();
-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "ajustes_prazo"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_projetos_ajustes_prazo()
RETURNS SETOF trigger AS
$body$
DECLARE
  var_status_projeto INTEGER;
BEGIN
  IF TG_OP = 'INSERT' OR  TG_OP = 'UPDATE' THEN
     -- Valida Inclusão do Prazo
     IF TG_OP = 'INSERT' THEN    
        -- Recupera data fim previsto antes do ajuste
        NEW.fim_previsto_anterior =  (SELECT pro.data_fim_previsto_atual
                                        FROM security.projetos pro
                                       WHERE pro.id = NEW.id_projeto);
     END IF;
     --  Calcula "Novo Fim Previsto"
     NEW.novo_fim_previsto = NEW.fim_previsto_anterior + NEW.dias_ajustados;
     RETURN NEW;

  ELSEIF TG_OP = 'UPDATE' THEN
     --  Calcula "Novo Fim Previsto" 
     NEW.novo_fim_previsto = NEW.fim_previsto_anterior + NEW.dias_ajustados;
     RETURN NEW;
     
  ELSEIF TG_OP = 'DELETE' THEN
     -- Nada definido por enquanto
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_projetos_ajustes_prazo
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_projetos_ajustes_prazo
BEFORE INSERT OR UPDATE OR DELETE ON security.projetos_ajustes_prazo
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_projetos_ajustes_prazo();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela security.projetos_ajustes_prazo
-- =============================================================================


-- =============================================================================
-- INICIO: Trigger AFTER da tabela security.projetos_ajustes_prazo
-- =============================================================================
DROP TRIGGER tg_scy_tga_projetos_ajustes_prazo ON security.projetos_ajustes_prazo;
DROP FUNCTION security.fn_scy_tga_projetos_ajustes_prazo();
-- ----------------------------------------------------------
-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "AFTER" da tabela "ajustes_prazo"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tga_projetos_ajustes_prazo()
RETURNS SETOF trigger AS
$body$
DECLARE
  var_data_inicio_previsto DATE;
  var_prazo_inicial        INTEGER;
  var_dias_ajustados_anter INTEGER;
  var_dias_ajustados_atual INTEGER;
  var_id_projeto           INTEGER;
  var_id_ajuste_atual      INTEGER;
BEGIN  
  IF TG_OP = 'DELETE'  THEN
     var_id_projeto           = OLD.id_projeto;
     var_id_ajuste_atual      = OLD.id;
     var_dias_ajustados_atual = 0;
  ELSE
     var_id_projeto           = NEW.id_projeto;
     var_id_ajuste_atual      = NEW.id;
     var_dias_ajustados_atual = COALESCE(NEW.dias_ajustados,0);
  END IF;
  
  -- Recupera dias prazos vigentes para recalcular novo fim previsto
  SELECT pro.data_inicio_previsto, pro.prazo_inicial
    INTO var_data_inicio_previsto, var_prazo_inicial
    FROM security.projetos pro
   WHERE pro.id = var_id_projeto;
   
  -- Recupera dias ajustados em lancamentos anteriores
  SELECT sum(pap.dias_ajustados)
    INTO var_dias_ajustados_anter
    FROM security.projetos_ajustes_prazo pap
   WHERE pap.id_projeto = var_id_projeto AND pap.id <> var_id_ajuste_atual;
          
  -- Atualiza qtd de dias ajustados na tabela Projetos
  var_dias_ajustados_anter = (SELECT COALESCE(var_dias_ajustados_anter,0));
  UPDATE security.projetos pro
     SET dias_ajustados          = var_dias_ajustados_anter + var_dias_ajustados_atual,
         data_fim_previsto_atual = (var_data_inicio_previsto - 1) 
                          + var_prazo_inicial   
                          + var_dias_ajustados_anter -- Inclui dias paralizados
                          + var_dias_ajustados_atual -- Inclui dias paralizados
   WHERE pro.id = var_id_projeto;
   
  RETURN NEW;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tga_projetos_ajustes_prazo
-- -----------------------------------------------------------------------------
CREATE TRIGGER                      tg_scy_tga_projetos_ajustes_prazo
AFTER INSERT OR UPDATE OR DELETE ON security.projetos_ajustes_prazo
FOR EACH ROW EXECUTE PROCEDURE      security.fn_scy_tga_projetos_ajustes_prazo();
-- =============================================================================
-- FIM: Trigger AFTER da tabela security.projetos_ajustes_prazo
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger AFTER da tabela security.projetos
-- =============================================================================
DROP TRIGGER tg_scy_tga_projetos ON security.projetos;
DROP FUNCTION security.fn_scy_tga_projetos();

-- =============================================================================
-- FUNÇÂO: Ações do tipo "AFTER" da tabela "projetos"
-- =============================================================================
CREATE OR REPLACE FUNCTION security.fn_scy_tga_projetos()
RETURNS SETOF trigger AS
$body$
DECLARE
  var_dias_ajuste INTEGER;
  var_obs_ajuste  text;
  var_per_exec    INTEGER;
  var_obs_exec    text;
  var_data_exec   TIMESTAMP;
  var_data_aux    Date;
BEGIN
  IF TG_OP = 'INSERT' THEN
     -- nada definido por enquanto
     RETURN NEW;

  ELSEIF TG_OP = 'UPDATE' THEN
      -- Gera histórico do percentual de execução do projeto
     -- ------------------------------------------------------------------------
     var_per_exec = 0;
     var_obs_exec = 'NAO';
     var_data_exec= now();
     
     --  Historico gerado após o Inico real do projeto([3-Aguardando Inicio] <--> [4-Em Execução])
     IF (OLD.id_status = 3) AND (NEW.id_status = 4) THEN 
        -- Registra ajuste de prazo se necessario
        IF NEW.data_inicio_previsto <> NEW.data_inicio_real THEN -- inicio previsto difere do real
           var_dias_ajuste =  NEW.data_inicio_real - NEW.data_inicio_previsto;
           IF var_dias_ajuste < 0 THEN           
              var_obs_ajuste = 'Ajuste de prazo automático por ter iniciado o projeto Adiantado em: ' 
                               || trim(to_char(abs(var_dias_ajuste),'9999')) || ' dias.';
           ELSE
              var_obs_ajuste = 'Ajuste de prazo automático por ter iniciado o projeto Atrasado em: '  
                               || trim(to_char(abs(var_dias_ajuste),'9999')) || ' dias.';
           END IF;
           INSERT INTO security.projetos_ajustes_prazo 
                  (id_projeto, motivo,         dias_ajustados)
           VALUES (NEW.id,     var_obs_ajuste, var_dias_ajuste);
        END IF;
        var_per_exec = 0;
        var_obs_exec = 'Inicio real da execução do projeto em: ' ||  to_char(NEW.data_inicio_real,'DD/MM/YYYY');
         
     --  Historico gerado após o Paralisação do projeto     ([4-Em Execução] <--> [5-Paralisado])
     ELSEIF (OLD.id_status = 4) AND (NEW.id_status = 5) THEN
        SELECT ppa.data_paralisacao
          INTO var_data_aux
          FROM security.projetos_paralisacoes ppa
         WHERE ppa.id = NEW.id_paralisacao;
                   
        var_per_exec = NEW.percentual_executado;
        var_obs_exec = 'Execução Paralisada em: ' || to_char(var_data_aux,'DD/MM/YYYY') ;        
        
     --  Historico gerado após o Re-inicio do projeto        ([5-Paralisado] <--> [4-Em Execução])
     ELSEIF (OLD.id_status = 5) AND (NEW.id_status = 4) THEN
        SELECT ppa.data_reinicio
          INTO var_data_aux
          FROM security.projetos_paralisacoes ppa
         WHERE ppa.id = NEW.id_paralisacao;
                   
        var_per_exec = NEW.percentual_executado;
        var_obs_exec = 'Execução Reiniciada Em: ' || to_char(var_data_aux,'DD/MM/YYYY');
        
     --  Historico gerado após o registro de Acompanhamento ([4-Em Execução] <--> [4-Em Execução])
     ELSEIF (OLD.id_status = 4) AND (NEW.id_status = 4) THEN 
        IF (NEW.percentual_executado <> OLD.percentual_executado) OR
           (NEW.observacao_progresso <> OLD.observacao_progresso) THEN
            var_per_exec = NEW.percentual_executado;
            var_obs_exec = NEW.observacao_progresso;
        END IF;
        
     --  Historico gerado após o Cancelamento do projeto       ([4-Execução] <--> [6-Cancelado])
     ELSEIF (OLD.id_status = 4) AND (NEW.id_status = 6) THEN
        var_per_exec = NEW.percentual_executado;
        var_obs_exec = 'Projeto Cancelado em: ' || to_char(var_data_exec,'DD/MM/YYYY');
        
     --  Historico gerado após a Conclusão do projeto          ([4-Execução] <--> [7-Concluido])
     ELSEIF (OLD.id_status = 4) AND (NEW.id_status = 7) THEN
        var_per_exec = NEW.percentual_executado;
        var_obs_exec = 'Projeto Concluido em: ' || to_char(NEW.data_fim_real,'DD/MM/YYYY');
     END IF;
     
     -- Se Houve Histórico gerado
     IF var_obs_exec <> 'NAO' THEN
        INSERT INTO security.projetos_progresso_execucao 
               (id_projeto,           data_historico,
                percentual_executado, observacao_progresso)
        VALUES (NEW.id, var_data_exec, var_per_exec, var_obs_exec);
     END IF;
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN
     -- nada definido por enquanto
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tga_projetos
-- -----------------------------------------------------------------------------
CREATE TRIGGER                      tg_scy_tga_projetos
AFTER INSERT OR UPDATE OR DELETE ON security.projetos
FOR EACH ROW EXECUTE PROCEDURE      security.fn_scy_tga_projetos();
-- =============================================================================
-- FIM: Trigger AFTER da tabela security.projetos
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger BEFORE da tabela security.atividades
-- =============================================================================
-- Atualiza status da atividade
-- -----------------------------------------------------------------------------
UPDATE security.atividades SET id_status=1 WHERE     data_inicio_real ISNULL AND     data_fim_real ISNULL; -- 1=A Iniciar
UPDATE security.atividades SET id_status=2 WHERE NOT data_inicio_real ISNULL AND     data_fim_real ISNULL; -- 2=Iniciada
UPDATE security.atividades SET id_status=3 WHERE NOT data_inicio_real ISNULL AND NOT data_fim_real ISNULL; -- 3=Concluida

-- -----------------------------------------------------------------------------
DROP TRIGGER tg_scy_tgb_atividades ON security.atividades;
DROP FUNCTION security.fn_scy_tgb_atividades();
DROP FUNCTION security.fn_scy_gera_codigo_atividade_tipo_projeto(var_id_projeto INTEGER);
DROP FUNCTION security.fn_scy_gera_codigo_atividade_tipo_manutencao(var_id_manutencao INTEGER);
DROP FUNCTION security.fn_scy_gera_codigo_atividade_tipo_diversa();

-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Gera código da atividade tipo Projeto
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_gera_codigo_atividade_tipo_projeto(var_id_projeto INTEGER)
RETURNS VARCHAR(10) AS
$body$
DECLARE
  cod_projeto    text;
  cod_parte_fixa text;
  seq_atividade  text;
  codigo_gerado  text;
BEGIN
  
  -- pega codigo do Projeto
  SELECT pjt.codigo
  INTO   cod_projeto
  FROM   security.projetos pjt
  WHERE  pjt.id = var_id_projeto;
  
  -- Calcula Parte Fixa do Código
  cod_parte_fixa = TRIM('P') || TRIM(cod_projeto);
    
  -- Pega ultimo código da Atividade do Projeto e adiciona 1
  SELECT to_char(to_number(max(SUBSTRING(atv.codigo,8,3)),'000')+1,'000')
  INTO   seq_atividade
  FROM   security.atividades atv 
  GROUP BY SUBSTRING(atv.codigo,1,7)
  HAVING   SUBSTRING(atv.codigo,1,7) = cod_parte_fixa;
     
  -- Se não existir Atividade do Projeto gerada anteriormente
  IF NOT FOUND THEN
    seq_atividade = '001';
  END IF;
  
  -- gera novo código
  codigo_gerado = TRIM(cod_parte_fixa) || TRIM(seq_atividade);
  RETURN codigo_gerado;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Gera código da atividade tipo Manutencao
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_gera_codigo_atividade_tipo_manutencao(var_id_manutencao INTEGER)
RETURNS VARCHAR(10) AS
$body$
DECLARE
  cod_manutencao text;
  cod_parte_fixa text;
  seq_atividade  text;
  codigo_gerado  text;
BEGIN  
  -- pega codigo do Manutencao
  SELECT msi.codigo
  INTO   cod_manutencao
  FROM   security.manutencoes_sistema msi
  WHERE  msi.id = var_id_manutencao;
  
  -- Calcula Parte Fixa do Código
  cod_parte_fixa = TRIM('M') || TRIM(cod_manutencao);
    
  -- Pega ultimo código da Atividade do Manutencao e adiciona 1
  SELECT to_char(to_number(max(SUBSTRING(atv.codigo,8,3)),'000')+1,'000')
  INTO   seq_atividade
  FROM   security.atividades atv 
  GROUP BY SUBSTRING(atv.codigo,1,7)
  HAVING   SUBSTRING(atv.codigo,1,7) = cod_parte_fixa;
  
  -- Se não existir Atividade da manutenção gerada anteriormente
  IF NOT FOUND THEN
    seq_atividade = '001';
  END IF;
  
  -- gera novo código
  codigo_gerado = TRIM(cod_parte_fixa) || TRIM(seq_atividade);
  RETURN codigo_gerado;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Gera código da atividade tipo Diversa
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_gera_codigo_atividade_tipo_diversa()
RETURNS VARCHAR(10) AS
$body$
DECLARE
  ano_mes        text;
  cod_parte_fixa text;
  seq_atividade  text;
  codigo_gerado  text;
BEGIN  
  -- Pega Ano Mes da data vigente  
  SELECT to_char(now(),'yyyyMM') INTO ano_mes;
  
  -- Calcula Parte Fixa do Código
  cod_parte_fixa = TRIM('D') || TRIM(ano_mes);
    
  -- Pega ultimo código da Atividade no Ano Mes Vigente e adiciona 1
  SELECT to_char(to_number(max(SUBSTRING(atv.codigo,8,3)),'000')+1,'000')
  INTO   seq_atividade
  FROM   security.atividades atv 
  GROUP BY SUBSTRING(atv.codigo,1,7)
  HAVING   SUBSTRING(atv.codigo,1,7) = cod_parte_fixa;
  
  -- Se não existir Atividade no Ano Mes vigente gerada anteriormente
  IF NOT FOUND THEN
    seq_atividade = '001';
  END IF;
  
  -- gera novo código
  codigo_gerado = TRIM(cod_parte_fixa) || TRIM(seq_atividade);
  RETURN codigo_gerado;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "atividades"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_atividades()
RETURNS SETOF trigger AS
$body$
BEGIN
  IF TG_OP = 'INSERT' THEN
     IF NEW.id_tipo_atividade     = 1  THEN -- 1 - Atividade tipo Projeto
        NEW.codigo  = security.fn_scy_gera_codigo_atividade_tipo_projeto(NEW.id_projeto);
     ELSEIF NEW.id_tipo_atividade = 2  THEN -- 1 - Atividade tipo manutencao
        NEW.codigo  = security.fn_scy_gera_codigo_atividade_tipo_manutencao(NEW.id_manutencao_sistema);
     ELSEIF NEW.id_tipo_atividade = 3  THEN -- 1 - Atividade diversa
        NEW.codigo  = security.fn_scy_gera_codigo_atividade_tipo_diversa(); 
     END IF; 
  END IF;  
  
  IF (TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
     IF NEW.id_status <> 4 THEN   -- 4=Cancelado
        IF NEW.data_inicio_real ISNULL AND NEW.data_fim_real ISNULL THEN     
           NEW.id_status=1;       -- 1=A Iniciar
        ELSE
           IF NOT NEW.data_inicio_real ISNULL AND NEW.data_fim_real ISNULL THEN
              NEW.id_status=2;    -- 2=Iniciado
           ELSE
              IF NOT NEW.data_inicio_real ISNULL AND NOT NEW.data_fim_real ISNULL THEN   
                 NEW.id_status=3; -- 3=Concluido
              END IF;
           END IF;
        END IF;
     END IF;
     RETURN NEW;
  END IF;
  
  IF TG_OP = 'DELETE' THEN
     -- nada definido por enquanto
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_atividades
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_atividades
BEFORE INSERT OR UPDATE OR DELETE ON security.atividades
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_atividades();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela security.atividades
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger BEFORE da tabela security.projetos
-- =============================================================================
DROP TRIGGER tg_scy_tgb_projetos ON security.projetos;
DROP FUNCTION security.fn_scy_tgb_projetos();
DROP FUNCTION security.fn_scy_gera_codigo_projetos(var_id_area_ti integer, var_id_tipo_projeto integer);
-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Gera código do Modulo
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_gera_codigo_projetos(var_id_area_ti INTEGER, var_id_tipo_projeto INTEGER)
RETURNS VARCHAR(6) AS
$body$
DECLARE
  cod_parte_fixa text;
  seq_projeto    text;
  codigo_gerado  text;
BEGIN
  -- Pega ultimo código de projeto gerado para area e tipo e adiciona 1
  SELECT to_char(to_number(max(SUBSTRING(pjt.codigo,4,3)),'000')+1,'000')
    INTO seq_projeto
    FROM security.projetos pjt
  GROUP BY pjt.id_area_ti, pjt.id_tipo
    HAVING pjt.id_area_ti = var_id_area_ti
       AND pjt.id_tipo    = var_id_tipo_projeto;
  -- Se não existir perjeto gerado anteriormente
  IF NOT FOUND THEN
    seq_projeto = '001';
  END IF;
  -- Pega Código do projeto atual e gera novo Código
  cod_parte_fixa = TRIM(to_char(var_id_area_ti,'0')) || TRIM(to_char(var_id_tipo_projeto,'00'));
  codigo_gerado  = TRIM(cod_parte_fixa) || TRIM(seq_projeto);
  RETURN codigo_gerado;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- =============================================================================
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "projetos"
-- =============================================================================
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_projetos()
RETURNS SETOF trigger AS
$body$
DECLARE
  var_qtd_atividade INTEGER;
BEGIN
  IF TG_OP = 'INSERT' THEN
     -- Gera código e clacula Prazo Inicial do projeto
     NEW.codigo  = security.fn_scy_gera_codigo_projetos(NEW.id_area_ti, NEW.id_tipo);
     NEW.prazo_inicial = (NEW.data_fim_previsto - NEW.data_inicio_previsto) + 1;
     NEW.data_fim_previsto_atual = NEW.data_fim_previsto;
     RETURN NEW;

  ELSEIF TG_OP = 'UPDATE' THEN
     -- ReGera Codigo se mexer em classificação
     IF (NEW.id_area_ti <> OLD.id_area_ti) OR
        (NEW.id_tipo    <> OLD.id_tipo)    THEN
        NEW.codigo  = security.fn_scy_gera_codigo_projetos(NEW.id_area_ti, NEW.id_tipo);
     END IF;
     
     -- Para Projetos Status 1 ou 2 ou 3 (Execucao Não iniciada)
     IF NEW.id_status < 4 THEN   -- +1 Inclui dia Inicial
        NEW.prazo_inicial = (NEW.data_fim_previsto - NEW.data_inicio_previsto) + 1;
        NEW.data_fim_previsto_atual = NEW.data_fim_previsto;
     END IF;
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN
     -- Verifica se Manutenção pode ser excluida
     IF OLD.id_status<>1 THEN -- 1-Aguardando Concepção
        RAISE EXCEPTION 'Projeto [%] Não Pode ser Excluido! Pois já foi apresentado Para Aprovação', OLD.sigla;
     END IF;
     -- verifica se já existe atividade associada
     SELECT count(atv.id)
     INTO   var_qtd_atividade
     FROM   security.atividades atv 
     WHERE  atv.id_projeto=OLD.id;
     
     var_qtd_atividade = COALESCE(var_qtd_atividade,0);
     
     IF var_qtd_atividade > 0 THEN
        RAISE EXCEPTION 'Projeto [%] Não Pode ser Excluido! Pois Existe Atividade associada ao projeto', OLD.sigla;
     END IF;   
     -- Antes de Excluir a Medição Exclui tabelas Filhas     
     DELETE FROM security.projetos_historicos  WHERE id_projeto=OLD.id;     
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_projetos
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_projetos
BEFORE INSERT OR UPDATE OR DELETE ON security.projetos
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_projetos();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela security.projetos
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger BEFORE da tabela security.manutencoes_sistema
-- =============================================================================
DROP TRIGGER tg_scy_tgb_manutencoes_sistema ON security.manutencoes_sistema;
DROP FUNCTION security.fn_scy_tgb_manutencoes_sistema();
DROP FUNCTION security.fn_scy_gera_codigo_manutencoes_sistema(var_id_modulo INTEGER);

-- -----------------------------------------------------------------------------
-- FUNÇÂO..: Gera código do Modulo
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_gera_codigo_manutencoes_sistema(var_id_modulo INTEGER)
RETURNS VARCHAR(6) AS
$body$
DECLARE
  cod_parte_fixa text;
  seq_manutencao text;
  codigo_gerado  text;
BEGIN
  
  -- pega codigo do Modulo
  SELECT mod.codigo_modulo
  INTO   cod_parte_fixa
  FROM   security.modulos mod
  WHERE  mod.id = var_id_modulo;
    
  -- Pega ultimo código da manutenção do Modulo e adiciona 1
  SELECT to_char(to_number(max(SUBSTRING(msi.codigo,4,3)),'000')+1,'000')
  INTO   seq_manutencao
  FROM   security.manutencoes_sistema msi 
  GROUP BY SUBSTRING(msi.codigo,1,3)
  HAVING   SUBSTRING(msi.codigo,1,3) = cod_parte_fixa;
     
  -- Se não existir manutenção gerada anteriormente para o modulo
  IF NOT FOUND THEN
    seq_manutencao = '001';
  END IF;
  -- gera novo código
  codigo_gerado = TRIM(cod_parte_fixa) || TRIM(seq_manutencao);
  RETURN codigo_gerado;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "manutencoes_sistema"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_manutencoes_sistema ()
RETURNS SETOF trigger AS
$body$
DECLARE
  var_qtd_atividade INTEGER;
BEGIN
  IF TG_OP = 'INSERT' THEN
     NEW.codigo  = security.fn_scy_gera_codigo_manutencoes_sistema(NEW.id_modulo);
     RETURN NEW;

  ELSEIF TG_OP = 'UPDATE' THEN
     -- nada definido por enquanto
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN
     -- Verifica se Manutenção pode ser excluida
     IF OLD.id_status<>1 THEN -- 1-A Iniciar
        RAISE EXCEPTION 'Manutenção Nr. [%] Não Pode ser Excluida! Pois já foi iniciada a execução', OLD.codigo;
     END IF;
     -- verifica se já existe atividade associada
     SELECT count(atv.id) INTO var_qtd_atividade
     FROM   security.atividades atv 
     WHERE  atv.id_manutencao_sistema=OLD.id;
     
     var_qtd_atividade = COALESCE(var_qtd_atividade,0);
     
     IF var_qtd_atividade > 0 THEN
        RAISE EXCEPTION 'Manutenção Nr. [%] Não Pode ser Excluida! Pois Existe Atividade associada a Manutenção', OLD.codigo;
     END IF;   
     -- Antes de Excluir a Medição Exclui tabelas Filhas     
     DELETE FROM security.manutencoes_sistema_historicos  WHERE id_manutencao=OLD.id;     
     RETURN OLD;

  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_manutencoes_sistema
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_manutencoes_sistema
BEFORE INSERT OR UPDATE OR DELETE ON security.manutencoes_sistema
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_manutencoes_sistema();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela security.manutencoes_sistema
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger AFTER da tabela security.manutencoes_sistema_paralisacoes
-- =============================================================================
DROP TRIGGER           tg_scy_tga_manutencoes_sistema_paralisacoes ON security.manutencoes_sistema_paralisacoes;
DROP FUNCTION security.fn_scy_tga_manutencoes_sistema_paralisacoes();

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "AFTER" da tabela "paralisacoes"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tga_manutencoes_sistema_paralisacoes()
RETURNS SETOF trigger AS
$body$
DECLARE
  var_dias_parado_anter INTEGER;
  var_dias_parado_atual INTEGER;
  var_id_ajuste_prazo   INTEGER;
  var_motivo_ajuste     text;
BEGIN  
  -- Processa ações de INCLUSÃO e ATUALIZAÇÂO
  -- -----------------------------------------
  IF TG_OP = 'INSERT'  THEN
     UPDATE security.manutencoes_sistema AS pro
        SET id_paralisacao  = NEW.id -- Id da ultima paralisacao registrada
      WHERE pro.id = NEW.id_manutencao;
   
     RETURN NEW;
     
  ELSEIF TG_OP = 'UPDATE'  THEN        
     -- Nada por enquanto
     RETURN NEW;
      
  ELSEIF TG_OP = 'DELETE'  THEN
     -- Nada por enquanto     
     RETURN OLD;
  END IF;  
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tga_manutencoes_sistema_paralisacoes
-- -----------------------------------------------------------------------------
CREATE TRIGGER                      tg_scy_tga_manutencoes_sistema_paralisacoes
AFTER INSERT OR UPDATE OR DELETE ON security.manutencoes_sistema_paralisacoes
FOR EACH ROW EXECUTE PROCEDURE      security.fn_scy_tga_manutencoes_sistema_paralisacoes();
-- =============================================================================
-- FIM: Trigger AFTER da tabela security.manutencoes_sistema_paralisacoes
-- =============================================================================

-- =============================================================================
-- INICIO: Controle de Profissional Por Tipo de Atividade
-- =============================================================================
CREATE SEQUENCE security.sq_projetos_x_profissionais_ti            INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE security.sq_manutencoes_sistema_x_profissionais_ti INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
      
CREATE TABLE security.projetos_x_profissionais_ti (
  id              INTEGER DEFAULT nextval('security.sq_projetos_x_profissionais_ti') NOT NULL,
  id_projeto      INTEGER NOT NULL,
  id_profissional INTEGER NOT NULL  
);
CREATE TABLE security.manutencoes_sistema_x_profissionais_ti (
  id              INTEGER DEFAULT nextval('security.sq_manutencoes_sistema_x_profissionais_ti') NOT NULL,
  id_manutencao   INTEGER NOT NULL,
  id_profissional INTEGER NOT NULL  
);

ALTER TABLE security.projetos_x_profissionais_ti            ADD CONSTRAINT pk_projetos_x_profissionais_ti            PRIMARY KEY (id);
ALTER TABLE security.manutencoes_sistema_x_profissionais_ti ADD CONSTRAINT pk_manutencoes_sistema_x_profissionais_ti PRIMARY KEY (id);
  
-- FOREIGN KEY´s da Tabela: 'projetos_x_profissionais_ti'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.projetos_x_profissionais_ti
  ADD CONSTRAINT fk_projeto      FOREIGN KEY (id_projeto) 
      REFERENCES security.projetos(id); 

ALTER TABLE ONLY security.projetos_x_profissionais_ti
  ADD CONSTRAINT fk_profissional FOREIGN KEY (id_profissional) 
      REFERENCES security.profissionais_ti(id); 

-- FOREIGN KEY´s da Tabela: 'manutencoes_sistema_x_profissionais_ti'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY security.manutencoes_sistema_x_profissionais_ti
  ADD CONSTRAINT fk_manutencao   FOREIGN KEY (id_manutencao) 
      REFERENCES security.manutencoes_sistema(id); 

ALTER TABLE ONLY security.manutencoes_sistema_x_profissionais_ti
  ADD CONSTRAINT fk_profissional FOREIGN KEY (id_profissional) 
      REFERENCES security.profissionais_ti(id); 
  
-- -----------------------------------------------------------------------------
-- FUNÇÃO: Atualiza Relação de profissionais por Projeto
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_atualiza_projetos_x_profissionais_ti (
  var_id_atividade    INTEGER,
  var_id_profissional INTEGER,
  var_id_projeto      INTEGER,
  var_acao            text
)
RETURNS void AS
$body$
DECLARE
  var_registros  integer;
BEGIN
  -- Se AÇÂO for EXCLUSAO de uma Profissional da Atividade
  IF var_acao = 'DELETE' THEN  
     -- Verifica se existe Atividade associada ao Profissional
     SELECT count(axp.id_atividade)
       INTO var_registros
       FROM security.atividades_x_profissionais_ti axp INNER JOIN
            security.atividades                    atv ON atv.id = axp.id_atividade
      WHERE atv.id_projeto     = var_id_projeto
        AND axp.id_profissional= var_id_profissional;                
     -- Se NÃO Existir Atividade para o Profissional exclui do Projeto
     var_registros = COALESCE(var_registros,0);
     IF var_registros = 0 THEN
        DELETE FROM security.projetos_x_profissionais_ti pxp
         WHERE pxp.id_profissional= var_id_profissional
           AND pxp.id_projeto     = var_id_projeto;
     END IF;     
  -- Se AÇÂO for INCLUSAO de uma profissional na tividade
  ELSE       
     -- Verifica se projeto já possui Profissioal associado
     SELECT count(pxp.id)
       INTO var_registros
       FROM security.projetos_x_profissionais_ti pxp
      WHERE pxp.id_profissional= var_id_profissional
        AND pxp.id_projeto     = var_id_projeto;  
     
     -- Se Profissional não estiver associado Inclui na relação do Projeto
     var_registros = COALESCE(var_registros,0);
     IF var_registros = 0 THEN
        INSERT INTO security.projetos_x_profissionais_ti (id_profissional, id_projeto) 
        VALUES (var_id_profissional, var_id_projeto);
     END IF;     
  END IF;
END;
$body$
LANGUAGE 'plpgsql'VOLATILE CALLED ON NULL INPUT
SECURITY INVOKER COST 100;

-- -----------------------------------------------------------------------------
-- FUNÇÃO: Atualiza Relação de profissionais por manutenção
-- -----------------------------------------------------------------------------    
CREATE OR REPLACE FUNCTION security.fn_scy_atualiza_manutencoes_sistema_x_profissionais_ti (
  var_id_atividade    INTEGER,
  var_id_profissional INTEGER,
  var_id_manutencao   INTEGER,
  var_acao            text
)
RETURNS void AS
$body$
DECLARE
  var_registros     integer;
BEGIN 
  -- Se AÇÂO for EXCLUSAO de uma Profissional da Atividade
  IF var_acao = 'DELETE' THEN  
     -- Verifica se existe Atividade associada ao Profissional
     SELECT count(axp.id)
       INTO var_registros
       FROM security.atividades_x_profissionais_ti axp INNER JOIN
            security.atividades                    atv ON atv.id = axp.id_atividade
      WHERE atv.id_manutencao_sistema= var_id_manutencao
        AND axp.id_profissional      = var_id_profissional;      
     -- Se NÃO Existir Atividade para o Profissional exclui da manutenção
     var_registros = COALESCE(var_registros,0);
     IF var_registros = 0 THEN
        DELETE FROM security.manutencoes_sistema_x_profissionais_ti pxp
         WHERE pxp.id_profissional = var_id_profissional
           AND pxp.id_manutencao   = var_id_manutencao;
     END IF;
     
  -- Se AÇÂO for INCLUSAO de uma profissional na tividade
  ELSE
     -- Verifica se Manutencao já possui profissional associada
     SELECT count(pxp.id)
       INTO var_registros
       FROM security.manutencoes_sistema_x_profissionais_ti pxp
      WHERE pxp.id_profissional= var_id_profissional
        AND pxp.id_manutencao  = var_id_manutencao;          
     -- Se Profissional não estiver associado Inclui na relação da Manautenção
     var_registros = COALESCE(var_registros,0);
     IF var_registros = 0 THEN
        INSERT INTO security.manutencoes_sistema_x_profissionais_ti (id_profissional, id_manutencao) 
        VALUES (var_id_profissional, var_id_manutencao);
     END IF;     
  END IF;
END;
$body$
LANGUAGE 'plpgsql'VOLATILE CALLED ON NULL INPUT
SECURITY INVOKER COST 100;

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "AFTER" da tabela "atividades_x_profissionais_ti"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tga_atividades_x_profissionais_ti()
RETURNS SETOF trigger AS
$body$
DECLARE
  var_id_atividade      integer;
  var_id_profissional   integer;
  var_id_tipo_atividade integer;
  var_id_projeto        integer;
  var_id_manutencao     integer;
BEGIN 
  -- Pega id da atividade e do Profissional
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN  
     var_id_atividade    = NEW.id_atividade;
     var_id_profissional = NEW.id_profissional;
  ELSE
     var_id_atividade    = OLD.id_atividade;
     var_id_profissional = OLD.id_profissional;
  END IF;
  
  -- Pega id do tipo de atividade, Projeto/ manutenção  
  SELECT atv.id_tipo_atividade, atv.id_projeto, atv.id_manutencao_sistema
    INTO var_id_tipo_atividade, var_id_projeto, var_id_manutencao
    FROM security.atividades atv
   WHERE atv.id = var_id_atividade; 
   
  IF TG_OP = 'INSERT' THEN
    CASE 
      WHEN var_id_tipo_atividade = 1 THEN -- 1=Projeto
        PERFORM security.fn_scy_atualiza_projetos_x_profissionais_ti(var_id_atividade, var_id_profissional,var_id_projeto,'INSERT'); 
      WHEN var_id_tipo_atividade = 2 THEN-- 2=Manutencao
        PERFORM security.fn_scy_atualiza_manutencoes_sistema_x_profissionais_ti(var_id_atividade, var_id_profissional,var_id_manutencao,'INSERT');
      WHEN var_id_tipo_atividade = 3 THEN -- 3=Diversa
        -- nada por enquanto
    END CASE;
  ELSEIF TG_OP = 'UPDATE' THEN
     -- nada definido por enquanto

  ELSEIF TG_OP = 'DELETE' THEN
    CASE 
      WHEN var_id_tipo_atividade = 1 THEN -- 1=Projeto
    	PERFORM security.fn_scy_atualiza_projetos_x_profissionais_ti(var_id_atividade, var_id_profissional,var_id_projeto,'DELETE');
      WHEN var_id_tipo_atividade = 2 THEN -- 2=Manutencao
        PERFORM security.fn_scy_atualiza_manutencoes_sistema_x_profissionais_ti(var_id_atividade, var_id_profissional,var_id_manutencao,'DELETE');
      WHEN var_id_tipo_atividade = 3 THEN -- 3=Diversa
        -- nada por enquanto
    END CASE;
  END IF;
  RETURN NULL;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 100 ROWS 1000;
-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tga_projetos_paralisacoes
-- -----------------------------------------------------------------------------
CREATE TRIGGER                      tg_scy_tga_atividades_x_profissionais_ti
AFTER INSERT OR UPDATE OR DELETE ON security.atividades_x_profissionais_ti
FOR EACH ROW EXECUTE PROCEDURE      security.fn_scy_tga_atividades_x_profissionais_ti();
-- =============================================================================
-- FIM: Controle de Profissional Por Tipo de Atividade
-- =============================================================================

-- =============================================================================
-- INICIO: FUNCOES para a tabela MANUTENCAO_SISTEMA
-- =============================================================================
CREATE OR REPLACE FUNCTION security.fn_scy_manutencao_em_execucao(var_id_manutencao integer)
RETURNS boolean AS
$body$
DECLARE
  var_id_status   INTEGER;
  var_em_execucao BOOLEAN;
BEGIN 
  -- Recupera Status do MANUTENCAO
  SELECT man.id_status          
    INTO var_id_status
    FROM security.manutencoes_sistema man
   WHERE man.id = var_id_manutencao;
  -- Verifica se está em execução
  var_em_execucao = false;       
  IF var_id_status = 2 THEN -- 2 - Em execução
     var_em_execucao = true;
  END IF;    
  RETURN var_em_execucao;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT
SECURITY INVOKER COST 100;
-- =============================================================================
-- FIM: FUNCOES para a tabela MANUTENCAO_SISTEMA
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger BEFORE da tabela security.manutencoes_sistema_paralisacoes
-- =============================================================================
DROP TRIGGER tg_scy_tgb_manutencoes_sistema_paralisacoes ON security.manutencoes_sistema_paralisacoes;
DROP FUNCTION security.fn_scy_tgb_manutencoes_sistema_paralisacoes();
-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "paralisacoes"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION security.fn_scy_tgb_manutencoes_sistema_paralisacoes()
RETURNS SETOF trigger AS
$body$
DECLARE
  var_data_inicio_real        DATE;
  var_id_paralisacao_anterior INTEGER;
BEGIN
  IF TG_OP = 'INSERT' THEN
     -- Só permite incluir Se Manutencao estiver com Status "Em execução"
     IF NOT security.fn_scy_manutencao_em_execucao(NEW.id_manutencao)  THEN        
        RAISE EXCEPTION 'Paralisação só pode ser realizado com Manutenção em Execução.';
     END IF;
     -- Só permite incluir Se Data Paralisação Maior Igual a Data Inicio Real da Manutenção
     SELECT man.data_inicio_real   
       INTO var_data_inicio_real
       FROM SECURITY.manutencoes_sistema man 
      WHERE man.id = NEW.id_manutencao;
       
     IF NEW.data_paralisacao < var_data_inicio_real THEN
        RAISE EXCEPTION 'Paralisação só pode ser realizado após Inicio da Manutenção!';     
     END IF;
  END IF;
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
     IF NEW.data_reinicio ISNULL  THEN
        NEW.dias_parado = NULL;
     ELSE
        IF NEW.data_reinicio < NEW.data_paralisacao THEN
           RAISE EXCEPTION 'Data Reinicio inferior a data Paralisação!';
	END IF;
        -- Calcula qtd dias parado entre paralização e reinicio
	NEW.dias_parado = NEW.data_reinicio - NEW.data_paralisacao;        
     END IF;    
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN
     -- Recupera ID paralisação anterior     
     SELECT max(msp.id)
       INTO var_id_paralisacao_anterior
       FROM security.manutencoes_sistema_paralisacoes msp
      WHERE msp.id_manutencao = OLD.id_manutencao
        AND msp.id <> OLD.id;
     -- Atualiza qtd de dias paraliado na tabela Obras
     UPDATE security.manutencoes_sistema AS man
        SET id_paralisacao = var_id_paralisacao_anterior
      WHERE man.id = OLD.id_manutencao;
     -- nada definido por enquanto
     RETURN OLD;
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
-- -----------------------------------------------------------------------------
-- TRIGGER: tg_scy_tgb_manutencoes_sistema_paralisacoes
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_scy_tgb_manutencoes_sistema_paralisacoes
BEFORE INSERT OR UPDATE OR DELETE ON security.manutencoes_sistema_paralisacoes
FOR EACH ROW EXECUTE PROCEDURE       security.fn_scy_tgb_manutencoes_sistema_paralisacoes();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela security.manutencoes_sistema_paralisacoes
-- =============================================================================

-- /////////////////////////////////////////////////////////////////////////////
--
-- ALTERAÇÕES FEITA NO SCRIPT APÓS  A CRIAÇÃO DO BANCO DE PRODUÇÃO
--
-- /////////////////////////////////////////////////////////////////////////////


