-- Revert asr:role-table from pg

BEGIN;

DROP TRIGGER set_modified ON role;
DROP TABLE role;

COMMIT;
