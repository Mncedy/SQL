Use covidStats;

Select Top 5 
	* 
From 
	CovidDeaths;
Select Top 5 
	* 
From	
	CovidVaccinations;

Select 
	* 
	From dbo.CovidDeaths
Order BY 
	3,4;

Select 
	* 
From 
	dbo.CovidVaccinations
Order BY 
	3,4;

/*
This query retrieves the total cases, new cases, total deaths, and population for each location on each date, ordered by location and date. 
It provides a detailed timeline of COVID-19 statistics for different locations.
*/

WITH CovidStats AS (
    SELECT 
        location, 
        CAST(date AS DATE) AS Date, 
        total_cases, 
        new_cases,
        total_deaths, 
        population
    FROM 
        covidStats..CovidDeaths
    WHERE 
        continent IS NOT NULL
)
SELECT 
    location, 
    Date, 
    total_cases, 
    new_cases,
    total_deaths, 
    population
FROM 
    CovidStats
ORDER BY 
    location, Date;


/* 1. Total Cases vs Total Deaths
Use Case Summary: This query calculates the likelihood of dying if you contract COVID-19 in countries where the location contains 'south'. 
This is crucial for understanding the severity of the disease in specific regions.
*/

WITH DeathPercentageCTE AS (
    SELECT 
        Location, 
        date, 
        total_cases,
        total_deaths,
		ROUND((CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)) * 100, 2) AS DeathPercentage
    FROM 
        covidStats..CovidDeaths
    WHERE 
        continent IS NOT NULL
)
SELECT 
    Location, 
    date, 
	total_cases,
    DeathPercentage
FROM 
    DeathPercentageCTE
WHERE 
    Location LIKE '%south%'
ORDER BY 
    Location, date;



/* 2. Total Cases vs Population
This query calculates the percentage of the population infected with COVID-19, 
providing insight into the spread of the disease in different countries.
*/

CREATE VIEW PercentagePopulationInfected AS
SELECT 
    Location, 
    date, 
    Population, 
    total_cases, 
	ROUND((CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100, 2) AS PercPopInfec
FROM 
    covidStats..CovidDeaths
WHERE 
    continent IS NOT NULL;

-- Using the view
SELECT 
    Location, 
    date,
	total_cases,
	PercPopInfec
FROM 
    PercentagePopulationInfected
Where
	location LIKE '%south%'
ORDER BY 
    Location, date;



/*
This query identifies countries with the highest infection count and the highest percentage of the population infected, 
which is useful for targeting public health interventions.
*/

CREATE VIEW HighestInfectionRates AS
SELECT 
    Location, 
    Population, 
    MAX(total_cases) AS HighestInfectionCount,  
    MAX((total_cases/population))*100 AS PercentPopulationInfected,
	ROUND(MAX((CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100), 2) AS PercPopInfec
FROM  
    covidStats..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    Location, Population;

-- Using the view
SELECT 
    Location,
	population,
    HighestInfectionCount,
	PercPopInfec
FROM 
    HighestInfectionRates
ORDER BY 
    PercentPopulationInfected DESC;

-- Store view results in a temp table
SELECT *
INTO #HighestInfectionRates
FROM HighestInfectionRates;

-- Reuse temp table in another query
SELECT 
    Location, 
    HighestInfectionCount, 
    ROUND(CAST(PercentPopulationInfected AS float), 2) AS PercPopInfec
FROM 
    #HighestInfectionRates
ORDER BY 
    PercentPopulationInfected DESC;


/*
This query identifies countries with the highest total death count, 
providing critical information for understanding the impact of the pandemic.
*/

WITH HighestDeathCountCTE AS (
    SELECT 
        Location, 
        MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
    FROM 
        covidStats..CovidDeaths
    WHERE 
        continent IS NOT NULL
    GROUP BY 
        Location
)
SELECT 
    Location, 
    TotalDeathCount
FROM 
    HighestDeathCountCTE
ORDER BY 
    TotalDeathCount DESC;

-- Only includes data for locations that do not have a specified continent (i.e., the continent is missing or unspecified).
Select 
	Location, 
	MAX(CAST(total_deaths as int)) as TotalDeathCount
From 
	covidStats..CovidDeaths
Where 
	continent is null
Group BY 
	Location
Order BY 
	TotalDeathCount DESC


-- Using Continent Demographics

/*
This query shows the continents with the highest death count per population, useful for continent-wide health policy planning.
*/

CREATE VIEW ContinentDeathCounts AS
SELECT 
    continent, 
    MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM 
    covidStats..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent;

-- Using the view
SELECT 
    continent, 
    TotalDeathCount
FROM 
    ContinentDeathCounts
ORDER BY 
    TotalDeathCount DESC;



/*
This query provides daily statistics on new COVID-19 cases, new deaths, and the death percentage, helping track the pandemic's daily impact.
*/

WITH DailyStatsCTE AS (
    SELECT 
        CAST(date AS DATE) AS Date,
        SUM(new_cases) AS TotalCases, 
        SUM(CAST(new_deaths AS int)) AS TotalDeath,
        CAST(ROUND((SUM(CAST(new_deaths AS int)) * 100.0) / SUM(new_cases), 2) AS decimal(10, 2)) AS DeathPer
    FROM 
        covidStats..CovidDeaths
    WHERE 
        continent IS NOT NULL AND
        new_cases IS NOT NULL 
    GROUP BY 
        date
)
SELECT 
    date,
    TotalCases, 
    TotalDeath,
    DeathPer
FROM 
    DailyStatsCTE
ORDER BY 
    date;


/*
Summary of Skills Demonstrated:
Joins, Common Table Expressions (CTEs), Temporary Tables.
Window Functions, Aggregate Functions.
Creating Views, Converting Data Types.


Using CTEs, views, and temp tables, enhance modularity, readability, maintainability, reusability, and performance. 
Temp tables allow the results of complex queries to be stored temporarily for reuse in multiple subsequent queries, reducing duplication and ensuring consistency. 
This approach is beneficial for complex data exploration and analysis tasks, making the process more efficient and manageable.
*/
