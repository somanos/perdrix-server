
DELIMITER $

DROP PROCEDURE IF EXISTS `site_get`$
CREATE PROCEDURE `site_get`(
  IN _id INTEGER
)
BEGIN
  SELECT 
    *,
    id siteId
    FROM `site` s
      WHERE s.id = _id;
END$

DELIMITER ;
