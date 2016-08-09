-- Revert asr:user-table from pg

BEGIN;

DROP TRIGGER set_modified ON "user";
DROP TABLE "user";

COMMIT;
