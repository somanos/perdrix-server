
DELIMITER $

DROP PROCEDURE IF EXISTS `note_get`$
CREATE PROCEDURE `note_get`(
  IN _id INTEGER
)
BEGIN
  SELECT 
    *,
    id noteId
    FROM note
      WHERE id = _id;
END$

DELIMITER ;
