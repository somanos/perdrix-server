
DELIMITER $

DROP PROCEDURE IF EXISTS `bill_balance`$
CREATE PROCEDURE `bill_balance`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;
  DECLARE _fiscalYear INTEGER;

  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_VALUE(_args, "$.fiscalYear") INTO _fiscalYear;
  SELECT
    SUM(ttc) ttc,
    SUM(ht) ht
  FROM bill b
    WHERE 
       IF(_custId IS NULL, 1, b.custId=_custId) AND
       IF(_fiscalYear IS NULL, 1, fiscalYear=_fiscalYear);
END$

DELIMITER ;
