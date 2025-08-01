
DELIMITER $

DROP PROCEDURE IF EXISTS `adress_get_or_create`$
CREATE PROCEDURE `adress_get_or_create`(
  IN _args JSON,
  OUT _addressId INTEGER
)
BEGIN
  DECLARE _housenumber VARCHAR(10);
  DECLARE _streettype VARCHAR(512);
  DECLARE _streetcode INTEGER;
  DECLARE _streetname VARCHAR(512);
  DECLARE _additional VARCHAR(512);
  DECLARE _ccode INTEGER;
  DECLARE _postcode INTEGER;
  DECLARE _citycode INTEGER;
  DECLARE _city VARCHAR(512);
  DECLARE _countrycode VARCHAR(512);
  DECLARE _reference JSON;
  DECLARE _location JSON;
  DECLARE _geometry JSON;

  SELECT IFNULL(JSON_VALUE(_args, "$.housenumber"), "") INTO _housenumber;
  SELECT IFNULL(JSON_VALUE(_args, "$.streettype"), "") INTO _streettype;
  SELECT IFNULL(JSON_VALUE(_args, "$.streetname"), "") INTO _streetname;
  SELECT IFNULL(JSON_VALUE(_args, "$.additional"), "") INTO _additional;
  SELECT IFNULL(JSON_VALUE(_args, "$.postcode"), 99999) INTO _postcode;
  SELECT IFNULL(JSON_VALUE(_args, "$.city"), _postcode) INTO _city;
  SELECT IFNULL(JSON_VALUE(_args, "$.countrycode"), 'France') INTO  _countrycode;

  SELECT id FROM streetType WHERE longTag=_streettype OR shortTag=_streettype 
    LIMIT 1 INTO _streetcode;
  IF _streetcode IS NULL THEN 
    INSERT INTO streetType SELECT NULL, _streettype, _streettype;
  END IF;

  SELECT JSON_EXTRACT(_args, "$.geometry") INTO _geometry;

  SELECT JSON_ARRAY(
    _housenumber, _streettype, _streetname, _additional, "", ""
  ) INTO _location;

  SELECT id FROM country WHERE code=_countrycode INTO _ccode;

  SELECT address_get_id(_location, _postcode, _ccode) INTO _addressId;

  IF _addressId IS NULL THEN
    SELECT id FROM country WHERE code=_countrycode INTO _ccode;

    REPLACE INTO address
      (
      `housenumber`,
      `streettype`,
      `streetname`,
      `additional`,
      `postcode`,
      `city`,
      `countrycode`,
      `geometry`,
      `ctime`
      )
      SELECT
      _housenumber,
      _streettype,
      _streetname,
      _additional,
      _postcode,
      _city,
      _ccode,
      _geometry,
      UNIX_TIMESTAMP();
    SELECT max(id) FROM `address` INTO _addressId;
    
    SELECT JSON_OBJECT(
      'id', _addressId,
      'table', 'address'
    ) INTO _reference;

    CALL seo_index(_city, 'city', _reference);
    CALL seo_index(CONCAT(_housenumber, " ", _streettype, ' ', _streetname), 'streetName', _reference);
  END IF;
END$
 
DELIMITER ;
