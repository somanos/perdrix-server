
DELIMITER $

DROP PROCEDURE IF EXISTS `seo_search`$
CREATE PROCEDURE `seo_search`(
  IN _args JSON,
  IN _tables JSON
)
BEGIN
  DECLARE _key TEXT;
  DECLARE _offset INTEGER UNSIGNED;
  DECLARE _range INTEGER UNSIGNED;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'nom';
  DECLARE _words TEXT;
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _page INTEGER DEFAULT 1;

  DROP TABLE IF EXISTS _results;
  CREATE TEMPORARY TABLE _results(
    `ikey` text DEFAULT NULL,
    `ref_id` varchar(64) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
    `word` varchar(300) NOT NULL,
    `relevance` double DEFAULT 0
  );

  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'nom') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.words"), "") INTO _words;

  CALL yp.pageToLimits(_page, _offset, _range);
  SELECT REGEXP_REPLACE(_words, '^ +| +$', '') INTO _key;
  SELECT REGEXP_REPLACE(_key, ' +', ',') INTO _key;
  
  INSERT INTO _results SELECT 
    _key ikey, ref_id, word, MATCH(word) AGAINST(_key) relevance 
      FROM seo WHERE MATCH(word) AGAINST (_key IN BOOLEAN mode) 
      ORDER BY relevance DESC LIMIT _offset, _range;

  DROP TABLE IF EXISTS _view;
  CREATE TEMPORARY TABLE _view(
    itemId INTEGER UNSIGNED,
    word VARCHAR(512),
    relevance DOUBLE DEFAULT 0,
    ctype VARCHAR(16),
    content JSON,
    ctime INT(11) UNSIGNED,
    PRIMARY KEY (itemId, ctype)
  );

  DROP TABLE IF EXISTS _types;
  CREATE TEMPORARY TABLE _types(
    ctype VARCHAR(32)
  );
  SELECT _tables INTO @_tables;

  IF _tables IS NULL OR json_array_contains(_tables, "chantier") THEN
    REPLACE INTO _view SELECT 
      c.id, 
      r.word,
      r.relevance,
      'chantier',
      JSON_OBJECT(
        'clientId', cl.id,
        'civilite', ci.shortTag,
        'stype', ts.tag,
        'nomClient', IF(cl.categorie=0, cl.societe, CONCAT(cl.nom, IF(cl.prenom != '', CONCAT(' ', cl.prenom), ''))),
        'numVoie', c.numVoie,
        'typeVoie', v.shortTag,
        'nomVoie', c.nomVoie,
        'localite', IF(l.designation !='', l.designation, c.codePostal),
        'codepostal', IF(l.designation !='', l.codePostal, '')
      ) content,
      c.ctime
      FROM chantier c 
        INNER JOIN seo_object o USING(id) 
        INNER JOIN client cl ON cl.id=c.clientId AND c.id=o.id
        INNER JOIN _results r USING(ref_id) 
        LEFT JOIN civilite ci ON ci.id=cl.genre
        LEFT JOIN typeSoc ts ON cl.type = ts.id
        LEFT JOIN localite l ON c.codePostal=l.codePostal
        LEFT JOIN typeVoie v ON c.codeVoie=v.id
        WHERE o.table = 'chantier';
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "client") THEN
    REPLACE INTO _view SELECT 
      c.id, 
      r.word,
      r.relevance,
      'client',
      JSON_OBJECT(
        'id', c.id,
        'nom', IF(c.categorie=0, c.societe, CONCAT(c.nom, IF(c.prenom != '', CONCAT(' ', c.prenom), ''))),
        'stype', ts.tag,
        'civilite', ci.shortTag,
        'numVoie', c.numVoie,
        'typeVoie', v.shortTag,
        'nomVoie', c.nomVoie,
        'localite', IF(l.designation !='', l.designation, c.codePostal),
        'codepostal', IF(l.designation !='', l.codePostal, '')
      ) content,
      c.ctime
      FROM client c 
        INNER JOIN seo_object o USING(id) 
        INNER JOIN _results r USING(ref_id) 
        LEFT JOIN typeSoc ts ON c.type = ts.id
        LEFT JOIN localite l ON c.codePostal=l.codePostal
        LEFT JOIN civilite ci ON ci.id=c.genre
        LEFT JOIN typeVoie v ON c.codeVoie=v.id
        WHERE o.table = 'client';
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "contactChantier") THEN
    REPLACE INTO _view SELECT 
      c.id, 
      r.word,
      r.relevance,
      'contactChantier',
      JSON_OBJECT(
        'nomClient', IF(cl.categorie=0, cl.societe, CONCAT(cl.nom, IF(cl.prenom != '', CONCAT(' ', cl.prenom), ''))),
        'type', 'contactChantier',
        'stype', ts.tag,
        'categorie', c.categorie,
        'civilite', ci.shortTag,
        'clientId', cl.id,
        'chantierId', chantierId,
        'nom', CONCAT(c.nom, IF(c.prenom != '', CONCAT(' ', c.prenom), '')),
        'telBureau', c.telBureau,
        'telDom', c.telDom,
        'mobile', c.mobile,
        'email', c.email,
        'fax', c.fax
      ) content,
      c.ctime
      FROM contactChantier c 
        INNER JOIN seo_object o USING(id) 
        INNER JOIN client cl ON cl.id=c.clientId AND c.id=o.id
        INNER JOIN _results r USING(ref_id)
        LEFT JOIN civilite ci ON ci.id=c.civilite
        LEFT JOIN typeSoc ts ON cl.type = ts.id
        WHERE o.table = 'contactChantier';
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "travaux") THEN
    REPLACE INTO _view SELECT 
      t.id, 
      r.word,
      r.relevance,
      'travaux',
      JSON_OBJECT(
        'nomClient', IF(cl.categorie=0, cl.societe, CONCAT(cl.nom, IF(cl.prenom != '', CONCAT(' ', cl.prenom), ''))),
        'type', 'travaux',
        'stype', ts.tag,
        'typeTravail', tt.tag,
        'civilite', ci.shortTag,
        'clientId', cl.id,
        'devisId', d.id,
        'chrono', d.chrono,
        'description', t.description,
        'ht', d.ht,
        'taux_tva', d.tva,
        'val_tva', d.ttc-d.ht,
        'ttc', d.ttc,
        'remis', d.remis,
        'remis', d.folderId,
        'ctime', d.ctime,
        'statut', d.statut
      ) content,
      d.ctime
      FROM travaux t 
        INNER JOIN seo_object o USING(id) 
        INNER JOIN _results r USING(ref_id)
        INNER JOIN devis d ON t.id=d.travauxId AND t.clientId=d.clientId
        INNER JOIN typeTravaux tt ON t.categorie=tt.id
        INNER JOIN client cl ON cl.id=t.clientId AND t.clientId=d.clientId
        LEFT JOIN civilite ci ON ci.id=cl.genre
        LEFT JOIN typeSoc ts ON cl.type = ts.id
        WHERE o.table = 'travaux';
  END IF;

  SELECT *, ctype `type` FROM _view ORDER BY relevance LIMIT _offset ,_range;
END$

DELIMITER ;
