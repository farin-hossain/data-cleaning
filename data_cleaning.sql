-- Data cleaning with company financials data using SQL 

-- 1. Loading data into temp table 'financials'

SELECT * FROM shopping_trends..financials

-- create temp table 'financials' 

CREATE TABLE #financials (
	Segment NVARCHAR(50),
	Country NVARCHAR(50),
	Product NVARCHAR(50),
	Units_Sold NVARCHAR(50),
	Manufacturing_Price NVARCHAR(50),
	Sale_Price NVARCHAR(50),
	Gross_Sales NVARCHAR(50),
	Discounts NVARCHAR(50),
	Sales NVARCHAR(50),
	COGS NVARCHAR(50),
	Profit NVARCHAR(50),
	Date NVARCHAR(50),
	Month_Number INT,
	Month_Name NVARCHAR(50),
	Year INT
)

SELECT *
INTO financials
FROM shopping_trends..financials 

SELECT * FROM financials

-- drop unneeded column Month_Number

ALTER TABLE financials
DROP COLUMN Month_Number

-- 2. Cleaning data

-- rename columns to be more accurate

sp_rename 'financials.[COGS]','Cost_Of_Goods_Sold', 'COLUMN'

sp_rename 'financials.[Month_Name]',  'Month', 'COLUMN'

-- remove dollar sign ('$') from numerical columns

UPDATE financials
SET Units_Sold = replace(Units_Sold, '$', ''),
	Manufacturing_Price = replace(Manufacturing_Price, '$', ''),
	Sale_Price = replace(Sale_Price, '$', ''),
	Gross_Sales = replace(Gross_Sales, '$', ''),
	Discounts = replace(Discounts, '$', ''),
	Sales = replace(Sales, '$', ''),
    Cost_of_goods_sold = replace(Cost_of_goods_sold, '$', ''),
	Profit = replace(Profit, '$', '')

-- remove comma (',') from numerical columns

UPDATE financials
SET Units_Sold = replace(Units_Sold, ',', ''),
	Manufacturing_Price = replace(Manufacturing_Price, ',', ''),
    Sale_Price = replace(Sale_Price, ',', ''),
	Gross_Sales = replace(Gross_Sales, ',', ''),
	Discounts = replace(Discounts, ',', ''),
	Sales = replace(Sales, ',', ''),
	Cost_of_goods_sold = replace(Cost_of_goods_sold, ',', ''),
	Profit = replace(Profit, ',', '')

-- replace '-' from numerical columns with 0

UPDATE financials
SET Discounts = CASE WHEN Discounts = '-' THEN '0'
	ELSE Discounts
	END

UPDATE financials
SET Profit = CASE WHEN Profit = '-' THEN '0'
	ELSE Profit
	END

-- add column that contains the day of the week corresponding to the date

ALTER TABLE financials
ADD Day AS DATENAME(WEEKDAY,Date)  

-- replace the losses represented in (X.XX) form to -X.XX in the Profit column 

UPDATE financials
SET Profit = REPLACE(REPLACE(Profit,'(','-'),')','')

-- change numeric data to type FLOAT, and change Date from type TIMESTAMP to type DATE

ALTER TABLE financials
ALTER COLUMN Units_Sold FLOAT;

ALTER TABLE financials
ALTER COLUMN Manufacturing_Price FLOAT;

ALTER TABLE financials
ALTER COLUMN Sale_Price FLOAT;

ALTER TABLE financials
ALTER COLUMN Gross_Sales FLOAT;

ALTER TABLE financials
ALTER COLUMN Discounts FLOAT;

ALTER TABLE financials
ALTER COLUMN Sales FLOAT;

ALTER TABLE financials
ALTER COLUMN Cost_of_goods_sold FLOAT;

ALTER TABLE financials
ALTER COLUMN Profit FLOAT;

ALTER TABLE financials
ALTER COLUMN Date DATE;

-- check for null values

SELECT *
 FROM financials
 WHERE Segment IS NULL
 OR Country IS NULL
 OR Product IS NULL
 OR Discount_Band IS NULL

-- check for empty values

SELECT *
 FROM financials
 WHERE Segment  = ' '
 OR Country = ' '
 OR Product = ' '
 OR Discount_Band = ' '

-- remove leading and trailing whitespace from all text columns

UPDATE financials
SET  Segment = TRIM(Segment),
  Country = TRIM(Country),
  Product = TRIM(Product),
  Discount_Band = TRIM(Discount_Band)

-- check for duplicates 

WITH unique_combinations AS
   (SELECT *, ROW_NUMBER()
     OVER (PARTITION BY Segment, Country, Product, Discount_Band, Date ORDER BY Segment) row_num
	 FROM financials)
SELECT *
FROM unique_combinations
WHERE row_num > 1
