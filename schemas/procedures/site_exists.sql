
DELIMITER $

DROP FUNCTION IF EXISTS `site_exists`$
CREATE FUNCTION `site_exists`(
  IN _args JSON
)
RETURNS INTEGER DETERMINISTIC

BEGIN
  DECLARE _location JSON;
  DECLARE _id INTEGER DEFAULT 0;
  DECLARE _postcode INTEGER DEFAULT 99999;
  DECLARE _custId INTEGER;

  DECLARE _housenumber VARCHAR(10) DEFAULT "";
  DECLARE _streettype VARCHAR(512) DEFAULT "";
  DECLARE _streetname VARCHAR(512) DEFAULT "";
  DECLARE _additional VARCHAR(512) DEFAULT "";
  DECLARE _floor VARCHAR(10) DEFAULT "";
  DECLARE _room VARCHAR(10) DEFAULT "";
  DECLARE _other VARCHAR(512) DEFAULT "";

  SELECT JSON_VALUE(_args, "$.postcode") INTO _postcode;
  SELECT JSON_EXTRACT(_args, "$.location") INTO _location;
  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;

  SELECT JSON_VALUE(_args, "$.housenumber") INTO _housenumber;
  SELECT JSON_VALUE(_args, "$.streettype") INTO _streettype;
  SELECT JSON_VALUE(_args, "$.streetname") INTO _streetname;
  SELECT JSON_VALUE(_args, "$.additional") INTO _additional;
  SELECT JSON_VALUE(_args, "$.floor") INTO _floor;
  SELECT JSON_VALUE(_args, "$.room") INTO _room;
  SELECT JSON_VALUE(_args, "$.other") INTO _other;

  IF _location IS NULL THEN 
    SELECT JSON_ARRAY(
      _housenumber, _streettype, _streetname, _additional, _floor, _room
    ) INTO _location;
  END IF;

  SELECT id FROM `site` s
    WHERE json_array_equal(_location, s.location) 
      AND _postcode=s.postcode AND s.custId = _custId
      ORDER BY id ASC
      LIMIT 1 INTO _id;
  RETURN IFNULL(_id, 0);
END$

DELIMITER ;
