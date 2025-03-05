
DELIMITER $

DROP PROCEDURE IF EXISTS `seo_index`$
CREATE PROCEDURE `seo_index`(
  _word varchar(300),
  _type varchar(16) CHARACTER SET ascii COLLATE ascii_general_ci,
  _reference JSON
)
BEGIN
  DECLARE _ts INT(11) UNSIGNED;
  DECLARE _count INTEGER UNSIGNED DEFAULT 0;
  DECLARE _id INTEGER UNSIGNED;
  DECLARE _table VARCHAR(16) CHARACTER SET ascii COLLATE ascii_general_ci;
  DECLARE _db VARCHAR(64) CHARACTER SET ascii COLLATE ascii_general_ci;
  DECLARE _ref_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_general_ci;

  SELECT unix_timestamp() INTO _id;
  SELECT JSON_VALUE(_reference, "$.id") INTO _id;
  SELECT JSON_VALUE(_reference, "$.table") INTO _table;
  SELECT JSON_VALUE(_reference, "$.db") INTO _db;

  SELECT MD5(REGEXP_REPLACE(CONCAT(_type, _word), ' +', '')) INTO _ref_id;
  SELECT count(1) FROM seo_object WHERE ref_id=_ref_id INTO _count;
  SELECT unix_timestamp() INTO _ts;

  IF LENGTH(_word) > 3 THEN
    IF _count = 0 THEN
      INSERT INTO seo
        SELECT NULL, _ts, 1, _word, _type, _ref_id
        ON DUPLICATE KEY UPDATE occurrence=occurrence+1;
    END IF;

    IF _id IS NOT NULL THEN
      INSERT INTO seo_object (`ref_id`, `reference`, `ctime`) 
        VALUE (_ref_id, _reference, _ts)
        ON DUPLICATE KEY UPDATE reference=_reference, ctime=_ts;
    END IF;
  END IF;
    
END$

DELIMITER ;
