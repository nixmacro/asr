-- Deploy asr:set_modified to pg

BEGIN;

CREATE OR REPLACE FUNCTION set_modified() RETURNS TRIGGER AS
$$
BEGIN
  NEW.modified := CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMIT;
