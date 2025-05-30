
DELIMITER $

DROP PROCEDURE IF EXISTS `bill_reassign`$
CREATE PROCEDURE `bill_reassign`(
  IN _id INTEGER,
  IN _custId INTEGER
)
BEGIN
  UPDATE bill SET custId=_custId WHERE id = _id AND custId=0;
END$


DELIMITER ;
