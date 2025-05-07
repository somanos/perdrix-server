
DELIMITER $

DROP PROCEDURE IF EXISTS `site_add_poc`$
CREATE PROCEDURE `site_add_poc`(
  IN _args JSON
)
BEGIN
  DECLARE _pocId INTEGER;

  SELECT IFNULL(JSON_VALUE(_args, "$.pocId"), 0) INTO _pocId;
  REPLACE INTO site_poc 
    SELECT 
      JSON_VALUE(_args, "$.pocId"), 
      JSON_VALUE(_args, "$.custId"), 
      JSON_VALUE(_args, "$.siteId"),
      UNIX_TIMESTAMP();
  CALL site_get_poc(_pocId);
END$

DELIMITER ;
