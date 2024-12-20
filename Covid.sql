-- Taking a general look of the data
SELECT *
FROM coviddeath
WHERE continent  is not null
ORDER BY 3,4

-----------------------------------------------------------------------------------------------------------------------------------------------
--ALTERING DATE COLUMN TO DATE
ALTER TABLE covidvaccinations
ALTER COLUMN new_vaccinations TYPE int
USING new_vaccinations::int;

------------------------------------------------------------------------------------------------------------------------------------------------
--Looking at Total deaths vs Total Cases
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
FROM coviddeath
WHERE total_cases !=0 and  continent  is not null --AND location = 'Nigeria'
ORDER BY death_percentage desc ;

--- Looking at Total deaths vs Population
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Covid_Pop_Percentage
FROM coviddeath
-- WHERE location = 'Nigeria'
WHERE continent  is not null
ORDER BY 1,2
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Looking at Countries with the highest infection rates compared to population
SELECT 
Location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Highest_Covid_Pop_Percentage
FROM coviddeath
--WHERE location = 'Nigeria'
WHERE continent  is not null
GROUP BY Location, population
ORDER BY  Highest_Covid_Pop_Percentage DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------
--Looking at Countries with the highest Death Count
SELECT 
Location, SUM(CAST (total_deaths AS int)) AS total_Death_count
FROM coviddeath
--WHERE location = 'Nigeria'
WHERE continent  is not null
GROUP BY Location
ORDER BY total_Death_count  DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking down by continent: Showing continents with the highest number of deaths 
SELECT 
Continent, SUM(CAST (total_deaths AS int)) AS total_Death_count
FROM coviddeath
--WHERE location = 'Nigeria'
WHERE continent  is not  null
GROUP BY continent
ORDER BY total_Death_count  DESC;      --For the sake of visualization 


--RIGHT query for continent breakdown:
SELECT 
Location, SUM(CAST (total_deaths AS int)) AS total_Death_count
FROM coviddeath
WHERE location = 'Nigeria' --AND continent  is NOT  null
GROUP BY location
ORDER BY total_Death_count  DESC; 
-------------------------------------------------------------------------------------------------------------------------------------------------------

--GROUPING GLOBALLY
SELECT --date,
SUM(CAST(new_cases AS numeric)) AS total_new_cases,
SUM(CAST(new_deaths AS numeric)) AS total_new_deaths,
(SUM(CAST(new_deaths AS numeric))/SUM(CAST(new_cases AS numeric)))*100 AS new_death_percentage
FROM coviddeath
WHERE total_cases !=0 and  continent  is not null --AND location = 'Nigeria'
GROUP BY date
ORDER BY date ;


SELECT date,
SUM(CAST(new_cases AS numeric)) AS total_new_cases,
SUM(CAST(new_deaths AS numeric)) AS total_new_deaths,
(SUM(CAST(new_deaths AS numeric))/SUM(CAST(new_cases AS numeric)))*100 AS new_death_percentage
FROM coviddeath
WHERE total_cases !=0 and  continent  is not null --AND location = 'Nigeria'
GROUP BY date
ORDER BY date ;               --Considering Date

------------------------------------------------------------------------------------------------------------------------
--JOINING coviddeath and covidvaccinations table using locations and date

-- Looking at Total Populations Vs Vaccinations
--Using CTE since I would be creating a new columnn 
WITH PopVsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
cde.continent,cde.location, 
cde.date,cde.population, cva.new_vaccinations, 
SUM( cva.new_vaccinations) OVER (PARTITION BY cde.Location ORDER BY cde.location, cde.date) AS RollingPeopleVaccinated
FROM coviddeath cde
JOIN covidvaccinations cva
ON cde.location = cva.location AND cde.date = cva.date
WHERE cde.continent is not null
order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac
-------------------------------------------------------------------------------------------------------------------------------

--TEMP TABLE

DROP TABLE IF exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent  varchar(255),
Location  varchar(255),
Date  timestamp without time zone,
Population  numeric,
New_vaccinations Numeric, 
RollingPeopleVaccinated numeric
)
	
INSERT INTO PercentPopulationVaccinated
SELECT 
cde.continent,cde.location, 
cde.date,cde.population, cva.new_vaccinations, 
SUM( cva.new_vaccinations) OVER (PARTITION BY cde.Location ORDER BY cde.location, cde.date) AS RollingPeopleVaccinated
FROM coviddeath cde
JOIN covidvaccinations cva
ON cde.location = cva.location AND cde.date = cva.date
WHERE cde.continent is not null
order by 2,3

SELECT *
FROM PercentPopulationVaccinated 


----creating view for visualization later
CREATE VIEW PercentPopulationVaccinated AS 
SELECT 
cde.continent,cde.location, 
cde.date,cde.population, cva.new_vaccinations, 
SUM( cva.new_vaccinations) OVER (PARTITION BY cde.Location ORDER BY cde.location, cde.date) AS RollingPeopleVaccinated
FROM coviddeath cde
JOIN covidvaccinations cva
ON cde.location = cva.location AND cde.date = cva.date
WHERE cde.continent is not null



SELECT *
FROM PercentPopulationVaccinated

-- For Data Visualization
--Table 1
SELECT 
SUM(CAST(new_cases AS numeric)) AS total_cases,
SUM(CAST(new_deaths AS numeric)) AS total_deaths,
(SUM(CAST(new_deaths AS numeric))/SUM(CAST(new_cases AS numeric)))*100 AS death_percentage
FROM coviddeath
WHERE total_cases !=0 and  continent  is not null --AND location = 'Nigeria'
ORDER BY 1,2;

--Table 2
SELECT location, SUM(CAST(new_deaths AS numeric)) AS total_death_count
FROM coviddeath
--WHERE location =  'Nigeria'
WHERE continent IS null AND location NOT in ('World', 'European Union', 'International') 
GROUP BY location
ORDER BY total_death_count DESC;

--Table 3
SELECT 
Location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS PopPercentageAffected
FROM coviddeath
--WHERE location = 'Nigeria'
WHERE continent  is not null 
GROUP BY Location, population
ORDER BY PopPercentageAffected;

-- Table 4
SELECT 
Location, population,date, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases)/population)*100 AS PopPercentageAffected
FROM coviddeath
--WHERE location = 'Nigeria'
WHERE continent  is not null 
GROUP BY Location, population, date
ORDER BY PopPercentageAffected DESC;