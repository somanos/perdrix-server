
DELIMITER $

DROP PROCEDURE IF EXISTS `quote_create`$
CREATE PROCEDURE `quote_create`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;
  DECLARE _siteId INTEGER;
  DECLARE _workId INTEGER;
  DECLARE _id INTEGER;
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
  SELECT IFNULL(JSON_VALUE(_args, "$.description"), "") INTO _description;

  SELECT JSON_VALUE(_args, "$.ht") INTO _ht;
  SELECT JSON_VALUE(_args, "$.tva") INTO _tva;
  SELECT JSON_VALUE(_args, "$.ttc") INTO _ttc;
  SELECT JSON_VALUE(_args, "$.discount") INTO _discount;

  SELECT JSON_EXTRACT(_args, "$.site") INTO _site;

  IF _siteId IS NULL THEN
    SELECT IFNULL(JSON_VALUE(_site, "$.id"), 0) INTO _siteId;
  END IF;

  REPLACE INTO quotation 
    SELECT NULL,
    _custId,
    _siteId,
    _workId,
    quote_chrono(_workId),
    fiscal_year(null),
    _description,
    _ht,
    _tva,      
    _ttc,      
    _discount, 
    NULL,
    UNIX_TIMESTAMP(),  
    0;

  SELECT max(id) FROM `quotation` INTO _id;
  IF skip_number(_id) THEN
    DELETE FROM `quotation` WHERE id=_id;
    REPLACE INTO quotation 
      SELECT _id+1,
      _custId,
      _siteId,
      _workId,
      quote_chrono(_workId),
      fiscal_year(null),
      _description,
      _ht,
      _tva,      
      _ttc,      
      _discount, 
      NULL,
      UNIX_TIMESTAMP(),  
        0;
  END IF;


  CALL seo_index(_description, 'quotation', JSON_OBJECT(
    'id', _id,
    'table', 'note'
  ));
  CALL quote_get(_id);
END$

DELIMITER ;
