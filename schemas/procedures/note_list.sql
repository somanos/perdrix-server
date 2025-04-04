
DELIMITER $

DROP PROCEDURE IF EXISTS `note_list`$
CREATE PROCEDURE `note_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _custId INTEGER ;
  DECLARE _order VARCHAR(20) DEFAULT 'asc';

  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'desc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;

  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT
    n.id,
    n.custId,
    n.workId,
    n.siteId,
    n.description,
    n.ctime,
    n.folderId,
    t.tag workType,
    JSON_OBJECT(
      'countrycode', s.countrycode,
      'location', s.location,
      'postcode', s.postcode,
      'citycode', s.citycode,
      'city', s.city,
      'geometry', s.geometry,
      'ctime', s.ctime
    ) `site`,
    JSON_OBJECT(
      'description', w.description,
      'ctime', w.ctime
    ) `work`
  FROM note n
    LEFT JOIN `site` s ON s.id=n.siteId
    LEFT JOIN work w ON w.id=n.workId
    INNER JOIN `workType` t ON t.id=w.category
    WHERE n.custId = _custId 
  ORDER BY 
    CASE WHEN LCASE(_order) = 'asc' THEN n.ctime END ASC,
    CASE WHEN LCASE(_order) = 'desc' THEN n.ctime END DESC
    LIMIT _offset ,_range;
END$

DELIMITER ;
