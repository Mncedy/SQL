use covidStats;

select top 5 * from CovidDeaths;
select top 5 * from CovidVaccinations;

select * from dbo.CovidDeaths
order by 3,4;

select * from dbo.CovidVaccinations
order by 3,4;

select location, date, total_cases, new_cases,total_deaths, population
from covidStats..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPer
from covidStats..CovidDeaths
where location like '%south%'
order by 1,2

-- Total Cases vs Population

select location, Population, total_cases, (total_cases/population)*100 as DeathPerPop
from covidStats..CovidDeaths
where location like '%south%'
order by 1,2

-- Highest country infection rate to its population

select location, Population, MAX(total_cases) as HighestInfecCount,
	MAX(total_cases/population)*100 as PopulationPerInfected
from covidStats..CovidDeaths
--where location like '%south%'
group by Location, Population
order by PopulationPerInfected desc


-- Highest death country per country by populaton

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from covidStats..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount asc

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from covidStats..CovidDeaths
where continent is null
group by Location
order by TotalDeathCount desc


-- Using Continent Demographics

-- Continent Highest Death Count per Population

select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from covidStats..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Total Global Numbers

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath,
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPer
from covidStats..CovidDeaths
where continent is not null
--group by date
order by 1,2

Select COUNT((cast(total_deaths as int))) as TotalDeath
From covidStats..CovidDeaths
