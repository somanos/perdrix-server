
DELIMITER $

DROP PROCEDURE IF EXISTS `search_mission`$
CREATE PROCEDURE `search_mission`(
  IN _args JSON
)
BEGIN
  DECLARE _key TEXT;
  DECLARE _offset INTEGER UNSIGNED;
  DECLARE _range INTEGER UNSIGNED;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'lastname';
  DECLARE _description TEXT;
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _housenumber TEXT;
  DECLARE _streettype TEXT;
  DECLARE _street TEXT;
  DECLARE _city TEXT;
  DECLARE _postcode TEXT;


  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'lastname') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT JSON_VALUE(_args, "$.description") INTO _description;
  SELECT JSON_VALUE(_args, "$.street") INTO _street;
  SELECT JSON_VALUE(_args, "$.housenumber") INTO _housenumber;
  SELECT JSON_VALUE(_args, "$.streettype") INTO _streettype;
  SELECT JSON_VALUE(_args, "$.city") INTO _city;
  SELECT JSON_VALUE(_args, "$.postcode") INTO _postcode;

  CALL yp.pageToLimits(_page, _offset, _range);
  SELECT 
      w.*,
      a.id addressId,
      w.id workId,
      t.tag workType,
      a.city,
      'work' `type`,
      JSON_ARRAY(
        JSON_OBJECT(
          'id', c.id,
          'custId', c.id,
          'addressId', ca.id,
          'gender', g.shortTag,
          'companyclass', cc.tag,
          'category', c.category,
          'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
          'location', ca.location,
          'site', ca.location,
          'geometry', ca.geometry,
          'city', ca.city,
          'postcode', ca.postcode
        ),
        JSON_OBJECT(
          'id', s.id,
          'addressId', a.id,
          'siteId', s.id,
          'location', a.location,
          'geometry', a.geometry,
          'city', a.city,
          'postcode', a.postcode
        )
      ) reference,
      JSON_OBJECT(
        'id', w.id,
        'workId', w.id,
        'addressId', a.id,
        'description', w.description,
        'custId', w.custId,
        'siteId', w.siteId,
        'category', w.category,
        'workType', t.tag,
        'ctime', w.ctime,
        'status', w.status
      ) content
      FROM work w
        INNER JOIN customer c ON c.id=w.custId
        INNER JOIN `site` s ON w.siteId=s.id 
        INNER JOIN `address` a ON s.addressId=a.id
        INNER JOIN `address` ca ON c.addressId=ca.id
        LEFT JOIN companyClass cc ON c.type = cc.id
        LEFT JOIN gender g ON g.id=c.gender
        LEFT JOIN `workType` t ON t.id=w.category
        WHERE 
          IF(_description IS NULL, 1, w.description REGEXP _description) AND
          IF(_housenumber IS NULL, 1, a.housenumber REGEXP _housenumber) AND
          IF(_streettype IS NULL, 1, a.streettype REGEXP _streettype) AND
          IF(_street IS NULL, 1, a.streetname REGEXP _street) AND
          IF(_city IS NULL, 1, a.city  REGEXP _city) AND
          IF(_postcode IS NULL, 1, a.postcode=_postcode) 
        ORDER BY
        CASE WHEN LCASE(_order) = 'asc' THEN a.streetname END ASC,
        CASE WHEN LCASE(_order) = 'desc' THEN a.streetname END DESC
      LIMIT _offset ,_range;
END$

DELIMITER ;
