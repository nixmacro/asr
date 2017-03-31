-- Deploy asr:tag-data to pg
-- requires: tag-table

BEGIN;

INSERT INTO tag (id, name, info) VALUES (0, 'default', 'All data will be tagged with this unless specified otherwise.');

COMMIT;
