Use AirBnB;

-- Identify the top 10 hosts with the most listings.

Select Top 10 host_id, COUNT(*) AS Max_Listings
From AirBnB..Listings
Group By host_id
Order By Max_Listings DESC;

--Select HOST_ID
--From AirBnB..Listings
--Where HOST_ID = 8534462


-- Find the top 10 most reviewed listings.

Select Top 10 listing_id, COUNT(*) Max_Reviews
From AirBnB..Reviews
Group By listing_id
Order By Max_Reviews DESC;


-- Determine the distribution of listing prices using quartiles.

Select Top 1
    PERCENTILE_CONT(0.25) WITHIN GROUP (Order By price) OVER () AS Q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (Order By price) OVER () AS Q2,
    PERCENTILE_CONT(0.75) WITHIN GROUP (Order By price) OVER () AS Q3
From 
    AirBnB..Calendar



-- Identify seasonal trends in listing prices.

-- Calculate the percentage change in listing prices compared to the previous year.

WITH PriceComparison AS (
    SELECT
        listing_id,
        YEAR(ListingDate) AS Year,
        price,
        LAG(price) OVER (Order By listing_id) AS PrevYearPrice
    FROM
        AirBnB..Calendar
	Where Price is not null
	Group By listing_id, Year(ListingDate), Price
)
SELECT
    listing_id,
    Year,
    price,
    PrevYearPrice,
    CASE 
        WHEN PrevYearPrice IS NULL THEN NULL
        ELSE ((price - PrevYearPrice) / PrevYearPrice) * 100
    END AS PercentageChange
FROM
    PriceComparison;


