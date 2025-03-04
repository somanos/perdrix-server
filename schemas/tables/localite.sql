DROP TABLE IF EXISTS localite;
CREATE TABLE
  localite (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    codeRegion INTEGER UNSIGNED,
    codeDepartement INTEGER UNSIGNED,
    codePostal INTEGER UNSIGNED,
    designation TEXT,
    designationP TEXT,
    PRIMARY KEY (`id`)
  );