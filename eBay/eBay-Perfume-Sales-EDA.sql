-- Summary statistics for numeric columns in mens_perfume
SELECT 
    AVG(price) AS AvgPrice, 
    MIN(price) AS MinPrice, 
    MAX(price) AS MaxPrice, 
    STDEV(price) AS StdDevPrice,
    COUNT(*) AS TotalRecords
FROM 
    mens_perfume;

-- Womens_perfume
SELECT 
    AVG(price) AS AvgPrice, 
    MIN(price) AS MinPrice, 
    MAX(price) AS MaxPrice, 
    STDEV(price) AS StdDevPrice,
    COUNT(*) AS TotalRecords
FROM 
    womens_perfume;


-- Price distribution in mens_perfume using GROUP BY
SELECT 
    price, 
    COUNT(*) AS Frequency
FROM 
    mens_perfume
GROUP BY 
    price
ORDER BY 
    price;

-- Womens_perfume
SELECT 
    price, 
    COUNT(*) AS Frequency
FROM 
    womens_perfume
GROUP BY 
    price
ORDER BY 
    price;


-- Count of available and sold items in mens_perfume
SELECT 
    SUM(available) AS TotalAvailable, 
    SUM(sold) AS TotalSold
FROM 
    mens_perfume;

-- Womens_perfume
SELECT 
    SUM(available) AS TotalAvailable, 
    SUM(sold) AS TotalSold
FROM 
    womens_perfume;


-- Top brands by sales volume in mens_perfume
SELECT Top 10
    brand, 
    SUM(sold) AS TotalSold
FROM 
    mens_perfume
GROUP BY 
    brand
ORDER BY 
    TotalSold DESC;

-- Womens_perfume
SELECT Top 10
    brand, 
    SUM(sold) AS TotalSold
FROM 
    womens_perfume
GROUP BY 
    brand
ORDER BY 
    TotalSold DESC;


-- Sales over time in mens_perfume
SELECT 
    CAST(lastUpdated AS DATE) AS SalesDate, 
    SUM(sold) AS TotalSold
FROM 
    mens_perfume
GROUP BY 
    CAST(lastUpdated AS DATE)
ORDER BY 
    SalesDate;

-- Womens_perfume
SELECT 
    CAST(lastUpdated AS DATE) AS SalesDate, 
    SUM(sold) AS TotalSold
FROM 
    womens_perfume
GROUP BY 
    CAST(lastUpdated AS DATE)
ORDER BY 
    SalesDate;



-- Price vs Sales in mens_perfume
SELECT 
    price, 
    SUM(sold) AS TotalSold
FROM 
    mens_perfume
GROUP BY 
    price
ORDER BY 
    price;

-- Womens_perfume
SELECT 
    price, 
    SUM(sold) AS TotalSold
FROM 
    womens_perfume
GROUP BY 
    price
ORDER BY 
    TotalSold;


-- Calculate correlation between price and sold (basic example)

-- Calculate mean of price and sold
WITH Stats AS (
    SELECT 
        AVG(price) AS AvgPrice, 
        AVG(sold) AS AvgSold
    FROM 
        mens_perfume
)
SELECT 
    (SUM((price - AvgPrice) * (sold - AvgSold)) / 
     (SQRT(SUM(POWER(price - AvgPrice, 2))) * SQRT(SUM(POWER(sold - AvgSold, 2))))) AS Correlation
FROM 
    mens_perfume, Stats;



-- SQL is limited in heatmap visualization but you can create a cross-tab to analyze relationships.
-- Example: Cross-tab between brand and availability

SELECT 
    brand, 
    available, 
    COUNT(*) AS Frequency
FROM 
    mens_perfume
GROUP BY 
    brand, available;




