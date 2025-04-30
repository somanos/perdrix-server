
DELIMITER $

DROP PROCEDURE IF EXISTS `work_list`$
CREATE PROCEDURE `work_list`(
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
  DECLARE _filter JSON ;
  DECLARE _words TEXT;
  DECLARE _i TINYINT(6) unsigned DEFAULT 0;


  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'date') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;

  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;

  SELECT JSON_EXTRACT(_args, "$.filter") INTO _filter;
  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_VALUE(_args, "$.siteId") INTO _siteId;
  SELECT id FROM yp.entity WHERE db_name=database() INTO _hub_id;

  CALL yp.pageToLimits(_page, _offset, _range);

  DROP TABLE IF EXISTS _view;
  CREATE TEMPORARY TABLE _view LIKE work;
  ALTER TABLE _view ADD column city VARCHAR(200);
  ALTER TABLE _view ADD column `type` VARCHAR(100);
  ALTER TABLE _view ADD column `page` BIGINT;
  ALTER TABLE _view ADD column `site` JSON;
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
    SELECT CONCAT(@stm, " ", "ctime desc") INTO @stm;
  END IF;
  INSERT INTO _view SELECT
    w.*,
    s.city,
    t.tag `type`,
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
  FROM work w
    -- LEFT JOIN quotation q ON w.custId=q.custId AND w.id=q.workId
    -- LEFT JOIN bill b ON w.custId=b.custId AND w.id=b.workId
    INNER JOIN `site` s ON s.custId=w.custId AND w.siteId=s.id
    LEFT JOIN `workType` t ON t.id=w.category
    WHERE w.custId=_custId AND IFNULL(_siteId, w.siteId)=w.siteId
    LIMIT _offset ,_range;
  SET @stm = CONCAT("SELECT *, type workType FROM _view", " ", @stm);
  PREPARE stmt FROM @stm;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END$

DELIMITER ;
