DROP TABLE IF EXISTS companyClass;

CREATE TABLE
  `companyClass` (
    `id` int (10) unsigned NOT NULL AUTO_INCREMENT,
    `tag` varchar(200) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `tag` (`tag`)
  )