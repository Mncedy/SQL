
Use covidStats;

Select Top 5 
	* 
From 
	CovidVaccinations;

Select 
	* 
From 
	covidStats..CovidVaccinations
Where 
	continent is not null
Order BY 
	3,4;

-- Joining CovidDeaths Table with CovidVaccinations Table

-- CTE to combine COVID-19 deaths and vaccinations data
WITH CovidCombined AS (
    SELECT 
        dea.location, 
        CAST(dea.date AS DATE) AS Date, 
        dea.total_cases, 
        dea.new_cases,
        dea.total_deaths, 
        dea.population,
        vac.new_vaccinations, 
        vac.total_vaccinations
    FROM 
        covidStats..CovidDeaths dea
    JOIN 
        covidStats..CovidVaccinations vac 
    ON 
        dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL AND
		vac.new_vaccinations IS NOT NULL
)
SELECT 
    location, 
    Date, 
    total_cases, 
    new_cases,
    total_deaths, 
    population,
    new_vaccinations, 
    total_vaccinations
FROM 
    CovidCombined
ORDER BY 
    location, Date, total_cases;


-- Total Population vs Vaccinations

Select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From 
	covidStats..CovidDeaths dea
	JOIN covidStats..CovidVaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
Where 
	dea.continent is not null
Order BY 
	2,3

Select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY
	dea.location, dea.date) as PeopleVaccCount
From 
	covidStats..CovidDeaths dea
	JOIN covidStats..CovidVaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
Where 
	dea.continent is not null
Order BY 
	2,3


-- Using CTE for Population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccCount)
AS
(
Select
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY
	dea.location, dea.date) as PeopleVaccCount
From 
	covidStats..CovidDeaths dea
	JOIN covidStats..CovidVaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
Where 
	dea.continent is not null -- and dea.location = 'Albania'
--Order BY 
	--2,3
)
Select 
	*, 
	(PeopleVaccCount/Population)*100 as PeopleVaccPer
From 
	PopvsVac


-- Using Temp Table

Drop table if exists #PeopleVaccPer;
Create Table #PeopleVaccPer
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccCount numeric
)
Insert into #PeopleVaccPer
Select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY
	dea.location, dea.date) as PeopleVaccCount
From 
	covidStats..CovidDeaths dea
	JOIN covidStats..CovidVaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
Where 
	dea.continent is not null -- and dea.location = 'Albania'
Order BY 
	2,3
Select 
	*, 
	(PeopleVaccCount/Population)*100 as PeopleVaccPer
From 
	#PeopleVaccPer


-- Creating a View for later data visualizaton

create view PopVaccPer as
Select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY
	dea.location, dea.date) as PeopleVaccCount
From 
	covidStats..CovidDeaths dea
	JOIN covidStats..CovidVaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
Where 
	dea.continent is not null AND
	vac.new_vaccinations is not null

Select 
	*
From 
	PopVaccPer
--Where 
--	new_vaccinations is not null


