
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_update`$
CREATE PROCEDURE `poc_update`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;
  DECLARE _siteId INTEGER;
  DECLARE _pocId INTEGER;
  DECLARE _role VARCHAR(200);
  DECLARE _gender VARCHAR(512);
  DECLARE _lastname VARCHAR(512) DEFAULT "";
  DECLARE _firstname VARCHAR(128) DEFAULT "";

  DECLARE _mobile VARCHAR(128) DEFAULT "";
  DECLARE _home VARCHAR(128) DEFAULT "";
  DECLARE _office VARCHAR(128) DEFAULT "";
  DECLARE _fax VARCHAR(128) DEFAULT "";

  DECLARE _email VARCHAR(512);
  DECLARE _city VARCHAR(512) DEFAULT "";
  DECLARE _streetname VARCHAR(512) DEFAULT "";

  DECLARE _phones JSON;
  DECLARE _reference JSON;
  DECLARE _gcode INTEGER;

  SELECT IFNULL(JSON_VALUE(_args, "$.custId"), 0) INTO _custId;
  SELECT IFNULL(JSON_VALUE(_args, "$.siteId"), 0) INTO _siteId;
  SELECT IFNULL(JSON_VALUE(_args, "$.pocId"), 0) INTO _pocId;
  SELECT IFNULL(JSON_VALUE(_args, "$.role"), "") INTO _role;
  SELECT IFNULL(JSON_VALUE(_args, "$.gender"), "") INTO _gender;
  SELECT IFNULL(JSON_VALUE(_args, "$.lastname"), "") INTO _lastname;
  SELECT IFNULL(JSON_VALUE(_args, "$.firstname"), "") INTO _firstname;
  SELECT IFNULL(JSON_VALUE(_args, "$.email"), "") INTO _email;
  SELECT IFNULL(JSON_VALUE(_args, "$.mobile"), "") INTO _mobile;
  SELECT IFNULL(JSON_VALUE(_args, "$.home"), "") INTO _home;
  SELECT IFNULL(JSON_VALUE(_args, "$.office"), "") INTO _office;
  SELECT IFNULL(JSON_VALUE(_args, "$.fax"), "") INTO _fax;

  SELECT JSON_ARRAY(
    _office, _home, _mobile, _fax
  ) INTO _phones;

  SELECT id FROM gender WHERE shortTag=_gender OR longTag=_gender INTO _gcode;

  REPLACE INTO poc 
    SELECT _pocId,
    _custId,
    _siteId,
    _role,
    _gcode,
    _lastname,
    _firstname,
    _email,
    _phones,
    UNIX_TIMESTAMP(),
    1;


  SELECT JSON_OBJECT(
    'id', _pocId,
    'table', 'poc'
  ) INTO _reference;

  CALL seo_index(CONCAT(_lastname, ' ', _firstname), 'poc', _reference);
  SELECT city, JSON_VALUE(location, '$[2]') FROM customer WHERE id=_custId INTO
    _city, _streetname;

  IF _city IS NOT NULL THEN
    CALL seo_index(_city, 'cust_city', _reference);
  END IF;

  IF _streetname IS NOT NULL THEN
    CALL seo_index(_streetname, 'cust_streetName', _reference);
  END IF;

  SELECT city, JSON_VALUE(location, '$[2]') FROM site WHERE id=_custId INTO
    _city, _streetname;

  IF _city IS NOT NULL THEN
    CALL seo_index(_city, 'site_city', _reference);
  END IF;

  IF _streetname IS NOT NULL THEN
    CALL seo_index(_streetname, 'site_streetName', _reference);
  END IF;

  CALL poc_get(_pocId);
END$

DELIMITER ;
