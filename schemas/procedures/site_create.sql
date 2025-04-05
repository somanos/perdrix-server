
DELIMITER $

DROP PROCEDURE IF EXISTS `site_create`$
CREATE PROCEDURE `site_create`(
  IN _args JSON
)
BEGIN
  DECLARE _housenumber VARCHAR(10) DEFAULT "";
  DECLARE _streettype VARCHAR(512) DEFAULT "";
  DECLARE _streetname VARCHAR(512) DEFAULT "";
  DECLARE _additional VARCHAR(512) DEFAULT "";
  DECLARE _floor VARCHAR(10) DEFAULT "";
  DECLARE _room VARCHAR(10) DEFAULT "";
  DECLARE _other VARCHAR(512) DEFAULT "";
  DECLARE _postcode INTEGER DEFAULT 99999;
  DECLARE _city VARCHAR(512);

  DECLARE _location JSON;
  DECLARE _reference JSON;
  DECLARE _custId INTEGER;
  DECLARE _id INTEGER;
  DECLARE _ccode INTEGER;
  DECLARE _citycode INTEGER;

  DECLARE _lat double;
  DECLARE _lon double;
  DECLARE _countrycode VARCHAR(512);
  DECLARE _geometry JSON;

  SELECT IFNULL(JSON_VALUE(_args, "$.custId"), 0) INTO _custId;

  SELECT IFNULL(JSON_VALUE(_args, "$.housenumber"), "") INTO _housenumber;
  SELECT IFNULL(JSON_VALUE(_args, "$.streettype"), "34") INTO _streettype;
  SELECT IFNULL(JSON_VALUE(_args, "$.streetname"), "") INTO _streetname;
  SELECT IFNULL(JSON_VALUE(_args, "$.additional"), "") INTO _additional;
  SELECT IFNULL(JSON_VALUE(_args, "$.floor"), "") INTO _floor;
  SELECT IFNULL(JSON_VALUE(_args, "$.room"), "") INTO _room;
  SELECT IFNULL(JSON_VALUE(_args, "$.other"), "") INTO _other;

  SELECT IFNULL(JSON_VALUE(_args, "$.postcode"), 99999) INTO _postcode;
  SELECT IFNULL(JSON_VALUE(_args, "$.citycode"), _postcode) INTO _citycode;
  SELECT IFNULL(JSON_VALUE(_args, "$.city"), "") INTO _city;

  SELECT IFNULL(JSON_VALUE(_args, "$.lat"), 0) INTO _lat;
  SELECT IFNULL(JSON_VALUE(_args, "$.lon"), 0) INTO _lon;

  SELECT IFNULL(JSON_VALUE(_args, "$.countrycode"), 'France') INTO  _countrycode;

  SELECT JSON_EXTRACT(_args, "$.location") INTO  _location;

  IF _location IS NULL THEN 
    SELECT JSON_ARRAY(
      _housenumber, _streettype, _streetname, _additional, _floor, _room
    ) INTO _location;
  END IF;

  SELECT JSON_EXTRACT(_args, "$.geometry") INTO _geometry;

  SELECT id FROM country WHERE code=_countrycode INTO _ccode;
  SELECT site_exists(_args) INTO _id;
  IF NOT _id THEN 
    INSERT INTO `site` 
      SELECT NULL,
        _custId,
        _location,
        _postcode,
        _citycode,
        _city,
        _ccode,
        _geometry,
        UNIX_TIMESTAMP(),
        0;

    SELECT max(id) FROM `site` INTO _id;
    IF skip_number(_id) THEN
      INSERT INTO `site` 
        SELECT _id+1,
        _custId,
        _location,
        _postcode,
        _citycode,
        _city,
        _ccode,
        _geometry,
        UNIX_TIMESTAMP(),
        0;
      DELETE FROM `site` WHERE id=_id;
    END IF;

    SELECT JSON_OBJECT(
      'id', _id,
      'table', 'site'
    ) INTO _reference;
    CALL seo_index(_streetname, 'streetName', _reference);
    CALL seo_index(_city, 'city', _reference);
  END IF;
  CALL site_get(_id);
END$

DELIMITER ;
