
DELIMITER $

DROP PROCEDURE IF EXISTS `bill_details`$
CREATE PROCEDURE `bill_details`(
  IN _billId INTEGER
)
BEGIN

  SELECT
    w.*,
    b.id billId,
    JSON_OBJECT(
      'id', b.id,
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
    INNER JOIN `_filter` f ON f.val=b.status
    WHERE b.id=_billId;
END$

DELIMITER ;
