
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
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _custId INTEGER ;
  DECLARE _siteId INTEGER ;
  DECLARE _words TEXT;


  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'name') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_VALUE(_args, "$.siteId") INTO _siteId;
  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT
    w.*,
    q.id quoteId,
    t.tag `type`,
    JSON_OBJECT(
      'chrono', q.chrono,
      'description', q.description,
      'ht', q.ht,
      'tva', q.tva,
      'ttc', q.ttc,
      'discount', q.discount,
      'folderId', q.folderId,
      'ctime', q.ctime,
      'status', q.status
    ) `quote`,
    JSON_OBJECT(
      'countrycode', s.countrycode,
      'location', s.location,
      'postcode', s.postcode,
      'city', s.city,
      'lat', s.lattitude,
      'lon', s.longitude,
      'ctime', s.ctime,
      'statut', s.statut
    ) `site`
  FROM work w
    INNER JOIN quotation q ON w.custId=q.custId and w.id=q.workId
    INNER JOIN `site` s ON s.custId=w.custId AND w.siteId=s.id
    INNER JOIN `workType` t ON t.id=w.category
    WHERE w.custId=_custId AND IF(_siteId IS NULL, 1, w.siteId=_siteId)
    LIMIT _offset ,_range;
END$

DELIMITER ;
