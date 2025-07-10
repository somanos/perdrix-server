
DELIMITER $

DROP PROCEDURE IF EXISTS `search_customerPoc`$
CREATE PROCEDURE `search_customerPoc`(
  IN _args JSON
)
BEGIN
  DECLARE _key TEXT;
  DECLARE _offset INTEGER UNSIGNED;
  DECLARE _range INTEGER UNSIGNED;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'lastname';
  DECLARE _lastname TEXT;
  DECLARE _firstname TEXT;
  DECLARE _phones TEXT;
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
  SELECT JSON_VALUE(_args, "$.lastname") INTO _lastname;
  SELECT JSON_VALUE(_args, "$.firstname") INTO _firstname;
  SELECT JSON_VALUE(_args, "$.phones") INTO _phones;
  SELECT JSON_VALUE(_args, "$.street") INTO _street;
  SELECT JSON_VALUE(_args, "$.housenumber") INTO _housenumber;
  SELECT JSON_VALUE(_args, "$.streettype") INTO _streettype;
  SELECT JSON_VALUE(_args, "$.city") INTO _city;
  SELECT JSON_VALUE(_args, "$.postcode") INTO _postcode;

  CALL yp.pageToLimits(_page, _offset, _range);
  SELECT 
      p.id, 
      p.lastname,
      p.firstname,
      g.shortTag,
      'poc' `type`,
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
        )
      ) reference,
      JSON_OBJECT(
        'id', p.id,
        'pocId', p.id,
        'category', 'customer',
        'gender', g.shortTag,
        'lastname', p.lastname,
        'firstname', p.firstname,
        'pocName', normalize_name(1, '', p.lastname, p.firstname) ,
        'email', p.email,
        'phones', p.phones
      ) content
      FROM customerPoc p
        INNER JOIN poc_map m ON m.pocId=p.id AND m.category='customer'
        INNER JOIN customer c ON c.id=m.custId
        INNER JOIN `address` ca ON c.addressId=ca.id
        LEFT JOIN companyClass cc ON c.type = cc.id
        LEFT JOIN gender g ON g.id=p.gender
        WHERE 
          IF(_lastname IS NULL, 1, p.lastname REGEXP _lastname) AND
          IF(_firstname IS NULL, 1, p.firstname REGEXP _firstname) AND
          IF(_phones IS NULL, 1, p.phones REGEXP _phones) AND
          IF(_housenumber IS NULL, 1, ca.housenumber REGEXP _housenumber) AND
          IF(_streettype IS NULL, 1, ca.streettype REGEXP _streettype) AND
          IF(_street IS NULL, 1, ca.streetname REGEXP _street) AND
          IF(_city IS NULL, 1, ca.city  REGEXP _city) AND
          IF(_postcode IS NULL, 1, ca.postcode=_postcode) 
        ORDER BY
        CASE WHEN LCASE(_order) = 'asc' THEN p.lastname END ASC,
        CASE WHEN LCASE(_order) = 'desc' THEN p.lastname END DESC
      LIMIT _offset ,_range;
END$

DELIMITER ;
