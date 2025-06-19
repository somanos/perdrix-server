DROP TABLE IF EXISTS contact;
CREATE TABLE
  contact (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category` enum('customer','site') DEFAULT 'customer',    
  `role` varchar(50) DEFAULT NULL,
  `gender` int(10) unsigned DEFAULT NULL,
  `lastname` varchar(200) DEFAULT NULL,
  `firstname` varchar(200) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `office` varchar(200) DEFAULT NULL,
  `home` varchar(200) DEFAULT NULL,
  `mobile` varchar(200) DEFAULT NULL,
  `fax` varchar(200) DEFAULT NULL,
  `phones` JSON GENERATED ALWAYS AS (
    JSON_ARRAY(
      IFNULL(office,""),
      IFNULL(home,""),
      IFNULL(mobile,""),
      IFNULL(fax,"")
    )
  ) VIRTUAL,
  `ctime` int(11) unsigned DEFAULT NULL,
  `status` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phones` (`phones`) USING HASH
  );

  DROP TABLE IF EXISTS contact_map;
  CREATE TABLE
  contact_map (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `sourceId` int(10) unsigned NOT NULL,
    `targetId` int(10) unsigned NOT NULL,
    PRIMARY KEY (`id`)
  );
