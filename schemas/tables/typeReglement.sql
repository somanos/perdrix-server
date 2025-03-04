DROP TABLE IF EXISTS typeReglement;
CREATE TABLE
  typeReglement (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    tag VARCHAR(200),
    PRIMARY KEY (`id`),
    UNIQUE KEY (`tag`)
  );