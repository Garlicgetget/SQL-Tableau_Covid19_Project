USE Covid_19;

SELECT 
    location, MAX(people_vaccinated)
FROM
    covid_19.covid_vaccinations
GROUP BY location;

SELECT 
    location, date, total_cases, new_cases, total_deaths, population
FROM
    covid_19.covid_deaths
WHERE continent is not null;

ALTER TABLE covid_19.covid_deaths
ADD COLUMN datedrawn TEXT;
    
UPDATE covid_19.covid_deaths
SET datedrawn = date;

UPDATE covid_19.covid_deaths  
SET datedrawn = STR_TO_DATE(datedrawn, '%d/%m/%y');

ALTER TABLE covid_19.covid_deaths 
MODIFY COLUMN datedrawn datetime;

SELECT 
    location, datedrawn, total_cases, new_cases, total_deaths, population
FROM
    covid_19.covid_deaths 
WHERE continent is not null
ORDER BY 3,4;

#totall cases vs total death--shows the chance of dying if you had covid in your country
SELECT 
    location,
    (MAX(total_deaths) / MAX(total_cases)) * 100 AS DeathPercentage
FROM
    covid_19.covid_deaths
WHERE
    continent IS NOT NULL AND continent !=""
GROUP BY location
ORDER BY DeathPercentage DESC;
#What caused the suspicious outcome of North Korea?
SELECT 
    datedrawn, total_cases, new_cases, total_deaths, population
FROM
    covid_19.covid_deaths
WHERE
    location = 'North Korea'
    ORDER BY date DESC;
#Invalid data--remove from dataset for data cleaning and further investigations on the remaining part
DELETE FROM covid_19.covid_deaths 
WHERE
    location = 'North Korea';

#total cases vs population--shows what percentage of population infected with Covid
SELECT 
    location,
    (MAX(total_cases) / MAX(population)) * 100 AS PercentPopulationInfected
FROM
    covid_19.covid_deaths
WHERE
    continent IS NOT NULL AND continent !=""
GROUP BY location
ORDER BY PercentPopulationInfected DESC;

#looking at countries with highest infection rate compared to population
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM
    covid_19.covid_deaths
WHERE
    continent IS NOT NULL AND continent !=""
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC;


#showing countries with highest death count per population
SELECT 
    location,
    MAX(total_deaths) AS TotalDeathCount
FROM
    covid_19.covid_deaths
WHERE
    continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC;
#confused by the high income/low income/European Union categories
SELECT 
    *
FROM
    covid_19.covid_deaths
    WHERE location="High income";
#realize these categories have blank cells under continent column instead of NULL---update all queries
SELECT 
    location,
    MAX(total_deaths) AS TotalDeathCount
FROM
    covid_19.covid_deaths
WHERE
    continent IS NOT NULL AND continent !=""
GROUP BY location
ORDER BY TotalDeathCount DESC;

#breaking things dowm by continent--highest death count  population
SELECT 
    continent,
    MAX(total_deaths) AS TotalDeathCount
FROM
    covid_19.covid_deaths
WHERE
    continent IS NOT NULL AND continent !=""
GROUP BY continent
ORDER BY TotalDeathCount DESC;

#global numbers
SELECT
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths) / SUM(new_cases) *100 AS DeathPercentage
FROM
    covid_19.covid_deaths
WHERE
    continent IS NOT NULL AND continent !="";
    
#percentage of population that has recieved at least one covid vaccine
SELECT 
  d.continent, 
  d.location, 
  d.datedrawn, 
  d.population, 
  v.new_vaccinations,
  SUM(CONVERT(v.new_vaccinations,DECIMAL)) OVER 
  (PARTITION BY d.location ORDER BY d.location, d.datedrawn) AS RollingPeopleVaccinated,
  ((SUM(CONVERT(v.new_vaccinations,DECIMAL)) OVER 
  (PARTITION BY d.location ORDER BY d.location, d.datedrawn))/Population)*100 
FROM covid_19.covid_deaths d
JOIN covid_19.covid_vaccinations v
ON d.location = v. location AND d.date = v.date
WHERE d.continent IS NOT NULL AND d.continent !="" AND v.new_vaccinations IS NOT NULL AND v.new_vaccinations!=""
ORDER BY 2,3;
#new_vaccinations seems to be to little compared to per population, went back to check the dataset and found it did not match the records with total_vacinations
#it can not be used as reliable reference, switch to people_vaccinated

#percentage of population that has recieved at least one covid vaccine
SELECT 
  d.continent, 
  d.location, 
  d.datedrawn, 
  d.population, 
  v.people_vaccinated,
  v.people_vaccinated/d.population * 100 AS percent_population_vaccinated
FROM covid_19.covid_deaths d
JOIN covid_19.covid_vaccinations v
ON d.location = v. location AND d.date = v.date
WHERE d.continent IS NOT NULL AND d.continent !="" AND v.people_vaccinated !=""
ORDER BY 2,3;

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
  d.continent, 
  d.location, 
  d.datedrawn, 
  d.population, 
  v.people_vaccinated,
  v.people_vaccinated/d.population * 100 AS percent_population_vaccinated
FROM covid_19.covid_deaths d
JOIN covid_19.covid_vaccinations v
ON d.location = v. location AND d.date = v.date
WHERE d.continent IS NOT NULL AND d.continent !="" AND v.people_vaccinated !="";


