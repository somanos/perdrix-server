DROP TABLE IF EXISTS typeTravaux;
CREATE TABLE
  typeTravaux (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    tag VARCHAR(200),
    PRIMARY KEY (`id`),
    UNIQUE KEY (`tag`)
  );