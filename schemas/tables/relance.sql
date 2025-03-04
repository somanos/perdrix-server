DROP TABLE IF EXISTS relance;
CREATE TABLE
  relance (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    level INTEGER UNSIGNED,
    header TEXT,
    footer TEXT,
    PRIMARY KEY (`id`)
  );