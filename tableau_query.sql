--1.Global count
Select 
    SUM(new_cases) as total_cases, 
    SUM(new_deaths) as total_deaths, 
    SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From covid_deaths
where continent is not null 
order by 1,2;
--2.
Select 
    location, 
    SUM(new_deaths) as TotalDeathCount
From covid_deaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;
--3.
Select 
    Location, 
    Population,
    MAX(total_cases) as HighestInfectionCount,  
    Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc;
--4.
Select 
    Location,
    Population,
    source_date, 
    MAX(total_cases) as HighestInfectionCount,  
    Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Group by Location, Population, source_date
order by PercentPopulationInfected desc;
-- 5. New Cases Vs Vaccinations
select
    dea.location,
    dea.source_date,
    dea.new_cases,
    sum(dea.new_cases) over (partition by dea.location order by dea.location,dea.source_date) as RollingNewCases,
    vac.PEOPLE_FULLY_VACCINATED_PER_HUNDRED,
    dea.population,
    vac.new_tests,
    (dea.new_cases/dea.population)*100 as PercentPeopleInfected
FROM COVID_DEATHS DEA
JOIN COVID_VACCINATIONS VAC ON DEA.LOCATION = VAC.LOCATION AND DEA.SOURCE_DATE = VAC.SOURCE_DATE
WHERE VAC.LOCATION in ('Canada','United States','Europe','India')
--and dea.continent is not null

order by dea.location,dea.source_date desc;
