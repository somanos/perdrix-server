
DELIMITER $

DROP PROCEDURE IF EXISTS `customer_create`$
CREATE PROCEDURE `customer_create`(
  IN _args JSON
)
BEGIN
  DECLARE _category INTEGER;
  DECLARE _type INTEGER;
  DECLARE _companyname VARCHAR(512);
  DECLARE _companyclass VARCHAR(512);
  DECLARE _companycode INTEGER;
  DECLARE _ccode INTEGER;
  DECLARE _gender VARCHAR(512);
  DECLARE _lastname VARCHAR(512);
  DECLARE _firstname VARCHAR(512);
  DECLARE _location TEXT;
  DECLARE _postcode INTEGER;
  DECLARE _citycode INTEGER;
  DECLARE _city VARCHAR(512);
  DECLARE _countrycode VARCHAR(512);

  SELECT IFNULL(JSON_VALUE(_args, "$.category"), 0) INTO _category;
  SELECT IFNULL(JSON_VALUE(_args, "$.type"), 34) INTO _type;
  SELECT IFNULL(JSON_VALUE(_args, "$.companyname"), "") INTO _companyname;
  SELECT IFNULL(JSON_VALUE(_args, "$.companyclass"), "") INTO _companyclass;
  SELECT IFNULL(JSON_VALUE(_args, "$.gender"), 0) INTO _gender;
  SELECT IFNULL(JSON_VALUE(_args, "$.lastname"), "") INTO _lastname;
  SELECT IFNULL(JSON_VALUE(_args, "$.firstname"), "") INTO _firstname;
  SELECT JSON_EXTRACT(_args, "$.location") INTO _location;
  SELECT IFNULL(JSON_VALUE(_args, "$.postcode"), 99999) INTO _postcode;
  SELECT IFNULL(JSON_VALUE(_args, "$.citycode"), _postcode) INTO _citycode;
  SELECT IFNULL(JSON_VALUE(_args, "$.city"), "") INTO _city;
  SELECT IFNULL(JSON_VALUE(_args, "$.countrycode"), 'France') INTO  _countrycode;
  SELECT IFNULL(JSON_VALUE(_args, "$.countrycode"), 'France') INTO  _countrycode;

  SELECT id FROM country WHERE code=_countrycode INTO _ccode;
  SELECT id FROM companyClass WHERE tag=_companyclass INTO _companycode;

  INSERT INTO customer 
    SELECT NULL,
    _category,
    _companycode,
    _companyname,
    _gender,
    _lastname,
    _firstname,
    _location,
    _postcode,
    _citycode,
    _city,
    _ccode,
    UNIX_TIMESTAMP();
END$

DELIMITER ;
