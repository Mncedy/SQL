Use covidStats;

Select Top 5 
	*
From 
	covidStats..CovidDeaths

Select Top 5 
	*
From 
	covidStats..CovidVaccinations

-- Vaccination Rates:**  If data is available, explore the correlation between vaccination rates and confirmed cases/deaths.

Select 
	total_cases, total_deaths
From 
	covidStats..CovidDeaths
Order BY
	total_cases, total_deaths ASC

Select 
	new_vaccinations, 
	total_vaccinations, 
	people_vaccinated, 
	people_fully_vaccinated, 
	positive_rate
From 
	covidStats..CovidVaccinations
Where 
	total_vaccinations <> 0 AND 
	new_vaccinations is not null
Order By 
	total_vaccinations asc;

Select DISTINCT
	(cv.location), 
	SUM(CONVERT(decimal, cv.total_vaccinations)) OVER (PARTITION By cv.total_vaccinations) as TotalVacc, 
	SUM(CONVERT(decimal, cd.total_cases)) OVER (PARTITION By cd.total_cases) as TotalCases
From
	covidStats..CovidVaccinations cv
	JOIN covidStats..CovidDeaths cd ON cv.location = cd.location
Where 
	cv.total_vaccinations <> 0 AND cd.total_cases is not null
-- Group By 
	--total_cases
-- Order By 
	--total_vaccinations asc;

Select DISTINCT
	(location)
From 
	covidStats..CovidDeaths


-- Daily vs. Cumulative Data:**  Explore the difference between weekly and cumulative confirmed cases data.

Select 
	weekly_hosp_admissions
From 
	covidStats..CovidDeaths

-- Countries with Decreasing Cases**: Identify countries where the number of new COVID-19 cases has been decreasing consistently.

-- COVID-19 Testing Rate by Country**: Determine the COVID-19 testing rate (tests conducted/population) for each country.

Select 
	cv.total_tests, cd.location
From 
	covidStats..CovidVaccinations cv 
	JOIN covidStats..CovidDeaths cd ON cv.location = cd.location

-- Percentage Change in Cases from Previous Week**: Calculate the percentage change in confirmed cases from the previous week for each country.

Select	
	total_cases
From 
	covidStats..CovidDeaths


/* Case Fatality Rate (CFR):**  Calculate the CFR (deaths / confirmed cases) for different countries and over time. 
Analyze variations in CFR across regions and demographics. */

Select 
	total_deaths, total_cases
From 
	covidStats..CovidDeaths 
	

/* Excess Mortality:**  If available, explore data on excess mortality (deaths above expected levels) 
   to understand the true impact of the pandemic beyond confirmed cases. 
   Visualize this data alongside confirmed deaths to identify potential underreporting or indirect effects of the pandemic on mortality rates. */

/* Vaccine Effectiveness:**  Analyze the effectiveness of different vaccines based on real-world data (if available). 
	This might involve comparing vaccination rates and confirmed cases/deaths across vaccinated and unvaccinated populations. 
	Visualize the data to assess the impact of vaccination campaigns on reducing disease burden. */

/* Variant Spread:**  Analyze the spread of different Covid-19 variants across countries and over time. 
	Consider using bar charts with stacked segments to represent different variants. Track the emergence and dominance of new variants, 
	informing public health strategies and potential booster shot requirements. */

/* Predictive Modeling:** Explore statistical models (using SQL or external tools) to predict future trends in cases or deaths based on historical data. 
	Visualize the predicted trends alongside actual data points (Tableau/Power BI) to assess model accuracy and inform preparedness for potential future outbreaks. */

/* Correlations and Causality:**  Investigate potential correlations between various factors and Covid-19 metrics 
    (e.g., population density, healthcare access, socioeconomic indicators). 
	Visualize these correlations using scatter plots or heatmaps. Remember, correlation doesn't imply causation, 
	so further analysis might be required to establish causal relationships. */

--COVID-19 Vaccination Progress**: Analyze the progress of COVID-19 vaccination globally, including total doses administered, percentage of population vaccinated, etc.

Select 
	people_vaccinated
From 
	covidStats..CovidVaccinations

/* Correlation Analysis between Cases and Stringency Index**: Explore the correlation between COVID-19 cases and 
   government stringency measures using the Oxford Stringency Index. */

Select 
	stringency_index
From 
	covidStats..CovidVaccinations

-- Cluster Analysis of Countries Based on COVID-19 Metrics**: Perform cluster analysis to group countries based on COVID-19 metrics such as cases, deaths, fatality rate, etc.

Select 
	total_deaths
From 
	covidStats..CovidDeaths

-- Prediction of Future Cases using Time Series Analysis**: Use time series forecasting techniques to predict future COVID-19 case counts.

Select DISTINCT
	(location)
From 
	covidStats..CovidDeaths

-- Impact of Vaccination on Cases and Deaths**: Analyze the impact of COVID-19 vaccination on reducing cases and deaths over time.

