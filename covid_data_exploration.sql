/*
Covid 19 Data Exploration

Skills used: joins, CTE's, temp tables, window functions, aggregate functions, views, data type conversion

*/

-- 1. INVESTIGATE CovidDeaths DATASET
-- Query CovidDeaths

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

-- Query fields of interest

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_cases, 
	total_deaths, 
	population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Query total cases vs total deaths (Japan only)
-- Shows likelihood of dying if you contract covid given you reported the case
-- *Cannot cover total infections because not all infections are reported

SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	ROUND((total_deaths/total_cases)*100,2) as MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE location = 'Japan'
ORDER BY 1,2

-- Query total cases vs population
-- Shows what percentage of population got Covid
-- *Does not account for a case of multiple infections per person or unreported cases

SELECT 
	location, 
	date, 
	total_cases, 
	population, 
	ROUND((total_cases/population)*100,3) as PopRate
FROM PortfolioProject..CovidDeaths
WHERE location = 'Japan'
ORDER BY 1,2

-- Query countries with highest infection rate compared to population

SELECT 
	location, 
	MAX(total_cases) as TotalCaseCount, 
	population, 
	ROUND((MAX(total_cases)/population)*100,2) as TotalCaseRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY TotalCaseRate desc

-- Query countries with highest death count

SELECT 
	location, 
	MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null -- this guarantees that only countries show up in the location field
GROUP BY location
ORDER BY TotalDeathCount desc

-- Query by continent
-- Showing continents order by total death count
-- *6 continents only

SELECT 
	location, 
	MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null 
	AND location in 
	(
		'Europe',
		'North America', 
		'Asia', 
		'Africa', 
		'South America', 
		'Oceania'
	)
GROUP BY location
ORDER BY TotalDeathCount desc

-- Query just countries in Oceania
-- Oceania seemed too low so I wanted to make sure that Australia was included

SELECT 
	location, 
	continent, 
	MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent = 'Oceania'
group by location, continent
ORDER BY TotalDeathCount desc

-- Query by day, all countries
-- Shows chronological progression of covid cases, deaths, and mortality rate

SELECT 
	date, 
	SUM(new_cases) as TotalCases, 
	SUM(cast(new_deaths as int)) as TotalDeaths, 
	Round(SUM(cast(new_deaths as int))/SUM(new_cases) *100,2) as MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and total_cases is not null 
GROUP by date
ORDER by 1,2

-- Query globally
-- Shows total cases globally, total deaths globally, and case mortality rate up until July 11, 2022

SELECT 
	SUM(new_cases) as TotalCases, 
	SUM(cast(new_deaths as int)) as TotalDeaths, 
	Round(SUM(cast(new_deaths as int))/SUM(new_cases) *100,2) as MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER by 1,2

-- 2. INVESTIGATE CovidVaccinations DATA

-- Perform basic join on CovidDeaths data and CovidVaccinations data

SELECT *
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- Query total population vs administered vaccinations
-- Shows new daily count of vaccinations administered and a rolling total
-- *Rolling total calculation differs from "total_vaccinations" field for unknown reason

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) RollingTotal
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2, 3

-- Create CTE
-- Need to create a common table expression to divide RollingTotal by population in order to add a column for percent of population recieving one dose
-- Used Japan only
-- *Count is by dose administered, therefore a 200% vaccination rate merely indicates that 2x the population worth of individual vaccine does have been administered

WITH popvsvac (continent, location, date, population, new_vaccinations, RollingTotal)
as
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) RollingTotal
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, Round((RollingTotal/population)*100,2) as PercentOfPopulationVaccinated
FROM popvsvac
WHERE location = 'Japan'

-- Alternate method: create temp table
-- Using Canada as target location

DROP TABLE IF EXISTS #percentofpopulationvaccinated
CREATE TABLE #percentofpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingTotal numeric
)

INSERT INTO #percentofpopulationvaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) RollingTotal
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, Round((RollingTotal/population)*100,2) as PercentOfPopulationVaccinated
FROM #percentofpopulationvaccinated
WHERE location = 'Canada'

-- Alternate method: create view
-- Creating view to store date for future visualizations

CREATE VIEW percentofpopulationvaccinated as
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) RollingTotal
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

-- Test view
SELECT *
FROM percentofpopulationvaccinated



