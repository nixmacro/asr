-- Revert asr:tag-table from pg

BEGIN;

DROP TRIGGER set_modified ON tag;
DROP TABLE tag;

COMMIT;
