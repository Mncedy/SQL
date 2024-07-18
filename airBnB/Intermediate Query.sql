Use AirBnB;

-- Calculate the total number of listings.

Select COUNT(id) as TotalListings
From AirBnB..Listings

-- Find the average price of listings.

Select ROUND(AVG(price), 2) as AvgPrice
From AirBnB..Listings

-- Determine the median price of listings.

SELECT TOP 1 PERCENTILE_CONT(0.5) 
	WITHIN GROUP (ORDER BY Price) OVER () AS Median
FROM AirBnB..Listings;

-- AVG Price by Zipcode

Select Top 10 zipcode, ROUND(AVG(price), 2) AS AveragePrice
From AirBnB..Listings
Where zipcode is not null
Group By zipcode
Order By AveragePrice DESC;

-- Host with most Ratings

Select Top 5 HOST_ID, COUNT(host_is_superhost) AS SuperHost
From AirBnB..Listings
Where host_is_superhost = 't'
Group By host_id, host_is_superhost
Order By SuperHost desc;

-- Calculate the maximum and minimum prices of listings.

Select MAX(Price) as MAXPrice
From AirBnB..Listings

Select MIN(Price) as MINPrice
From AirBnB..Listings

-- Find the number of reviews per listing.

SELECT listing_id, COUNT(*) AS Num_Reviews
FROM AirBnB..Reviews
GROUP BY listing_id
Order BY listing_id asc;

-- Standardize Date Format

Alter Table Calendar
Add ListingDate date;

--Update Calendar
--SET ListingDate = CONVERT(date, Date);

--Select ListingDate, CONVERT(date, date)
--From AirBnB..Calendar;

-- Find the number of listings available per day in the calendar.

Select ListingDate, COUNT(DISTINCT listing_id) AS ListingsAvailable
From AirBnB..Calendar
Where available = 't'
Group By ListingDate
Order By ListingDate asc;

--Select COUNT(available)
--From AirBnB..Calendar
--Where available = 't';

--Select COUNT(available)
--From AirBnB..Calendar
--Where available = 'f';

-- Calculate the average price of listings per month.

Select 
    MONTH(ListingDate) AS Month,
    ROUND(AVG(price), 2) AS Avg_Price_PM
From 
    AirBnB..Calendar
Where
	Year(ListingDate) = 2016
Group By 
    MONTH(ListingDate)
Order By 
    MONTH(ListingDate);


-- Calculate the average price of listings per year.

Select 
    YEAR(ListingDate) AS Year,
    ROUND(AVG(price), 2) AS Avg_Price_PY
From 
    AirBnB..Calendar
Group By 
    YEAR(ListingDate)
Order By 
    YEAR(ListingDate);

        ------
Select DISTINCT bedrooms
From AirBnB..Listings


-- Calculate the range of prices for listings.

Select MAX(price) - MIN(price) AS Price_Range
From AirBnB..Listings;

-- Number of bedrooms per listing

Select DISTINCT bedrooms  AS Bedrooms, id AS Listings
From AirBnB..Listings
Where bedrooms is not null AND bedrooms <> 0 
Group By bedrooms, id
Order By bedrooms desc;

/* --------------------------------------------------------------------*/
WITH BedroomNum AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY bedrooms ORDER BY id) AS Listing
    FROM AirBnB..Listings
)
SELECT DISTINCT bedrooms, id
FROM BedroomNum
Where bedrooms is not null AND bedrooms <> 0
Order By bedrooms desc;



Select DISTINCT(bedrooms)
From AirBnB..Listings
Where bedrooms is not null AND bedrooms <> 0
Order By bedrooms;


-- Find the standard deviation of ratings for listings.

--Select STDDEV(price) AS price_std_dev
--From AirBnB..Listings;

-- Calculate the variance of ratings for listings.

--Select VARIANCE(price) AS price_variance
--FROM AirBnB..Listings;


-- Check if a column exists in a table

SELECT COUNT(*)
FROM information_schema.columns
WHERE table_schema = 'AirBnB'
AND table_name = 'Listings'
AND column_name = 'host_id';

-- Count and display column names

SELECT name AS cName
FROM sys.columns
WHERE object_id = OBJECT_ID('Listings');


