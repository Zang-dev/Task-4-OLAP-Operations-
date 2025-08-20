-- File: task4_olap_mysql.sql
DROP DATABASE IF EXISTS sales_olap;
CREATE DATABASE sales_olap;
USE sales_olap;

CREATE TABLE sales_sample (
  Product_Id INT NOT NULL,
  Region VARCHAR(50) NOT NULL,
  Date DATE NOT NULL,
  Sales_Amount DECIMAL(12,2) NOT NULL CHECK (Sales_Amount >= 0)
) ENGINE=InnoDB;

-- India-localized 10 rows (regions ~ India zones)
INSERT INTO sales_sample (Product_Id, Region, Date, Sales_Amount) VALUES
(101, 'North', '2025-01-05', 120000.00),
(101, 'West',  '2025-01-06',  95000.00),
(102, 'South', '2025-01-07', 150000.00),
(102, 'West',  '2025-01-08',  70000.00),
(103, 'East',  '2025-02-10',  30000.00),
(103, 'West',  '2025-02-11',  65000.00),
(101, 'North', '2025-02-12',  40000.00),
(102, 'South', '2025-03-01',  80000.00),
(103, 'East',  '2025-03-02',  90000.00),
(101, 'West',  '2025-03-03', 110000.00);

-- 3a) Drill Down: Single Region 
SELECT 
  Region, 
  Product_Id, 
  SUM(Sales_Amount) AS total_sales
FROM sales_sample
WHERE Region = 'West'
GROUP BY Region, Product_Id WITH ROLLUP
ORDER BY 
  Region IS NULL, Region, 
  Product_Id IS NULL, Product_Id; 


-- 3b) Rollup: totals by region + grand total
SELECT Region, SUM(Sales_Amount) AS region_total
FROM sales_sample
GROUP BY Region WITH ROLLUP
ORDER BY Region IS NULL, Region;

-- 3c) Cube emulation (all grouping sets) via UNION ALL
SELECT Product_Id, Region, Date, SUM(Sales_Amount) AS total_sales
FROM sales_sample
GROUP BY Product_Id, Region, Date
UNION ALL
SELECT Product_Id, Region, NULL, SUM(Sales_Amount)
FROM sales_sample
GROUP BY Product_Id, Region
UNION ALL
SELECT Product_Id, NULL, Date, SUM(Sales_Amount)
FROM sales_sample
GROUP BY Product_Id, Date
UNION ALL
SELECT NULL, Region, Date, SUM(Sales_Amount)
FROM sales_sample
GROUP BY Region, Date
UNION ALL
SELECT Product_Id, NULL, NULL, SUM(Sales_Amount)
FROM sales_sample
GROUP BY Product_Id
UNION ALL
SELECT NULL, Region, NULL, SUM(Sales_Amount)
FROM sales_sample
GROUP BY Region
UNION ALL
SELECT NULL, NULL, Date, SUM(Sales_Amount)
FROM sales_sample
GROUP BY Date
UNION ALL
SELECT NULL, NULL, NULL, SUM(Sales_Amount)
FROM sales_sample;

-- 3d) Slice: specific region or date range
SELECT Product_Id, Date, SUM(Sales_Amount) AS total_sales
FROM sales_sample
WHERE Region = 'West'
GROUP BY Product_Id, Date
ORDER BY Product_Id, Date;

SELECT Region, Product_Id, SUM(Sales_Amount) AS total_sales
FROM sales_sample
WHERE Date BETWEEN '2025-02-01' AND '2025-02-28'
GROUP BY Region, Product_Id
ORDER BY Region, Product_Id;

-- 3e) Dice: multiple filters
SELECT Product_Id, Region, Date, SUM(Sales_Amount) AS total_sales
FROM sales_sample
WHERE Product_Id IN (101,102)
  AND Region IN ('North','West')
  AND Date BETWEEN '2025-01-01' AND '2025-03-31'
GROUP BY Product_Id, Region, Date
ORDER BY Product_Id, Region, Date;
