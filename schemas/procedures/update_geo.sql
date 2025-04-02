
DELIMITER $

DROP PROCEDURE IF EXISTS `update_geo`$
CREATE PROCEDURE `update_geo`(
  IN _id INTEGER,
  IN _type VARCHAR(32),
  IN _args JSON
)
BEGIN  

  IF _type = 'site' THEN
    UPDATE `site` SET `geometry`=_args WHERE id=_id;
  ELSEIF _type = 'customer' THEN
    UPDATE `customer` SET `geometry`=_args WHERE id=_id;
  END IF;

END$

DELIMITER ;
