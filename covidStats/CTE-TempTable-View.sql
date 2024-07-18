select top 5 * from CovidVaccinations;

select * from dbo.CovidVaccinations
where continent is not null
order by 3,4;

-- Joining CovidDeaths Table with CovidVaccinations Table

select *
from covidStats..CovidDeaths dea
	JOIN covidStats..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from covidStats..CovidDeaths dea
	JOIN covidStats..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION By dea.location Order By
	dea.location, dea.date) as PeopleVaccCount
from covidStats..CovidDeaths dea
	JOIN covidStats..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE for Population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION By dea.location Order By
	dea.location, dea.date) as PeopleVaccCount
from covidStats..CovidDeaths dea
	JOIN covidStats..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
where dea.continent is not null -- and dea.location = 'Albania'
--order by 2,3
)
select *, (PeopleVaccCount/Population)*100 as PeopleVaccPer
from PopvsVac


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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION By dea.location Order By
	dea.location, dea.date) as PeopleVaccCount
from covidStats..CovidDeaths dea
	JOIN covidStats..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
where dea.continent is not null -- and dea.location = 'Albania'
order by 2,3
select *, (PeopleVaccCount/Population)*100 as PeopleVaccPer
from #PeopleVaccPer


-- Creating a View for later data visualizaton

create view PopVaccPer as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION By dea.location Order By
	dea.location, dea.date) as PeopleVaccCount
from covidStats..CovidDeaths dea
	JOIN covidStats..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
where dea.continent is not null

select *
from PopVaccPer
