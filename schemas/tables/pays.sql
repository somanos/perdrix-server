DROP TABLE IF EXISTS pays;
CREATE TABLE
  pays (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    code VARCHAR(200),
    indicatif INTEGER UNSIGNED,
    Zone VARCHAR(200),
    tva VARCHAR(200),
    codeTva VARCHAR(200),
    devises VARCHAR(200),
    poidsMax INTEGER UNSIGNED,
    PRIMARY KEY (`id`),
    UNIQUE KEY (`code`)
  );