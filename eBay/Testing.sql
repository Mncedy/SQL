BEGIN TRANSACTION;

-- Update rows with '$' and '/'
UPDATE mens_perfume
SET price = TRY_CAST(
                REPLACE(
                    SUBSTRING(priceWithCurrency, 
                              CHARINDEX('$', priceWithCurrency) + 1, 
                              CHARINDEX('/', priceWithCurrency) - CHARINDEX('$', priceWithCurrency) - 1
                    ), 
                    ',', ''
                ) AS DECIMAL(10,2)
            )
WHERE 
    CHARINDEX('$', priceWithCurrency) > 0 
    AND CHARINDEX('/', priceWithCurrency) > CHARINDEX('$', priceWithCurrency);

-- Update rows with '$' but no '/'
UPDATE mens_perfume
SET price = TRY_CAST(
                REPLACE(
                    SUBSTRING(priceWithCurrency, 
                              CHARINDEX('$', priceWithCurrency) + 1, 
                              LEN(priceWithCurrency) - CHARINDEX('$', priceWithCurrency)
                    ), 
                    ',', ''
                ) AS DECIMAL(10,2)
            )
WHERE 
    CHARINDEX('$', priceWithCurrency) > 0 
    AND CHARINDEX('/', priceWithCurrency) = 0;

-- Optionally, set price to NULL for rows without '$'
UPDATE mens_perfume
SET price = NULL
WHERE 
    CHARINDEX('$', priceWithCurrency) = 0;

-- Check for any remaining conversion issues
IF EXISTS (
    SELECT 1
    FROM mens_perfume
    WHERE priceWithCurrency IS NOT NULL 
      AND TRY_CAST(
            REPLACE(
                SUBSTRING(priceWithCurrency, CHARINDEX('$', priceWithCurrency) + 1, 
                          CASE 
                              WHEN CHARINDEX('/', priceWithCurrency) > 0 
                              THEN CHARINDEX('/', priceWithCurrency) - CHARINDEX('$', priceWithCurrency) - 1
                              ELSE LEN(priceWithCurrency)
                          END
                ), 
                ',', ''
            ) AS DECIMAL(10,2)
        ) IS NULL
)
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Update failed due to conversion errors.';
END

ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Price column updated successfully.';
END

UPDATE mens_perfume
SET price = CAST(
    REPLACE(
        SUBSTRING(priceWithCurrency, CHARINDEX('$', priceWithCurrency) + 1, 
                  CHARINDEX('/', priceWithCurrency) - CHARINDEX('$', priceWithCurrency) - 1), 
        ',', '') 
    AS DECIMAL(10, 2))
WHERE priceWithCurrency LIKE '%$%/%';


SELECT priceWithCurrency
FROM mens_perfume

-- Update rows with 'US $' and '/ea' format
UPDATE mens_perfume
SET price = CAST(
    REPLACE(
        SUBSTRING(priceWithCurrency, CHARINDEX('$', priceWithCurrency) + 1, 
                  CHARINDEX('/', priceWithCurrency) - CHARINDEX('$', priceWithCurrency) - 1), 
        ',', '') 
    AS DECIMAL(10, 2))
WHERE priceWithCurrency LIKE '%$%/%';

-- Update rows with only '$' and no '/ea' suffix
UPDATE mens_perfume
SET price = CAST(
    REPLACE(
        SUBSTRING(priceWithCurrency, CHARINDEX('$', priceWithCurrency) + 1, LEN(priceWithCurrency)), 
        ',', '') 
    AS DECIMAL(10, 2))
WHERE priceWithCurrency LIKE '%$%' AND priceWithCurrency NOT LIKE '%/%';

-- Handle cases where priceWithCurrency might be null or empty by setting price to NULL
UPDATE mens_perfume
SET price = NULL
WHERE priceWithCurrency IS NULL OR priceWithCurrency = '';

UPDATE mens_perfume
SET price = priceWithCurrency
WHERE price IS NULL;

SELECT price, priceWithCurrency
FROM mens_perfume

-- Display column data type
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'mens_perfume';

UPDATE mens_perfume
SET lastUpdated = CONVERT(DATETIME, lastUpdated, 120);

SELECT lastUpdated
FROM mens_perfume
WHERE TRY_CAST(lastUpdated AS DATETIME) IS NULL;

-- Set invalid dates to NULL or a default value, if desired
UPDATE mens_perfume
SET lastUpdated = NULL
WHERE TRY_CAST(lastUpdated AS DATETIME) IS NULL;

ALTER TABLE mens_perfume
ALTER COLUMN lastUpdated DATETIME;



SET ANSI_WARNINGS OFF;
-- fix = Warning: Null value is eliminated by an aggregate or other SET operation.
