
DELIMITER $

DROP PROCEDURE IF EXISTS `quote_remove`$
CREATE PROCEDURE `quote_remove`(
  IN _id INTEGER
)
BEGIN
  DELETE FROM quotation WHERE id = _id;
END$


DELIMITER ;
