
DELIMITER $

DROP PROCEDURE IF EXISTS `address_list`$
CREATE PROCEDURE `address_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _pre_range bigint;
  DECLARE _pre_offset bigint;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'name';
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _housenumber TEXT;
  DECLARE _streettype TEXT;
  DECLARE _street TEXT;
  DECLARE _city TEXT;
  DECLARE _postcode TEXT;
  DECLARE _filter JSON ;
  
  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'ctime') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'desc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;
  SELECT JSON_VALUE(_args, "$.street") INTO _street;
  SELECT JSON_VALUE(_args, "$.housenumber") INTO _housenumber;
  SELECT JSON_VALUE(_args, "$.streettype") INTO _streettype;
  SELECT JSON_VALUE(_args, "$.city") INTO _city;
  SELECT JSON_VALUE(_args, "$.postcode") INTO _postcode;
  SELECT JSON_EXTRACT(_args, "$.filter") INTO _filter;

  CALL yp.pageToLimits(_page, _offset, _range);  
  DROP TABLE IF EXISTS `_view`;
  CREATE TEMPORARY TABLE _view (
    addressId int(10) unsigned NOT NULL, 
    page int(10) unsigned NOT NULL,
    ctime int(11) unsigned NOT NULL,
    location JSON,
    geometry JSON,
    nh VARCHAR(500),
    housenumber int(10) unsigned DEFAULT 0,
    streetname VARCHAR(500),
    city VARCHAR(500),
    postcode VARCHAR(500),
    type VARCHAR(500),
    reference JSON,
    content JSON 
  );

  SELECT _offset, _range INTO _pre_offset, _pre_range;
  IF _housenumber IS NOT NULL OR _street IS NOT NULL OR _city IS NOT NULL OR _postcode IS NOT NULL THEN
    SELECT 1, 1000 INTO _pre_offset, _pre_range;
  END IF;
  INSERT INTO _view SELECT 
    a.id addressId, 
    _page `page`,
    a.ctime,
    a.location,
    a.geometry,
    housenumber,
    CAST(IF(housenumber REGEXP "^[0-9]+", REGEXP_REPLACE(housenumber,'^([0-9]{1,})(.*)', '\\1'), "0") AS INTEGER),
    a.streetname,
    a.city,
    a.postcode,
    'address' `type`,
    JSON_ARRAY() reference,
    JSON_OBJECT(
      'id', a.id,
      'addressId', a.id,
      'location', a.location,
      'geometry', a.geometry,
      'city', a.city,
      'postcode', a.postcode
    ) content
  FROM address a WHERE
    IF(_housenumber IS NULL, 1, a.housenumber REGEXP _housenumber) AND
    IF(_streettype IS NULL, 1, a.streettype REGEXP _streettype) AND
    IF(_street IS NULL, 1, a.streetname REGEXP _street) AND
    IF(_city IS NULL, 1, a.city  REGEXP _city) AND
    IF(_postcode IS NULL, 1, a.postcode REGEXP _postcode)
  LIMIT _pre_offset, _pre_range;

  SELECT address_filter(_filter) INTO @stm;
  SET @stm = CONCAT('SELECT * FROM _view ', @stm, " ", "LIMIT ?, ?");
  PREPARE stmt FROM @stm;
  EXECUTE stmt USING _offset, _range;
  DEALLOCATE PREPARE stmt;
END$

DELIMITER ;
