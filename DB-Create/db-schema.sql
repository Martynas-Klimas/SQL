-- Drop existing objects if they exist (in reverse order of creation)
DROP MATERIALIZED VIEW IF EXISTS MV_DainosIrIvertinimai;
DROP VIEW IF EXISTS V_AlbumaiTrukme;
DROP VIEW IF EXISTS V_GrupesIrDainos;

DROP INDEX IF EXISTS idx_pavadinimas;
DROP INDEX IF EXISTS idx_unikalus_pavadinimas;

DROP TRIGGER IF EXISTS trigger_check_gimimas_daugiau_ikurimas ON Atlikejas;
DROP TRIGGER IF EXISTS trigger_update_dainusk ON Daina;

DROP FUNCTION IF EXISTS check_gimimas_daugiau_ikurimas();
DROP FUNCTION IF EXISTS update_dainusk_in_albumas();

-- Drop tables in reverse order of foreign key dependencies
DROP TABLE IF EXISTS Ivertinimas;
DROP TABLE IF EXISTS Grupe_Daina;
DROP TABLE IF EXISTS Daina;
DROP TABLE IF EXISTS Albumas;
DROP TABLE IF EXISTS Atlikejas;
DROP TABLE IF EXISTS Grupe;

-- Create tables with IF NOT EXISTS
CREATE TABLE IF NOT EXISTS makl0069.Grupe(
    ID            SERIAL,
    Pavadinimas   VARCHAR(32) NOT NULL,
    Ikurimas      DATE  DEFAULT CURRENT_DATE
                CONSTRAINT CK_Grupe_Ikurimas 
                CHECK (Ikurimas > '1900-01-01' AND Ikurimas <= CURRENT_DATE),
    PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS makl0069.Atlikejas(
    ID          SERIAL,    
    GrupesID    INTEGER     NOT NULL,
    Role        VARCHAR(32) NOT NULL,
    Vardas      VARCHAR (15) NOT NULL,
    Pavarde     VARCHAR (20) NOT NULL,
    Gimimas     DATE        NOT NULL
                CONSTRAINT CK_Atlikejas_Gimimas 
                CHECK(Gimimas > '1900-01-01' AND Gimimas < CURRENT_DATE - INTERVAL '5 years'),
    Lytis       CHAR(7)     NOT NULL
                CONSTRAINT CK_Lytis CHECK (Lytis IN ('Vyras', 'Moteris')),
    PRIMARY KEY (ID),
    CONSTRAINT FK_Atlikejas_GrupesID FOREIGN KEY (GrupesID) REFERENCES makl0069.Grupe(ID) ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE IF NOT EXISTS makl0069.Albumas(
    ID          SERIAL,
    Pavadinimas VARCHAR(32) NOT NULL,
    DainuSk     INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS makl0069.Daina(
    ID      SERIAL,
    Pavadinimas VARCHAR(32) NOT NULL,
    Trukme     INTEGER  NOT NULL
                        CONSTRAINT CK_Daina_Trukme 
                        CHECK (Trukme > 0 AND Trukme <= 3600),
    Zanras     VARCHAR (15) DEFAULT 'Unknown',
    AlbumoID    INTEGER, 
    TakelioNr   INTEGER,
    PRIMARY KEY (ID),
    CONSTRAINT FK_Daina_AlbumoID FOREIGN KEY (AlbumoID) REFERENCES makl0069.Albumas(ID)
        ON UPDATE RESTRICT
);

CREATE TABLE IF NOT EXISTS makl0069.Grupe_Daina(
    GrupesID      INTEGER NOT NULL,
    DainosID      INTEGER NOT NULL,
    PRIMARY KEY (GrupesID, DainosID),
    CONSTRAINT FK_GrupeDaina_GrupesID FOREIGN KEY (GrupesID) REFERENCES makl0069.Grupe(ID)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT FK_GrupeDaina_DainosID FOREIGN KEY (DainosID) REFERENCES makl0069.Daina(ID)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE IF NOT EXISTS makl0069.Ivertinimas(
    DainosID     INTEGER NOT NULL, 
    Vertintojas  VARCHAR(20) NOT NULL,
    Reitingas    INTEGER NOT NULL 
                CONSTRAINT CK_Ivertinimas_Reitingas 
                CHECK (Reitingas > 0 AND Reitingas <= 10),
    PRIMARY KEY (DainosID, Vertintojas),
    CONSTRAINT FK_Ivertinimas_DainosID FOREIGN KEY (DainosID) REFERENCES makl0069.Daina(ID)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- Create indexes
CREATE UNIQUE INDEX IF NOT EXISTS idx_unikalus_pavadinimas ON makl0069.Grupe(Pavadinimas);
CREATE INDEX IF NOT EXISTS idx_pavadinimas ON makl0069.Daina(Pavadinimas);

-- Create views
CREATE OR REPLACE VIEW V_GrupesIrDainos AS 
SELECT gr.ID AS "Grupes ID", gr.Pavadinimas AS "Grupes pavadinimas", d.ID AS "Dainos ID", d.Pavadinimas AS "Dainos pavadinimas"
FROM makl0069.Grupe AS gr
JOIN makl0069.Grupe_Daina ON gr.ID = Grupe_Daina.GrupesID
JOIN makl0069.Daina AS d ON d.ID = Grupe_Daina.DainosID;

CREATE OR REPLACE VIEW V_AlbumaiTrukme AS
SELECT al.ID AS "Albumo ID", SUM(d.Trukme) AS "Albumo trukme"
FROM makl0069.Albumas AS al
LEFT JOIN makl0069.Daina AS d ON al.ID = d.AlbumoID
GROUP BY al.ID;

-- Create materialized view
CREATE MATERIALIZED VIEW IF NOT EXISTS MV_DainosIrIvertinimai AS
SELECT DainosID AS "Dainos ID", COUNT(*) AS "Reitingu skaicius", AVG(Reitingas) AS "Reitingu vidurkis" 
FROM makl0069.Ivertinimas
GROUP BY DainosID;

-- Function to update song count in album
CREATE OR REPLACE FUNCTION update_dainusk_in_albumas()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE makl0069.Albumas
    SET DainuSk = (SELECT COUNT(*) FROM makl0069.Daina WHERE AlbumoID = NEW.AlbumoID)
    WHERE ID = NEW.AlbumoID;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update song count
CREATE TRIGGER trigger_update_dainusk
AFTER INSERT OR DELETE ON makl0069.Daina
FOR EACH ROW
EXECUTE FUNCTION update_dainusk_in_albumas();

-- Function to check artist age against group creation
CREATE OR REPLACE FUNCTION check_gimimas_daugiau_ikurimas()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.Gimimas > (SELECT Ikurimas FROM makl0069.Grupe WHERE ID = NEW.GrupesID)) THEN
        RAISE EXCEPTION 'Atlikejas turi buti vyresnis uz grupes sukurimo data';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to check artist age
CREATE TRIGGER trigger_check_gimimas_daugiau_ikurimas
BEFORE INSERT OR UPDATE ON makl0069.Atlikejas
FOR EACH ROW
EXECUTE FUNCTION check_gimimas_daugiau_ikurimas();
