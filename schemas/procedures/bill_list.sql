
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
  DECLARE _siteId INTEGER ;
  DECLARE _status JSON ;
  DECLARE _words TEXT;
  DECLARE _i TINYINT(6) unsigned DEFAULT 0;


  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'name') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  SELECT JSON_EXTRACT(_args, "$.status") INTO _status;
  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_VALUE(_args, "$.siteId") INTO _siteId;
  CALL yp.pageToLimits(_page, _offset, _range);

  DROP TABLE IF EXISTS _filter;
  CREATE TEMPORARY TABLE _filter ( val INTEGER);
  IF JSON_TYPE(_status) = 'ARRAY' AND JSON_LENGTH(_status)>0 THEN 
    WHILE _i < JSON_LENGTH(_status) DO 
      INSERT INTO _filter SELECT JSON_VALUE(_status, CONCAT("$[", _i, "]"));
      SELECT _i + 1 INTO _i;
    END WHILE;
  ELSE 
    INSERT INTO _filter SELECT DISTINCT `status` FROM bill;
  END IF;

  SELECT id FROM yp.entity WHERE db_name=database() INTO _hub_id;

  SELECT
    w.*,
    w.id workId,
    b.id billId,
    t.tag `type`,
    t.tag `workType`,
    _page `page`,
    JSON_OBJECT(
      'id', b.id,
      'custId', w.custId,
      'chrono', b.chrono,
      'description', b.description,
      'ht', b.ht,
      'tva', b.tva,
      'ttc', b.ttc,
      'nid', b.docId,
      'hub_id', _hub_id,
      'filepath', filepath(b.docId),
      'ctime', b.ctime,
      'status', b.status
    ) `bill`,
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
    LEFT JOIN bill b ON w.custId=b.custId AND w.id=b.workId
    INNER JOIN `site` s ON s.custId=w.custId AND w.siteId=s.id
    -- INNER JOIN `_filter` f ON f.val=b.status
    LEFT JOIN `workType` t ON t.id=w.category
    WHERE w.custId=_custId
    ORDER BY b.ctime DESC
    LIMIT _offset ,_range;
END$

DELIMITER ;
