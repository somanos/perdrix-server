DROP TABLE IF EXISTS billType;

CREATE TABLE
  billType (
    `id` int (10) unsigned NOT NULL AUTO_INCREMENT,
    `tag` varchar(200) DEFAULT NULL,
    `prefix` varchar(5) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `tag` (`tag`)
  );