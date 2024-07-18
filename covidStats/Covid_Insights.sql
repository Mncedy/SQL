Use covidStats;


Select *
From covidStats..CovidDeaths

Select *
From covidStats..CovidVaccinations

/* Testing Rates:**  If available in the data, 
calculate the testing rate per capita (tests conducted / population) for each country. */

--With ratePerCapita As
--(
--Select cv.total_tests, cd.population, SUM(cv.total_tests / cd.population) as RatePerCapita
--From covidStats..CovidVaccinations cv
--	JOIN covidStats..CovidDeaths cd
--	ON cv.location = cd.location
--	AND cv.continent = cd.continent
--Where cv.total_tests is not null
--Group By cv.total_tests AND cd.population
--)
--Select *
--From ratePerCpita


-- Total Deaths:**  Identify the total number of deaths attributed to Covid-19 globally and for each country

Select total_deaths, SUM(CONVERT(int, total_deaths)) Over (PARTITION BY total_deaths) as DeathsByCountry
From covidStats..CovidDeaths
Where total_deaths is not null
Group By total_deaths;


With numDeaths (Location, Total_Deaths, DeathsByCountry)
as
(
select cd.location, cd.total_deaths,
	SUM(CONVERT(int, cd.total_deaths)) OVER (PARTITION By cd.location Order By
	cd.location, cd.date) as DeathsByCountry
from covidStats..CovidDeaths cd
	--JOIN covidStats..CovidVaccinations vac
	--	ON cd.location = vac.location
	--	AND cd.date = vac.date
Where cd.location is not null  and cd.total_deaths is not null
--Group By cd.location
--Order By total_deaths
)
select *
from numDeaths;
