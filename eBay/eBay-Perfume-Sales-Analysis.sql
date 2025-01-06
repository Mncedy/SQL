Drop Database IF EXISTS Ebay;
Create Database Ebay;

Use Ebay;

Select Top 5
	*
From Ebay..mens_perfume;

Select Top 5
	*
From Ebay..womens_perfume;

-- Assuming prices are in different currencies, convert all prices to a single currency (e.g., USD)
-- You would typically have a conversion table with currency rates
-- For this example, we assume that all prices are in USD and we just remove the currency symbol

UPDATE mens_perfume
SET price = CAST(REPLACE(priceWithCurrency, '$', '') AS DECIMAL(10, 2));

UPDATE mens_perfume
SET priceWithCurrency = CAST(REPLACE(REPLACE(SUBSTRING(priceWithCurrency, 
                CHARINDEX('$', priceWithCurrency) + 1, 
                CASE
                    WHEN CHARINDEX('/', priceWithCurrency) > 0 
                    THEN CHARINDEX('/', priceWithCurrency) - CHARINDEX('$', priceWithCurrency) - 1
                    ELSE LEN(priceWithCurrency)
                END
            ), ',', ''), ' ', '') AS DECIMAL(10, 2))
WHERE priceWithCurrency LIKE 'US $%/%';


UPDATE mens_perfume
SET price = CAST(REPLACE(REPLACE(SUBSTRING(priceWithCurrency, 1, 
                CASE 
                    WHEN CHARINDEX('/', priceWithCurrency) > 0 
                    THEN CHARINDEX('/', priceWithCurrency) - 1
                    ELSE LEN(priceWithCurrency)
                END
            ), '$', ''), ',', '') AS DECIMAL(10, 2))
WHERE ISNUMERIC(REPLACE(REPLACE(SUBSTRING(priceWithCurrency, 1, 
                CASE 
                    WHEN CHARINDEX('/', priceWithCurrency) > 0 
                    THEN CHARINDEX('/', priceWithCurrency) - 1
                    ELSE LEN(priceWithCurrency)
                END
            ), '$', ''), ',', '')) = 1;


-- Replace NULL values in availableText and itemLocation with default values (e.g., 'Not Available')
UPDATE mens_perfume
SET availableText = 0
WHERE availableText IS NULL;

UPDATE womens_perfume
SET availableText = 0
WHERE availableText IS NULL;

UPDATE mens_perfume
SET itemLocation = 'Unknown'
WHERE itemLocation IS NULL;

UPDATE womens_perfume
SET itemLocation = 'Unknown'
WHERE itemLocation IS NULL;


-- Extracting brand information if it appears as the first word in the title

ALTER TABLE mens_perfume ADD BrandExtracted NVARCHAR(255);

UPDATE mens_perfume
SET BrandExtracted = SUBSTRING(title, 1, CHARINDEX(' ', title) - 1)
WHERE CHARINDEX(' ', title) > 0;

-- Similar logic applies to Womens_perfume
ALTER TABLE womens_perfume ADD BrandExtracted NVARCHAR(255);

UPDATE mens_perfume
SET BrandExtracted = SUBSTRING(title, 1, CHARINDEX(' ', title) - 1)
WHERE CHARINDEX(' ', title) > 0;

-- Convert lastUpdated column to datetime
ALTER TABLE mens_perfume ALTER COLUMN lastUpdated DATETIME;

ALTER TABLE Womens_perfume ALTER COLUMN lastUpdated DATETIME;


-- Calculate PricePerUnit
ALTER TABLE mens_perfume ADD PricePerUnit DECIMAL(10, 2);

UPDATE mens_perfume
SET PricePerUnit = price / sold
WHERE sold IS NOT NULL;

SELECT brand, PricePerUnit FROM mens_perfume

-- Similar logic applies to Womens_perfume
ALTER TABLE womens_perfume ADD PricePerUnit DECIMAL(10, 2);

UPDATE womens_perfume
SET PricePerUnit = price / sold
WHERE sold IS NOT NULL;

SELECT brand, PricePerUnit FROM womens_perfume
SELECT brand, PricePerUnit FROM mens_perfume

--1. Sales Performance Analysis
--Key Question: Which brands are generating the most sales in terms of revenue and units sold?
--Query 1: Top Brands by Revenue (Using CTE and Subqueries)
-- CTE to calculate total sales for each brand
WITH BrandSales AS (
    SELECT 
        brand, 
        ROUND(SUM(sold * price), 2) AS TotalRevenue,
        SUM(sold) AS TotalUnitsSold
    FROM 
        mens_perfume
    WHERE 
        sold IS NOT NULL
    GROUP BY 
        brand
)
-- Main query to find top 10 brands by revenue
SELECT TOP 10
    brand, 
    TotalRevenue, 
    TotalUnitsSold
FROM 
    BrandSales
ORDER BY 
    TotalRevenue DESC;

-- Query 2:
-- Step 1: CTE to calculate average price and total sales by brand and type
WITH BrandTypeAnalysis AS (
    SELECT 
        p.brand,
        p.type, -- Assuming this identifies the fragrance type (e.g., Eau de Parfum)
        AVG(p.price) AS AvgPricePoint,
        SUM(s.sold) AS TotalUnitsSold
    FROM 
        mens_perfume AS p
    JOIN 
        mens_perfume AS s ON p.brand = s.brand
    WHERE 
        s.sold IS NOT NULL
    GROUP BY 
        p.brand, p.type
),
-- Step 2: Rank brands and types by total sales
BestsellingBrands AS (
    SELECT 
        brand,
        type,
        AvgPricePoint,
        TotalUnitsSold,
        RANK() OVER (ORDER BY TotalUnitsSold DESC) AS SalesRank
    FROM 
        BrandTypeAnalysis
)
-- Final Query: Retrieve top 10 brands with highest sales
SELECT 
    brand,
    type,
    ROUND(AvgPricePoint, 2) AS AvgPricePoint,
    TotalUnitsSold
FROM 
    BestsellingBrands
WHERE 
    SalesRank <= 10 -- Top 10 bestselling brands
ORDER BY 
    TotalUnitsSold DESC;




-- Step 1: CTE to calculate total sales by product
WITH ProductSales AS (
    SELECT 
        p.brand,
        p.type AS FragranceType,
        p.price,
        SUM(s.sold) AS TotalUnitsSold
    FROM 
        mens_perfume AS p
    JOIN 
        mens_perfume AS s ON p.brand = s.brand
    WHERE 
        s.sold IS NOT NULL
    GROUP BY 
        p.brand, p.type, p.price
),
-- Step 2: CTE to rank products based on total units sold
RankedProducts AS (
    SELECT 
        brand,
        FragranceType,
        price,
        TotalUnitsSold,
        RANK() OVER (ORDER BY TotalUnitsSold DESC) AS SalesRank
    FROM 
        ProductSales
)
-- Final Query: Retrieve features of the top 10 bestselling fragrances
SELECT TOP 10
    rp.brand,
    rp.FragranceType,
    rp.price,
    rp.TotalUnitsSold,
    CASE 
        WHEN rp.price BETWEEN 15 AND 85 THEN 'Popular Price Range'
        ELSE 'Other Price Range'
    END AS PriceCategory
FROM 
    RankedProducts AS rp
WHERE 
    rp.SalesRank <= 10
ORDER BY 
    rp.SalesRank;



--2. Inventory and Stock Management
--Key Question: Which products are frequently out of stock or have low availability?
--Query 3: Products with High Sales but Low Availability (Using Subqueries)
-- Find products with high sales but low availability
SELECT 
    brand,  
    sold, 
    available,
    SellThroughRate
FROM (
    SELECT 
        brand, 
        title, 
        available, 
        sold, 
        ROUND((sold / NULLIF(available, 0)) * 100, 2) AS SellThroughRate
    FROM 
        mens_perfume
) AS ProductSalesWithRate
WHERE 
    sold > 0 
    AND available < 10  -- Threshold for low availability
    AND brand = 'Tommy Hilfiger'
ORDER BY 
    SellThroughRate DESC;

-- Temp table to calculate stock-outs over time
DROP TABLE IF EXISTS #OutOfStock;
CREATE TABLE #OutOfStock (
    brand NVARCHAR(255),
    title NVARCHAR(255),
    outOfStockDate DATE
);

-- Insert into temp table where availability is zero
INSERT INTO #OutOfStock
SELECT 
    brand, 
    title, 
    lastUpdated AS outOfStockDate
FROM 
    mens_perfume
WHERE 
    available IS NOT NULL;

-- Query the temp table to find frequently out of stock products
SELECT 
    brand, 
    title, 
    COUNT(outOfStockDate) AS OutOfStockOccurrences
FROM 
    #OutOfStock
GROUP BY 
    brand, title
ORDER BY 
    OutOfStockOccurrences DESC;


--3. Price Sensitivity and Discount Analysis
--Key Question: How does price affect the number of units sold?
--Query 5: Price Elasticity of Demand (Using Subqueries and CTE)
-- CTE to calculate average sales and prices by brand
WITH PriceElasticity AS (
    SELECT 
        brand, 
        AVG(price) AS AvgPrice,
        AVG(sold) AS AvgSales
    FROM 
        mens_perfume
    WHERE 
        sold IS NOT NULL
    GROUP BY 
        brand
)
-- Main query to find brands with the highest price sensitivity
SELECT 
    brand, 
    ROUND(AvgSales, 2),  
    ROUND(AvgPrice, 2),
    ROUND((AvgSales / NULLIF(AvgPrice, 0)), 2) AS SalesPerPriceUnit
FROM 
    PriceElasticity
ORDER BY 
    SalesPerPriceUnit DESC;

/** This code helps identify brands that have the highest price sensitivity. 
Brands with a higher SalesPerPriceUnit likely achieve more sales relative to their pricing, suggesting greater price sensitivity. 
This insight can help in pricing decisions, indicating which brands might benefit from price adjustments to optimize sales. **/

-- Function to calculate the impact of discounts on sales for a specific brand
CREATE FUNCTION dbo.DiscountImpactOnSales(@BrandName NVARCHAR(255))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        brand, 
        title, 
        price, 
        sold, 
        ROUND(price - (price * 0.1), 2) AS DiscountedPrice, -- Assuming a 10% discount
        ROUND(sold * 1.1, 2) AS ProjectedSales -- Assuming sales increase by 10% after discount
    FROM 
        mens_perfume
    WHERE 
        brand = @BrandName
);
SELECT 
	* 
FROM 
	dbo.DiscountImpactOnSales('Giorgio Armani')

--4. Customer Location and Market Segmentation
--Key Question: Which locations have the highest fragrance sales volume?
--Top Locations by Sales Volume (Using Views)
-- Create a view to simplify sales by location analysis
CREATE VIEW LocationSales AS
SELECT 
    itemLocation, 
    SUM(sold * price) AS TotalRevenue, 
    SUM(sold) AS TotalUnitsSold
FROM 
    mens_perfume
GROUP BY 
    itemLocation;
-- Query the view to find top-selling locations
SELECT 
    itemLocation, 
    ROUND(TotalRevenue, 2), 
    TotalUnitsSold
FROM 
    LocationSales
ORDER BY 
    TotalRevenue DESC;

--5. Competitor and Brand Benchmarking
--Key Question: How does our pricing strategy compare to competitors?
--Competitor Price Comparison (Using Subqueries and CTE)
--CTE to calculate average price and sales for each brand
WITH BrandPriceComparison AS (
    SELECT 
        brand, 
        AVG(price) AS AvgPrice, 
        SUM(sold) AS TotalUnitsSold
    FROM 
        mens_perfume
    WHERE 
        sold IS NOT NULL
    GROUP BY 
        brand
)
-- Main query to compare brands and highlight pricing discrepancies
SELECT 
    brand, 
    ROUND(AvgPrice, 2), 
    TotalUnitsSold
FROM 
    BrandPriceComparison
WHERE 
    AvgPrice > (SELECT AVG(price) FROM mens_perfume) -- Compare against the overall average price
ORDER BY 
    AvgPrice DESC;

--6. Seasonality and Sales Trends
--Key Question: Is there a clear seasonal trend in fragrance sales?
--Query 9: Seasonal Sales Trends (Using CTE and Date Functions)
-- CTE to calculate monthly sales trends
WITH MonthlySales AS (
    SELECT 
        brand, 
        DATEPART(MONTH, lastUpdated) AS Month,
        SUM(sold) AS TotalUnitsSold,
        SUM(sold * price) AS TotalRevenue
    FROM 
        mens_perfume
    WHERE 
        sold IS NOT NULL
    GROUP BY 
        brand, DATEPART(MONTH, lastUpdated)
)
-- Main query to find seasonality patterns
SELECT 
    Month, 
    SUM(TotalUnitsSold) AS UnitsSold, 
    SUM(TotalRevenue) AS RevenueGenerated
FROM 
    MonthlySales
GROUP BY 
    Month
ORDER BY 
    Month;


--7. Cross-Category Analysis
--Key Question: How do men�s and women�s fragrances compare in terms of sales?
--Query 10: Cross-Category Analysis (Using Temp Table)
-- Temp table to hold sales data by category (men vs. women)
DROP TABLE IF EXISTS #CategorySales;
CREATE TABLE #CategorySales (
    brands NVARCHAR(255),
    TotalRevenue DECIMAL(18, 2),
    TotalUnitsSold INT
);

-- Insert category sales into temp table
INSERT INTO #CategorySales
SELECT 
    brands, 
    SUM(sold * price) AS TotalRevenue,
    SUM(sold) AS TotalUnitsSold
FROM 
    mens_perfume as mp
	JOIN womens_perfume as wp
	ON mp.brand = wp.brand
GROUP BY 
    brands;

-- Query the temp table for comparison
SELECT 
    brands, 
    TotalRevenue, 
    TotalUnitsSold
FROM 
    #CategorySales
ORDER BY 
    TotalRevenue DESC;


-- Compare the total revenue and units sold for men's and women's fragrances across brands.
-- Joining men's and women's fragrances data to compare sales performance
SELECT 
    COALESCE(men.brand, women.brand) AS Brand, -- In case the brand exists only in one of the tables
    ROUND(SUM(men.sold * men.price), 2) AS MenTotalRevenue,
    ROUND(SUM(women.sold * women.price), 2) AS WomenTotalRevenue,
    ROUND(SUM(men.sold), 2) AS MenTotalUnitsSold,
    ROUND(SUM(women.sold), 2) AS WomenTotalUnitsSold
FROM 
    mens_perfume men
FULL OUTER JOIN 
    womens_perfume women ON men.brand = women.brand
GROUP BY 
    COALESCE(men.brand, women.brand)
ORDER BY 
    (SUM(men.sold * men.price) + SUM(women.sold * women.price)) DESC;

-- Analyze how prices differ between men's and women's fragrances for the same brand.
-- Joining men's and women's fragrances data to compare average prices for the same brands
SELECT 
    men.brand AS Brand, 
    ROUND(AVG(men.price), 2) AS AvgMenPrice,
    ROUND(AVG(women.price), 2) AS AvgWomenPrice,
    ROUND((AVG(men.price) - AVG(women.price)), 2) AS PriceDifference
FROM 
    mens_perfume men
INNER JOIN 
    womens_perfume women ON men.brand = women.brand
GROUP BY 
    men.brand
ORDER BY 
    PriceDifference DESC;


-- Identify the top locations where both men's and women's fragrances are sold and compare total sales by location
-- Joining men's and women's fragrances data to compare sales by location
SELECT 
    COALESCE(men.itemLocation, women.itemLocation) AS Location, 
    SUM(men.sold) AS MenTotalUnitsSold, 
    SUM(women.sold) AS WomenTotalUnitsSold,
    ROUND(SUM(men.sold * men.price), 2) AS MenTotalRevenue,
    ROUND(SUM(women.sold * women.price), 2) AS WomenTotalRevenue
FROM 
    mens_perfume men
FULL OUTER JOIN 
    womens_perfume women ON men.itemLocation = women.itemLocation
GROUP BY 
    COALESCE(men.itemLocation, women.itemLocation)
ORDER BY 
    (SUM(men.sold * men.price) + SUM(women.sold * women.price)) DESC;

-- Determine the sales performance of different brands in various locations to understand regional trends.
-- Query to find sales performance of each brand in different locations
SELECT TOP 10
    brand,
    itemLocation,
    ROUND(SUM(sold * price), 2) AS TotalRevenue,
    SUM(sold) AS TotalUnitsSold
FROM 
    mens_perfume
GROUP BY 
    brand, itemLocation
ORDER BY 
    TotalRevenue DESC, itemLocation DESC;

-- Stored Procedure to Get Top Brands by Type
-- Stored procedure to get top brands by fragrance type
DROP PROCEDURE IF EXISTS GetTopBrandsByType;

CREATE PROCEDURE GetTopBrandsByType
    @FragranceType NVARCHAR(255), 
    @TopN INT
AS
BEGIN
    SET NOCOUNT ON;

    WITH BrandTypeSales AS (
        SELECT 
            brand, 
            type, 
            ROUND(SUM(ISNULL(sold, 0) * ISNULL(price, 0)), 2) AS TotalRevenue,
			SUM(ISNULL(sold, 0)) AS TotalUnitsSold
        FROM 
            mens_perfume
        WHERE 
            type IS NOT NULL
        GROUP BY 
            brand, type
    )
    SELECT TOP (@TopN) 
        brand, 
        TotalRevenue, 
        TotalUnitsSold
    FROM 
        BrandTypeSales
    ORDER BY 
        TotalRevenue DESC;
END;

EXEC GetTopBrandsByType @FragranceType = '', @TopN = 6;

-- SQL is limited in heatmap visualization but you can create a cross-tab to analyze relationships.
-- Example: Cross-tab between brand and availability.

SELECT 
    brand, 
    available, 
    COUNT(*) AS Frequency
FROM 
    mens_perfume
WHERE
	available <> 0 AND
	brand IS NOT NULL
GROUP BY 
    brand, available;



 