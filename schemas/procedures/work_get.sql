
DELIMITER $

DROP PROCEDURE IF EXISTS `work_get`$
CREATE PROCEDURE `work_get`(
  IN _workId INTEGER
)
BEGIN
  SELECT 
    w.*,
    w.id workId,
    a.id addressId,
    t.tag `type`,
    t.tag `workType`,
    JSON_OBJECT(
      'siteId', s.id,
      'addressId', a.id,
      'countrycode', a.countrycode,
      'location', a.location,
      'postcode', a.postcode,
      'city', a.city,
      'geometry', a.geometry,
      'ctime', a.ctime
    )`site`,
    JSON_OBJECT(
      'id', c.id,
      'addressId', ca.id,
      'custId', c.id,
      'gender', g.shortTag,
      'companyclass', cc.tag,
      'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
      'location', ca.location,
      'geometry', ca.geometry,
      'city', ca.city,
      'postcode', ca.postcode
    ) customer
    FROM work w
      INNER JOIN customer c ON c.id=w.custId
      INNER JOIN site s ON s.id=w.siteId AND s.custId=c.id
      INNER JOIN `address` a ON s.addressId=a.id
      INNER JOIN `address` ca ON c.addressId=ca.id
      LEFT JOIN gender g ON g.id=c.gender
      LEFT JOIN companyClass cc ON c.type = cc.id
      LEFT JOIN `workType` t ON t.id=w.category
      WHERE w.id = _workId;
END$

DELIMITER ;
