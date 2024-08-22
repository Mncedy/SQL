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

UPDATE Womens_perfume
SET price = CAST(REPLACE(priceWithCurrency, '$', '') AS DECIMAL(10, 2));

-- Replace NULL values in availableText and itemLocation with default values (e.g., 'Not Available')
UPDATE mens_perfume
SET available = 0
WHERE available IS NULL;

UPDATE Womens_perfume
SET itemLocation = 'Unknown'
WHERE itemLocation IS NULL;

-- Replace NULL values in availableText and itemLocation with default values (e.g., 'Not Available')
UPDATE mens_perfume
SET availableText = 'Not Available'
WHERE availableText IS NULL;

UPDATE Womens_perfume
SET itemLocation = 'Unknown'
WHERE itemLocation IS NULL;


-- SQL has limited text processing capabilities compared to Python
-- However, you can use basic functions like SUBSTRING or CHARINDEX
-- Example: Extracting brand information if it appears as the first word in the title

ALTER TABLE mens_perfume ADD BrandExtracted NVARCHAR(255);

UPDATE mens_perfume
SET BrandExtracted = SUBSTRING(title, 1, CHARINDEX(' ', title) - 1)
WHERE CHARINDEX(' ', title) > 0;

-- Similar logic applies to Womens_perfume


-- Convert lastUpdated column to datetime
ALTER TABLE mens_perfume ALTER COLUMN lastUpdated DATETIME;

ALTER TABLE Womens_perfume ALTER COLUMN lastUpdated DATETIME;


-- Assuming you have a quantity column, calculate PricePerUnit
ALTER TABLE mens_perfume ADD PricePerUnit DECIMAL(10, 2);

UPDATE mens_perfume
SET PricePerUnit = price / quantity
WHERE quantity IS NOT NULL;

-- Calculate DaysOnMarket assuming you have a 'listingDate' column
ALTER TABLE mens_perfume ADD DaysOnMarket INT;

UPDATE mens_perfume
SET DaysOnMarket = DATEDIFF(day, listingDate, lastUpdated);

-- Similar logic applies to Womens_perfume

