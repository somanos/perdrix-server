
DELIMITER $

DROP PROCEDURE IF EXISTS `yp_perdrix_init`$
CREATE PROCEDURE `yp_perdrix_init`(
  IN _api_key VARCHAR(128),
  IN _hostname VARCHAR(128)
)
BEGIN
  DECLARE _db_name VARCHAR(512);
  DECLARE _vhost VARCHAR(512);
  DECLARE _uid VARCHAR(16);
  DECLARE _hub_id VARCHAR(16);
  DECLARE _home_id VARCHAR(16);
  DECLARE _owner_id VARCHAR(16);

  SELECT  CONCAT(_hostname, '.', main_domain()) INTO _vhost;
  REPLACE INTO sys_conf SELECT 'map-tiler-api-key', _api_key;
  REPLACE INTO sys_conf SELECT 'address_api_endpoint', "https://api-adresse.data.gouv.fr/search/?q={0}&limit=10&autocomplete=1";
  REPLACE INTO sys_conf SELECT 'app_host', _vhost;

  SELECT db_name, e.id, e.home_id FROM vhost v INNER JOIN entity e USING(id) WHERE 
    fqdn=_vhost INTO _db_name, _hub_id, _home_id;
  
  REPLACE INTO sys_conf SELECT 'perdrix-hub', _hub_id;

  SELECT owner_id FROM hub WHERE id=_hub_id INTO _owner_id;

  SET @s = CONCAT("DELETE FROM ", _db_name, ".media WHERE parent_id!='0'");
  PREPARE stmt FROM @s;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;

  SET @s = CONCAT("UPDATE ", _db_name, ".media SET id=? WHERE parent_id='0'");
  PREPARE stmt FROM @s;
  EXECUTE stmt USING _home_id;
  DEALLOCATE PREPARE stmt;

  SET @s = CONCAT("UPDATE ", _db_name, ".permission SET entity_id=? WHERE permission=63");
  PREPARE stmt FROM @s;
  EXECUTE stmt USING _owner_id;
  DEALLOCATE PREPARE stmt;

END$

DELIMITER ;
