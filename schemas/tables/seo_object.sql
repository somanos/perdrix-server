DROP TABLE IF EXISTS seo_object;
CREATE TABLE `seo_object` (
  `sys_id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `ctime` int(11) unsigned DEFAULT NULL,
  `ref_id` varchar(64) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `id` varchar(64) GENERATED ALWAYS AS (json_value(`reference`,'$.id')) VIRTUAL,
  `table` varchar(64) GENERATED ALWAYS AS (json_value(`reference`,'$.table')) VIRTUAL,
  `db` varchar(64) GENERATED ALWAYS AS (json_value(`reference`,'$.db')) VIRTUAL,
  `reference` JSON CHECK (json_valid(`reference`)),
  PRIMARY KEY (`sys_id`),
  UNIQUE KEY `ref` (`id`, `table`, `db`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
