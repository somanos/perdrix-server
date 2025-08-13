
DELIMITER $

DROP PROCEDURE IF EXISTS `address_merge`$
CREATE PROCEDURE `address_merge`(
  IN _srcId INTEGER,
  IN _destId INTEGER
)
BEGIN
  UPDATE customer SET addressId=_destId WHERE addressId=_srcId;
  UPDATE site SET addressId=_destId WHERE addressId=_srcId;
  UPDATE poc_map SET addressId=_destId WHERE addressId=_srcId;
  DELETE FROM address WHERE id=_srcId;
  CALL address_get(_destId);
END$
 
DELIMITER ;
