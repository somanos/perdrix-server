DROP TABLE IF EXISTS departement;
CREATE TABLE
  departement (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    tag VARCHAR(200),
    PRIMARY KEY (`id`),
    UNIQUE KEY (`tag`)
  );