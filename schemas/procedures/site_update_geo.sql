
DELIMITER $

DROP PROCEDURE IF EXISTS `site_update_geo`$
CREATE PROCEDURE `site_update_geo`(
  IN _id INTEGER,
  IN _args JSON
)
BEGIN  DECLARE _siteId INTEGER ;
  UPDATE `site` SET `geometry`=_args WHERE id=_id;
END$

DELIMITER ;
