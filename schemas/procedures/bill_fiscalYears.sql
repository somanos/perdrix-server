
DELIMITER $

DROP PROCEDURE IF EXISTS `fiscal_years`$
CREATE PROCEDURE `fiscal_years`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;

  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  
  SELECT fiscalYear `name` FROM bill
    WHERE IF(_custId IS NULL, 1, custId=_custId);
END$

DELIMITER ;
