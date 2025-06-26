
DELIMITER $

DROP PROCEDURE IF EXISTS `site_search`$
CREATE PROCEDURE `site_search`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _words TEXT;
  DECLARE _custId INTEGER;

  
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.words"), '.+') INTO _words;
  SELECT IFNULL(JSON_VALUE(_args, "$.custId"), 0) INTO _custId;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  CALL yp.pageToLimits(_page, _offset, _range);  

  SELECT 
    s.*,
    s.id siteId,
    normalize_name(c.category, c.company, c.lastname, c.firstname) custName,
    a.location,
    a.geometry,
    a.city,
    a.postcode,
    JSON_OBJECT(
      'id', c.id,
      'custId', c.id,
      'gender', g.shortTag,
      'companyclass', cc.tag,
      'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
      'location', ca.location,
      'geometry', ca.geometry,
      'city', ca.city,
      'postcode', ca.postcode
    ) customer
    FROM `site` s
      INNER JOIN customer c ON c.id=s.custId
      INNER JOIN `address` a ON s.addressId=a.id
      INNER JOIN `address` ca ON c.addressId=ca.id
      LEFT JOIN gender g ON g.id=c.gender
      LEFT JOIN companyClass cc ON c.type = cc.id
      WHERE IF(_custId IS NULL, 1, s.custId=_custId) AND 
      (a.streetname REGEXP _words OR a.city REGEXP _words)
    LIMIT _offset ,_range;

END$

DELIMITER ;
