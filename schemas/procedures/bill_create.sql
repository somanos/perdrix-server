-- id   | billNumber | custId | siteId | workId | chrono  | category | ht     | tva   | ttc    | description | docId          | ctime      | status | d                   |

DELIMITER $

DROP PROCEDURE IF EXISTS `bill_create`$
CREATE PROCEDURE `bill_create`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;
  DECLARE _siteId INTEGER;
  DECLARE _workId INTEGER;
  DECLARE _id INTEGER;
  DECLARE _ccode INTEGER;
  DECLARE _category VARCHAR(512) DEFAULT "Facture";

  DECLARE _description TEXT;
  DECLARE _ht DOUBLE;
  DECLARE _tva DOUBLE;
  DECLARE _ttc DOUBLE;
  DECLARE _discount DOUBLE;
  DECLARE _chrono VARCHAR(200);
  DECLARE _site JSON;

  SELECT IFNULL(JSON_VALUE(_args, "$.custId"), 0) INTO _custId;
  SELECT IFNULL(JSON_VALUE(_args, "$.siteId"), 0) INTO _siteId;
  SELECT IFNULL(JSON_VALUE(_args, "$.workId"), 0) INTO _workId;
  SELECT IFNULL(JSON_VALUE(_args, "$.category"), "Facture") INTO _category;
  SELECT IFNULL(JSON_VALUE(_args, "$.description"), "") INTO _description;

  SELECT JSON_VALUE(_args, "$.ht") INTO _ht;
  SELECT JSON_VALUE(_args, "$.tva") INTO _tva;
  SELECT JSON_VALUE(_args, "$.ttc") INTO _ttc;
  SELECT JSON_VALUE(_args, "$.discount") INTO _discount;

  SELECT JSON_EXTRACT(_args, "$.site") INTO _site;

  SELECT id FROM billType WHERE tag=_category INTO _ccode;

  IF _ccode IS NULL THEN 
    INSERT INTO billType SELECT NULL, _category, substring(_category, 1, 3);
    SELECT id FROM billType WHERE tag=_category INTO _ccode;
  END IF;

  IF _siteId IS NULL THEN
    SELECT IFNULL(JSON_VALUE(_site, "$.id"), 0) INTO _siteId;
  END IF;

  INSERT INTO bill 
    SELECT NULL,
    _custId,
    _siteId,
    _workId,
    bill_chrono(),
    fiscal_year(null),
    _ccode,
    _ht,
    _tva,      
    _ttc,      
    _description,
    NULL,
    UNIX_TIMESTAMP(),  
    0;

  SELECT max(id) FROM `bill` INTO _id;
  IF skip_number(_id) THEN
    DELETE FROM `bill` WHERE id=_id;
    INSERT INTO bill 
      SELECT _id+1,
      _custId,
      _siteId,
      _workId,
      bill_chrono(),
      fiscal_year(null),
      _ccode,
      _ht,
      _tva,      
      _ttc,      
      _description,
      NULL,
      UNIX_TIMESTAMP(),  
      0;
  END IF;

  CALL seo_index(_description, 'bill', JSON_OBJECT(
    'id', _id,
    'table', 'bill'
  ));
  CALL bill_get(_id);

END$

DELIMITER ;
