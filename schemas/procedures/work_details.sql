
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
    a.id addressId,
    q.id quoteId,
    t.tag `type`,
    (SELECT count(*) FROM bill WHERE workId=_workId) bill,
    (SELECT count(*) FROM quote WHERE workId=_workId) quote,
    (SELECT count(*) FROM note WHERE workId=_workId) note,
    JSON_OBJECT(
      'custId', w.custId,
      'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
      'countrycode', ca.countrycode,
      'location', ca.location,
      'postcode', ca.postcode,
      'city', ca.city,
      'geometry', ca.geometry
    ) `customer`,
    JSON_OBJECT(
      'custId', w.custId,
      'countrycode', a.countrycode,
      'location', a.location,
      'postcode', a.postcode,
      'city', a.city,
      'geometry', a.geometry,
      'ctime', s.ctime,
      'statut', s.statut,
      'siteId', s.id,
      'id', s.id
    ) `site`
  FROM work w
    LEFT JOIN quote q ON w.custId=q.custId AND w.id=q.workId
    INNER JOIN `site` s ON s.custId=w.custId AND w.siteId=s.id
    INNER JOIN `customer` c ON c.id=w.custId 
    INNER JOIN `address` a ON s.addressId=a.id
    INNER JOIN `address` ca ON c.addressId=ca.id
    INNER JOIN `workType` t ON t.id=w.category
    WHERE w.id=_workId
    ORDER BY q.chrono DESC LIMIT 1;
END$

DELIMITER ;
