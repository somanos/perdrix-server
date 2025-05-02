
DELIMITER $

DROP PROCEDURE IF EXISTS `bill_update`$
CREATE PROCEDURE `bill_update`(
  IN _args JSON
)
BEGIN
  DECLARE _id INTEGER;
  DECLARE _description TEXT;
  DECLARE _ht DOUBLE;
  DECLARE _tva DOUBLE;
  DECLARE _ttc DOUBLE;
  DECLARE _docId VARCHAR(200);
  DECLARE _status INTEGER;

  SELECT JSON_VALUE(_args, "$.id") INTO _id;
  SELECT JSON_VALUE(_args, "$.description") INTO _description;
  SELECT JSON_VALUE(_args, "$.ht") INTO _ht;
  SELECT JSON_VALUE(_args, "$.tva") INTO _tva;
  SELECT JSON_VALUE(_args, "$.ttc") INTO _ttc;
  SELECT JSON_VALUE(_args, "$.docId") INTO _docId;
  SELECT JSON_VALUE(_args, "$.status") INTO _status;

  UPDATE bill SET `description`=_description WHERE id=_id AND _description IS NOT NULL;
  UPDATE bill SET `ht`=_ht WHERE id=_id AND _ht IS NOT NULL;
  UPDATE bill SET `tva`=_tva WHERE id=_id AND _tva IS NOT NULL;
  UPDATE bill SET `ttc`=_ttc WHERE id=_id AND _ttc IS NOT NULL;
  UPDATE bill SET `docId`=_docId WHERE id=_id AND _docId IS NOT NULL;
  UPDATE bill SET `status`=_status WHERE id=_id AND _status IS NOT NULL;

  CALL seo_index(_description, 'bill', JSON_OBJECT(
    'id', _id,
    'table', 'bill'
  ));

  CALL bill_get(_id);
END$

DELIMITER ;
