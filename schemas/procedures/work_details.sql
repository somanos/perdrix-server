
DELIMITER $

DROP PROCEDURE IF EXISTS `work_details`$
CREATE PROCEDURE `work_details`(
  IN _workId INTEGER
)
BEGIN
  DECLARE _hub_id VARCHAR(16) ;
  SELECT id FROM yp.entity WHERE db_name=DATABASE() INTO _hub_id;
  SELECT
    w.*,
    w.id workId,
    q.id quoteId,
    t.tag `type`,
    (SELECT count(*) FROM bill WHERE workId=_workId) bill,
    (SELECT count(*) FROM quotation WHERE workId=_workId) quote,
    (SELECT count(*) FROM note WHERE workId=_workId) note,
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
