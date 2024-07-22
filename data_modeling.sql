-- Creating dimensional data model using the star schema

SELECT * FROM shopping_trends..financials_cleaned

-- create dimension table DATE

CREATE TABLE DIM_DATE (
    Date_ID INT IDENTITY(1, 1) PRIMARY KEY,
	Date DATE,
	Month NVARCHAR(50),
	Year INT,
	Day NVARCHAR(50)
)

-- populate dimension table DATE

INSERT INTO DIM_DATE (Date, Month, Year, Day)
SELECT 
	DISTINCT Date, Month,  Year,  Day
FROM 
	shopping_trends..financials_cleaned

-- create dimension table COUNTRY

CREATE TABLE DIM_COUNTRY (
    Country_ID INT IDENTITY(1, 1) PRIMARY KEY,
	Country NVARCHAR(50)
)

-- populate dimension table COUNTRY

INSERT INTO DIM_COUNTRY (Country)
SELECT 
	DISTINCT Country
FROM 
	shopping_trends..financials_cleaned

SELECT * FROM DIM_COUNTRY

-- create dimension table SEGMENT

CREATE TABLE DIM_SEGMENT (
    Segment_ID INT IDENTITY(1, 1) PRIMARY KEY,
	Segment NVARCHAR(50)
)

-- populate dimension table SEGMENT

INSERT INTO DIM_SEGMENT (Segment)
SELECT 
	DISTINCT Segment
FROM 
	shopping_trends..financials_cleaned

-- create dimension table PRODUCT

CREATE TABLE DIM_PRODUCT (
    Product_ID INT IDENTITY(1, 1) PRIMARY KEY,
    Product NVARCHAR(50),
	Manufacturing_Price FLOAT
)

-- populate dimension table PRODUCT

INSERT INTO DIM_PRODUCT (Product, Manufacturing_Price)
SELECT 
	DISTINCT Product, Manufacturing_Price
FROM 
	shopping_trends..financials_cleaned

-- create dimension table DISCOUNT_BAND

CREATE TABLE DIM_DISCOUNT_BAND (
    Discount_Band_ID INT IDENTITY(1, 1)  PRIMARY KEY,
    Discount_Band NVARCHAR(50)
)

-- populate dimension table DISCOUNT_BAND

INSERT INTO DIM_DISCOUNT_BAND (Discount_Band)
SELECT 
	DISTINCT Discount_Band
FROM 
	shopping_trends..financials_cleaned

SELECT * FROM DIM_DISCOUNT_BAND

-- create fact table

CREATE TABLE FACT (
	Fact_ID INT IDENTITY(1, 1) PRIMARY KEY,
    Date_ID INT,
	Country_ID INT,
	Segment_ID INT,
	Product_ID INT,
	Sale_Price INT,
	Discount_Band_ID INT,
	Units_Sold FLOAT,
	Gross_Sales FLOAT,
	Discounts FLOAT,
	Sales FLOAT,
	Cost_of_goods_sold FLOAT,
	Profit FLOAT, 
	FOREIGN KEY (Date_ID) REFERENCES DIM_DATE(Date_ID),
	FOREIGN KEY (Country_ID) REFERENCES DIM_COUNTRY(Country_ID),
	FOREIGN KEY (Segment_ID) REFERENCES DIM_SEGMENT(Segment_ID),
	FOREIGN KEY (Product_ID) REFERENCES DIM_PRODUCT(Product_ID),
	FOREIGN KEY (Discount_Band_ID) REFERENCES DIM_DISCOUNT_BAND(Discount_Band_ID)
)

-- populate fact table 

INSERT INTO FACT ( 
	Date_ID, 
	Country_ID, 
	Segment_ID, 
	Product_ID, 
	Sale_Price,
	Discount_Band_ID, 
	Units_Sold, 
	Gross_Sales, 
	Discounts,
	Sales,
	Cost_Of_Goods_Sold, 
	Profit)
SELECT 
	Date_ID, 
	Country_ID, 
	Segment_ID, 
	Product_ID,
	Sale_Price,
	Discount_Band_ID, 
	Units_Sold, 
	Gross_Sales, 
	Discounts, 
	Sales,
	Cost_Of_Goods_Sold, 
	Profit
FROM shopping_trends..financials_cleaned f
	JOIN 
		DIM_DATE d ON f.Date = d.Date
	JOIN 
		DIM_COUNTRY c ON f.Country = c.Country
	JOIN 
		DIM_SEGMENT s ON f.Segment = s.Segment
	JOIN 
		DIM_PRODUCT p ON f.Product = p.Product
	JOIN 
		DIM_DISCOUNT_BAND b ON f.Discount_Band = b.Discount_Band

SELECT * FROM FACT 

