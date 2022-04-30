-- DATA SOURCE: Retrieved from: https://ourworldindata.org/coronavirus (dates 2/24/2020 - 3/30/2022)
-- Queries used for Tableau Covid Dashboard Projects


-- 1. Global Numbers - double checking global numbers based off of: total_cases, total_deaths, and global death_percentage

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- 2. Continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count desc

-- 3. Countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY percent_population_infected desc

-- 4. Grouping the percent of population infected by Covid by date

SELECT Location, Population, date, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population, date
ORDER BY percent_population_infected desc

-- 5. Joining CovidDeaths table and CovidVaccinations table
-- Creating a Temp Table showing rolling percent count of individuals vaccinated by country, location, and date

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccination_count numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) as rolling_vaccination_count
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (rolling_vaccination_count/population)*100 as percent_rolling_vaccination
FROM #PercentPopulationVaccinated