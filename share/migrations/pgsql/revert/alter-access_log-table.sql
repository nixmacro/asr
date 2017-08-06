-- Revert asr:alter-access_log-table from pg

BEGIN;

   ALTER TABLE access_log ALTER COLUMN host SET NOT NULL;
   ALTER TABLE access_log ALTER COLUMN site SET NOT NULL;

COMMIT;
