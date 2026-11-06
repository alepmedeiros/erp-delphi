-- Views do MySQL nao migradas pelo pgloader (necessarias para login e outros modulos).
-- Executar no banco t2tierp com usuario postgres:
--   psql -h localhost -U postgres -d t2tierp -f pg-views-login.sql

SET search_path TO t2tierp, public;

-- Login: lista empresas do usuario (ULogin + ViewSessaoEmpresaVO)
DROP VIEW IF EXISTS view_sessao_empresa;

CREATE VIEW view_sessao_empresa AS
SELECT
  ep.id_empresa,
  ep.id_pessoa,
  e.razao_social
FROM empresa_pessoa ep
INNER JOIN empresa e ON ep.id_empresa = e.id;

-- NFC-e (opcional; descomente se usar esse modulo)
-- DROP VIEW IF EXISTS view_nfce_cliente;
-- Ver definicao em Frente de Caixa/NFC-e/DUMP_MySQL.sql (linha ~7839)
