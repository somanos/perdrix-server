
DELIMITER $

DROP PROCEDURE IF EXISTS `site_create`$
CREATE PROCEDURE `site_create`(
  IN _args JSON
)
BEGIN
  DECLARE _addressId INTEGER;
  DECLARE _custId INTEGER;
  DECLARE _id INTEGER;
  DECLARE _ccode INTEGER;
  DECLARE _citycode INTEGER;

  DECLARE _lat double;
  DECLARE _lon double;
  DECLARE _countrycode VARCHAR(512);
  DECLARE _geometry JSON;

  SELECT IFNULL(JSON_VALUE(_args, "$.custId"), 0) INTO _custId;
  SELECT JSON_VALUE(_args, "$.addressId") INTO _addressId;

  CALL adress_get_or_create(_args, _addressId);
  IF _addressId IS NULL THEN
    SELECT addressId FROM customer WHERE id=_custId INTO _addressId;
  END IF;

  SELECT id FROM `site` WHERE custId=_custId AND addressId=_addressId ORDER BY id DESC LIMIT 1 INTO _id;
  IF _id IS NULL THEN 
    INSERT IGNORE INTO `site` SELECT 
      NULL,
      _custId,
      _addressId,
      UNIX_TIMESTAMP(),
      0;

    SELECT max(id) FROM `site` INTO _id;
    IF skip_number(_id) THEN
      DELETE FROM `site` WHERE id=_id;
      INSERT INTO `site` 
        SELECT _id+1,
        _custId,
        _addressId,
        UNIX_TIMESTAMP(),
        0;
    END IF;
    SELECT max(id) FROM `site` INTO _id;
  END IF;

  CALL site_get(_id);
END$

DELIMITER ;
