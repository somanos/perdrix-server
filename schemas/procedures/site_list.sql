
DELIMITER $

DROP PROCEDURE IF EXISTS `site_list`$
CREATE PROCEDURE `site_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _custId INTEGER;
  DECLARE _filter JSON ;
  DECLARE _i TINYINT(6) unsigned DEFAULT 0;

  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO @_page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  CALL yp.pageToLimits(@_page, _offset, _range);

  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_EXTRACT(_args, "$.filter") INTO _filter;

  SET @stm = "ORDER BY";
  IF JSON_TYPE(_filter) = 'ARRAY' AND JSON_LENGTH(_filter)>0 THEN 
    WHILE _i < JSON_LENGTH(_filter) DO 
      SELECT JSON_EXTRACT(_filter, CONCAT("$[", _i, "]")) INTO @r;
      SELECT JSON_VALUE(@r, "$.name") INTO @_name;
      SELECT JSON_VALUE(@r, "$.value") INTO @_value;
      SELECT CONCAT(@stm, " ", @_name, " ", @_value) INTO @stm;
      IF(_i < JSON_LENGTH(_filter) - 1) THEN
        SELECT CONCAT(@stm, ",") INTO @stm;
      END IF;
      SELECT _i + 1 INTO _i;
    END WHILE;
  ELSE
    SELECT CONCAT(@stm, " ", "city asc, street asc, housenumber desc") INTO @stm;
  END IF;
  DROP TABLE IF EXISTS `_site`;

  CREATE TEMPORARY TABLE _site AS SELECT 
    @_page page,
    s.id,
    s.custId,
    a.id addressId,
    a.location,
    a.housenumber,
    a.streettype,
    a.streetname,
    a.streetname street,
    a.city,
    a.postcode,
    a.additional,
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
  FROM site s
    INNER JOIN customer c ON c.id=s.custId
    INNER JOIN `address` a ON s.addressId=a.id
    INNER JOIN `address` ca ON c.addressId=ca.id
    LEFT JOIN gender g ON g.id=c.gender
    LEFT JOIN companyClass cc ON c.type = cc.id    
  WHERE IF(_custId IS NULL, 1, s.custId=_custId);

  ALTER TABLE _site MODIFY customer JSON;

  SET @stm = CONCAT('SELECT * FROM _site ', @stm, " ", "LIMIT ?, ?");
  PREPARE stmt FROM @stm;
  EXECUTE stmt USING _offset, _range;
  DEALLOCATE PREPARE stmt;

END$

DELIMITER ;
