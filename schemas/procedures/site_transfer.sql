
DELIMITER $

DROP PROCEDURE IF EXISTS `site_transfer`$
CREATE PROCEDURE `site_transfer`(
  IN _id INTEGER,
  IN _newCustId INTEGER
)
BEGIN
  UPDATE `site` SET custId=_newCustId WHERE id=_id;
  CALL site_get(_id);
END$

DELIMITER ;
