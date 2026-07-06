-- Executado automaticamente pelo container postgres no PRIMEIRO boot
-- (apenas quando o volume de dados está vazio).
--
-- O container já cria o banco principal (lista_production) e o usuário "lista"
-- via POSTGRES_DB / POSTGRES_USER. Aqui criamos os bancos extras que o
-- Rails 8 usa para Solid Cache, Solid Queue e Solid Cable.
CREATE DATABASE lista_production_cache OWNER lista;
CREATE DATABASE lista_production_queue OWNER lista;
CREATE DATABASE lista_production_cable OWNER lista;
