DROP TABLE IF EXISTS seo;
CREATE TABLE `seo` (
  `sys_id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `ctime` int(11) unsigned DEFAULT NULL,
  `occurrence` int(6) unsigned DEFAULT 1,
  `word` varchar(300) NOT NULL,
  `type` varchar(16) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `ref_id` varchar(64) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  PRIMARY KEY (`sys_id`),
  FULLTEXT KEY (`word`),
  UNIQUE KEY `key` (`word`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
