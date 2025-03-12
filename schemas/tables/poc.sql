DROP TABLE IF EXISTS poc;
CREATE TABLE
  poc (
    `id` int (10) unsigned NOT NULL AUTO_INCREMENT,
    `custId` int (10) unsigned DEFAULT NULL,
    `siteId` int (10) unsigned DEFAULT NULL,
    `category` varchar(200) DEFAULT NULL,
    `gender` int (10) unsigned DEFAULT NULL,
    `lastname` varchar(200) DEFAULT NULL,
    `firstname` varchar(200) DEFAULT NULL,
    `email` varchar(200) DEFAULT NULL,
    `phones` JSON,
    `ctime` int (11) unsigned DEFAULT NULL,
    `actif` varchar(200) DEFAULT NULL,
    PRIMARY KEY (`id`)
  );