
DELIMITER $

DROP PROCEDURE IF EXISTS `quote_list`$
CREATE PROCEDURE `quote_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'name';
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _hub_id VARCHAR(20);

  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _addressId INTEGER ;
  DECLARE _custId INTEGER ;
  DECLARE _fiscalYear INTEGER ;
  DECLARE _siteId INTEGER ;
  DECLARE _status JSON ;
  DECLARE _words TEXT;
  DECLARE _housenumber TEXT;
  DECLARE _streettype TEXT;
  DECLARE _street TEXT;
  DECLARE _city TEXT;
  DECLARE _postcode TEXT;
  DECLARE _custName TEXT;

  DECLARE _i TINYINT(6) unsigned DEFAULT 0;


  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'name') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  SELECT IFNULL(JSON_VALUE(_args, "$.fiscalYear"), 0) INTO _fiscalYear;

  SELECT JSON_VALUE(_args, "$.street") INTO _street;
  SELECT JSON_VALUE(_args, "$.housenumber") INTO _housenumber;
  SELECT JSON_VALUE(_args, "$.streettype") INTO _streettype;
  SELECT JSON_VALUE(_args, "$.city") INTO _city;
  SELECT JSON_VALUE(_args, "$.postcode") INTO _postcode;
  SELECT IFNULL(JSON_VALUE(_args, "$.custName"), '.+') INTO _custName;

  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_VALUE(_args, "$.siteId") INTO _siteId;
  SELECT JSON_VALUE(_args, "$.addressId") INTO _addressId;
  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT id FROM yp.entity WHERE db_name=database() INTO _hub_id;

  SELECT
    q.*,
    a.id addressId,
    t.tag `type`,
    t.tag `workType`,
    _page `page`,
    JSON_OBJECT(
      'custId', w.custId,
      'addressId', a.id,
      'countrycode', a.countrycode,
      'location', a.location,
      'postcode', a.postcode,
      'city', a.city,
      'geometry', a.geometry,
      'ctime', s.ctime,
      'statut', s.statut,
      'siteId', s.id,
      'id', s.id
    ) `site`,
    JSON_OBJECT(
      'custId', w.custId,
      'addressId', ca.id,
      'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
      'countrycode', ca.countrycode,
      'location', ca.location,
      'postcode', ca.postcode,
      'city', ca.city,
      'geometry', ca.geometry
    ) `customer`
  FROM quote q
    INNER JOIN work w ON w.id=q.workId
    INNER JOIN `site` s ON w.siteId=s.id
    INNER JOIN `customer` c ON c.id=q.custId 
    INNER JOIN `address` ca ON c.addressId=ca.id
    INNER JOIN `address` a ON s.addressId=a.id
    LEFT JOIN `workType` t ON t.id=w.category
    WHERE 
      IF(_custName IS NULL, 1, normalize_name(c.category, c.company, c.lastname, c.firstname) REGEXP _custName) AND
      IF(_housenumber IS NULL, 1, a.housenumber REGEXP _housenumber) AND
      IF(_streettype IS NULL, 1, a.streettype REGEXP _streettype) AND
      IF(_street IS NULL, 1, a.streetname REGEXP _street) AND
      IF(_city IS NULL, 1, a.city  REGEXP _city) AND
      IF(_postcode IS NULL, 1, a.postcode REGEXP _postcode) AND 
      IF(_custId IS NULL, 1, w.custId=_custId) AND 
      IF(_siteId IS NULL, 1, q.siteId=_siteId) AND
      IF(_fiscalYear REGEXP "^ *([0-9]{4,4}) *$", fiscalYear=_fiscalYear, 1) AND
      IF (_addressId IS NULL, 1, a.id=_addressId) 
    ORDER BY q.ctime DESC
    LIMIT _offset ,_range;
END$

DELIMITER ;
