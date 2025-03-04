DROP TABLE IF EXISTS typeVoie;
CREATE TABLE typeVoie (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    shortTag VARCHAR(10),
    longTag VARCHAR(20),
    PRIMARY KEY (`id`),
    UNIQUE KEY (`shortTag`),
    UNIQUE KEY (`longTag`)
);
