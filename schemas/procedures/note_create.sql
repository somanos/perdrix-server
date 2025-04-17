
DELIMITER $
-- | id | custId | siteId | workId | ctime      | description       | docId |
DROP PROCEDURE IF EXISTS `note_create`$
CREATE PROCEDURE `note_create`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;
  DECLARE _siteId INTEGER;
  DECLARE _workId INTEGER;
  DECLARE _id INTEGER;
  DECLARE _description TEXT;
  DECLARE _ccode INTEGER;
  DECLARE _category VARCHAR(512) DEFAULT "Serrurerie";
  DECLARE _docId VARCHAR(512) DEFAULT "";

  SELECT IFNULL(JSON_VALUE(_args, "$.custId"), 0) INTO _custId;
  SELECT IFNULL(JSON_VALUE(_args, "$.workId"), 0) INTO _workId;
  SELECT IFNULL(JSON_VALUE(_args, "$.siteId"), 0) INTO _siteId;
  SELECT IFNULL(JSON_VALUE(_args, "$.category"), "site") INTO _category;
  SELECT IFNULL(JSON_VALUE(_args, "$.description"), "") INTO _description;
  SELECT IFNULL(JSON_VALUE(_args, "$.docId"), "") INTO _docId;

  SELECT id FROM workType WHERE tag=_category INTO _ccode;

  IF _ccode IS NULL THEN 
    INSERT INTO workType SELECT NULL, _category;
    SELECT id FROM workType WHERE tag=_category INTO _ccode;
  END IF;

  INSERT INTO note 
    SELECT NULL,
    _custId,
    _siteId,
    _workId,
    UNIX_TIMESTAMP(),
    _description,
    _docId;

  SELECT max(id) FROM `note` INTO _id;
  IF skip_number(_id) THEN
    DELETE FROM `note` WHERE id=_id;
    INSERT INTO note 
      SELECT _id+1,
      _custId,
      _siteId,
      _workId,
      UNIX_TIMESTAMP(),
      _description,
      _docId;
  END IF;

  CALL seo_index(_description, 'workNote', JSON_OBJECT(
    'id', _id,
    'table', 'note')
  );
  CALL note_get(_id);
END$

DELIMITER ;
