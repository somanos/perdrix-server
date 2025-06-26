
DELIMITER $

DROP PROCEDURE IF EXISTS `update_geo`$
CREATE PROCEDURE `update_geo`(
  IN _addressId INTEGER,
  IN _args JSON
)
BEGIN  

  UPDATE `address` SET `geometry`=_args WHERE id=_addressId;

END$

DELIMITER ;
