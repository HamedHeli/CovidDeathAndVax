/*
===========================================
ETL Transaction Cheat Sheets:

============================================
*/


/*
===========================================
CREATE A NEW TABLE 
============================================
*/

CREATE TABLE table1(

  col2 smallint, 
  col3 integer, 
  col4 bigint, 
  col5 char(10), 
  col6 varchar(10), 
  col7 date, 
  col8 timestamp, 
  col9 time, 
  col10 decimal(10, 2), 
  col11 float, 
  col12 float
) 

/*
===========================================
COPY A TABLE INTO A NEW TABLE 
============================================
*/

SELECT *
	INTO table2
	FROM table1
	WHERE 1=2;


/*
===========================================
ADD A COLUMN TO AN EXISTING TABLE 
============================================
*/

ALTER table 
  table2 
ADD 
  table2_new varchar(30), 
  table2_new2 varchar(30);

  /*
===========================================
DROP A COLUMN FROM AN EXISTING TABLE
============================================
*/

ALTER table 
  table2 
DROP COLUMN
  table2_new,
  table2_new2

 /*
===========================================
DELETE A TABLE
============================================
*/

DROP TABLE table2

 /*
===========================================
CHECK FOR NULL
============================================
*/
SELECT 
  * 
FROM 
  table1 
WHERE 
  col2 IS NOT NULL 
  and col3 is NULL;

 /*
===========================================
CHECK FOR STRING PATTERN
============================================
*/

SELECT 
  * 
FROM 
  table1 
WHERE 
  col2 like 'T % ' OR col2 like 'S %'


   /*
===========================================
COALENSCE (the first non-null values)
============================================
*/


SELECT 
  col2 as w_sk, 
  COALESCE(col2, 'Not Available') as col13 
FROM 
  table1;



   /*
===========================================
USING CASE 
============================================
*/

  SELECT 
  col10 as w_sk, 
  col12 as w_id, 
  col11 as w_city, 
  CASE when col11 = 'California' then 'CA' when col12 = 'Florida' then 'FL' else 'Other States' END as col14 
FROM 
  table1;


     /*
===========================================
OVER PARTITION BY ORDER BY
============================================
*/

SELECT *, 
       AVG(col10) OVER(PARTITION BY col5 ORDER BY col5) AS col14, 
       MIN(col12) OVER(PARTITION BY col5 ORDER BY col5) AS col15, 
       SUM(col3) OVER(PARTITION BY col5 ORDER BY col5) col16
FROM table1;



     /*
===========================================
Lookup Function Excel
============================================
*/


UPDATE 
	table1 
SET 
	table1.col11 = table2.col12,
	table1.col10 = table2.col12

FROM table1 AS table1
LEFT JOIN 
table2 AS table2

ON 
table1.col3= table2.col3
WHERE 1=2

SELECT *
FROM table2