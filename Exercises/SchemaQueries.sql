
--psql -h pgsql3.mif studentu -f schema.sql
--visos biblio lenteles kurioms einamasis vartotojas gali rasyti uzklausas
SELECT grantee, Table_Schema, Table_Name
FROM information_schema.table_privileges
WHERE grantee = CURRENT_USER
	AND Table_Catalog = 'biblio'
	AND Privilege_Type = 'SELECT';

--visos stud lenteles kurioms einamasis vartotojas gali rasyti uzklausas
SELECT grantee, Table_Catalog, Table_Schema, Table_Name
FROM information_schema.table_privileges
WHERE grantee = CURRENT_USER
	AND Table_Catalog = 'biblio'
	AND Table_Schema = 'stud'
	AND Privilege_Type = 'SELECT'

-- Stud lenteles kuriu stulpeliu skaicius < negu vidurkio
WITH stulpeliai(lentele, skaicius) AS(
	SELECT Table_Name, COUNT(*)
	FROM Information_Schema.Columns
	WHERE Table_Catalog = 'biblio'
	AND Table_Schema = 'stud'
	GROUP BY Table_Catalog, Table_Schema, Table_Name
), vidurkis (vid) AS (
	SELECT AVG(skaicius)
	FROM stulpeliai
)
SELECT st.lentele, st.skaicius
FROM stulpeliai st, vidurkis v
WHERE st.skaicius < v.vid

--privilegijos visoms lentelems tiek dabartiniam, tiek public vartotojui 
SELECT grantee, table_catalog, table_schema, table_name, privilege_type
FROM information_schema.table_privileges
WHERE grantee IN ('PUBLIC', CURRENT_USER)
ORDER BY grantee, table_schema, table_name;

--kiekvienai lentelei ilgiausia stulpelio ilgio charakteristika (reikia ir kito parametro)
SELECT c.Table_Name, c.Column_Name, c.Character_Maximum_Length, c.
FROM Information_Schema.Columns c
WHERE c.Character_Maximum_Length IS NOT NULL
AND Character_Maximum_Length = (
    SELECT MAX(Character_Maximum_Length)
    FROM Information_Schema.Columns c2
    WHERE c2.Table_Name = c.Table_Name
		AND c2.Table_Catalog = c.Table_Catalog
		AND c2.Table_Schema = c.Table_Schema
    )
ORDER BY c.Table_Name;

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

	
--pagrindines lenteles, kuriose visi stulpeliai privalomi
SELECT t.Table_Name
FROM Information_Schema.Tables t, Information_Schema.Columns c
WHERE t.Table_Name = c.Table_Name
	AND t.Table_Catalog = c.Table_Catalog
	AND t.Table_Schema = c.Table_Schema
	AND t.table_type = 'BASE TABLE'
	AND c.is_nullable = 'NO'
GROUP BY t.Table_Name, t.table_schema
HAVING COUNT(*) = (
	SELECT COUNT(*)
	FROM Information_Schema.Columns c1
	WHERE c1.Table_Name = t.Table_Name
	AND c1.Table_Schema = t.Table_Schema
);

--isvesti pagrindines lenteles kuriose yra bent 3 skirtingi duomenu tipai
SELECT t.Table_Name
FROM Information_Schema.Tables t, Information_Schema.Columns c
WHERE t.Table_Name = c.Table_Name
	AND t.Table_Catalog = c.Table_Catalog
	AND t.Table_Schema = c.Table_Schema
	AND t.table_type = 'BASE TABLE'
GROUP BY t.Table_Name , t.table_schema
HAVING COUNT(DISTINCT c.data_type) >= 3;

--isvesti lenteles kuriose nera isorinio rakto 
SELECT Table_Name
FROM Information_Schema.tables
WHERE Table_Name NOT IN ( --jeigu noretume specifiskai pagrindiniu lenteliu, reiktu pridet table_type = 'BASE TABLE'
	SELECT Table_Name
	FROM Information_Schema.key_column_usage
	WHERE Position_In_Unique_Constraint IS NOT NULL
);

--isvesti lenteles kuriose nera isorinio rakto (vienas select) su join
SELECT t.Table_Name
FROM Information_Schema.tables t
LEFT JOIN Information_Schema.key_column_usage k
ON t.Table_Name = k.Table_Name 
AND t.Table_Schema = k.Table_Schema
AND k.Position_In_Unique_Constraint IS NULL 

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
