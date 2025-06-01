
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
  INSERT INTO _count_q SELECT workId, count(*) FROM quote GROUP BY workId;

  DROP TABLE IF EXISTS _count_n;
  CREATE TEMPORARY TABLE _count_n(
    workId INTEGER,
    count INTEGER,
    PRIMARY KEY(workId)
  );
  INSERT INTO _count_n SELECT workId, count(*) FROM note GROUP BY workId;

  SELECT 
    w.*,
    w.id workId,
    s.city,
    t.tag `type`,
    _page `page`,
    JSON_VALUE(s.location, "$[2]") street,
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
      HAVING w.custId=_custId AND 
      (street REGEXP _words OR s.city REGEXP _words OR `description` REGEXP _words)
    LIMIT _offset ,_range;
END$

DELIMITER ;
