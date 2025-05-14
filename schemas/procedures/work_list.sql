
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
  ALTER TABLE _view ADD column workId INTEGER;
  ALTER TABLE _view ADD column city VARCHAR(200);
  ALTER TABLE _view ADD column `type` VARCHAR(100);
  ALTER TABLE _view ADD column `page` BIGINT;
  ALTER TABLE _view ADD column `bill` BIGINT;
  ALTER TABLE _view ADD column `quote` BIGINT;
  ALTER TABLE _view ADD column `note` BIGINT;
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

  DROP TABLE IF EXISTS _count_b;
  CREATE TEMPORARY TABLE _count_b(
    workId INTEGER,
    count INTEGER,
    PRIMARY KEY(workId)
  );
  INSERT INTO _count_b SELECT workId, count(*) FROM bill GROUP BY workId;

  DROP TABLE IF EXISTS _count_q;
  CREATE TEMPORARY TABLE _count_q(
    workId INTEGER,
    count INTEGER,
    PRIMARY KEY(workId)
  );
  INSERT INTO _count_q SELECT workId, count(*) FROM quotation GROUP BY workId;

  DROP TABLE IF EXISTS _count_n;
  CREATE TEMPORARY TABLE _count_n(
    workId INTEGER,
    count INTEGER,
    PRIMARY KEY(workId)
  );
  INSERT INTO _count_n SELECT workId, count(*) FROM note GROUP BY workId;

  INSERT INTO _view SELECT
    w.*,
    w.id workId,
    s.city,
    t.tag `type`,
    _page `page`,
    IFNULL(cb.count, 0) bill,
    IFNULL(cq.count, 0) quote,
    IFNULL(cn.count, 0) note,
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
    INNER JOIN `site` s ON s.custId=w.custId AND w.siteId=s.id
    LEFT JOIN `workType` t ON t.id=w.category
    LEFT JOIN _count_b cb ON cb.workId=w.id
    LEFT JOIN _count_q cq ON cq.workId=w.id
    LEFT JOIN _count_n cn ON cn.workId=w.id
    WHERE w.custId=_custId AND IFNULL(_siteId, w.siteId)=w.siteId;
  SET @stm = CONCAT("SELECT *, type workType FROM _view", " ", @stm, " ", "LIMIT ?, ?");
  PREPARE stmt FROM @stm;
  EXECUTE stmt USING _offset, _range;
  DEALLOCATE PREPARE stmt;
END$

DELIMITER ;
