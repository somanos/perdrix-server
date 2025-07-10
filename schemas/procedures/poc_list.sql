
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_list`$
CREATE PROCEDURE `poc_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _addressId INTEGER ;
  DECLARE _type VARCHAR(20) DEFAULT 'site';
  DECLARE _lastname VARCHAR(20) DEFAULT 'desc';
  DECLARE _order VARCHAR(20) DEFAULT 'desc';
  DECLARE _phones TEXT;

  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.type"), 'site') INTO _type;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;

  SELECT JSON_VALUE(_args, "$.lastname") INTO _lastname;
  SELECT JSON_VALUE(_args, "$.addressId") INTO _addressId;
  SELECT JSON_VALUE(_args, "$.phones") INTO _phones;

  CALL yp.pageToLimits(_page, _offset, _range);
  DROP TABLE IF EXISTS _view;
  CREATE TEMPORARY TABLE _view AS
  SELECT
    p.id,
    p.id pocId,
    'customer' category,
    0 addressId,
    p.custId,
    p.role,
    g.shortTag gender,
    p.lastname,
    p.firstname,
    p.email,
    p.office,
    p.home,
    p.mobile,
    p.fax,
    p.phones,
    _page `page`
  FROM customerPoc p 
    INNER JOIN gender g ON p.gender=g.id 
    WHERE 1=2;

  IF _type= 'site' THEN
    SELECT
      p.id,
      p.id pocId,
      'site' category,
      m.addressId,
      p.custId,
      p.role,
      g.shortTag gender,
      p.lastname,
      p.firstname,
      p.email,
      p.office,
      p.home,
      p.mobile,
      p.fax,
      p.phones,
      _page `page`,
      JSON_OBJECT(
        'id', s.id,
        'siteId', s.id,
        'location', a.location,
        'geometry', a.geometry,
        'city', a.city,
        'postcode', a.postcode
      ) site
    FROM sitePoc p 
      INNER JOIN poc_map m ON m.pocId=p.id AND m.category='site'
      INNER JOIN site s ON s.id=m.siteId
      INNER JOIN `address` a ON m.addressId=a.id
      LEFT JOIN gender g ON p.gender=g.id 
      WHERE 
        IF (_lastname IS NULL, 1, p.lastname REGEXP _lastname) AND
        IF (_addressId IS NULL, 1, m.addressId=_addressId) ORDER BY
        CASE WHEN LCASE(_order) = 'asc' THEN lastname END ASC,
        CASE WHEN LCASE(_order) = 'desc' THEN lastname END DESC
        LIMIT _offset ,_range;
    -- UPDATE _view v INNER JOIN poc_map m ON m.pocId=v.pocId 
    --   SET v.addressId=m.addressId;
  ELSE
    SELECT
      p.id,
      p.id pocId,
      'customer' category,
      m.addressId,
      p.custId,
      p.role,
      g.shortTag gender,
      p.lastname,
      p.firstname,
      p.email,
      p.office,
      p.home,
      p.mobile,
      p.fax,
      p.phones,
      _page `page`,
      JSON_OBJECT(
        'id', c.id,
        'custId', c.id,
        'gender', g.shortTag,
        'companyclass', cc.tag,
        'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
        'location', a.location,
        'geometry', a.geometry,
        'city', a.city,
        'postcode', a.postcode
      ) customer
    FROM customerPoc p 
      INNER JOIN poc_map m ON m.pocId=p.id AND m.category='customer'
      INNER JOIN customer c ON c.id=m.custId
      INNER JOIN `address` a ON m.addressId=a.id
      LEFT JOIN companyClass cc ON c.type = cc.id
      LEFT JOIN gender g ON p.gender=g.id 
      WHERE 
        IF (_lastname IS NULL, 1, p.lastname REGEXP _lastname) AND
        IF(_phones IS NULL, 1, p.phones REGEXP _phones) AND
        IF (_addressId IS NULL, 1, m.addressId=_addressId) ORDER BY
        CASE WHEN LCASE(_order) = 'asc' THEN lastname END ASC,
        CASE WHEN LCASE(_order) = 'desc' THEN lastname END DESC
      LIMIT _offset ,_range;
    -- UPDATE _view v INNER JOIN poc_map m ON m.pocId=v.pocId 
    --   SET v.addressId=m.addressId;
  END IF;

  -- SELECT v.*,
  --   JSON_OBJECT(
  --     'id', c.id,
  --     'custId', c.id,
  --     'gender', g.shortTag,
  --     'companyclass', cc.tag,
  --     'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
  --     'location', ca.location,
  --     'geometry', ca.geometry,
  --     'city', ca.city,
  --     'postcode', ca.postcode
  --   ) customer 
  -- FROM _view v 
  -- INNER JOIN customer c ON c.id=v.custId
  -- INNER JOIN `address` ca ON c.addressId=ca.id
  -- LEFT JOIN gender g ON g.id=c.gender
  -- LEFT JOIN companyClass cc ON c.type = cc.id
  -- WHERE IF (_addressId IS NULL, 1, v.addressId=_addressId) ORDER BY
  --   CASE WHEN LCASE(_order) = 'asc' THEN v.lastname END ASC,
  --   CASE WHEN LCASE(_order) = 'desc' THEN v.lastname END DESC;
END$


DELIMITER ;
