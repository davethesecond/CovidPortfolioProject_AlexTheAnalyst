--COVID DEATHS DATASET

SELECT   *
FROM     PortfolioProject..CovidDeathsNew
ORDER BY 3,4



--DATA TO BE USED 

SELECT   Location, date, total_cases, new_cases, total_deaths, population
FROM     PortfolioProject..CovidDeathsNew
ORDER BY 1,2



--TOTAL CASES VS TOTAL DEATHS
--Showing mortality rate

SELECT   Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM     PortfolioProject..CovidDeathsNew
WHERE    location like '%Nigeria%'
ORDER BY 1,2



--Total Cases Vs Population
--Showing percentage of population that got Covid

SELECT   Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
FROM     PortfolioProject..CovidDeathsNew
ORDER BY 1,2



--Countries With Highest Infection Rates Compared to Population

SELECT   Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PopulationPercentage
FROM     PortfolioProject..CovidDeathsNew
GROUP BY location, population
ORDER BY PopulationPercentage desc



--Countries With Highest Death-Count

SELECT   Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM     PortfolioProject..CovidDeathsNew
WHERE    continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc



--Continents With Highest Death-Count

SELECT   continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM     PortfolioProject..CovidDeathsNew
WHERE    continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



--Global Numbers

SELECT   SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths as int)) as Total_Deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM     PortfolioProject..CovidDeathsNew
WHERE    continent is not null
ORDER BY 1,2




--Total Population Vs Vaccination

--USING CTE

WITH   popsvac (Continent, location, date, population, new_vaccinations, RollingpopVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingpopVaccinated
FROM   PortfolioProject..CovidDeathsNew dea
JOIN   PortfolioProject..CovidVaccinations vac
  ON   dea.location = vac.location
  and  dea.date = vac.date
WHERE  dea.continent is not null
)

SELECT *, (RollingpopVaccinated/population)*100
FROM   popsvac


--TEMP TABLE

DROP TABLE if exists #PercentagepopVaccinated
CREATE TABLE         #PercentagepopVaccinated
(
continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpopVaccinated numeric
)
INSERT INTO #PercentagepopVaccinated
SELECT      dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
            SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingpopVaccinated
FROM        PortfolioProject..CovidDeathsNew dea
JOIN        PortfolioProject..CovidVaccinations vac
  ON        dea.location = vac.location
  and       dea.date = vac.date
WHERE       dea.continent is not null

SELECT      *, (RollingpopVaccinated/population)*100
FROM        #PercentagepopVaccinated



--Creating View To Store Data For Future Visualisation

CREATE VIEW PercentagepopVaccinated as
SELECT      dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
            SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingpopVaccinated
FROM        PortfolioProject..CovidDeathsNew dea
JOIN        PortfolioProject..CovidVaccinations vac
  ON        dea.location = vac.location
 and        dea.date = vac.date
WHERE       dea.continent is not null

SELECT      *
FROM        PortfolioProject..PercentagepopVaccinated