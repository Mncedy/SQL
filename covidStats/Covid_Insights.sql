Use covidStats;


Select Top 5
	*
From 
	covidStats..CovidDeaths

Select Top 5
	*
From 
	covidStats..CovidVaccinations



/* Testing Rates:**  If available in the data, 
calculate the testing rate per capita (tests conducted / population) for each country. */

/* With ratePerCapita As
(
Select 
	cv.total_tests, 
	cd.population, SUM(cv.total_tests / cd.population) as RatePerCapita
From 
	covidStats..CovidVaccinations cv
	JOIN covidStats..CovidDeaths cd ON cv.location = cd.location
	AND cv.continent = cd.continent
Where 
	cv.total_tests is not null
Group By 
	cv.total_tests AND cd.population
)
Select 
	*
From 
	ratePerCpita */


-- Total Deaths:**  Identify the total number of deaths attributed to Covid-19 globally and for each country

Select 
	location,
	total_deaths, 
	SUM(CONVERT(int, total_deaths)) Over (PARTITION BY location) as DeathsByCountry
From 
	covidStats..CovidDeaths
Where 
	total_deaths is not null
Group By 
	total_deaths, location;


With numDeaths (Location, Total_Deaths, DeathsByCountry)
as
(
select 
	cd.location, cd.total_deaths,
	SUM(CONVERT(int, cd.total_deaths)) OVER (PARTITION By cd.location Order By
	cd.location, cd.date) as DeathsByCountry
from 
	covidStats..CovidDeaths cd
	--JOIN covidStats..CovidVaccinations vac ON cd.location = vac.location
--	AND cd.date = vac.date
Where 
	cd.location is not null  and cd.total_deaths is not null
--Group By 
	--cd.location
--Order By 
	--total_deaths
)
select *
from numDeaths;


/*
This query calculates the total number of new vaccinations for each continent on a monthly basis and includes a year-over-year 
comparison to highlight trends and changes in vaccination rates over time.

Summary: This query uses a Common Table Expression (CTE) to first calculate the total monthly vaccinations per continent. 
It then performs a year-over-year comparison by using the LAG function to get the previous year's data and calculates the change in vaccination numbers. 
This advanced analysis helps identify seasonal trends and yearly growth or decline in vaccination rates.
*/

-- Monthly vaccination trend analysis with year-over-year comparison
WITH MonthlyVaccinations AS (
    SELECT 
        location, 
        DATEPART(YEAR, date) AS Year,
        DATEPART(MONTH, date) AS Month,
        SUM(CAST(new_vaccinations AS int)) AS TotalNewVaccinations
    FROM 
        PopVaccPer
    GROUP BY 
        location, DATEPART(YEAR, date), DATEPART(MONTH, date)
	),
YearlyComparison AS (
    SELECT 
        location,
        Year,
        Month,
        TotalNewVaccinations,
        LAG(TotalNewVaccinations) OVER (PARTITION BY location, Month ORDER BY Year) AS PreviousYearVaccinations,
        COALESCE(TotalNewVaccinations - LAG(TotalNewVaccinations) OVER (PARTITION BY location, Month ORDER BY Year), 0) AS YearOverYearChange
    FROM 
        MonthlyVaccinations
)
SELECT 
    location,
    Year,
    Month,
    TotalNewVaccinations,
    PreviousYearVaccinations,
    YearOverYearChange
FROM 
    YearlyComparison
ORDER BY 
    location, Year, Month;



/*
This query calculates the cumulative vaccination rates for each continent and location, 
highlighting locations that have surpassed a certain vaccination rate threshold.

Summary: This query calculates the cumulative vaccination rates for each location and adds a column that indicates 
whether the vaccination rate has surpassed a predefined threshold (e.g., 45%). 
This helps in quickly identifying which locations have achieved significant vaccination coverage.
*/

-- Cumulative vaccination rates by continent and location with threshold highlighting
WITH CumulativeVaccinationRates AS (
    SELECT 
        continent, 
        location, 
        date,
        PeopleVaccCount,
		ROUND((PeopleVaccCount * 100.0 / population), 2) AS PeopleVaccPer
    FROM 
        PopVaccPer
)
SELECT 
    continent,
    location,
    Date,
    PeopleVaccCount,
    PeopleVaccPer,
    CASE 
        WHEN PeopleVaccPer >= 45 THEN 'Above Threshold'
        ELSE 'Below Threshold'
    END AS VaccinationStatus
FROM 
    CumulativeVaccinationRates
ORDER BY 
    continent, location, Date;


/*
This query performs a simple linear regression analysis to predict future vaccination counts based on historical data, 
using a rolling window to calculate the trend.

Summary: This query performs a basic linear regression analysis to predict future vaccination counts based on historical data. 
It calculates the slope and intercept of the trend line for each location and uses these values to predict future vaccination counts. 
This predictive analysis helps in understanding the future trajectory of vaccination efforts based on past trends.
*/

-- Predictive analysis on vaccination progress using linear regression
WITH HistoricalData AS (
    SELECT 
        location, 
        Date, 
        PeopleVaccCount,
        ROW_NUMBER() OVER (PARTITION BY location ORDER BY date) AS DayNumber
    FROM 
        PopVaccPer
),
LinearRegression AS (
    SELECT 
        location,
        AVG(CAST(DayNumber * PeopleVaccCount AS FLOAT)) AS XY,
        AVG(CAST(DayNumber AS FLOAT)) AS X,
        AVG(CAST(PeopleVaccCount AS FLOAT)) AS Y,
        AVG(CAST(DayNumber * DayNumber AS FLOAT)) AS XX,
        COUNT(*) AS N
    FROM 
        HistoricalData
    GROUP BY 
        location
),
TrendLine AS (
    SELECT 
        lr.location,
        lr.N,
        -- Ensure proper handling of potential overflow with larger data types
        CASE 
            WHEN (lr.XX - lr.N * lr.X * lr.X) = 0 THEN NULL
            ELSE (lr.XY - lr.N * lr.X * lr.Y) / (lr.XX - lr.N * lr.X * lr.X)
        END AS Slope,
        -- Ensure proper handling of potential overflow with larger data types
        CASE 
            WHEN (lr.XX - lr.N * lr.X * lr.X) = 0 THEN NULL
            ELSE lr.Y - ((lr.XY - lr.N * lr.X * lr.Y) / (lr.XX - lr.N * lr.X * lr.X)) * lr.X
        END AS Intercept
    FROM 
        LinearRegression lr
)
SELECT 
    hd.location,
    hd.Date,
    hd.PeopleVaccCount,
    ROUND(tl.Slope, 0) AS Slope,
    ROUND(tl.Intercept, 0) AS Intercept,
    CASE 
        WHEN tl.Slope IS NOT NULL AND tl.Intercept IS NOT NULL THEN 
            ROUND((tl.Slope * hd.DayNumber + tl.Intercept), 0)
        ELSE 
            NULL
    END AS PredictedVaccCount
FROM 
    HistoricalData hd
JOIN 
    TrendLine tl ON hd.location = tl.location
ORDER BY 
    hd.location, hd.Date;


