DROP TABLE IF EXISTS info;
CREATE TABLE
  info (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    drumateId VARCHAR(16),
    ctime INT (11) UNSIGNED,
    categorie INTEGER UNSIGNED,
    sujet VARCHAR(200),
    `description` TEXT,
    baseId INTEGER UNSIGNED,
    resolved INTEGER UNSIGNED,
    dateResolved INT (11) UNSIGNED,
    drumateIdResolved VARCHAR(200),
    PRIMARY KEY (`id`)
  );