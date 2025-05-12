
DELIMITER $

DROP PROCEDURE IF EXISTS `seo_populate_client`$
DROP FUNCTION IF EXISTS `translate_street`$
CREATE FUNCTION `translate_street`(
  _name VARCHAR(100)
)
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
  DECLARE _res VARCHAR(100) DEFAULT "";
  SELECT longTag FROM streetType WHERE shortTag=_name OR longTag=_name INTO _res;
  RETURN IFNULL(_res, "");
END$

DELIMITER ;
