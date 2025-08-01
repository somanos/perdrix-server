DROP TABLE IF EXISTS address_tmp;
CREATE TABLE
  address_tmp (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `old_id` int(10) unsigned NOT NULL,
    `housenumber` varchar(100) DEFAULT "",
    `streettype` varchar(50) DEFAULT "",
    `streetname` varchar(200) DEFAULT "",
    `additional` varchar(200) DEFAULT "",
    `location` JSON GENERATED ALWAYS AS (
      JSON_ARRAY(
        IFNULL(housenumber,""),
        IFNULL(streettype,""),
        IFNULL(streetname,""),
        IFNULL(additional,"")
      )
    ) VIRTUAL,
    `postcode` varchar(200) DEFAULT NULL,
    `city` text DEFAULT NULL,
    `countrycode` int(10) unsigned DEFAULT NULL,
    `geometry` JSON,
    `ctime` int(11) unsigned DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `loc` (`housenumber`, `streettype`, `streetname`, `additional`, `postcode`,`countrycode`) USING HASH
);

INSERT IGNORE INTO address_tmp (
  old_id, housenumber, streettype, streetname, postcode, city, countrycode, geometry, ctime
  ) SELECT id, housenumber, streettype, streetname, postcode, city, countrycode, geometry, ctime
    FROM address;

UPDATE customer c INNER JOIN address_tmp a ON c.addressId=a.old_id SET c.addressId=a.id;
UPDATE site s INNER JOIN address_tmp a ON s.addressId=a.old_id SET s.addressId=a.id;

DROP TABLE IF EXISTS address_bak;
CREATE TABLE address_bak LIKE address;

INSERT IGNORE INTO address_bak (
  id, housenumber, streettype, streetname, postcode, city, countrycode, geometry, ctime
  ) SELECT id, housenumber, streettype, streetname, postcode, city, countrycode, geometry, ctime
FROM address;

DROP TABLE address;
CREATE TABLE ADDRESS LIKE address_tmp;
ALTER TABLE ADDRESS DROP column old_id;

INSERT INTO address (
  id, housenumber, streettype, streetname, postcode, city, countrycode, geometry, ctime
  ) SELECT id, housenumber, streettype, streetname, postcode, city, countrycode, geometry, ctime
FROM address_tmp;