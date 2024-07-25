/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Use covidStats;

Select 
	*
From 
	covidStats..CovidDeaths
Where 
	continent IS NOT NULL 
Order BY 
	3,4


-- Select Data that we are going to be starting with

Select 
	Location, date, 
	total_cases, new_cases, 
	total_deaths, 
	population
From 
	covidStats..CovidDeaths
Where 
	continent IS NOT NULL 
Order BY 
	1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select 
	Location, 
	date, 
	total_cases,
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
From 
	covidStats..CovidDeaths
Where 
	location like '%states%'
	AND continent IS NOT NULL 
Order BY 
	1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select 
	Location, 
	date, 
	Population, total_cases,  
	(total_cases/population)*100 as PercentPopulationInfected
From 
	covidStats..CovidDeaths
--Where 
	--location like '%states%'
Order BY 
	1,2


-- Countries with Highest Infection Rate compared to Population

Select 
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount,  
	Max((total_cases/population))*100 as PercentPopulationInfected
From 
	covidStats..CovidDeaths
--Where 
	--location like '%states%'
Group BY 
	Location, Population
Order BY 
	PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

Select 
	Location, 
	MAX(CAST(Total_deaths as int)) as TotalDeathCount
From 
	covidStats..CovidDeaths
--Where 
	--location like '%states%'
Where 
	continent IS NOT NULL 
Group BY 
	Location
Order BY 
	TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select 
	continent, 
	MAX(CAST(Total_deaths as int)) as TotalDeathCount
From 
	covidStats..CovidDeaths
Where 
	--location like '%south%'
	continent IS NOT NULL 
Group BY 
	continent
Order BY 
	TotalDeathCount DESC



-- GLOBAL NUMBERS

Select 
	SUM(new_cases) as total_cases, 
	SUM(CAST(new_deaths as int)) as total_deaths, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From 
	covidStats..CovidDeaths
--Where 
	--location like '%states%'
Where 
	continent IS NOT NULL 
--Group BY 
	--date
Order BY 
	1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location Order BY dea.location, dea.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From 
	covidStats..CovidDeaths dea
	Join covidStats..CovidVaccinations vac On dea.location = vac.location
	AND dea.date = vac.date
Where 
	dea.continent IS NOT NULL 
Order BY 
	2,3


-- Using CTE to perform Calculation on Partition BY in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location Order BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From 
	covidStats..CovidDeaths dea
	Join covidStats..CovidVaccinations vac On dea.location = vac.location
	AND dea.date = vac.date
Where 
	dea.continent IS NOT NULL 
--Order BY 
	--2,3
)
Select 
	*, 
	(RollingPeopleVaccinated/Population)*100
From 
	PopvsVac



-- Using Temp Table to perform Calculation on Partition BY in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location Order BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From 
	covidStats..CovidDeaths dea
	Join covidStats..CovidVaccinations vac On dea.location = vac.location
	AND dea.date = vac.date
--Where 
	--dea.continent IS NOT NULL 
--Order BY 
	--2,3

Select 
	*, 
	(RollingPeopleVaccinated/Population)*100
From 
	#PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location Order BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From 
	covidStats..CovidDeaths dea
	Join covidStats..CovidVaccinations vac On dea.location = vac.location
	AND dea.date = vac.date
Where 
	dea.continent IS NOT NULL 


