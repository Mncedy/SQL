
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


/*
This query retrieves data to compare the total population with new vaccinations for each location and date, 
providing insights into vaccination progress across different locations.
*/

-- Store CTE results in a temp table
WITH PopulationVaccination AS (
    SELECT 
        dea.continent, 
        dea.location, 
        CAST(dea.date AS DATE) AS Date, 
        dea.population, 
        vac.new_vaccinations
    FROM 
        covidStats..CovidDeaths dea
    JOIN 
        covidStats..CovidVaccinations vac 
    ON 
        dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT *
INTO #PopulationVaccination
FROM PopulationVaccination;

-- Reuse temp table in another query
SELECT 
    continent, 
    location, 
    Date, 
    population, 
    new_vaccinations
FROM 
    #PopulationVaccination
Where
	new_vaccinations IS NOT NULL
ORDER BY 
    location, Date;


/*
This query retrieves data to compare the total population with new vaccinations for each location and date, 
and also calculates the running total of vaccinations for each location, 
providing insights into vaccination progress over time.
*/

-- CTE to combine population and vaccination data and calculate running total of vaccinations
WITH PopulationVaccination AS (
    SELECT 
        dea.continent, 
        dea.location, 
        CAST(dea.date AS DATE) AS Date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS PeopleVaccCount
    FROM 
        covidStats..CovidDeaths dea
    JOIN 
        covidStats..CovidVaccinations vac 
    ON 
        dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    continent, 
    location, 
    Date, 
    population, 
    new_vaccinations, 
    PeopleVaccCount
FROM 
    PopulationVaccination
Where
	new_vaccinations IS NOT NULL
ORDER BY 
    location, Date;



/*
This query retrieves data to compare the total population with new vaccinations for each location and date, 
calculates the running total of vaccinations for each location, and then computes the percentage of people vaccinated relative to the population.
*/

-- CTE to combine population and vaccination data and calculate running total of vaccinations
WITH PopvsVac AS (
    SELECT
        dea.continent, 
        dea.location, 
        CAST(dea.date AS DATE) AS Date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS PeopleVaccCount
    FROM 
        covidStats..CovidDeaths dea
    JOIN 
        covidStats..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    continent, 
    location, 
    Date, 
    population, 
    new_vaccinations, 
    PeopleVaccCount,
    ROUND((PeopleVaccCount * 100.0 / population), 2) AS PeopleVaccPer
FROM 
    PopvsVac
WHERE
	new_vaccinations IS NOT NULL
ORDER BY 
    location, Date;



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
	ROUND(CAST((PeopleVaccCount * 100.0 / Population) AS DECIMAL(10, 2)), 2) AS PeopleVaccPer
From 
	#PeopleVaccPer
WHERE
	new_vaccinations IS NOT NULL


-- Creating a View for later data visualizaton

-- Create a view that combines population and vaccination data
CREATE VIEW PopVaccPer AS
SELECT 
    dea.continent, 
    dea.location, 
    CAST(dea.date AS DATE) AS Date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS PeopleVaccCount
FROM 
    covidStats..CovidDeaths dea
JOIN 
    covidStats..CovidVaccinations vac 
ON 
    dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL AND
    vac.new_vaccinations IS NOT NULL;

-- Select data from the view and calculate the vaccination percentage
SELECT 
    continent, 
    location, 
    Date, 
    population, 
    new_vaccinations, 
    PeopleVaccCount,
    ROUND(CAST((PeopleVaccCount * 100.0 / Population) AS DECIMAL(10, 2)), 2) AS PeopleVaccPer
FROM 
    PopVaccPer
ORDER BY 
    location, Date;




