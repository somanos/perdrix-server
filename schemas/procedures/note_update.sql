
DELIMITER $

DROP PROCEDURE IF EXISTS `note_update`$
CREATE PROCEDURE `note_update`(
  IN _args JSON
)
BEGIN
  DECLARE _id INTEGER;
  DECLARE _description TEXT;

  SELECT JSON_VALUE(_args, "$.id") INTO _id;
  SELECT JSON_VALUE(_args, "$.description") INTO _description;

  IF _description IS NOT NULL THEN
    UPDATE note SET `description`=_description WHERE id=_id AND _description IS NOT NULL;
    CALL seo_index(_description, 'note', JSON_OBJECT(
      'id', _id,
      'table', 'note'
    ));
  END IF;

  CALL note_get(_id);
END$

DELIMITER ;
