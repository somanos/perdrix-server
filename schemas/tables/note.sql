DROP TABLE IF EXISTS note;
CREATE TABLE
  note (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    clientId INTEGER UNSIGNED,
    chantierId INTEGER UNSIGNED,
    travauxId INTEGER UNSIGNED,
    ctime INT (11) UNSIGNED,
    description TEXT,
    docId VARCHAR(1000),
    PRIMARY KEY (`id`)
  );