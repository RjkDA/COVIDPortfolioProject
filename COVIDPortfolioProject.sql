
/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE Continent IS NOT NULL
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT Location, Date, Total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, Date, Total_cases, total_deaths, ((CAST(total_deaths AS DECIMAL)/CAST(total_cases AS DECIMAL))*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%' AND Continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, Date, population, Total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to population

SELECT Location, population, MAX(Total_cases) AS HighestInfectionCount, MAX(total_cases)/population*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT Continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_cases, SUM(CAST(New_deaths AS INT)) AS Total_deaths, SUM(CAST(New_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
--GROUP BY Date
ORDER BY 1,2


-- Total Population vs Vaccination
-- Shows Percentage of Population that has recieved at least one covid vaccine

SELECT Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_vaccinations
, SUM(CONVERT(BIGINT, Vac.New_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.Location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE Dea.Continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform calculation on Partition By in pervious query

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_vaccinations
, SUM(CONVERT(BIGINT, Vac.New_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.Location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE Dea.Continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Using Temp Table to perform calculation on Partition By in pervious query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_vaccinations
, SUM(CONVERT(BIGINT, Vac.New_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.Location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE Dea.Continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations


-- RollingPeopleVaccinated
CREATE VIEW RollingPeopleVaccinated AS
SELECT Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_vaccinations
, SUM(CONVERT(BIGINT, Vac.New_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.Location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE Dea.Continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM RollingPeopleVaccinated


-- PercentPopulationInfected
CREATE VIEW PercentPopulationInfected AS
SELECT Location, population, MAX(Total_cases) AS HighestInfectionCount, MAX(total_cases)/population*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Location, population
--ORDER BY PercentPopulationInfected DESC

SELECT *
FROM PercentPopulationInfected


-- TotalDeathCount
CREATE VIEW TotalDeathCount AS
SELECT Continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
--ORDER BY TotalDeathCount DESC

SELECT *
FROM TotalDeathCount


-- DeathPercentage
CREATE VIEW DeathPercentage AS
SELECT SUM(new_cases) AS Total_cases, SUM(CAST(New_deaths AS INT)) AS Total_deaths, SUM(CAST(New_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
--GROUP BY Date
--ORDER BY 1,2

SELECT *
FROM DeathPercentage


