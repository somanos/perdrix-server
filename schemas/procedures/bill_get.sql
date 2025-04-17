
DELIMITER $

DROP PROCEDURE IF EXISTS `bill_get`$
CREATE PROCEDURE `bill_get`(
  IN _id INTEGER
)
BEGIN
  SELECT 
    *,
    id billId
    FROM bill
      WHERE id = _id;
END$

DELIMITER ;
