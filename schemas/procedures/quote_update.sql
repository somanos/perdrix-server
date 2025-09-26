
DELIMITER $

DROP PROCEDURE IF EXISTS `quote_update`$
CREATE PROCEDURE `quote_update`(
  IN _args JSON
)
BEGIN
  DECLARE _id INTEGER;
  DECLARE _description TEXT;
  DECLARE _ht DOUBLE;
  DECLARE _tva DOUBLE;
  DECLARE _ttc DOUBLE;
  DECLARE _discount DOUBLE;
  DECLARE _docId VARCHAR(200);
  DECLARE _status INTEGER;
  DECLARE _uid VARCHAR(20);

  SELECT JSON_VALUE(_args, "$.id") INTO _id;
  SELECT JSON_VALUE(_args, "$.description") INTO _description;
  SELECT JSON_VALUE(_args, "$.ht") INTO _ht;
  SELECT JSON_VALUE(_args, "$.tva") INTO _tva;
  SELECT JSON_VALUE(_args, "$.ttc") INTO _ttc;
  SELECT JSON_VALUE(_args, "$.discount") INTO _discount;
  SELECT JSON_VALUE(_args, "$.docId") INTO _docId;
  SELECT JSON_VALUE(_args, "$.status") INTO _status;
  SELECT JSON_VALUE(_args, "$.uid") INTO _uid;

  UPDATE quote SET `description`=_description WHERE id=_id AND _description IS NOT NULL;
  UPDATE quote SET `ht`=_ht WHERE id=_id AND _ht IS NOT NULL;
  UPDATE quote SET `tva`=_tva WHERE id=_id AND _tva IS NOT NULL;
  UPDATE quote SET `ttc`=_ttc WHERE id=_id AND _ttc IS NOT NULL;
  UPDATE quote SET `discount`=_discount WHERE id=_id AND _discount IS NOT NULL;
  UPDATE quote SET `docId`=_docId WHERE id=_id AND _docId IS NOT NULL;
  UPDATE quote SET `status`=_status WHERE id=_id AND _status IS NOT NULL;

  CALL seo_index(_description, 'quote', JSON_OBJECT(
    'id', _id,
    'table', 'quote'
  ));

  CALL quote_get(_id, _uid);
END$

DELIMITER ;
