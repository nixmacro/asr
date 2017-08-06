-- Deploy asr:alter-access_log-table to pg
-- requires: access_log-table

BEGIN;

   ALTER TABLE access_log ALTER COLUMN host DROP NOT NULL;
   ALTER TABLE access_log ALTER COLUMN site DROP NOT NULL;

COMMIT;
