
DELIMITER $

DROP PROCEDURE IF EXISTS `site_poc_create`$
CREATE PROCEDURE `site_poc_create`(
  IN _args JSON
)
BEGIN
  DECLARE _custId INTEGER;
  DECLARE _addressId INTEGER;
  DECLARE _pocId INTEGER;
  DECLARE _siteId INTEGER;
  DECLARE _isNew INTEGER;
  DECLARE _role VARCHAR(200);
  DECLARE _gender VARCHAR(512);
  DECLARE _lastname VARCHAR(512) DEFAULT "";
  DECLARE _firstname VARCHAR(128) DEFAULT "";

  DECLARE _mobile VARCHAR(128) DEFAULT "";
  DECLARE _home VARCHAR(128) DEFAULT "";
  DECLARE _office VARCHAR(128) DEFAULT "";
  DECLARE _fax VARCHAR(128) DEFAULT "";

  DECLARE _email VARCHAR(512);
  DECLARE _city VARCHAR(512) DEFAULT "";
  DECLARE _streetname VARCHAR(512) DEFAULT "";

  DECLARE _phones JSON;
  DECLARE _reference JSON;
  DECLARE _address JSON;
  DECLARE _gcode INTEGER;

  SELECT IFNULL(JSON_VALUE(_args, "$.addressId"), 0) INTO _addressId;
  SELECT IFNULL(JSON_VALUE(_args, "$.custId"), 0) INTO _custId;
  SELECT IFNULL(JSON_VALUE(_args, "$.siteId"), 0) INTO _siteId;
  SELECT IFNULL(JSON_VALUE(_args, "$.role"), "") INTO _role;
  SELECT IFNULL(JSON_VALUE(_args, "$.gender"), "") INTO _gender;
  SELECT IFNULL(JSON_VALUE(_args, "$.lastname"), "") INTO _lastname;
  SELECT IFNULL(JSON_VALUE(_args, "$.firstname"), "") INTO _firstname;
  SELECT IFNULL(JSON_VALUE(_args, "$.email"), "") INTO _email;
  SELECT IFNULL(JSON_VALUE(_args, "$.mobile"), "") INTO _mobile;
  SELECT IFNULL(JSON_VALUE(_args, "$.home"), "") INTO _home;
  SELECT IFNULL(JSON_VALUE(_args, "$.office"), "") INTO _office;
  SELECT IFNULL(JSON_VALUE(_args, "$.fax"), "") INTO _fax;

  SELECT JSON_VALUE(_args, "$.addressId") INTO _addressId;
  SELECT JSON_VALUE(_args, "$.pocId") INTO _pocId;
  SELECT JSON_EXTRACT(_args, "$.address") INTO _address;

  SELECT JSON_ARRAY(
    _office, _home, _mobile, _fax
  ) INTO _phones;

  SELECT id FROM gender WHERE shortTag=_gender OR longTag=_gender INTO _gcode;

  IF _addressId IS NULL AND _address IS NOT NULL THEN
    CALL adress_get_or_create(_address, _addressId);
  END IF;

  IF _addressId IS NULL THEN
    SELECT addressId FROM site WHERE id=_custId INTO _addressId;
  END IF;
  SET _isNew = 1;
  IF _pocId IS NULL THEN
    INSERT INTO sitePoc 
      SELECT 
        NULL,
        _custId,
        _siteId,
        _role,
        _gcode,
        _lastname,
        _firstname,
        _email,
        _office,
        _home, 
        _mobile, 
        _fax,
        UNIX_TIMESTAMP(),
        1;
    SELECT max(id) FROM sitePoc INTO _pocId;
    IF skip_number(_pocId) THEN
      DELETE FROM `sitePoc` WHERE id=_pocId;
      INSERT INTO sitePoc 
        SELECT _pocId+1,
          _custId,
          _siteId,
          _role,
          _gcode,
          _lastname,
          _firstname,
          _email,
          _office,
          _home, 
          _mobile, 
          _fax,
          UNIX_TIMESTAMP(),
          1;
    END IF;
    SELECT max(id) FROM sitePoc INTO _pocId;
    INSERT INTO poc_map SELECT _pocId, 'site', _custId, _siteId, _addressId;
  ELSE
    SET _isNew = 0;
    UPDATE sitePoc SET
      custId=_custId,
      siteId=_siteId,
      role= _role,
      gender= _gcode,
      lastname=_lastname,
      firstname=_firstname,
      email=_email,
      office=_office,
      home=_home, 
      mobile=_mobile, 
      fax=_fax
    WHERE id=_pocId;
  END IF;


  SELECT JSON_OBJECT(
    'id', _pocId,
    'table', 'sitePoc'
  ) INTO _reference;

  CALL seo_index(CONCAT(_lastname, ' ', _firstname), 'site_poc_name', _reference);
  SELECT city, CONCAT(streettype, ' ', streetname) FROM address WHERE id=_addressId 
    INTO _city, _streetname;

  IF _city IS NOT NULL THEN
    CALL seo_index(_city, 'site_poc_city', _reference);
  END IF;

  IF _streetname IS NOT NULL THEN
    CALL seo_index(_streetname, 'site_poc_streetName', _reference);
  END IF;

  SELECT 
    p.*,
    _isNew isNew,
    JSON_OBJECT(
      'siteId', m.siteId,
      'custId', m.custId,
      'addressId', m.addressId,
      'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
      'companyclass', cc.tag,
      'gender', g.shortTag,
      'location', ca.location,
      'city', ca.city,
      'geometry', ca.geometry,
      'postcode', ca.postcode
    ) customer,
    JSON_OBJECT(
      'siteId', m.siteId,
      'custId', m.custId,
      'addressId', m.addressId,
      'location', a.location,
      'city', a.city,
      'geometry', a.geometry,
      'postcode', a.postcode
    ) site
    FROM sitePoc p 
      INNER JOIN poc_map m ON m.pocId=p.id
      INNER JOIN customer c ON m.custId=c.id
      INNER JOIN site s ON m.siteId=s.id AND m.custId=s.custId
      INNER JOIN `address` a ON s.addressId=a.id AND m.addressId=s.addressId
      INNER JOIN `address` ca ON c.addressId=ca.id AND m.custId=c.id AND p.id=m.pocId
      LEFT JOIN companyClass cc ON c.type = cc.id
      LEFT JOIN gender g ON g.id=c.gender
    WHERE p.id=_pocId;
END$

DELIMITER ;
