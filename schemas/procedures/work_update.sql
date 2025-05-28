
DELIMITER $

DROP PROCEDURE IF EXISTS `work_update`$
CREATE PROCEDURE `work_update`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;
  DECLARE _siteId INTEGER;
  DECLARE _id INTEGER;
  DECLARE _description TEXT;
  DECLARE _ccode INTEGER;
  DECLARE _category VARCHAR(512) DEFAULT NULL;
  DECLARE _reference JSON;

  SELECT JSON_VALUE(_args, "$.id") INTO _id;
  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_VALUE(_args, "$.siteId") INTO _siteId;
  SELECT JSON_VALUE(_args, "$.category") INTO _category;
  SELECT JSON_VALUE(_args, "$.description") INTO _description;


  IF _category IS NOT NULL THEN
    SELECT id FROM workType WHERE tag=_category INTO _ccode;
    IF _ccode IS NULL THEN 
      INSERT INTO workType SELECT NULL, _category;
      SELECT id FROM workType WHERE tag=_category INTO _ccode;
    END IF;
   UPDATE work SET category = _ccode WHERE id = _id;
  END IF;

  IF _custId IS NOT NULL THEN
    UPDATE work SET custId = _custId WHERE id = _id;
  END IF;

  IF _siteId IS NOT NULL THEN
    UPDATE work SET siteId = _siteId WHERE id = _id;
  END IF;

  IF _description IS NOT NULL THEN
    UPDATE work SET description = _description WHERE id = _id;
    CALL seo_index(_description, 'workDesc', JSON_OBJECT(
      'id', _id,
      'table', 'work'
    ));
  END IF;

  CALL work_get(_id);
END$

DELIMITER ;
