
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_create`$
CREATE PROCEDURE `poc_create`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;
  DECLARE _siteId INTEGER;
  DECLARE _id INTEGER;
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
  DECLARE _siteType VARCHAR(512) DEFAULT "site";

  DECLARE _phones JSON;
  DECLARE _reference JSON;
  DECLARE _gcode INTEGER;

  SELECT IFNULL(JSON_VALUE(_args, "$.custId"), 0) INTO _custId;
  SELECT IFNULL(JSON_VALUE(_args, "$.siteId"), 0) INTO _siteId;
  SELECT IFNULL(JSON_VALUE(_args, "$.siteType"), "site") INTO _siteType;
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

  INSERT INTO poc 
    SELECT NULL,
    _custId,
    _siteId,
    _siteType,
    _role,
    _gcode,
    _lastname,
    _firstname,
    _email,
    _phones,
    UNIX_TIMESTAMP(),
    1;

  SELECT max(id) FROM `poc` INTO _id;
  IF(_id LIKE "%666%") THEN
    DELETE FROM `poc` WHERE id=_id;
    INSERT INTO poc 
      SELECT _id+1,
        _custId,
        _siteId,
        _siteType,
        _role,
        _gcode,
        _lastname,
        _firstname,
        _email,
        _phones,
        UNIX_TIMESTAMP(),
        1;
  END IF;

  SELECT JSON_OBJECT(
    'id', _id,
    'table', 'site',
    'db', database()
  ) INTO _reference;

  CALL seo_index(CONCAT(_lastname, ' ', _firstname), 'poc', _reference);
  SELECT city, JSON_VALUE(location, '$[2]') FROM customer WHERE id=_custId INTO
    _city, _streetname;

  IF _city IS NOT NULL THEN
    CALL seo_index(_city, 'city', _reference);
  END IF;

  IF _streetname IS NOT NULL THEN
    CALL seo_index(_streetname, 'streetName', _reference);
  END IF;

  SELECT max(id) FROM `poc` INTO _id;
  CALL poc_get(_id);
END$

DELIMITER ;
