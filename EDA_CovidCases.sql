SELECT * FROM coviddeaths order by 3,4;

SELECT * FROM covidvaccinations order by 3,4;

/*select data that we're going to be using*/
SELECT location, 
		date, 
        total_cases, 
        new_cases, 
        total_deaths, 
        population 
FROM coviddeaths
where location = 'Afghanistan' 
order by 1,2;


/*total cases vs total deaths*/
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage FROM coviddeaths where location like '%Costa Rica%' order by 1,2;

/*total cases vs population*/
/*what % of population has got covid*/
SELECT location, 
		date, 
        population, 
        total_cases, 
        total_deaths, 
        (total_cases/population)*100 as covid_infects 
FROM coviddeaths 
order by 1,2;



/*highest infected by countries as commpared to their population*/
SELECT location, 
		population, 
        max(total_cases) as HighestInfectionRates, 
        max((total_cases/population))*100 as InfectedPopulation 
FROM coviddeaths 
group by population, location 
order by InfectedPopulation desc;



/* highest death count*/
SELECT location, 
		max(total_deaths) as total_death_count 
FROM coviddeaths 
group by location 
order by total_death_count desc;



/* continents with highest death count */
SELECT continent, 
	max(total_deaths) as total_death_count 
FROM coviddeaths 
group by continent 
order by total_death_count desc;



/*global death count*/
SELECT sum(new_cases) as sum_cases, 
		sum(cast(new_deaths as int)) as sum_deaths, 
		sum(cast(new_deaths as int))/sum(new_cases)*100 as death_per 
from coviddeaths order by 1,2;


/*joining two tables*/
SELECT * FROM coviddeaths dea 
join covidvaccinations vac on dea.location = vac.location and dea.date = vac.date;


/*total population vs vaccination*/
SELECT dea.continent, 
		sum(dea.population) as total_population 
FROM coviddeaths dea 
join covidvaccinations vac on dea.location = vac.location and dea.date = vac.date 
group by dea.continent;


/*rolling count using subquery*/
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations,
       rolling_vaccinations
FROM coviddeaths dea 
JOIN covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date 
JOIN (
    SELECT location, SUM(CAST(new_vaccinations AS UNSIGNED)) AS rolling_vaccinations
    FROM covidvaccinations
    GROUP BY location
) AS subquery ON dea.location = subquery.location
ORDER BY 2, 3;


/*using CTE to use nrely generated columns in the aggregations*/
with PopVsVac
as (SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations,
       rolling_vaccinations
FROM coviddeaths dea 
JOIN covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date 
JOIN (
    SELECT location, SUM(CAST(new_vaccinations AS UNSIGNED)) AS rolling_vaccinations
    FROM covidvaccinations
    GROUP BY location
) AS subquery ON dea.location = subquery.location
ORDER BY 2, 3) 
select *, (rolling_vaccinations/population)*100 from PopVsVac;


/*creating temp table*/
create temporary table #PerPopVacc
(continent nvarchar(255),
location nvarchar(255),
date datetime
population numeric
new_vaccination numeric
rolling_vaccinations numeric
)
insert into #PerPopVacc
(SELECT continent, 
       location, 
       date, 
       population, 
       new_vaccinations,
       rolling_vaccinations
FROM coviddeaths dea 
JOIN covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date 
JOIN (
    SELECT location, SUM(CAST(new_vaccinations AS UNSIGNED)) AS rolling_vaccinations
    FROM covidvaccinations
    GROUP BY location
) AS subquery ON dea.location = subquery.location
ORDER BY 2, 3)
select *, (rolling_vaccinations/population)*100 from #PerPopVacc;


CREATE TEMPORARY TABLE PerPopVacc (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC(18, 2), -- Example precision and scale (adjust as needed)
    new_vaccination NUMERIC(18, 2), -- Example precision and scale (adjust as needed)
    rolling_vaccinations NUMERIC(18, 2) -- Example precision and scale (adjust as needed)
);

INSERT INTO PerPopVacc
(SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    subquery.rolling_vaccinations
FROM 
    coviddeaths dea 
JOIN 
    covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date 
JOIN (
    SELECT 
        location, 
        SUM(CAST(new_vaccinations AS UNSIGNED)) AS rolling_vaccinations
    FROM 
        covidvaccinations
    GROUP BY 
        location
) AS subquery ON dea.location = subquery.location
ORDER BY 
    dea.location, dea.date);

SELECT 
    *, 
    (rolling_vaccinations/population)*100 
FROM 
    PerPopVacc;

