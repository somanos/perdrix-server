DROP TABLE IF EXISTS address;
CREATE TABLE
  address (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `housenumber` varchar(10) DEFAULT NULL,
    `streettype` varchar(50) DEFAULT NULL,
    `streetname` varchar(200) DEFAULT NULL,
    `additional` varchar(200) DEFAULT NULL,
    `floor` varchar(8) DEFAULT NULL,
    `roomnumber` varchar(8) DEFAULT NULL,
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