
DELIMITER $

DROP PROCEDURE IF EXISTS `bill_list`$
CREATE PROCEDURE `bill_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'name';
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _hub_id VARCHAR(20);

  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _custId INTEGER ;
  DECLARE _fiscalYear INTEGER ;
  DECLARE _siteId INTEGER ;
  DECLARE _status BOOLEAN ;
  DECLARE _words TEXT;
  DECLARE _i TINYINT(6) unsigned DEFAULT 0;


  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'name') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  SELECT IFNULL(JSON_VALUE(_args, "$.fiscalYear"), 0) INTO _fiscalYear;
  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_VALUE(_args, "$.siteId") INTO _siteId;
  SELECT JSON_VALUE(_args, "$.status") INTO _status;
  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT id FROM yp.entity WHERE db_name=database() INTO _hub_id;

  SELECT
    b.*,
    t.tag `type`,
    t.tag `workType`,
    _page `page`,
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
  FROM bill b
    INNER JOIN work w ON w.id=b.workId
    INNER JOIN `site` s ON w.siteId=s.id
    LEFT JOIN `workType` t ON t.id=w.category
    WHERE 
      IF(_custId IS NULL, 1, w.custId=_custId) AND 
      IF(_siteId IS NULL, 1, b.siteId=_siteId) AND
      IF(_fiscalYear REGEXP "^ *([0-9]{4,4}) *$", fiscalYear=_fiscalYear, 1) AND
      IF(_status IS NULL, 1, b.status=1)
    ORDER BY b.ctime DESC
    LIMIT _offset ,_range;
END$

DELIMITER ;
