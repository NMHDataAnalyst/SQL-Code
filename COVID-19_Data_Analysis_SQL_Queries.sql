SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths in Vietnam

SELECT Location, Date, Total_Cases, Total_Deaths, (CAST(Total_Deaths AS FLOAT)/CAST(Total_Cases AS FLOAT))*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths 
WHERE Location LIKE '%Vietnam%'  AND continent is not null
ORDER BY 1,2;

--Shows what percentage of population in Vietnam
SELECT Location, Date, Total_Cases, Population, (CAST(Total_cases AS FLOAT)/CAST(Population AS FLOAT))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Vietnam%' AND continent is not null
ORDER BY 1,2;



--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(CAST(Total_Cases AS FLOAT)) as HighestInfectionCount, MAX((CAST(Total_cases AS FLOAT)/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location,Population 
ORDER BY PercentPopulationInfected DESC;

--Showing Contries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_Deaths AS FLOAT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;


--Showing continents with the highest death count 

SELECT continent, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global Number Death

SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, 
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null;

--Looking at Total Deaths and Total cases in the world
SELECT date, SUM(CAST(Total_deaths AS BIGINT)) AS TOTALDEATH,SUM(CAST(Total_cases AS BIGINT)) AS TOTALCASE
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY date ASC;

--Looking at Total Population and Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY vac.Location ORDER BY dea.Location,
dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location
	AND dea.date=dea.date
	WHERE dea.continent is not null
	ORDER BY 2,3;


	--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY vac.Location ORDER BY dea.Location,
dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location
	AND dea.date=dea.date
	WHERE dea.continent is not null
	)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY vac.Location ORDER BY dea.Location,
dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location
	AND dea.date=dea.date
	WHERE dea.continent is not null

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentagePopulationVaccinated


--Creating View to store data for later Visualizations

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY vac.Location ORDER BY dea.Location,
dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location
	AND dea.date=dea.date
	WHERE dea.continent is not null

SELECT * FROM PercentagePopulationVaccinated


--Shows what percentage of population in the 
SELECT Location, Date, Total_Cases, Population, (CAST(Total_cases AS FLOAT)/CAST(Population AS FLOAT))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;