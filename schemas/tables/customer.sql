DROP TABLE IF EXISTS client;

CREATE TABLE
  client (
    `id` int (10) unsigned NOT NULL AUTO_INCREMENT,
    `category` int (10) unsigned DEFAULT NULL,
    `type` int (10) unsigned DEFAULT NULL,
    `company` varchar(200) DEFAULT NULL,
    `gender` int (10) unsigned DEFAULT NULL,
    `lastname` text DEFAULT NULL,
    `firstname` text DEFAULT NULL,
    `location` JSON,
    `postcode` varchar(200) DEFAULT NULL,
    `citycode` varchar(200) DEFAULT NULL,
    `city` text DEFAULT NULL,
    `countrycode` int (10) unsigned DEFAULT NULL,
    `ctime` int (11) unsigned DEFAULT NULL,
    PRIMARY KEY (`id`)
  );