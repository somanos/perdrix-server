
DROP TABLE IF EXISTS customerPoc;
CREATE TABLE `customerPoc` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `custId` int(10) unsigned DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL,
  `gender` int(10) unsigned DEFAULT NULL,
  `lastname` varchar(200) DEFAULT NULL,
  `firstname` varchar(200) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `office` varchar(200) DEFAULT NULL,
  `home` varchar(200) DEFAULT NULL,
  `mobile` varchar(200) DEFAULT NULL,
  `fax` varchar(200) DEFAULT NULL,
  `phones` JSON GENERATED ALWAYS AS (json_array(ifnull(`office`,''),ifnull(`home`,''),ifnull(`mobile`,''),ifnull(`fax`,''))) VIRTUAL CHECK (json_valid(`phones`)),
  `ctime` int(11) unsigned DEFAULT NULL,
  `status` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `contact` (`gender`,`lastname`,`firstname`,`email`,`phones`) USING HASH
);