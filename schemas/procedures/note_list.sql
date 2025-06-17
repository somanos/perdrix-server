
DELIMITER $

DROP PROCEDURE IF EXISTS `note_list`$
CREATE PROCEDURE `note_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _addressId INTEGER ;
  DECLARE _workId INTEGER ;
  DECLARE _order VARCHAR(20) DEFAULT 'desc';

  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'desc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;

  SELECT JSON_VALUE(_args, "$.workId") INTO _workId;
  SELECT JSON_VALUE(_args, "$.addressId") INTO _addressId;

  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT
    n.id,
    a.id addressId,
    n.custId,
    n.workId,
    n.siteId,
    n.description,
    n.ctime,
    n.docId,
    t.tag workType,
    _page `page`,
    JSON_OBJECT(
      'id', s.id,
      'countrycode', s.countrycode,
      'location', s.location,
      'postcode', s.postcode,
      'citycode', s.citycode,
      'city', s.city,
      'geometry', s.geometry,
      'ctime', s.ctime
    ) `site`,
    JSON_OBJECT(
      'id', w.id,
      'description', w.description,
      'ctime', w.ctime
    ) `work`
  FROM note n
    INNER JOIN work w ON w.id=n.workId
    INNER JOIN `site` s ON s.id=n.siteId
    INNER JOIN `address` a ON s.addressId=a.id
    LEFT JOIN `workType` t ON t.id=w.category
    WHERE 
      IF (_workId IS NULL, 1, n.workId=_workId) AND
      IF (_addressId IS NULL, 1, a.id=_addressId) 
  ORDER BY 
    CASE WHEN LCASE(_order) = 'asc' THEN n.ctime END ASC,
    CASE WHEN LCASE(_order) = 'desc' THEN n.ctime END DESC
    LIMIT _offset ,_range;
END$

DELIMITER ;
