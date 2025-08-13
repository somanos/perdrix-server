
DELIMITER $

DROP PROCEDURE IF EXISTS `customer_create`$
CREATE PROCEDURE `customer_create`(
  IN _args JSON
)
BEGIN
  DECLARE _category INTEGER;
  DECLARE _companyname VARCHAR(512);
  DECLARE _companyclass VARCHAR(128) DEFAULT "";
  DECLARE _companycode INTEGER;
  DECLARE _addressId INTEGER;
  DECLARE _gcode INTEGER DEFAULT 0;
  DECLARE _gender VARCHAR(128) DEFAULT "";
  DECLARE _lastname VARCHAR(512);
  DECLARE _firstname VARCHAR(512);
  DECLARE _id INTEGER;


  SELECT IFNULL(JSON_VALUE(_args, "$.category"), 0) INTO _category;
  SELECT IFNULL(JSON_VALUE(_args, "$.companyname"), "") INTO _companyname;
  SELECT IFNULL(JSON_VALUE(_args, "$.companyclass"), "") INTO _companyclass;
  SELECT IFNULL(JSON_VALUE(_args, "$.gender"), "") INTO _gender;
  SELECT IFNULL(JSON_VALUE(_args, "$.lastname"), "") INTO _lastname;
  SELECT IFNULL(JSON_VALUE(_args, "$.firstname"), "") INTO _firstname;
  SELECT IFNULL(JSON_VALUE(_args, "$.id"), 0) INTO _id;

  SELECT JSON_VALUE(_args, "$.addressId") INTO  _addressId;

  SELECT id FROM companyClass WHERE tag=_companyclass INTO _companycode;
  SELECT id FROM gender WHERE longTag=_gender OR shortTag=_gender INTO _gcode;

  IF _companycode IS NULL THEN 
    INSERT INTO companyClass SELECT NULL, _companyclass;
    SELECT id FROM companyClass WHERE tag=_companyclass INTO _companycode;
  END IF;


  CALL adress_get_or_create(_args, _addressId);
  IF _id IS NULL OR _id=0 THEN 
    INSERT INTO customer 
      SELECT NULL,
      _category,
      _companycode,
      _companyname,
      _gcode,
      _lastname,
      _firstname,
      _addressId,
      UNIX_TIMESTAMP();

    SELECT max(id) FROM `customer` INTO _id;
    IF skip_number(_id) THEN
      DELETE FROM `customer` WHERE id=_id;
      INSERT INTO customer 
        SELECT _id+1,
        _category,
        _companycode,
        _companyname,
        _gcode,
        _lastname,
        _firstname,
        _addressId,
        UNIX_TIMESTAMP();
    END IF;
  ELSE
    REPLACE INTO customer 
      SELECT _id,
      _category,
      _companycode,
      _companyname,
      _gcode,
      _lastname,
      _firstname,
      _addressId,
      UNIX_TIMESTAMP();
  END IF;

  SELECT max(id) FROM `customer` INTO _id;
  CALL seo_index(CONCAT(_lastname, ' ', _firstname), 'custName', JSON_OBJECT(
    'id', _id,
    'table', 'customer'
  ));
  CALL customer_get(_id);
END$

DELIMITER ;
