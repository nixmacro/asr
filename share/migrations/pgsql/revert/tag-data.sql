-- Revert asr:tag-data from pg

BEGIN;

DELETE FROM tag WHERE id = 0;

COMMIT;
