DROP TABLE IF EXISTS address;
CREATE TABLE
  address (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `housenumber` varchar(100) DEFAULT "",
    `streettype` varchar(50) DEFAULT "",
    `streetname` varchar(200) DEFAULT "",
    `additional` varchar(200) DEFAULT "",
    `floor` varchar(100) DEFAULT "",
    `roomnumber` varchar(100) DEFAULT "",
    `location` JSON GENERATED ALWAYS AS (
      JSON_ARRAY(
        IFNULL(housenumber,""),
        IFNULL(streettype,""),
        IFNULL(streetname,""),
        IFNULL(additional,""),
        IFNULL(floor,""),
        IFNULL(roomnumber,"")
      )
    ) VIRTUAL,
    `postcode` varchar(200) DEFAULT NULL,
    `city` text DEFAULT NULL,
    `countrycode` int(10) unsigned DEFAULT NULL,
    `geometry` JSON,
    `ctime` int(11) unsigned DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `loc` (`location`,`postcode`,`countrycode`) USING HASH
);
DROP TABLE IF EXISTS site;
CREATE TABLE site LIKE site_bak;
INSERT INTO site SELECT * FROM site_bak;
INSERT IGNORE INTO address 
    (
    `housenumber`,
    `streettype`,
    `streetname`,
    `additional`,
    `floor`,
    `roomnumber`,
    `postcode`,
    `city`,
    `countrycode`,
    `geometry`,
    `ctime`
    )
    SELECT
    IFNULL(JSON_VALUE(location, "$[0]"), ""), 
    IFNULL(JSON_VALUE(location, "$[1]"), ""), 
    IFNULL(JSON_VALUE(location, "$[2]"), ""), 
    IFNULL(JSON_VALUE(location, "$[3]"), ""), 
    IFNULL(JSON_VALUE(location, "$[4]"), ""), 
    IFNULL(JSON_VALUE(location, "$[5]"), ""), 
    postcode, 
    city, 
    countrycode, 
    geometry, 
    ctime 
FROM site;

DROP TABLE IF EXISTS customer;
CREATE TABLE customer LIKE customer_bak;
INSERT INTO customer SELECT * FROM customer_bak;
INSERT IGNORE INTO address 
    (
    `housenumber`,
    `streettype`,
    `streetname`,
    `additional`,
    `floor`,
    `roomnumber`,
    `postcode`,
    `city`,
    `countrycode`,
    `geometry`,
    `ctime`
    )
    select 
    IFNULL(JSON_VALUE(location, "$[0]"), ""), 
    IFNULL(JSON_VALUE(location, "$[1]"), ""), 
    IFNULL(JSON_VALUE(location, "$[2]"), ""), 
    IFNULL(JSON_VALUE(location, "$[3]"), ""), 
    IFNULL(JSON_VALUE(location, "$[4]"), ""), 
    IFNULL(JSON_VALUE(location, "$[5]"), ""), 
    postcode, 
    city, 
    countrycode, 
    geometry, 
    ctime 
from customer;

UPDATE customer set location = JSON_ARRAY(
    IFNULL(JSON_VALUE(location, "$[0]"), ""), 
    IFNULL(JSON_VALUE(location, "$[1]"), ""), 
    IFNULL(JSON_VALUE(location, "$[2]"), ""), 
    IFNULL(JSON_VALUE(location, "$[3]"), ""), 
    IFNULL(JSON_VALUE(location, "$[4]"), ""), 
    IFNULL(JSON_VALUE(location, "$[5]"), "") 
);

UPDATE site set location = JSON_ARRAY(
    IFNULL(JSON_VALUE(location, "$[0]"), ""), 
    IFNULL(JSON_VALUE(location, "$[1]"), ""), 
    IFNULL(JSON_VALUE(location, "$[2]"), ""), 
    IFNULL(JSON_VALUE(location, "$[3]"), ""), 
    IFNULL(JSON_VALUE(location, "$[4]"), ""), 
    IFNULL(JSON_VALUE(location, "$[5]"), "") 
);

UPDATE customer c INNER JOIN address a ON c.location=a.location AND c.postcode=a.postcode
    SET c.addressId=a.id;

UPDATE site c INNER JOIN address a ON c.location=a.location AND c.postcode=a.postcode 
    SET c.addressId=a.id;

alter table customer drop column location;
alter table customer drop column postcode;
alter table customer drop column citycode;
alter table customer drop column city;
alter table customer drop column countrycode;
alter table customer drop column geometry

alter table site drop column location;
alter table site drop column postcode;
alter table site drop column citycode;
alter table site drop column city;
alter table site drop column countrycode;
alter table site drop column geometry;
