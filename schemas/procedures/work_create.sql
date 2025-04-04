
DELIMITER $

DROP PROCEDURE IF EXISTS `work_create`$
CREATE PROCEDURE `work_create`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;
  DECLARE _siteId INTEGER;
  DECLARE _id INTEGER;
  DECLARE _description TEXT;
  DECLARE _ccode INTEGER;
  DECLARE _category VARCHAR(512) DEFAULT "Serrurerie";
  DECLARE _reference JSON;

  SELECT IFNULL(JSON_VALUE(_args, "$.custId"), 0) INTO _custId;
  SELECT IFNULL(JSON_VALUE(_args, "$.siteId"), 0) INTO _siteId;
  SELECT IFNULL(JSON_VALUE(_args, "$.category"), "Serrurerie") INTO _category;
  SELECT IFNULL(JSON_VALUE(_args, "$.description"), "") INTO _description;

  SELECT id FROM workType WHERE tag=_category INTO _ccode;

  IF _ccode IS NULL THEN 
    INSERT INTO workType SELECT NULL, _category;
    SELECT id FROM workType WHERE tag=_category INTO _ccode;
  END IF;

  INSERT INTO work 
    SELECT NULL,
    _custId,
    _siteId,
    _ccode,
    _description,
    UNIX_TIMESTAMP(),
    0;

  SELECT max(id) FROM `work` INTO _id;
  IF skip_number(_id) THEN
    DELETE FROM `work` WHERE id=_id;
    INSERT INTO work 
      SELECT _id+1,
        _custId,
        _siteId,
        _ccode,
        _description,
        UNIX_TIMESTAMP(),
        0;
  END IF;

  SELECT JSON_OBJECT(
    'id', _id,
    'table', 'work',
    'db', database()
  ) INTO _reference;

  CALL seo_index(_description, 'workDesc', _reference);
  CALL work_get(_id);
END$

DELIMITER ;
