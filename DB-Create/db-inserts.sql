-- Insert test data with various scenarios

-- 1. Insert Groups (Testing Ikurimas constraint)
-- Successful inserts
INSERT INTO makl0069.Grupe (Pavadinimas, Ikurimas) 
VALUES 
    ('The Rockers', '1990-05-15'),     -- Valid past date
    ('Modern Sounds', '2010-03-22'),   -- More recent valid date
    ('Acoustic Legends', CURRENT_DATE);  -- Today's date (valid)


--Intentionally failing inserts 
INSERT INTO makl0069.Grupe (Pavadinimas, Ikurimas) 
VALUES ('Future Band', '2100-01-01');     -- Future date 

INSERT INTO makl0069.Grupe (Pavadinimas, Ikurimas) 
VALUES ('Ancient Band', '1800-01-01');    -- Too old date 

INSERT INTO makl0069.Grupe (Pavadinimas, Ikurimas) 
VALUES ('The Rockers', '2000-01-01');     --Should fail because of index
       

-- 2. Insert Artists (Testing multiple constraints)
-- Successful inserts
INSERT INTO makl0069.Atlikejas (GrupesID, Role, Vardas, Pavarde, Gimimas, Lytis)
VALUES 
    (1, 'Vokalistas', 'Jonas', 'Jonaitis', '1965-03-15', 'Vyras'),     -- Born before group creation
    (1, 'Gitaristas', 'Eglė', 'Petrauskaitė', '1975-07-22', 'Moteris'), -- Different roles, valid ages
    (2, 'Būgnininkas', 'Petras', 'Kazlauskas', '1985-11-30', 'Vyras');


-- Intentionally failing inserts 
INSERT INTO makl0069.Atlikejas (GrupesID, Role, Vardas, Pavarde, Gimimas, Lytis)
VALUES (1, 'Bassist', 'Jaunas', 'Muzikas', '1995-01-01', 'Vyras');  -- Born after group creation (should fail)

INSERT INTO makl0069.Atlikejas (GrupesID, Role, Vardas, Pavarde, Gimimas, Lytis)
VALUES (999, 'Singer', 'Kitas', 'Asmuo', '1970-05-10', 'Vyras');     

INSERT INTO makl0069.Atlikejas (GrupesID, Role, Vardas, Pavarde, Gimimas, Lytis)
VALUES (1, 'Drummer', 'Naujas', 'Vardas', '1800-01-01', 'Vyras');  -- Too old birthdate (should fail)
       

-- 3. Insert Albums
INSERT INTO makl0069.Albumas (Pavadinimas, DainuSk)
VALUES 
    ('Greatest Hits', 0),              -- Initial empty album
    ('Summer Collection', 0),
    ('Acoustic Sessions', 0);

-- 4. Insert Songs (Testing Trigger for song count)
INSERT INTO makl0069.Daina (Pavadinimas, Trukme, Zanras, AlbumoID, TakelioNr)
VALUES 
    ('Rock Anthem', 240, 'Rock', 1, 1),        -- First song in Greatest Hits
    ('Silent Melody', 210, 'Ballad', 1, 2),    -- Second song in Greatest Hits
    ('Summer Love', 195, 'Pop', 2, 1),         -- First song in Summer Collection
    ('Acoustic Dream', 180, 'Acoustic', 3, 1); -- First song in Acoustic Sessions


-- Intentionally failing inserts (uncomment to test)
 INSERT INTO makl0069.Daina (Pavadinimas, Trukme, Zanras, AlbumoID, TakelioNr)
 VALUES ('Too Long Song', 3700, 'Experimental', 1, 3);  -- Too long duration (should fail)

INSERT INTO makl0069.Daina (Pavadinimas, Trukme, Zanras, AlbumoID, TakelioNr)
VALUES ('Negative Duration', -50, 'Error', 1, 4);     -- Negative duration (should fail)
     

-- 5. Link Groups with Songs (Many-to-Many relationship)
INSERT INTO makl0069.Grupe_Daina (GrupesID, DainosID)
VALUES 
    (1, 1),  -- Rockers perform Rock Anthem
    (1, 2),  -- Rockers perform Silent Melody
    (2, 3);  -- Modern Sounds perform Summer Love

-- 6. Insert Ratings (Testing Rating constraints)
INSERT INTO makl0069.Ivertinimas (DainosID, Vertintojas, Reitingas)
VALUES 
    (1, 'User1', 8),   -- Valid rating
    (1, 'User2', 9),   -- Another valid rating for same song
    (2, 'User1', 7),   -- Rating for different song
    (3, 'User3', 6);   -- Rating for third song

-- Intentionally failing inserts (uncomment to test)

INSERT INTO makl0069.Ivertinimas (DainosID, Vertintojas, Reitingas)
VALUES (1, 'User1', 15); -- Rating out of range (should fail)
       
INSERT INTO makl0069.Ivertinimas (DainosID, Vertintojas, Reitingas)
VALUES (999, 'User4', 7);   -- Non-existent song (should fail)
       
-- Verify results
SELECT * FROM makl0069.Grupe;
SELECT * FROM makl0069.Atlikejas;
SELECT * FROM makl0069.Albumas;
SELECT * FROM makl0069.Daina;
SELECT * FROM makl0069.Grupe_Daina;
SELECT * FROM makl0069.Ivertinimas;
SELECT * FROM makl0069.V_GrupesIrDainos;
SELECT * FROM makl0069.V_AlbumaiTrukme;
REFRESH MATERIALIZED VIEW makl0069.MV_DainosIrIvertinimai;
SELECT * FROM makl0069.MV_DainosIrIvertinimai;

