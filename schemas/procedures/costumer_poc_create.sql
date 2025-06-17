
DELIMITER $

DROP PROCEDURE IF EXISTS `costumer_poc_create`$
CREATE PROCEDURE `costumer_poc_create`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;
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

  DECLARE _phones JSON;
  DECLARE _reference JSON;
  DECLARE _gcode INTEGER;

  SELECT IFNULL(JSON_VALUE(_args, "$.custId"), 0) INTO _custId;
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

  INSERT INTO customerPoc 
    SELECT NULL,
    _custId,
    _role,
    _gcode,
    _lastname,
    _firstname,
    _email,
    _phones,
    UNIX_TIMESTAMP(),
    1;

  SELECT max(id) FROM `customerPoc` INTO _id;
  IF skip_number(_id) THEN
    DELETE FROM `customerPoc` WHERE id=_id;
    INSERT INTO customerPoc 
      SELECT _id+1,
        _custId,
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
    'table', 'customer_poc'
  ) INTO _reference;

  CALL seo_index(CONCAT(_lastname, ' ', _firstname), 'customerPoc', _reference);
  SELECT city, JSON_VALUE(a.location, '$[2]') FROM customer c
    INNER JOIN `address` a ON c.addressId=a.id WHERE c.id=_custId INTO _city, _streetname;

  IF _city IS NOT NULL THEN
    CALL seo_index(_city, 'cust_city', _reference);
  END IF;

  IF _streetname IS NOT NULL THEN
    CALL seo_index(_streetname, 'cust_streetName', _reference);
  END IF;

  SELECT max(id) FROM `customerPoc` INTO _id;
  CALL customer_get(_custId);
END$

DELIMITER ;
