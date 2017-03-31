-- Revert asr:set_modified from pg

BEGIN;

DROP FUNCTION set_modified();

COMMIT;
