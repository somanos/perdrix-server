DROP TABLE IF EXISTS address;
CREATE TABLE
  address (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `housenumber` varchar(100) DEFAULT "",
    `streettype` varchar(50) DEFAULT "",
    `streetname` varchar(200) DEFAULT "",
    `additional` varchar(200) DEFAULT "",
    `floor` varchar(100) DEFAULT "",
    `roomnumber` varchar(100) DEFAULT "",
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
insert ignore into address 
    (
    `housenumber`,
    `streettype`,
    `streetname`,
    `additional`,
    `floor`,
    `roomnumber`,
    `postcode`,
    `city`,
    `countrycode`,
    `geometry`,
    `ctime`
    )
    select
    IFNULL(JSON_VALUE(location, "$[0]"), ""), 
    IFNULL(JSON_VALUE(location, "$[1]"), ""), 
    IFNULL(JSON_VALUE(location, "$[2]"), ""), 
    IFNULL(JSON_VALUE(location, "$[3]"), ""), 
    IFNULL(JSON_VALUE(location, "$[4]"), ""), 
    IFNULL(JSON_VALUE(location, "$[5]"), ""), 
    postcode, 
    city, 
    countrycode, 
    geometry, 
    ctime 
from site;

insert ignore into address 
    (
    `housenumber`,
    `streettype`,
    `streetname`,
    `additional`,
    `floor`,
    `roomnumber`,
    `postcode`,
    `city`,
    `countrycode`,
    `geometry`,
    `ctime`
    )
    select 
    IFNULL(JSON_VALUE(location, "$[0]"), ""), 
    IFNULL(JSON_VALUE(location, "$[1]"), ""), 
    IFNULL(JSON_VALUE(location, "$[2]"), ""), 
    IFNULL(JSON_VALUE(location, "$[3]"), ""), 
    IFNULL(JSON_VALUE(location, "$[4]"), ""), 
    IFNULL(JSON_VALUE(location, "$[5]"), ""), 
    postcode, 
    city, 
    countrycode, 
    geometry, 
    ctime 
from customer;

-- update customer c inner join address a on c.location=a.location and c.postcode=a.postcode and a.category='csutomer' 
--     set c.addressId=a.id;

-- update site c inner join address a on c.location=a.location and c.postcode=a.postcode and a.category='site' 
--     set c.addressId=a.id
