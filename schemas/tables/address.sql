DROP TABLE IF EXISTS address;
CREATE TABLE
address (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
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
    UNIQUE KEY `loc` (`housenumber`, `streettype`, `streetname`, `additional`, `postcode`, `countrycode`)
);
