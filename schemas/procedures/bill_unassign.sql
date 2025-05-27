
DELIMITER $

DROP PROCEDURE IF EXISTS `bill_unassign`$
CREATE PROCEDURE `bill_unassign`(
  IN _id INTEGER
)
BEGIN
  UPDATE bill SET custId = 0 WHERE id = _id;
END$


DELIMITER ;
