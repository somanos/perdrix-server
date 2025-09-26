
DELIMITER $

DROP PROCEDURE IF EXISTS `quote_get`$
CREATE PROCEDURE `quote_get`(
  IN _id INTEGER,
  IN _uid VARCHAR(20)
)
BEGIN
  DECLARE _home_id VARCHAR(20);
  DECLARE _hub_id VARCHAR(20);
  DECLARE _privilege INTEGER ;

  SELECT id FROM yp.entity WHERE db_name=database() INTO _hub_id;
  SELECT id, home_id FROM yp.entity WHERE db_name=database() INTO _hub_id, _home_id;
  SELECT user_permission(_uid, _home_id) FROM media WHERE id=_home_id INTO _privilege;
  SELECT 
    q.*,
    q.id quoteId,
    m.id nid,
    m.file_path filepath,
    m.user_filename filename,
    m.extension ext,
    _privilege privilege,
    _home_id home_id,
    _hub_id hub_id,
    JSON_OBJECT(
      'custId', s.custId,
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
    FROM `quote` q
      INNER JOIN `site` s ON s.id=q.siteId
      INNER JOIN `address` a ON s.addressId=a.id
      LEFT JOIN media m ON m.file_path=concat('/devis/',fiscalYear,'/odt/dev', q.chrono, '.odt')
      WHERE q.id = _id;
END$

DELIMITER ;
