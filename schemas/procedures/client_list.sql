
DELIMITER $

DROP PROCEDURE IF EXISTS `client_list`$
CREATE PROCEDURE `client_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'nom';
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _page INTEGER DEFAULT 1;

  CALL yp.pageToLimits(_page, _offset, _range);  
  
  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'nom') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;

  SELECT 
    c.id clientId, 
    IF(c.type = 0, 'physique', 'morale') ptype,
    ts.tag,
    ci.shortTag,
    ci.longTag,
    IF(c.nom='', c.societe, c.nom) nom,
    c.prenom,
    c.numVoie,
    v.shortTag typeVoie,
    v.longTag typeVoieLong,
    c.nomVoie,
    c.codePostal,
    (SELECT COALESCE(c.localite, designation) FROM localite WHERE codePostal=c.codePostal) localite
  FROM client c
    LEFT JOIN typeSoc ts ON c.type = ts.id
    LEFT JOIN civilite ci ON c.genre = ci.id
    LEFT JOIN typeVoie v ON c.codeVoie = v.id

  ORDER BY 
    CASE WHEN LCASE(_sort_by) = 'id' and LCASE(_order) = 'asc' THEN nom END ASC,
    CASE WHEN LCASE(_sort_by) = 'id' and LCASE(_order) = 'desc' THEN nom END DESC,
    CASE WHEN LCASE(_sort_by) = 'nom' and LCASE(_order) = 'asc' THEN nom END ASC,
    CASE WHEN LCASE(_sort_by) = 'nom' and LCASE(_order) = 'desc' THEN nom END DESC,
    CASE WHEN LCASE(_sort_by) = 'prenom' and LCASE(_order) = 'asc' THEN prenom END ASC,
    CASE WHEN LCASE(_sort_by) = 'prenom' and LCASE(_order) = 'desc' THEN prenom END DESC,
    CASE WHEN LCASE(_sort_by) = 'nomVoie' and LCASE(_order) = 'asc' THEN nomVoie END ASC,
    CASE WHEN LCASE(_sort_by) = 'nomVoie' and LCASE(_order) = 'desc' THEN nomVoie END DESC,
    CASE WHEN LCASE(_sort_by) = 'ctime' and LCASE(_order) = 'asc' THEN ctime END ASC,
    CASE WHEN LCASE(_sort_by) = 'ctime' and LCASE(_order) = 'desc' THEN ctime END DESC
  LIMIT _offset ,_range;
END$

DELIMITER ;
