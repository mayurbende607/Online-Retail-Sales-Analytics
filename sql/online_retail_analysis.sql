SHOW VARIABLES LIKE 'secure_file_priv';
CREATE DATABASE ecommerce;
USE ecommerce;
CREATE TABLE online_retail (
    InvoiceNo INT,
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DOUBLE,
    CustomerID DOUBLE,
    Country VARCHAR(100),
    Revenue DOUBLE,
    Year INT,
    Month INT,
    Month_Name VARCHAR(20)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/online_retail_final.csv'
INTO TABLE online_retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
InvoiceNo,
StockCode,
Description,
Quantity,
@InvoiceDate,
UnitPrice,
CustomerID,
Country,
Revenue,
Year,
Month,
Month_Name
)
SET InvoiceDate = STR_TO_DATE(@InvoiceDate,'%Y-%m-%d %H:%i:%s');


SELECT COUNT(*) AS Total_Rows
FROM online_retail;


-- Total Revenue
SELECT ROUND(SUM(Revenue),2) AS Total_Revenue
FROM online_retail;

-- Total Order
select count(distinct invoiceNo) as Total_order from online_retail;

-- Total Customer
SELECT COUNT(DISTINCT CustomerID) AS Total_Customers
FROM online_retail;

-- Total Countries
SELECT COUNT(DISTINCT Country) AS Total_Countries
FROM online_retail;

-- Average order values
SELECT
ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo),2)
 AS Average_Order_Value
FROM online_retail;



-- Top 10 Customers by Revenue
SELECT CustomerID,ROUND(SUM(Revenue),2) AS Total_Revenue
FROM online_retail
GROUP BY CustomerID
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Customers with the Highest Number of Orders
SELECT CustomerID,COUNT(DISTINCT InvoiceNo) AS Total_Orders
FROM online_retail
GROUP BY CustomerID
ORDER BY Total_Orders DESC
LIMIT 10;

-- Revenue Contribution of Top Customers
SELECT
ROUND(SUM(Total_Revenue),2) AS Top10_Revenue
FROM
(
    SELECT CustomerID,SUM(Revenue) AS Total_Revenue
    FROM online_retail GROUP BY CustomerID
    ORDER BY Total_Revenue DESC
    LIMIT 10
) AS Top10;

SELECT
ROUND((1537659.21 / 8887208.89) * 100,2) AS Revenue_Contribution;


-- Repeat vs One-Time Customers
SELECT CustomerID,COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    CASE
        WHEN COUNT(DISTINCT InvoiceNo) = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS Customer_Type
FROM online_retail
GROUP BY CustomerID;

SELECT Customer_Type,COUNT(*) AS Total_Customers
FROM
(
    SELECT CustomerID,
        CASE
            WHEN COUNT(DISTINCT InvoiceNo) = 1 THEN 'One-Time Customer'
            ELSE 'Repeat Customer'
        END AS Customer_Type
    FROM online_retail
    GROUP BY CustomerID
) AS CustomerData
GROUP BY Customer_Type;


--  Average Revenue per Customer
SELECT ROUND(SUM(Revenue) / COUNT(DISTINCT CustomerID),2
) AS Average_Revenue_Per_Customer
FROM online_retail;

-- Customer Purchase Frequency
SELECT ROUND(COUNT(DISTINCT InvoiceNo) / COUNT(DISTINCT CustomerID),2
) AS Purchase_Frequency
FROM online_retail;

-- Top 10 Products by Revenue
SELECT StockCode,Description,ROUND(SUM(Revenue),2) AS Total_Revenue
FROM online_retail
GROUP BY StockCode, Description
ORDER BY Total_Revenue DESC
LIMIT 10;


-- Best-Selling Products by Quantity
SELECT StockCode,Description,SUM(Quantity) AS Total_Quantity_Sold
FROM online_retail
WHERE StockCode NOT IN ('POST','M')
GROUP BY StockCode, Description
ORDER BY Total_Quantity_Sold DESC
LIMIT 10;


-- Products with Highest Number of Orders
SELECT StockCode,Description,COUNT(DISTINCT InvoiceNo) AS Total_Orders
FROM online_retail
WHERE StockCode NOT IN ('POST','M')
GROUP BY StockCode, Description
ORDER BY Total_Orders DESC
LIMIT 10;


-- top 10 Product Revenue Contribution
SELECT
ROUND(SUM(Product_Revenue),2) AS Top10_Product_Revenue
FROM
(
    SELECT StockCode,SUM(Revenue) AS Product_Revenue
    FROM online_retail
    WHERE StockCode NOT IN ('POST','M')
    GROUP BY StockCode
    ORDER BY Product_Revenue DESC
    LIMIT 10
) AS TopProducts;


-- Average Revenue per Product
SELECT
ROUND(SUM(Revenue) / COUNT(DISTINCT StockCode),2)
 AS Average_Revenue_Per_Product
FROM online_retail
WHERE StockCode NOT IN ('POST','M');



-- Top 10 Countries by Revenue
SELECT Country,ROUND(SUM(Revenue),2) AS Total_Revenue
FROM online_retail
GROUP BY Country
ORDER BY Total_Revenue DESC
LIMIT 10;


-- Countries with Highest Number of Orders
SELECT Country,COUNT(DISTINCT InvoiceNo) AS Total_Orders
FROM online_retail
GROUP BY Country
ORDER BY Total_Orders DESC
LIMIT 10;


-- Countries with Highest Number of Customers
SELECT Country,COUNT(DISTINCT CustomerID) AS Total_Customers
FROM online_retail
GROUP BY Country
ORDER BY Total_Customers DESC
LIMIT 10;


-- Average Revenue per Country
SELECT ROUND(SUM(Revenue) / COUNT(DISTINCT Country),2
) AS Average_Revenue_Per_Country
FROM online_retail;

--  top Country Revenue Contribution
SELECT ROUND((SUM(CASE WHEN Country = 'United Kingdom' THEN Revenue ELSE 0 END)
    / SUM(Revenue)) * 100,
    2
) AS UK_Revenue_Contribution_Percentage
FROM online_retail;