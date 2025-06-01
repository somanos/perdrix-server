
DELIMITER $

DROP PROCEDURE IF EXISTS `quote_balance`$
CREATE PROCEDURE `quote_balance`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;
  DECLARE _siteId INTEGER;
  DECLARE _fiscalYear INTEGER;

  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_VALUE(_args, "$.siteId") INTO _siteId;
  SELECT JSON_VALUE(_args, "$.fiscalYear") INTO _fiscalYear;
  SELECT
    SUM(ttc) ttc,
    SUM(ht) ht
  FROM quote q
    WHERE 
       IF(_custId IS NULL, 1, q.custId=_custId) AND
       IF(_siteId IS NULL, 1, q.siteId=_siteId) AND
       IF(_fiscalYear IS NULL, 1, fiscalYear=_fiscalYear);
END$

DELIMITER ;
