
SELECT *
FROM SQL_project..[CovidDeaths$]
Where continent is not NULL
ORDER BY 3,4 
SELECT *
FROM SQL_project..[' vaccination worksheet$']
ORDER BY 3,4 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQL_project..CovidDeaths$
ORDER BY 1,2
--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in different countries
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM SQL_project..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2
--Looking at Total Cases vs the population
--Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentpopulationInfected
FROM SQL_project..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentpopulationInfected
FROM SQL_project..CovidDeaths$
--WHERE location like '%states%'
GROUP BY continent, population
ORDER BY PercentpopulationInfected desc

--Showing countries with highest death count per population

SELECT location,  MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM SQL_project..CovidDeaths$
--WHERE location like '%states%'
Where continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Break down by continent
--Showing continents with the highest death count

SELECT location,  MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM SQL_project..CovidDeaths$
--WHERE location like '%states%'
Where continent is not NULL
GROUP BY continent 
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM SQL_project..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM SQL_project..CovidDeaths$ dea
JOIN SQL_project.. CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 2, 3

 --CTE

 WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
 ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM SQL_project..CovidDeaths$ dea
JOIN SQL_project.. CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
 WHERE dea.continent is not null

 )
-- ORDER BY 2, 3
select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp Table
DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
 ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM SQL_project..CovidDeaths$ dea
JOIN SQL_project.. CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
 WHERE dea.continent is not null

 SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

USE SQL_project
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
 ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM SQL_project..CovidDeaths$ dea
JOIN SQL_project.. CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
 WHERE dea.continent is not null

--Another view

CREATE VIEW Populationsvsvaccination as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
 ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM SQL_project..CovidDeaths$ dea
JOIN SQL_project.. CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
 WHERE dea.continent is not null












