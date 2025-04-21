/*
https://klevas.mif.vu.lt/~baronas/dbvs/uzduot_1/informat1.htm
komandos: psql -h pgsql3.mif biblio -f 1sql.sql
Jeigu faile: psql -h pgsql3.mif biblio -d 1sql.sql -o 1res.res

SELECT vardas, pavarde FROM stud.skaitytojas;

SELECT gimimas 
FROM stud.skaitytojas
WHERE INITCAP (vardas) = 'Jonas';

SELECT pavadinimas, leidykla, metai 
FROM stud.knyga
ORDER BY metai DESC;

SELECT COUNT (vardas), COUNT(DISTINCT INITCAP(vardas)) 
FROM stud.skaitytojas;

SELECT COUNT (DISTINCT skaitytojas) 
AS "Skaitytojų skaičius"
FROM stud.egzempliorius;

SELECT COUNT (isbn) 
AS "Knygų skaičius" 
FROM stud.knyga;

SELECT SUM(verte) 
AS "Visų knygų bendra vertė"
FROM stud.knyga;
	
--Knygų kurių vertė ne null, vidurkis
SELECT AVG(verte) 
AS "Knygų kainos vidurkis", 
AVG(COALESCE(verte, 0)) 
AS "Knygų kainos vidurkis kur null = 0"
FROM stud.knyga;

--Suapvalintos reiksmes
SELECT ROUND(AVG(verte), 3) 
AS "Knygų kainos vidurkis", 
ROUND(AVG(COALESCE(verte, 0)), 3) 
AS "Knygų kainos vidurkis kur null = 0"
FROM stud.knyga;

SELECT CAST(AVG(COALESCE(puslapiai, 0)) 
AS DECIMAL(4,1)) 
FROM Stud.Knyga;

SELECT * FROM stud.knyga
WHERE metai = 
EXTRACT(YEAR FROM CURRENT_DATE) - 1;

SELECT pavadinimas, leidykla
FROM stud.knyga
WHERE metai BETWEEN 2020 AND 2022;

SELECT pavadinimas, leidykla, metai
FROM stud.knyga
WHERE metai NOT BETWEEN 2020 AND 2022;

SELECT kn.pavadinimas, kn.verte
AS "Didžiausia knygos vertė"
FROM stud.knyga AS kn 
WHERE kn.verte = ( SELECT MAX(COALESCE(verte, 0)) FROM stud.knyga);

SELECT MAX(COALESCE(verte, 0))
AS "Didžiausia knygos vertė"
FROM stud.knyga;

SELECT pavadinimas, leidykla, metai 
FROM stud.knyga
WHERE INITCAP(leidykla) LIKE '%Bal%' 
AND metai BETWEEN 2015 AND 2020;


SELECT SUM(COALESCE(puslapiai, 0))
AS "Knygų iš Baltosios leidyklos puslapių suma"
FROM stud.knyga
WHERE INITCAP(leidykla) = 'Baltoji';


SELECT pavadinimas, verte
AS "Knygos kurių vertė 30 arba 22,5"
FROM stud.knyga
WHERE (COALESCE(verte, 0) > 50 OR COALESCE(verte, 0) = 22.5) AND INITCAP(pavadinimas) LIKE '%Duomenu%';

--1 lab uzduotis:
SELECT COUNT (*) 
AS "Skaitomų knygų skaičius"
FROM stud.egzempliorius
WHERE skaitytojas = 1000;

SELECT COUNT(DISTINCT(isbn)) 
AS "Knygų skaičius", 
COUNT(*)
AS "Visų egzempliorių sk", 
COUNT(CASE WHEN skaitytojas IS NULL THEN 1 END) 
AS "Nepaimtų egzempliorių sk",
COUNT(skaitytojas)
AS "Paimtų egzempliorių sk"
FROM stud.egzempliorius;


--visu konkretaus autoriaus nurodyto vardu ir pavarde visu jo parasytu knygu vertes vidurkis
-- reikia ismokti siuos papildomus dalykus

-- darbas su keliomis lentelemis
-- kada naudoti JOIN (lygybe)
-- RIGHT JOIN
-- OUTER JOIN
-- TABLE ir TABLE

--kokios knygos yra skaitomos kokiu skaitytoju
SELECT sk.nr, sk.vardas, egz.isbn
FROM stud.skaitytojas AS sk
INNER JOIN stud.egzempliorius AS egz
ON egz.skaitytojas = sk.nr
ORDER BY sk.nr;


--visos knygos ir skaitomos ir ne
SELECT sk.nr, sk.vardas, egz.isbn
FROM stud.skaitytojas AS sk
RIGHT JOIN stud.egzempliorius AS egz
ON egz.skaitytojas = sk.nr
ORDER BY sk.nr;


--knygu pavadinimai, kurios turi bent 1 skaitytoja
SELECT DISTINCT kn.pavadinimas, kn.isbn
FROM stud.knyga AS kn
INNER JOIN stud.egzempliorius as egz
ON egz.isbn = kn.isbn
WHERE egz.skaitytojas IS NOT NULL
ORDER BY kn.isbn;


--same table join - palyginame knygas kuriu leidimo metai vienodi, skirtinga verte ir isvengiame eiluciu pasikartojimo 
SELECT k1.isbn AS isbn1, k1.pavadinimas AS pavadinimas1, k1.verte AS verte1,
	   k2.isbn AS isbn2, k2.pavadinimas AS pavadinimas2, k2.verte AS verte2
FROM stud.knyga AS k1
JOIN stud.knyga AS k2
ON k1.metai = k2.metai
AND k1.verte <> k2.verte
AND k1.isbn < k2.isbn;


SELECT au.vardas, au.pavarde, kn.pavadinimas
FROM stud.autorius as au, stud.knyga as kn
WHERE au.isbn = kn.isbn AND INITCAP(kn.leidykla) = 'Baltoji';

--visu konkretaus autoriaus nurodyto vardu ir pavarde visu jo parasytu knygu vertes vidurkis AVG(COALESCE(kn.verte, 0)) AS "Knygu vertes vid"
SELECT  ROUND(AVG(COALESCE((kn.verte), 0)), 3)
FROM stud.autorius AS au
JOIN stud.knyga AS kn
ON au.isbn = kn.isbn AND 
	INITCAP(au.vardas) = 'Jonas' AND
	INITCAP(au.pavarde) = 'Jonaitis'
JOIN stud.egzempliorius AS egz
ON kn.isbn = egz.isbn;

--vardai ir pavardes visu skaitytoju kurie skaito konkrecioje leidykloje isleistas knygas 
SELECT sk.nr, sk.vardas, sk.pavarde
FROM stud.skaitytojas AS sk
JOIN stud.egzempliorius AS egz
ON egz.skaitytojas = sk.nr
JOIN stud.knyga AS kn
ON kn.isbn = egz.isbn 
WHERE INITCAP(kn.leidykla) = 'Juodoji';

--neprarasti informacijos, kas skaito knygas
SELECT au.vardas, au.pavarde, kn.pavadinimas, egz.paimta, egz.grazinti, 
	sk.vardas AS "skaitytojo vardas"
FROM stud.autorius AS au
JOIN stud.knyga AS kn ON au.isbn = kn.isbn
JOIN stud.egzempliorius AS egz ON kn.isbn = egz.isbn
LEFT JOIN stud.skaitytojas AS sk ON egz.skaitytojas = sk.nr 
WHERE INITCAP(kn.leidykla) = 'Baltoji';

--visi skaitytojai ir tie kurie skaito knygas ir ne.
SELECT sk.nr, sk.vardas, egz.isbn
FROM stud.skaitytojas AS sk
LEFT JOIN stud.egzempliorius AS egz
ON egz.skaitytojas = sk.nr
ORDER BY sk.nr;

-- isvesti skaitytojus kurie neskaito knygos
SELECT sk.nr, sk.vardas, egz.isbn
FROM stud.skaitytojas AS sk
LEFT JOIN stud.egzempliorius AS egz
ON egz.skaitytojas = sk.nr
WHERE egz.skaitytojas IS NULL
ORDER BY sk.nr;

*/
--3 atsiskaitymas (duomenų grupavimas)

/*
SELECT kn.pavadinimas, COUNT(*) AS "skaicius"
FROM stud.knyga AS kn, stud.egzempliorius AS egz
WHERE egz.isbn = kn.isbn
GROUP BY kn.isbn;

SELECT kn.isbn, kn.pavadinimas, COUNT(*) AS "skaicius"
FROM stud.knyga AS kn, stud.egzempliorius AS egz 
WHERE kn.isbn = egz.isbn
GROUP BY kn.isbn;

SELECT sk.vardas, sk.pavarde, COUNT(*) AS "skaicius"
FROM stud.skaitytojas as sk, stud.egzempliorius AS egz
WHERE sk.nr = egz.skaitytojas
GROUP BY sk.nr
ORDER BY skaicius DESC;

SELECT egz.isbn, COUNT(skaitytojas) AS "Skaitytoju skaicius"
FROM stud.egzempliorius AS egz 
GROUP BY egz.isbn 
HAVING COUNT(skaitytojas) > 1; 

--3 uzd
SELECT au.vardas, au.pavarde, COUNT (DISTINCT kn.isbn) AS "knygu skaicius", SUM(kn.puslapiai) AS "knygu psl"
FROM stud.autorius AS au 
JOIN stud.knyga AS kn ON au.isbn = kn.isbn
JOIN stud.egzempliorius AS egz ON kn.isbn = egz.isbn
GROUP BY au.vardas, au.pavarde;

SELECT kn.pavadinimas, kn.metai, SUM(kn.puslapiai) as "Puslapiai"
FROM stud.knyga AS kn
GROUP BY CUBE(kn.pavadinimas, kn.metai);

SELECT kn.pavadinimas, kn.metai, SUM(kn.puslapiai) as "Puslapiai"
FROM stud.knyga AS kn
GROUP BY ROLLUP(kn.pavadinimas, kn.metai);

*/
/*
-- 4 atsiskaitymas
SELECT pavadinimas, leidykla, verte 
FROM stud.knyga
WHERE verte > (SELECT AVG(COALESCE(verte, 0)) FROM stud.knyga);

-- užklausos su WITH
WITH vidurkis (reiksme) AS(
    SELECT AVG(COALESCE(verte, 0)) 
    FROM stud.knyga
)
    SELECT pavadinimas, leidykla, verte
    FROM stud.knyga AS kn, vidurkis AS vid
    WHERE kn.verte > vid.reiksme;

--knygos kurios neturi egzemplioriaus
SELECT isbn
FROM stud.knyga
EXCEPT (SELECT isbn FROM stud.egzempliorius);

SELECT pavadinimas, 'pigi' AS "Knygos verte", verte 
FROM stud.knyga AS kn 
WHERE verte < 20
UNION 
SELECT pavadinimas, 'vidutine' AS "Knygos verte", verte
FROM stud.knyga 
WHERE verte >= 20 AND verte <= 40
UNION 
SELECT pavadinimas, 'brangi' AS "Knygos verte", verte 
FROM stud.knyga
WHERE verte < 40;

SELECT sk.nr,
	CASE WHEN COUNT(egz.skaitytojas) > 1 THEN 'Skaito daugiau nei 1 knyga' 
		 WHEN COUNT(egz.skaitytojas) = 1 THEN 'Skaito tik 1 knyga'
		 ELSE 'Neskaito knygu'
		 END AS "Statusas"
FROM stud.skaitytojas AS sk
LEFT JOIN stud.egzempliorius AS egz ON sk.nr = egz.skaitytojas
GROUP BY sk.nr;

SELECT kn.pavadinimas
FROM stud.knyga AS kn
WHERE 5 <= (
    SELECT COUNT(egz.isbn)
    FROM stud.egzempliorius AS egz
    WHERE egz.isbn = kn.isbn
);

SELECT kn.pavadinimas, kn
FROM stud.knyga AS kn
WHERE kn.verte = ANY (
    SELECT kn2.verte
    FROM stud.knyga AS kn2
    WHERE kn2.verte > 30
);

*/

--kitos uzd su with 
--Pavadinimai knygu kuriu egzemplioriu yra paimta maziau uz visu knygu paimtu egzemplioriu vidurki
/*
--1. Kiekvienos knygos paimtu egzemplioriu skaicius 
WITH egzemplioriai(pavadinimas, skaicius) AS ( 
	SELECT pavadinimas, COUNT(egz.isbn)
	FROM stud.knyga AS kn
	JOIN stud.egzempliorius AS egz ON kn.isbn = egz.isbn
	WHERE egz.paimta IS NOT NULL
	GROUP BY kn.isbn
), vidurkis (vid) AS ( --2. Paimtu egzemplioriu vidurkis visoms knygoms
	SELECT AVG(skaicius)
	FROM egzemplioriai
)
--3. Grazinti tuos pavadinimus kur 1<2.
SELECT pavadinimas
FROM egzemplioriai, vidurkis
WHERE egzemplioriai.skaicius < vidurkis.vid;

--dienos, kai paemusiuju knygas skaitytoju buvo daugiau negu per visas paemimo dienas vidutiniskai. 
--Greta pateikti ir tuomet emusiuju knygas skaitytoju skaiciu 

--1.rasti skaitytoju, paemusiu knygas skaiciu konkrecioms datoms
WITH laikina (diena, skaicius) AS (
	SELECT paimta, COUNT(DISTINCT skaitytojas)
	FROM stud.egzempliorius
	GROUP BY paimta 
),
--2.rasti skaitytoju, paemusiu knygas vidurki visoms datoms
vidurkis (vid) AS(
	SELECT AVG(skaicius)
	FROM laikina
)--3.grazinti tas dienas su skaitytoju skaiciumi kur 1>2
SELECT diena, skaicius
FROM laikina, vidurkis
WHERE laikina.skaicius > vidurkis.vid;	
*/
/*
WITH skait1 (nr1, isbn1, gimimas) AS ( --pirmo skaitytojo info
    SELECT sk.nr, egz.isbn, sk.gimimas
	FROM stud.skaitytojas AS sk, stud.egzempliorius AS egz
	WHERE sk.nr = egz.skaitytojas
	GROUP BY sk.nr, egz.isbn, sk.gimimas
),
skait2 (nr2) AS( --antro skaitytojo nr, (skirtingas skaitytojas)
	SELECT sk.nr, egz.isbn
	FROM stud.skaitytojas AS sk, stud.egzempliorius AS egz, skait1
	WHERE sk.nr = egz.skaitytojas
	AND skait1.nr1 <> sk.nr
	AND egz.isbn = isbn1 --skaito tas pacias knygas 
	AND sk.gimimas > skait1.gimimas -- pirmas vyresnis uz antra
)

SELECT sk.vardas, sk.pavarde
FROM stud.skaitytojas AS sk, skait2 
WHERE sk.nr = skait2.nr2;
*/
--skaitytoja jeigu yra vyresnis skaitytojas jo skaitomu knygu

/*
WITH skaitytojas1 (nr, vardas, pavarde, gimimas) AS (
	SELECT sk.nr, sk.vardas, sk.pavarde, sk.gimimas
	FROM stud.skaitytojas AS sk
), knygos (isbn) AS (
	SELECT egz.isbn
	FROM stud.egzempliorius AS egz, skaitytojas1 AS sk1
	WHERE egz.skaitytojas = sk1.nr
), skaitytojas2 (nr) AS (
	SELECT sk1.nr, sk1.vardas, sk1.pavarde
	FROM stud.skaitytojas AS sk
	JOIN stud.egzempliorius AS egz ON egz.skaitytojas = sk.nr
	JOIN knygos AS kn ON egz.isbn = kn.isbn
	JOIN skaitytojas1 AS sk1 ON sk1.gimimas < sk.gimimas
	GROUP BY sk1.nr, sk1.vardas, sk1.pavarde
)
SELECT * FROM skaitytojas2;

SELECT sk1.nr, sk1.vardas, sk1.pavarde, sk1.gimimas
FROM stud.skaitytojas AS sk1
WHERE sk1.gimimas > ANY(
	SELECT sk2.gimimas
	FROM stud.egzempliorius AS egz1, stud.egzempliorius AS egz2, stud.skaitytojas AS sk2
	WHERE egz1.skaitytojas = sk1.nr
	AND egz2.isbn = egz1.isbn
	AND egz2.skaitytojas = sk2.nr
)
*/
-- Kiekvienai Leidyklai, surasti knyga kurios egzemplioriu isleista daugiausiai ir paimta maziausiai
/*
WITH leidyklos (leidykla, pavadinimas, paimta_skaicius, leidimu_skaicius) AS (
	SELECT kn.leidykla, kn.pavadinimas, COUNT(egz.paimta), COUNT(egz.isbn)
	FROM stud.knyga AS kn 
	JOIN stud.egzempliorius AS egz ON egz.isbn = kn.isbn
	GROUP BY kn.isbn
), laikina (leidykla, sk1, sk2) AS ( 
	SELECT leidykla, MIN(paimta_skaicius), MAX(leidimu_skaicius)
	FROM leidyklos
	GROUP BY leidykla
)
--grazinam leidykla su maziausiu paimtu egzemplioriu skaiciumi 
SELECT leid.leidykla, leid.paimta_skaicius, leid.pavadinimas, leid.leidimu_skaicius
FROM leidyklos AS leid, laikina AS laik
WHERE leid.paimta_skaicius = laik.sk1 
	AND leid.leidimu_skaicius = laik.sk2 
	AND leid.leidykla = laik.leidykla;
	
--Data, kada turinčiųjų grąžinti knygas skaitytojų skaičius yra mažiausias. 
--Greta pateikti ir turinčių tuomet grąžinti knygas skaitytojų skaičių.
--kiekvienai leidyklai
WITH laikina (reiksme, graz, leidykla) AS (
	SELECT COUNT (DISTINCT egz.skaitytojas) AS skaicius, egz.grazinti, kn.leidykla
	FROM stud.egzempliorius AS egz, stud.knyga AS kn
	WHERE egz.grazinti IS NOT NULL AND kn.isbn = egz.isbn
	GROUP BY egz.grazinti, kn.leidykla
),
laikina1 (maziausia, leid) AS (SELECT MIN(laik.reiksme), laik.leidykla   
FROM laikina AS laik
GROUP BY laik.leidykla
)
SELECT laik.graz AS "grazinimo data", laik1.leid AS "leidykla", laik.reiksme AS "skaicius"
FROM laikina AS laik, laikina1 AS laik1
WHERE laik.reiksme = laik1.maziausia AND laik.leidykla = laik1.leid;	
*/
-- 5uzd schemos

/*
--visos biblio lenteles is kuriu einamasis vartotojas gali gauti duomenis
SELECT grantee, Table_Schema, Table_Name
FROM information_schema.table_privileges
WHERE grantee = CURRENT_USER
	AND Table_Catalog = 'biblio'
	AND Privilege_Type = 'SELECT';

--visos stud lenteles is kuriu einamasis vartotojas gali gauti duomenis
SELECT grantee, Table_Catalog, Table_Schema, Table_Name
FROM information_schema.table_privileges
WHERE grantee = CURRENT_USER
	AND Table_Catalog = 'biblio'
	AND Table_Schema = 'stud'
	AND Privilege_Type = 'SELECT';
*/
	
--grantee 'PUBLIC' visiems vartotojams, jeigu grantee = CURRENT_USER - dabartinis vartotojas
--privilegiju tipas kiekvienai lentelei dabartiniam naudotojui ir public  
/*
SELECT grantee, table_catalog, table_schema, table_name, privilege_type
FROM information_schema.table_privileges
WHERE grantee IN ('PUBLIC', CURRENT_USER)
ORDER BY grantee, table_schema, table_name;
*/
--TABLE_TYPE = 'BASE TABLE' - pagrindine lentelei
--TABLE_TYPE = 'VIEW' - virtuali lentele

/*
--visos lenteles duombazeje (ju pavadinimai)
SELECT Table_Name
FROM Information_Schema.Tables;

--pateikti visa sarasa lenteliu (tiesiogiai arba su role) kurias gali naudoti uzklausose einamasis vartotojas
SELECT grantee, Table_Schema, Table_Name
FROM information_schema.table_privileges
WHERE grantee = CURRENT_USER
	AND Privilege_Type = 'SELECT';

--role table_privileges public ir current user

*/
/*
--kiekvienai lentelei ilgiausia stulpelio ilgio charakteristika
SELECT c.Table_Name, c.Column_Name, c.Character_Maximum_Length
FROM Information_Schema.Columns c
WHERE c.Character_Maximum_Length IS NOT NULL
    AND Character_Maximum_Length = (
        SELECT MAX(Character_Maximum_Length)
        FROM Information_Schema.Columns c2
        WHERE c2.Table_Name = c.Table_Name
			AND c2.Table_Catalog = c.Table_Catalog
			AND c2.Table_Schema = c.Table_Schema
    )
ORDER BY 
    c.Table_Name;
--pagrindines lenteles, kuriose visi stulpeliai privalomi

SELECT t.Table_Name
FROM Information_Schema.Tables t, Information_Schema.Columns c
WHERE t.Table_Name = c.Table_Name
	AND t.Table_Catalog = c.Table_Catalog
	AND t.Table_Schema = c.Table_Schema
	AND t.table_type = 'BASE TABLE'
	AND c.is_nullable = 'NO'
GROUP BY t.Table_Name
HAVING COUNT(*) = (
	SELECT COUNT(*)
	FROM Information_Schema.Columns c1
	WHERE c1.Table_Name = t.Table_Name
);
*/
/*
WITH stulpeliai(lentele, skaicius) AS(
	SELECT Table_Name, COUNT(*)
	FROM Information_Schema.Columns
	WHERE Table_Catalog = 'biblio'
	AND Table_Schema = 'stud'
	GROUP BY Table_Name
), vidurkis (vid) AS (
	SELECT AVG(skaicius)
	FROM stulpeliai
)
SELECT st.lentele, st.skaicius
FROM stulpeliai st, vidurkis v
WHERE st.skaicius < v.vid
*/
SELECT grantee, Table_Schema, Table_Name
FROM information_schema.table_privileges
WHERE grantee = CURRENT_USER
	AND Table_Catalog = 'biblio'
	AND Privilege_Type = 'SELECT';
/*
--isvesti pagrindines lenteles kuriose yra bent 3 skirtingi duomenu tipai
SELECT t.Table_Name
FROM Information_Schema.Tables t, Information_Schema.Columns c
WHERE t.Table_Name = c.Table_Name
	AND t.Table_Catalog = c.Table_Catalog
	AND t.Table_Schema = c.Table_Schema
	AND t.table_type = 'BASE TABLE'
GROUP BY t.Table_Name 
HAVING COUNT(DISTINCT c.data_type) >= 3;


--isvesti lenteles kuriose nera isorinio rakto
SELECT Table_Name
FROM Information_Schema.tables
WHERE Table_Name NOT IN ( --jeigu noretume specifiskai pagrindiniu lenteliu, reiktu pridet table_type = 'BASE TABLE'
	SELECT Table_Name
	FROM Information_Schema.key_column_usage
	WHERE Position_In_Unique_Constraint IS NOT NULL
);

--isvesti stud lenteles kuriose nera isorinio rakto
SELECT Table_Name
FROM Information_Schema.tables
WHERE table_catalog = 'biblio'
AND table_schema = 'stud'
AND Table_Name NOT IN ( --jeigu noretume specifiskai pagrindiniu lenteliu, reiktu pridet table_type = 'BASE TABLE'
	SELECT Table_Name
	FROM Information_Schema.key_column_usage
	WHERE table_catalog = 'biblio'
	AND table_schema = 'stud' 
	AND Position_In_Unique_Constraint IS NOT NULL
);

*/

WITH MaxLengths AS (
    SELECT Table_Name, Table_Schema, MAX(Character_Maximum_Length) AS MaxCharacterLength, MAX(Numeric_Precision) AS MaxNumericPrecision
    FROM Information_Schema.Columns
    WHERE Character_Maximum_Length IS NOT NULL
          OR Numeric_Precision IS NOT NULL
    GROUP BY 
        Table_Name, Table_Schema
)
SELECT c.Table_Name, c.Column_Name, c.Character_Maximum_Length, c.Numeric_Precision
FROM Information_Schema.Columns c
JOIN MaxLengths AS m ON c.Table_Name = m.Table_Name 
				AND c.Table_Schema = m.Table_Schema
WHERE (c.Character_Maximum_Length = m.MaxCharacterLength OR c.Numeric_Precision = m.MaxNumericPrecision)
ORDER BY c.Table_Name;
