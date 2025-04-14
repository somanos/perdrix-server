
DELIMITER $

DROP PROCEDURE IF EXISTS `work_details`$
CREATE PROCEDURE `work_details`(
  IN _workId INTEGER
)
BEGIN

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
      'nid', q.folderId,
      'hub_id', _hub_id,
      'filepath', filepath(q.folderId),
      'ctime', q.ctime,
      'status', q.status
    ) `quote`,
    JSON_OBJECT(
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
    LEFT JOIN quotation q ON w.custId=q.custId AND w.id=q.workId
    INNER JOIN `site` s ON s.custId=w.custId AND w.siteId=s.id
    INNER JOIN `workType` t ON t.id=w.category
    WHERE w.id=_workId
    ORDER BY q.chrono DESC LIMIT 1;
END$

DELIMITER ;
