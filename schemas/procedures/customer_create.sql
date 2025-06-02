
DELIMITER $

DROP PROCEDURE IF EXISTS `customer_create`$
CREATE PROCEDURE `customer_create`(
  IN _args JSON
)
BEGIN
  DECLARE _housenumber VARCHAR(10);
  DECLARE _streettype VARCHAR(512);
  DECLARE _streetname VARCHAR(512);
  DECLARE _additional VARCHAR(512);
  DECLARE _category INTEGER;
  DECLARE _companyname VARCHAR(512);
  DECLARE _companyclass VARCHAR(128) DEFAULT "";
  DECLARE _companycode INTEGER;
  DECLARE _streetcode INTEGER;
  DECLARE _ccode INTEGER;
  DECLARE _gcode INTEGER DEFAULT 0;
  DECLARE _gender VARCHAR(128) DEFAULT "";
  DECLARE _lastname VARCHAR(512);
  DECLARE _firstname VARCHAR(512);
  DECLARE _postcode INTEGER;
  DECLARE _citycode INTEGER;
  DECLARE _city VARCHAR(512);
  DECLARE _countrycode VARCHAR(512);
  DECLARE _reference JSON;
  DECLARE _id INTEGER;
  DECLARE _location JSON;
  DECLARE _geometry JSON;

  SELECT IFNULL(JSON_VALUE(_args, "$.housenumber"), "") INTO _housenumber;
  SELECT IFNULL(JSON_VALUE(_args, "$.streettype"), "34") INTO _streettype;
  SELECT IFNULL(JSON_VALUE(_args, "$.streetname"), "") INTO _streetname;
  SELECT IFNULL(JSON_VALUE(_args, "$.additional"), "") INTO _additional;

  SELECT IFNULL(JSON_VALUE(_args, "$.category"), 0) INTO _category;
  SELECT IFNULL(JSON_VALUE(_args, "$.companyname"), "") INTO _companyname;
  SELECT IFNULL(JSON_VALUE(_args, "$.companyclass"), "") INTO _companyclass;
  SELECT IFNULL(JSON_VALUE(_args, "$.gender"), "") INTO _gender;
  SELECT IFNULL(JSON_VALUE(_args, "$.lastname"), "") INTO _lastname;
  SELECT IFNULL(JSON_VALUE(_args, "$.firstname"), "") INTO _firstname;
  SELECT IFNULL(JSON_VALUE(_args, "$.postcode"), 99999) INTO _postcode;
  SELECT IFNULL(JSON_VALUE(_args, "$.citycode"), _postcode) INTO _citycode;
  SELECT IFNULL(JSON_VALUE(_args, "$.city"), "") INTO _city;
  SELECT IFNULL(JSON_VALUE(_args, "$.id"), 0) INTO _id;
  SELECT IFNULL(JSON_VALUE(_args, "$.countrycode"), 'France') INTO  _countrycode;
  SELECT JSON_EXTRACT(_args, "$.geometry") INTO _geometry;


  SELECT id FROM companyClass WHERE tag=_companyclass INTO _companycode;
  SELECT id FROM gender WHERE longTag=_gender OR shortTag=_gender INTO _gcode;

  IF _companycode IS NULL THEN 
    INSERT INTO companyClass SELECT NULL, _companyclass;
    SELECT id FROM companyClass WHERE tag=_companyclass INTO _companycode;
  END IF;

  SELECT id FROM streetType WHERE longTag=_streettype OR shortTag=_streettype 
    LIMIT 1 INTO _streetcode;
  IF _streetcode IS NULL THEN 
    INSERT INTO streetType SELECT NULL, _streettype;
    SELECT id FROM cstreetType WHERE tag=_streettype INTO _streetcode;
  END IF;

  SELECT JSON_ARRAY(
    _housenumber, _streettype, _streetname, _additional
  ) INTO _location;

  SELECT id FROM country WHERE code=_countrycode INTO _ccode;

  IF _id IS NULL OR _id=0 THEN 
    INSERT INTO customer 
      SELECT NULL,
      _category,
      _companycode,
      _companyname,
      _gcode,
      _lastname,
      _firstname,
      _location,
      _postcode,
      _citycode,
      _city,
      _ccode,
      _geometry,
      UNIX_TIMESTAMP();

    SELECT max(id) FROM `customer` INTO _id;
    IF skip_number(_id) THEN
      INSERT INTO customer 
        SELECT _id+1,
        _category,
        _companycode,
        _companyname,
        _gcode,
        _lastname,
        _firstname,
        _location,
        _postcode,
        _citycode,
        _city,
        _ccode,
        _geometry,
        UNIX_TIMESTAMP();
      DELETE FROM `customer` WHERE id=_id;
    END IF;
  ELSE
    REPLACE INTO customer 
      SELECT _id,
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
      _geometry,
      UNIX_TIMESTAMP();
  END IF;

  SELECT JSON_OBJECT(
    'id', _id,
    'table', 'site'
  ) INTO _reference;

  CALL seo_index(CONCAT(_lastname, ' ', _firstname), 'custName', _reference);
  CALL seo_index(_city, 'city', _reference);
  CALL seo_index(_streetname, 'streetName', _reference);
  CALL customer_get(_id);
END$

DELIMITER ;
