
DELIMITER $

DROP PROCEDURE IF EXISTS `work_search`$
CREATE PROCEDURE `work_search`(
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
    w.*,
    s.city,
    wt.tag `type`,
    _page `page`,
    JSON_VALUE(s.location, "$[2]") street,
    JSON_OBJECT(
      'custId', w.custId,
      'countrycode', s.countrycode,
      'location', s.location,
      'postcode', s.postcode,
      'city', s.city,
      'geometry', s.geometry,
      'ctime', s.ctime,
      'statut', s.statut,
      'siteId', s.id,
      'id', s.id
    ) `site`
    FROM work w
      INNER JOIN `site` s ON w.siteId=s.id AND w.custId=s.custId
      INNER JOIN workType wt ON w.category=wt.id
      HAVING w.custId=_custId AND 
      (street REGEXP _words OR s.city REGEXP _words)
    LIMIT _offset ,_range;
END$

DELIMITER ;
