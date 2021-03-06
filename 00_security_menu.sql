-- =============================================================================
-- Script Para Criação dos Menus do Módulop Security
-- =============================================================================
-- Regras de acesso do Módulo Security
-- -----------------------------------------------------------------------------
INSERT INTO security.roles (id_role,id_tipo_regra,conditional,role_name,descricao) VALUES (211,3,FALSE,'GESTAO.SIGDER.TABELAS'    ,'Tabelas de Controle de Gestao dado SIGDER');
INSERT INTO security.roles (id_role,id_tipo_regra,conditional,role_name,descricao) VALUES (212,3,FALSE,'GESTAO.SIGDER.CADASTROS'  ,'Permite acessar rotinas de Cadastros Gerais');
INSERT INTO security.roles (id_role,id_tipo_regra,conditional,role_name,descricao) VALUES (213,3,FALSE,'GESTAO.SIGDER.ACESSOS'    ,'Permite atribuir os acessos a usuários do SIGDER');
INSERT INTO security.roles (id_role,id_tipo_regra,conditional,role_name,descricao) VALUES (214,3,FALSE,'GESTAO.SIGDER.CONSULTAS'  ,'Permite Consultar e Emitir relatórorios de informações da gestão SIGDER');
INSERT INTO security.roles (id_role,id_tipo_regra,conditional,role_name,descricao) VALUES (215,3,FALSE,'GESTAO.SIGDER.SISTEMA'    ,'Permite Acessar a rotina de controle de Dados do Sistema');
INSERT INTO security.roles (id_role,id_tipo_regra,conditional,role_name,descricao) VALUES (216,3,FALSE,'GESTAO.SIGDER.ATIVIDADES' ,'Permite Acessar a rotina de controle de Atividades');
INSERT INTO security.roles (id_role,id_tipo_regra,conditional,role_name,descricao) VALUES (217,3,FALSE,'GESTAO.SIGDER.REUNIOES'   ,'Permite Acessar a rotina de controle de Reuniões');
INSERT INTO security.roles (id_role,id_tipo_regra,conditional,role_name,descricao) VALUES (218,3,FALSE,'GESTAO.SIGDER.PROJETOS'   ,'Permite Acessar a rotina de controle de Projetos');
INSERT INTO security.roles (id_role,id_tipo_regra,conditional,role_name,descricao) VALUES (219,3,FALSE,'GESTAO.SIGDER.COORDENADOR','Permite Acessar a rotina por usuário da Coordenacao da GETIC');

-- Insert do Modulo Security
-- -----------------------------------------------------------------------------
INSERT INTO security.modulos (id, codigo_modulo, data_inicio, data_fim, 
  id_status, id_area, ordem_menu, id_fase, id_modulo_pai, sigla, nome,  descricao) 
VALUES
  (1, 401, '14/6/2012', null, 1, 4, 1, 4, NULL, 'GESTAO_TI', 'Gestão de TI da GETIC',
   'Modulo para controles das Iniciativas da TI no DER.');

-- -----------------------------------------------------------------------------
-- INICIO: Menu do Módulo: S E C U R I T Y
-- -----------------------------------------------------------------------------
-- Menor Id : 1000
-- Maior Id : 1499
DELETE FROM security.roles_x_elementos_modulo rxe WHERE rxe.id_elemento>=1000 and rxe.id_elemento <=1499;
DELETE FROM security.elementos_modulo         emo WHERE emo.id>=1000          and emo.id <=1499;

-- -----------------------------------------------------------------------------
-- Insert dos ELEMENTOS do Modulo SECURITY
-- -----------------------------------------------------------------------------

-- MENU: Tabelas Classificação (GESTAO.SIGDER.TABELAS)  
-- Menor Id : 1000 - Maior Id : 1089
-- -----------------------------------------------------------------------------
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1000, 1, '001'      , 1, 1, 'mngGestaoTiTabelas'                                             , 'Tabelas Classificação'                , 'Exibir o Grupo de Menu: Tabelas Classificação');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1001, 1, '001001'   , 1, 2, '/gestaoTi/profissionalTi/listarAreaTi.jsf'                      , 'Área da TI'                           , 'Mostrar a Tabela: Área da TI');
-- SUB-MENU: Tabelas Classificação: Sistemas (GESTAO.SIGDER.TABELAS)
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1010, 1, '001002'   , 1, 1, 'mngGestaoTiTabelasSistema'                                      , 'Classificação Sistema'                , 'Exibir o Grupo de Menu: Tabela de Classificação do sistema');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1011, 1, '001002001', 1, 2, '/gestaoTi/sistema/tabelas/listarAreaAtuacao.jsf'                , 'Área de Atuação do Módulo'            , 'Mostrar a Tabela: Area de atuação do módulo');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1012, 1, '001002002', 1, 2, '/gestaoTi/sistema/tabelas/listarFaseDesenvolvimento.jsf'        , 'Fase Desenvolvimento do Módulo'       , 'Mostrar a Tabela: Fase Desenvolvimento do Módulo');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1013, 1, '001002003', 1, 2, '/gestaoTi/sistema/tabelas/listarTipoElemento.jsf'               , 'Tipo de Elemento do Módulo'           , 'Mostrar a Tabela: Tipo elemento do modulo');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1014, 1, '001002004', 1, 2, '/gestaoTi/sistema/tabelas/listarStatusAcesso.jsf'               , 'Status Acesso'                        , 'Mostrar a Tabela: Status Acesso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1015, 1, '001002005', 1, 2, '/gestaoTi/sistema/tabelas/listarStatusVersaoModulo.jsf'         , 'Status Vesão Módulo'                  , 'Mostrar a Tabela: Status Vesão Módulo');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1016, 1, '001002006', 1, 2, '/gestaoTi/sistema/tabelas/listarTipoRegraAcesso.jsf'            , 'Tipo Regra Acesso'                    , 'Mostrar a Tabela: Tipo Regra Acesso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1017, 1, '001002007', 1, 2, '/gestaoTi/sistema/tabelas/listarAgenteSistema.jsf'              , 'Agentes do Sistema'                   , 'Mostrar a Tabela: Agentes do Sistema');
-- SUB-MENU: Tabelas Classificação: Usuarios (GESTAO.SIGDER.TABELAS)
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1020, 1, '001003'   , 1, 1, 'mngGestaoTiTabelasUsuarios'                                     , 'Classificação Usuário'                , 'Exibir o Grupo de Menu: Tabelas de Classificação dos Usuário');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1021, 1, '001003001', 1, 2, '/gestaoTi/usuario/listarTipoSkin.jsf'                           , 'Tipo de Skin'                         , 'Mostrar a Tabela: Tipo de SKIN');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1022, 1, '001003002', 1, 2, '/gestaoTi/usuario/listarTipoMenu.jsf'                           , 'Tipo de Menu'                         , 'Mostrar a Tabela: Tipo de Menu');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1023, 1, '001003003', 1, 2, '/gestaoTi/usuario/listarTipoUsuario.jsf'                        , 'Tipo de Usuário'                      , 'Mostrar a Tabela: Tipo de Usuário');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1024, 1, '001003004', 1, 2, '/gestaoTi/usuario/listarTipoHistoricoUsuario.jsf'               , 'Tipo Histórico Usuário'               , 'Mostrar a Tabela: Tipo Histórico Usuário');
-- SUB-MENU: Tabelas Classificação: Caso de Uso (GESTAO.SIGDER.TABELAS)
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1030, 1, '001004'   , 1, 1, 'mngGestaoTiTabelasCasosDeUso'                                   , 'Classificação Caso de uso'            , 'Exibir o Grupo de Menu: Tabelas de Classificação dos Caso de Uso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1031, 1, '001004001', 1, 2, '/gestaoTi/desenv/casoDeUso/listarCduEscopo.jsf'                 , 'Escopo do Caso de Uso'                , 'Mostrar a Tabela: Escopo do Caso de Uso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1032, 1, '001004002', 1, 2, '/gestaoTi/desenv/casoDeUso/listarCduEsforco.jsf'                , 'Esforço Desenvolvimento'              , 'Mostrar a Tabela: Esforço Desenvolvimento do Caso de Uso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1033, 1, '001004003', 1, 2, '/gestaoTi/desenv/casoDeUso/listarCduNivel.jsf'                  , 'Nível Organizacional'                 , 'Mostrar a Tabela: Nível Organizacional do Caso de Uso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1034, 1, '001004004', 1, 2, '/gestaoTi/desenv/manutencao/listarTipoManutencaoSistema.jsf'    , 'Tipo de Manutenção'                   , 'Mostrar a Tabela: Tipo de Manutenção de Sistema');
-- SUB-MENU: Tabelas Classificação: Projetos (GESTAO.SIGDER.TABELAS)
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1040, 1, '001005'   , 1, 1, 'mngGestaoTiTabelasProjetos'                                     , 'Classificação Projeto'                , 'Exibir o Grupo de Menu: Tabelas de Classificação Projetos');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1041, 1, '001005001', 1, 2, '/gestaoTi/gerencia/projeto/listarStatusProjeto.jsf'             , 'Status do Projeto'                    , 'Mostrar a Tabela: Status do Projeto');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1042, 1, '001005002', 1, 2, '/gestaoTi/gerencia/projeto/listarTipoProjeto.jsf'               , 'Tipo de Projeto'                      , 'Mostrar a Tabela: Tipo de Projeto');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1043, 1, '001005003', 1, 2, '/gestaoTi/gerencia/projeto/listarTipoHistoricoProjeto.jsf'      , 'Tipo de Histórico'                    , 'Mostrar a Tabela: Tipo de Histórico do Projeto');
-- SUB-MENU: Tabelas Classificação: Atividades (GESTAO.SIGDER.TABELAS)
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1050, 1, '001006'   , 1, 1, 'mngGestaoTiTabelasAtividades'                                   , 'Classificação Atividades'             , 'Exibir o Grupo de Menu: Tabelas de Classificação Atividdes');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1051, 1, '001006001', 1, 2, '/gestaoTi/gerencia/atividade/listarStatusAtividade.jsf'         , 'Status da Atividade'                  , 'Mostrar a Tabela: Status da Atividade');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1052, 1, '001006002', 1, 2, '/gestaoTi/gerencia/atividade/listarTipoAtividade.jsf'           , 'Tipo de Atividade'                    , 'Mostrar a Tabela: Tipo de Atividade');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1053, 1, '001006003', 1, 2, '/gestaoTi/gerencia/atividade/listarTipoHistoricoAtividade.jsf'  , 'Tipo de Histórico'                    , 'Mostrar a Tabela: Tipo de Histórico da Atividade');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1054, 1, '001006004', 1, 2, '/gestaoTi/gerencia/atividade/listarTipoAcompanhamentoAtividade.jsf', 'Tipo de Acompanhamento Atividade'  , 'Mostrar a Tabela: Tipo de Acompanhamento da Atividade');
-- SUB-MENU: Tabelas Classificação: Reuniões (GESTAO.SIGDER.TABELAS)
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1060, 1, '001007'   , 1, 1, 'mngGestaoTiTabelasReunioes'                                     , 'Classificação Reunião'                , 'Exibir o Grupo de Menu: Tabelas de Classificação de Reuniões');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1061, 1, '001007001', 1, 2, '/gestaoTi/gerencia/reuniao/listarStatusReuniao.jsf'             , 'Status da Reunião'                    , 'Mostrar a Tabela: Status da Reunião');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1062, 1, '001007002', 1, 2, '/gestaoTi/gerencia/reuniao/listarTipoReuniao.jsf'               , 'Tipo de Reunião'                      , 'Mostrar a Tabela: Tipo de Reunião');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1063, 1, '001007003', 1, 2, '/gestaoTi/gerencia/reuniao/listarTipoHistoricoReuniao.jsf'      , 'Tipo de Histórico'                    , 'Mostrar a Tabela: Tipo de Histórico da Reunião');

-- MENU: Tabelas: Profissionais de TI (GESTAO.SIGDER.CADASTROS)  
-- Menor Id : 1090 - Maior Id : 1099
-- -----------------------------------------------------------------------------
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1090, 1, '002'      , 1, 1, 'mngGestaoTiProfissionaisTi'                                     , 'Profissionais de TI'                  , 'Exibir o Grupo de Menu: Profissionais de TI');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1091, 1, '002001'   , 1, 2, '/gestaoTi/profissionalTi/manterProfissionalTi.jsf'              , 'Manter Profissionais TI'              , 'Permitir cadastrar (incluir/alterar/excluir) dados dos Profissionais TI');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1093, 1, '002003'   , 1, 2, '/gestaoTi/profissionalTi/consultarRelacaoProfissionaisTi.jsf'   , 'Consultar Relação de Profissionais TI', 'Permitir consultar uma relação dos Profissionais de TI cadastrados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1094, 1, '002004'   , 1, 2, '/gestaoTi/profissionalTi/emitirFichaProfissionalTi.jsf'         , 'Emitir Ficha do Profissional TI'      , 'Permitir emitir a ficha de cadastro de um Profissional TI');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1095, 1, '002005'   , 1, 2, '/gestaoTi/profissionalTi/emitirRelacaoProfissionaisTi.jsf'      , 'Emitir Relação de Profissionais TI'   , 'Permitir emitir uma relação de Profissionais TI');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1096, 1, '002006'   , 1, 2, '/gestaoTi/profissionalTi/exportarDadosProfissionaisTi.jsf'      , 'Exportar Dados dos Profissionais TI'  , 'Permitir exportar dados dos Profissionais de TI Cadastrados');

-- MENU: Gestão Sistemas (GESTAO.SIGDER.SISTEMA)
-- Menor Id : 1100 - Maior Id : 1139
-- -----------------------------------------------------------------------------
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1100, 1, '003'      , 1, 1, 'mngGestaoTiSistema'                                             , 'Dados do Sistema'                    , 'Exibir o Grupo de Menu: Dados do Sistema');
-- SUB-MENU: Gestão Sistemas: Módulos (GESTAO.SIGDER.SISTEMA)
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1110, 1, '003001'   , 1, 1, 'mngGestaoTiSistemaModulos'                                      , 'Módulos do Sistema'                  , 'Exibir o Grupo de Menu: Módulos do Sistema');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1111, 1, '003001001', 1, 2, '/gestaoTi/sistema/modulo/manterModulo.jsf'                      , 'Manter Módulos'                      , 'Permitir cadastrar (incluir/alterar/excluir) dados dos Modulos do sistema');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1113, 1, '003001003', 1, 2, '/gestaoTi/sistema/modulo/consultarRelacaoModulos.jsf'           , 'Consultar Relação de Módulos'        , 'Permitir consultar uma relação dos Módulos cadastrados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1114, 1, '003001004', 1, 2, '/gestaoTi/sistema/modulo/emitirFichaModulo.jsf'                 , 'Emitir Ficha do Módulo'              , 'Permitir emitir a ficha com dados de um Módulo cadastrado');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1115, 1, '003001005', 1, 2, '/gestaoTi/sistema/modulo/emitirRelacaoModulos.jsf'              , 'Emitir Relação de Módulos'           , 'Permitir emitir uma relação de Módulos cadastrados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1116, 1, '003001006', 1, 2, '/gestaoTi/sistema/modulo/exportarDadosModulos.jsf'              , 'Exportar Dados dos Módulos'          , 'Permitir exportar dados de Módulos cadastrdos');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1117, 1, '003001007', 1, 2, '/gestaoTi/sistema/modulo/emitirSituacaoModulos.jsf'             , 'Emitir Situação dos Módulos'         , 'Permitir emitir a situação dos Módulos cadastrados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1118, 1, '003001008', 1, 2, '/gestaoTi/sistema/modulo/consultarRotinasModulo.jsf'            , 'Consultar Rotinas do Módulo'         , 'Permitir consultar relação de rotinas dos Módulos cadastrados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1119, 1, '003001009', 1, 2, '/gestaoTi/sistema/modulo/emitirRotinasModulo.jsf'               , 'Emitir Rotinas do Módulo'            , 'Permitir emitir relação de rotinas dos Módulos cadastrados');

-- SUB-MENU: Gestão Sistemas: Elementos Módulos (GESTAO.SIGDER.SISTEMA)
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1120, 1, '003002'   , 1, 1, 'mngGestaoTiSistemaElementosModulo'                              , 'Elementos dos Módulos'               , 'Exibir o Grupo de Menu: Elementos do Módulos');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1121, 1, '003002001', 1, 2, '/gestaoTi/sistema/elemento/manterElementoModulo.jsf'            , 'Manter Elementos'                    , 'Permitir cadastrar (incluir/alterar/excluir) dados dos Elementos dos Módulos do sistema');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1123, 1, '003002003', 1, 2, '/gestaoTi/sistema/elemento/consultarRelacaoElementosModulo.jsf' , 'Consultar Relacao dos Elementos'     , 'Permitir consultar uma relação dos Elementos cadastrados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1124, 1, '003002004', 1, 2, '/gestaoTi/sistema/elemento/emitirFichaElementoModulo.jsf'       , 'Emitir Ficha do Elemento'            , 'Permitir emitir a ficha com dados de um Elemento cadastrado');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1125, 1, '003002005', 1, 2, '/gestaoTi/sistema/elemento/emitirRelacaoElementoModulo.jsf'     , 'Emitir Relação dos Elementos'        , 'Permitir emitir uma relação de Elementos Cadastrados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1126, 1, '003002006', 1, 2, '/gestaoTi/sistema/eleento/exportarDadosElementos.jsf'           , 'Exportar Dados dos Elementos'        , 'Permitir exportar dados de Elementos Cadastrados');
-- SUB-MENU: Gestão Sistemas: Regras de Acesso (GESTAO.SIGDER.SISTEMA)
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1130, 1, '003003'   , 1, 1, 'mngGestaoTiSistemaRegras'                                       , 'Regras de Acesso'                    , 'Exibir o Grupo de Menu: Regras de Acesso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1131, 1, '003003001', 1, 2, '/gestaoTi/sistema/regra/manterRegra.jsf'                        , 'Manter Regras'                       , 'Permitir cadastrar (incluir/alterar/excluir) dados das Regras de Acesso do sistema');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1133, 1, '003003003', 1, 2, '/gestaoTi/sistema/regra/consultarRelacaoRegras.jsf'             , 'Consultar Relação de Regras'         , 'Permitir consultar uma relação das Regra de acesso cadastradas');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1134, 1, '003003004', 1, 2, '/gestaoTi/sistema/regra/emitirFichaRegra.jsf'                   , 'Emitir Ficha da Regra'               , 'Permitir emitir a ficha de uma Regra de acesso cadastrada');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1135, 1, '003003005', 1, 2, '/gestaoTi/sistema/regra/emitirRelacaoRegras.jsf'                , 'Emitir Relação de Regras'            , 'Permitir emitir uma relação de Regras cadastradas');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1136, 1, '003003006', 1, 2, '/gestaoTi/sistema/regra/exportarDadosRegras.jsf'                , 'Exportar Dados das Regras'           , 'Permitir exportar dados de Regras de Acesso cadastradas');

-- MENU: Usuários (GESTAO.SIGDER.CADASTROS)
-- Menor Id : 1140 - Maior Id : 1149
-- -----------------------------------------------------------------------------
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1140, 1, '004'      , 1, 1, 'mngGestaoTiUsuarios'                                            , 'Usuários do Sistema'                 , 'Exibir o Grupo de Menu: Usuários do sistema');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1141, 1, '004001'   , 1, 2, '/gestaoTi/usuario/manterUsuario.jsf'                            , 'Manter Usuários'                     , 'Permitir cadastrar (incluir/alterar/excluir) dados dos Usuários do sistema');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1143, 1, '004003'   , 1, 2, '/gestaoTi/usuario/consultarRelacaoUsuarios.jsf'                 , 'Consultar Relação de Usuários'       , 'Permitir consultar uma relação dos Usuários cadastrados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1144, 1, '004004'   , 1, 2, '/gestaoTi/usuario/emitirFichaUsuario.jsf'                       , 'Emitir Ficha de Usuário'             , 'Permitir emitir a ficha com dados de um Usuário cadastrado');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1145, 1, '004005'   , 1, 2, '/gestaoTi/usuario/emitirRelacaoUsuarios.jsf'                    , 'Emitir Relação de Usuários'          , 'Permitir emitir uma relação de Usuários cadastrados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1146, 1, '004006'   , 1, 2, '/gestaoTi/usuario/exportarDadosUsuarios.jsf'                    , 'Exportar Dados dos Usuários'         , 'Permitir exportar dados de Usuários cadastrados');

-- MENU: Ativar/Desativar Acessos (GESTAO.SIGDER.ACESSOS)
-- Menor Id : 1150 - Maior Id : 1199
-- -----------------------------------------------------------------------------
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1150, 1, '005'      , 1, 1, 'mngGestaoTiAtivarDesativarAcessos'                              , 'Ativar/Desativar Acessos'            , 'Exibir o Grupo de Menu: Ativar/Desativar Acessos');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1151, 1, '005001'   , 1, 2, '/gestaoTi/acesso/ativarAcessosUsuario.jsf'                      , 'Usuários'                            , 'Permitir ativar/desativar cesso de um Usuário');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1152, 1, '...'      , 1, 2, '/gestaoTi/acesso/ativarAcessosUsuarioXRegras.jsf'               , 'Regras de um Usuário'                , 'Permitir incluir-ativar/desativar acesso das regras de um Usuário');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1153, 1, '005002'   , 1, 2, '/gestaoTi/acesso/ativarAcessosRegra.jsf'                        , 'Regras'                              , 'Permitir aaivar/desativar acesso de uma Regra');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1154, 1, '...'      , 1, 2, '/gestaoTi/acesso/ativarAcessosRegraXUsuarios.jsf'               , 'Usuários de uma Regra'               , 'Permitir incluir-ativar/desativar acesso aos usuários de uma Regra');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1155, 1, '...'      , 1, 2, '/gestaoTi/acesso/ativarAcessosRegraXElementos.jsf'              , 'Elementos de uma Regra'              , 'Permitir incluir-ativar/desativar acesso aos elemento de módulo de uma Regra');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1156, 1, '005003'   , 1, 2, '/gestaoTi/acesso/ativarAcessosElemento.jsf'                     , 'Elementos de Módulo'                 , 'Permitir ativar/desativar acesso de um Elemento de Módulo');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1157, 1, '...'      , 1, 2, '/gestaoTi/acesso/ativarAcessosElementoXRegras.jsf'              , 'Regras de um Elemento'               , 'Permitir incluir-ativar/desativar acesso das regras de um Elemento de Módulo');

-- MENU: Gerência (GESTAO.SIGDER.PROJETOS) - (GESTAO.SIGDER.REUNIOES) - (GESTAO.SIGDER.ATIVIDADES)
-- Menor Id : 1200 - Maior Id : 1299
-- -----------------------------------------------------------------------------
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1200, 1, '006'      , 1, 1, 'mngGestaoTiGerencia'                                            , 'Gerência'                            , 'Exibir o Grupo de Menu: Gerencia');
-- SUB-MENU: Gerência: Controle de Reuniões (GESTAO.SIGDER.REUNIOES)
-- Menor Id : 1210 - Maior Id : 1239
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1210, 1, '006001'   , 1, 1, 'mngGestaoTiGerenciaReunioes'                                    , 'Controle de Reuniões'                , 'Exibir o Grupo de Menu: Controle de Reuniões');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1211, 1, '006001001', 1, 2, '/gestaoTi/gerencia/reuniao/incluirReuniaoSemAgendamento.jsf'    , 'Incluir Reunião Sem Agendamento'     , 'Permitir incluir uma nova Reunião na base de dados com Status Aguardando Agendamento');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1212, 1, '006001002', 1, 2, '/gestaoTi/gerencia/reuniao/incluirReuniaoComAgendamento.jsf'    , 'Incluir Reunião Com Agendamento'     , 'Permitir incluir uma nova Reunião na base de dados com Status Agendada');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1213, 1, '006001003', 1, 2, '/gestaoTi/gerencia/reuniao/incluirReuniaoRealizada.jsf'         , 'Incluir Reunião Realizada'           , 'Permitir incluir uma nova Reunião na base de dados com Status ""Realizada""');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1214, 1, '006001004', 1, 2, '/gestaoTi/gerencia/reuniao/registrarAgendamentoReuniao.jsf'     , 'Registrar Agendamento de Reuniões'   , 'Permitir registrar agendamento de Reuniões com Status ""Aguardando Agendamento');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1215, 1, '006001005', 1, 2, '/gestaoTi/gerencia/reuniao/registrarReAgendamentoReuniao.jsf'   , 'Registrar Re-Agendamento de Reuniões', 'Permitir registrar re-agendamento de Reuniões com Status Agendada');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1216, 1, '006001006', 1, 2, '/gestaoTi/gerencia/reuniao/registrarRealizacaoReuniao.jsf'      , 'Registrar Realização de Reuniões'    , 'Permitir registrar realização de Reuniões com Status Agendada');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1217, 1, '006001007', 1, 2, '/gestaoTi/gerencia/reuniao/registrarCancelamentoReuniao.jsf'    , 'Registrar Cancelamento de Reuniões'  , 'Permitir registrar cancelamento de Reuniões com Status Agendada e Aguardando Agendamento');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1218, 1, '006001008', 1, 2, '/gestaoTi/gerencia/reuniao/consultarReunioes.jsf'               , 'Consultar Reuniões Cadastradas'      , 'Permitir consultar Reuniões cadastradas');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1219, 1, '006001009', 1, 2, '/gestaoTi/gerencia/reuniao/emitirRelacaoReunioes.jsf'           , 'Emitir Relação de Reuniões'          , 'Permitir emitir relação de Reuniões cadastradas');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1220, 1, '006001010', 1, 2, '/gestaoTi/gerencia/reuniao/emitirAtaReuniao.jsf'                , 'Emitir ATA da Reunião'               , 'Permitir emitir a ATA de uma reunião já realizada');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1221, 1, '006001011', 1, 2, '/gestaoTi/gerencia/reuniao/emitirListaParticipantesReuniao.jsf' , 'Emitir Lista de Participantes'       , 'Permitir emitir uma lista com os participantes da reunião');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1222, 1, '006001012', 1, 2, '/gestaoTi/gerencia/reuniao/emitirFichaReuniao.jsf'              , 'Emitir Ficha da Reunião'             , 'Permitir emitir a Ficha de uma Reunião cadastrada');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1223, 1, '006001013', 1, 2, '/gestaoTi/gerencia/reuniao/registrarRelatoAcaoReuniao.jsf'      , 'Registrar Relato/Ação'               , 'Permitir consultar Reuniões cadastradas para registrar relato e ação');
-- SUB-MENU: Gerência: Controle de Projetos (GESTAO.SIGDER.PROJETOS)
-- Menor Id : 1240 - Maior Id : 1259
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1240, 1, '006002'   , 1, 1, 'mngGestaoTiGerenciaProjetos'                                    , 'Controle de Projetos'                , 'Exibir o Grupo de Menu: Controle de Projetos');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1241, 1, '006002001', 1, 2, '/gestaoTi/gerencia/projeto/incluirProjeto.jsf'                  , 'Incluir Projetos'                    , 'Permitir incluir um novo Projeto na base de dados com Status Aguardando Concepção');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1242, 1, '...'      , 1, 2, '/gestaoTi/gerencia/projeto/editarAtividadesProjeto.jsf'         , 'Editar Atividades do Projeto'        , 'Permitir registrar e manter atividades relacionadas a projetos da GETIC');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1243, 1, '006002002', 1, 2, '/gestaoTi/gerencia/projeto/registrarConcepcaoProjeto.jsf'       , 'Registrar Concepção do Projeto'      , 'Permitir registrar informações da Concepção de Projetos com status Aguardando Concepção');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1244, 1, '006002003', 1, 2, '/gestaoTi/gerencia/projeto/registrarAprovacaoProjeto.jsf'       , 'Registrar Aprovação Projeto'         , 'Permitir registrar a aprovação de Projetos com Status: Aguardando Aprovação');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1245, 1, '006002004', 1, 2, '/gestaoTi/gerencia/projeto/registrarInicioProjeto.jsf'          , 'Registrar Início do Projeto'         , 'Permitir registrar o inicio de Projetos com Status: Aguardando Iniciar');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1246, 1, '006002005', 1, 2, '/gestaoTi/gerencia/projeto/registrarAcompanhamentoProjeto.jsf'  , 'Registrar Acompanhamento do Projeto' , 'Permitir registrar informações de acompanhamento de projetos com Status: Em Execucao');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1247, 1, '006002006', 1, 2, '/gestaoTi/gerencia/projeto/registrarReinicioProjeto.jsf'        , 'Registrar Reinício do Projeto'       , 'Permitir registrar o reinicio da execução de projetos com Status: Paralisado');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1248, 1, '006002007', 1, 2, '/gestaoTi/gerencia/projeto/registrarCancelamentoProjeto.jsf'    , 'Registrar Cancelamento do Projeto'   , 'Permitir registrar cancelamento de projetos cadastrados e ainda não concluidos');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1249, 1, '006002009', 1, 2, '/gestaoTi/gerencia/projeto/consultarProjetosCadastrados.jsf'    , 'Consultar Projetos Cadastrados'      , 'Permitir consultar os projetos cadastrados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1250, 1, '006002010', 1, 2, '/gestaoTi/gerencia/projeto/emitirFichaProjeto.jsf'              , 'Emitir Ficha do Projeto'             , 'Permitir emitir a Ficha de um Projeto cadastrado');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1251, 1, '006002011', 1, 2, '/gestaoTi/gerencia/projeto/emitirRelacaoProjetosCadastrados.jsf', 'Emitir Relação de Projetos'          , 'Permitir emitir uma relação de Projetos cadastrados conforme parametros informados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1252, 1, '006002012', 1, 2, '/gestaoTi/gerencia/projeto/emitirMapaAnualProjetos.jsf'         , 'Emitir Mapa Anual dos Projetos'      , 'Permitir emitir um Mapa Anual com a relação de projetos no ano Vigente');
-- SUB-MENU: Gerência: Controle de Atividades Avulsa (GESTAO.SIGDER.ATIVIDADES)
-- Menor Id : 1260 - Maior Id : 1269
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1260, 1, '006003'   , 1, 1, 'mngGestaoTiGerenciaAtividadesAvulsas'                           ,'Controle de Atividades Avulsas'      ,'Exibir o Grupo de Menu: Controle de Atividades Avulsas.');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1261, 1, '006003001', 1, 2, '/gestaoTi/gerencia/atividade/incluirAtividadeAvulsa.jsf'        ,'Manter Atividade Avulsa'             ,'Permitir manter uma ativiadde avulsa.');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1262, 1, '006003002', 1, 2, '/gestaoTi/gerencia/atividade/consultarAtividadeAvulsa.jsf'      ,'Consultar Atividades Avulsas'        ,'Exibe uma Lista de atividades avulsas.');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1263, 1, '006003003', 1, 2, '/gestaoTi/gerencia/atividade/emitirFichaAtividadeAvulsa.jsf'    ,'Emitir Ficha Atividade Avulsa'       ,'Permitir emitir a Ficha da Atividade Avulsa Cadastrada.');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1264, 1, '006003004', 1, 2, '/gestaoTi/gerencia/atividade/emitirRelacaoAtividadeAvulsa.jsf'  ,'Emitir Relação de Atividades Avulsas','Permitir emitir a Lista de Atividades Avulsas Cadastradas.');
-- SUB-MENU: Gerência: Acompanhamento de Atividades (GESTAO.SIGDER.ATIVIDADES)
-- Menor Id : 1270 - Maior Id : 1279
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1270, 1, '006004'   , 1, 1, 'mngGestaoTiGerenciaACompanhamentos'                                  , 'Acompanhamentos Atividades'     , 'Exibir o Grupo de Menu: Acompanhamentos Atividades');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1271, 1, '006004001', 1, 2, '/gestaoTi/gerencia/atividade/consultarAtividadesQuadroKanban.jsf'    , 'Consultar Quadro Kanban'        , 'Exibe uma Lista de atividades nos molde de um quadro Kanban');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1272, 1, '006004002', 1, 2, '/gestaoTi/gerencia/atividade/emitirRelacaoAtividadesQuadroKanban.jsf', 'Emitir Quadro Kanban'           , 'Permitir Emitir uma Lista de atividades nos molde de um quadro Kanban');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1273, 1, '006004003', 1, 2, '/gestaoTi/gerencia/atividade/consultarListaParalisacoes.jsf'         , 'Consultar Lista Paralisacoes'   , 'Exibe uma Lista de Paralisações de (Projeto / Manutenções / Atividades)');

-- MENU: Desenvolvimento (GESTAO.SIGDER.SISTEMA)
-- Menor Id : 1300 - Maior Id : 1499
-- -----------------------------------------------------------------------------
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1300, 1, '007'      , 1, 1, 'mngGestaoTiDesenv'                                              , 'Desenvolvimento'                     , 'Exibir o Grupo de Menu: Desenvolvimento');
-- MENU: Desenvolvimento: Controle de Caso de Uso (GESTAO.SIGDER.SISTEMA)
-- Menor Id : 1310 - Maior Id : 1319
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1310, 1, '007001'   , 1, 1, 'mngGestaoTiDesenvCasoDeUso'                                     , 'Casos de Uso'                        , 'Exibir o Grupo de Menu: Casos de uso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1311, 1, '007001001', 1, 2, '/gestaoTi/desenv/casoDeUso/manterCasoDeUso.jsf'                 , 'Manter Casos de Uso'                 , 'Permitir cadastrar (incluir/alterar/excluir) dados dos Casos de Uso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1312, 1, '007001002', 1, 2, '/gestaoTi/desenv/casoDeUso/consultarDadosCasoDeUso.jsf'         , 'Consultar Dados do Caso de Uso'      , 'Permitir consultar dados de um Profissional de TI cadastrado');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1313, 1, '007001003', 1, 2, '/gestaoTi/desenv/casoDeUso/consultarRelacaoCasosDeUso.jsf'      , 'Consultar Relação de Casos de Uso'   , 'Permitir consultar uma relação dos Profissionais de TI cadastrados');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1314, 1, '007001004', 1, 2, '/gestaoTi/desenv/casoDeUso/emitirFichaCasoDeUso.jsf'            , 'Emitir Ficha do Caso de Uso'         , 'Permitir emitir a ficha de cadastro de um Caso de Uso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1315, 1, '007001005', 1, 2, '/gestaoTi/desenv/casoDeUso/emitirRelacaoCasosDeUso.jsf'         , 'Emitir Relação de Caso de Uso'       , 'Permitir emitir uma relação de Casos de Uso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1316, 1, '007001006', 1, 2, '/gestaoTi/desenv/casoDeUso/exportarDadosCasosDeUso.jsf'         , 'Exportar Dados dos Casos de Uso'     , 'Permitir exportar dados dos Profissionais de TI Cadastrados');
-- MENU: Desenvolvimento: Controle de Manutenção (GESTAO.SIGDER.SISTEMA)
-- Menor Id : 1320 - Maior Id : 1329
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1320, 1, '007002'   , 1, 1, 'mngGestaoTiDesenvManutencao'                                      , 'Controle de Manutenção'              , 'Exibir o Grupo de Menu: Controle de manutenções dos módulos');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1321, 1, '007002001', 1, 2, '/gestaoTi/desenv/manutencao/incluirManutencaoSistema.jsf'         , 'Incluir Manutenção Sistema'          , 'Permitir incluir uma nova maanutenção de Sistema com Status A Iniciar');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1322, 1, '...'      , 1, 2, '/gestaoTi/desenv/manutencao/editarAtividadesManutencao.jsf'       , 'Editar Atividades de Manutenção'     , 'Permitir a edição das atividades relacionadas a Manutenção de sistema');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1323, 1, '007002002', 1, 2, '/gestaoTi/desenv/manutencao/registrarInicioManutencao.jsf'        , 'Registrar Inicio Manutenção'         , 'Permitir registrar a data de inicio da execução de uma Manutenção de Sistema');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1324, 1, '007002003', 1, 2, '/gestaoTi/desenv/manutencao/registrarAcompanhamentoManutencao.jsf', 'Registrar Acompanhamento Manutenção' , 'Permitir registrar dados de acomphamento da execução além das ações Paralisar/Cancelar/Concluir');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1325, 1, '007002004', 1, 2, '/gestaoTi/desenv/manutencao/registrarReinicioManutencao.jsf'      , 'Registrar Reinicio Manutenção'       , 'Permitir registrar reinico da execução de uma manutenção paralisada');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1326, 1, '007002005', 1, 2, '/gestaoTi/desenv/manutencao/consultarManutencaoSistema.jsf'       , 'Consultar Manutenção Sistema'        , 'Permitir consultar a lista de Manutenções registrar através da utilização de diversos filtros');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1327, 1, '007002006', 1, 2, '/gestaoTi/desenv/manutencao/emitirFichaManutencoesSistema.jsf'    , 'Emitir Ficha da Manutenção Sistema'  , 'Permitir emitir a Ficha de Manutenção de Sistema Cadastrado');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1328, 1, '007002007', 1, 2, '/gestaoTi/desenv/manutencao/emitirRelacaoManutencoesSistema.jsf'  , 'Emitir Relação de Manutenções Sistema', 'Permitir emitir uma relação de Manutenções de Sistemas, conforme parametros informados');
-- MENU: Desenvolvimento: Controle de Atualização (GESTAO.SIGDER.SISTEMA)
-- Menor Id : 1330 - Maior Id : 1332
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1330, 1, '007003'   , 1, 1, 'mngGestaoTiDesenvAtualizacoes'                                    , 'Controle de Atualizações'            , 'Exibir o Grupo de Menu: Controle de atualizações');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1331, 1, '007003001', 1, 2, '/gestaoTi/desenv/atualizacao/registrarVersaoSistema.jsf'          , 'Registrar Versão do SIGDER'          , 'Permitir Abrir/Alterar/Fechar uma Versão de Atualização do SIGDER');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1332, 1, '007003002', 1, 2, '/gestaoTi/desenv/atualizacao/registrarVersaoModulo.jsf'           , 'Registrar Versão dos Módulos'        , 'Permitir registrar as Modificações realizadas em cada módulo do SIGDER');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1333, 1, '007003003', 1, 2, '/gestaoTi/desenv/atualizacao/consultarVersoesSistema.jsf'         , 'Consultar Versoes do SIGDER'         , 'Permitir consulta a relação de versões cadastradas do SIGDER');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1334, 1, '007003004', 1, 2, '/gestaoTi/desenv/atualizacao/consultarVersoesModulo.jsf'          , 'Consultar Versoes dos Módulos'       , 'Permitir consulta a relação de versões cadastradas dos módulos do SIGDER');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1335, 1, '007003005', 1, 2, '/gestaoTi/desenv/atualizacao/emitirRelacaoVersoesModulo.jsf'      , 'Emitir Versoes dos Módulos'          , 'Permitir Emitir uma relação de versões de modulos com agrupamentos e filtros.');

-- MENU: Desenvolvimento (GESTAO.SIGDER.CADASTROS E GESTAO.SIGDER.CONSULTAS)
-- Menor Id : 1350 - Maior Id : 1359
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1350, 1, '008'      , 1, 1, 'mngGestaoTiContadorAcesso'                                        , 'Contador de Acesso'                  , 'Exibir o Grupo de Menu: Contador de Acesso');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1351, 1, '008001'   , 1, 2, '/der/ce/contador_acesso/manterChaveSite.jsf'                      , 'Manter Chave do Site'                , 'Manter Chave do Site');
INSERT INTO security.elementos_modulo (id, id_modulo, ordem_menu, id_status, id_tipo_elemento, nome_interno, nome_externo, objetivo) VALUES (1352, 1, '008002'   , 1, 2, '/der/ce/contador_acesso/consultarContadorAcesso.jsf'              , 'Consulta do Contador Acesso'         , 'Consulta do Contador de Acesso');
-- -----------------------------------------------------------------------------
-- Insert das REGRAS que acessam o Modulo SECURITY
-- -----------------------------------------------------------------------------

-- MENU: Tabelas Classificação (GESTAO.SIGDER.TABELAS=)  
-- -----------------------------------------------------------------------------
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1000);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1001);
-- SUB-MENU: Tabelas Classificação: Sistemas (GESTAO.SIGDER.TABELAS)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1010);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1011);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1012);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1013);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1014);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1015);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1016);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1017);
-- SUB-MENU: Tabelas Classificação: Usuarios (GESTAO.SIGDER.TABELAS)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1020);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1021);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1022);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1023);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1024);
-- SUB-MENU: Tabelas Classificação: Caso de Uso (GESTAO.SIGDER.TABELAS)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1030);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1031);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1032);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1033);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1034);
-- SUB-MENU: Tabelas Classificação: Projetos (GESTAO.SIGDER.TABELAS)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1040);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1041);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1042);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1043);
-- SUB-MENU: Tabelas Classificação: Atividades (GESTAO.SIGDER.TABELAS)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1050);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1051);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1052);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1053);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1054);
-- SUB-MENU: Tabelas Classificação: Reuniões (GESTAO.SIGDER.TABELAS)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1060);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1061);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1062);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (211,1063);

-- MENU: Tabelas: Profissionais de TI (GESTAO.SIGDER.CADASTROS=212)  
-- -----------------------------------------------------------------------------
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1090); -- GESTAO.SIGDER.CADASTROS=212
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1091);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1093);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1094);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1095);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1096);

-- MENU: Tabelas: Profissionais de TI (GESTAO.SIGDER.CONSULTAS=214)  
-- -----------------------------------------------------------------------------
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1090); -- GESTAO.SIGDER.CONSULTAS=214
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1093);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1094);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1095);

-- MENU: Gestão Sistemas (GESTAO.SIGDER.SISTEMA=215)
-- -----------------------------------------------------------------------------
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1100); -- GESTAO.SIGDER.SISTEMA=215
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1100); -- GESTAO.SIGDER.CONSULTAS=214
-- SUB-MENU: Gestão Sistemas: Módulos (GESTAO.SIGDER.SISTEMA=215)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1110); -- GESTAO.SIGDER.SISTEMA=215
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1111);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1113);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1114);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1115);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1116);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1117);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1118);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1119);
-- SUB-MENU: Gestão Sistemas: Módulos (GESTAO.SIGDER.CONSULTAS=214)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1110); -- GESTAO.SIGDER.CONSULTAS=214
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1113);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1114);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1115);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1117);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1118);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1119);
-- SUB-MENU: Gestão Sistemas: Elementos Módulos (GESTAO.SIGDER.SISTEMA=215)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1120); -- GESTAO.SIGDER.SISTEMA=215
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1121);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1123);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1124);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1125);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1126);
-- SUB-MENU: Gestão Sistemas: Elementos Módulos (GESTAO.SIGDER.CONSULTAS=214)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1120); -- GESTAO.SIGDER.CONSULTAS=214
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1123);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1124);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1125);
-- SUB-MENU: Gestão Sistemas: Regras de Acesso (GESTAO.SIGDER.SISTEMA=215)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1130); -- GESTAO.SIGDER.SISTEMA=215
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1131);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1133);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1134);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1135);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1136);
-- SUB-MENU: Gestão Sistemas: Regras de Acesso (GESTAO.SIGDER.CONSULTAS=214)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1130); -- GESTAO.SIGDER.CONSULTAS=214
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1133);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1134);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1135);

-- MENU: Usuários (GESTAO.SIGDER.CADASTROS=212)
-- -----------------------------------------------------------------------------
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1140); -- GESTAO.SIGDER.CADASTROS=212
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1141);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1143);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1144);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1145);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1146);
-- MENU: Usuários (GESTAO.SIGDER.CONSULTAS=214)
-- -----------------------------------------------------------------------------
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1140); -- GESTAO.SIGDER.CONSULTAS=214
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1143);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1144);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1145);

-- MENU: Ativar/Desativar Acessos (GESTAO.SIGDER.ACESSOS=213)
-- -----------------------------------------------------------------------------
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (213,1150); -- GESTAO.SIGDER.ACESSOS=213
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (213,1151);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (213,1152);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (213,1153);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (213,1154);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (213,1155);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (213,1156);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (213,1157);

-- MENU: Gerência (GESTAO.SIGDER.PROJETOS) - (GESTAO.SIGDER.REUNIOES) - (GESTAO.SIGDER.ATIVIDADES)
-- -----------------------------------------------------------------------------
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (216,1200); -- GESTAO.SIGDER.ATIVIDADES=216
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1200); -- GESTAO.SIGDER.REUNIOES=217
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1200); -- GESTAO.SIGDER.PROJETOS=218
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1200); -- GESTAO.SIGDER.CONSULTAS=214
-- SUB-MENU: Gerência: Controle de Reuniões (GESTAO.SIGDER.REUNIOES=217)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1210); -- GESTAO.SIGDER.REUNIOES=217
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1211);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1212);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1213);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1214);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1215);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1216);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1217);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1218);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1219);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1220);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1221);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (217,1222);
-- SUB-MENU: Gerência: Controle de Reuniões (GESTAO.SIGDER.CONSULTAS=214)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1210); -- GESTAO.SIGDER.CONSULTAS=214
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1218);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1219);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1220);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1221);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1222);
-- SUB-MENU: Gerência: Controle de Projetos (GESTAO.SIGDER.PROJETOS=218)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1240);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1241);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1242);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1243);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1244);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1245);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1246);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1247);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1248);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1249);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1250);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1252);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (218,1253);
-- SUB-MENU: Gerência: Controle de Projetos (GESTAO.SIGDER.CONSULTAS=214)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1240); -- GESTAO.SIGDER.CONSULTAS=214
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1250);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1251);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1252);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1253);
-- SUB-MENU: Gerência: Controle de Atividades (GESTAO.SIGDER.ATIVIDADES=216)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (216,1260);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (216,1261);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (216,1262);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (216,1263);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (216,1264);
-- SUB-MENU: Gerência: Acomphamento de Atividades (GESTAO.SIGDER.ATIVIDADES)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (216,1270);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (216,1271);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (216,1272);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (216,1273);
-- MENU: Desenvolvimento (GESTAO.SIGDER.SISTEMA)
-- -----------------------------------------------------------------------------
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1300);
-- MENU: Desenvolvimento: Controle de Caso de Uso (GESTAO.SIGDER.SISTEMA)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1310);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1311);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1312);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1313);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1314);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1315);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1316);
-- MENU: Desenvolvimento: Controle de Manutenção (GESTAO.SIGDER.SISTEMA)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1320);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1321);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1322);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1323);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1324);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1325);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1326);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1327);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1328);
-- MENU: Desenvolvimento: Controle de Atualização (GESTAO.SIGDER.SISTEMA)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1330);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1331);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1332);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1333);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1334);
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (215,1335);

-- MENU: Contador de Acesso (212 - GESTAO.SIGDER.CADASTROS)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1350); 
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (212,1351); 
-- MENU: Contador de Acesso (214 - GESTAO.SIGDER.CONSULTAR)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1350); 
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (214,1352);
-- MENU: Contador de Acesso (219 - GESTAO.SIGDER.COORDENADOR)
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (219,1350); 
INSERT INTO security.roles_x_elementos_modulo (id_role, id_elemento) VALUES (219,1352);
-- /////////////////////////////////////////////////////////////////////////////
--
-- ALTERAÇÕES FEITA NO SCRIPT APÓS  A CRIAÇÃO DO BANCO DE PRODUÇÃO
--
-- /////////////////////////////////////////////////////////////////////////////
