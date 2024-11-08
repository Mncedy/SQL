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
