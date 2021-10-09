-- Data clening
-- to check if both the tables have the same records
select * from covid_deaths;

select * from covid_deaths d right join covid_vaccination v
on d.iso_code||d.source_date = v.iso_code||v.source_date
;
select location,source_date from covid_deaths 
minus select location,source_date from covid_vaccination;

select location,source_date from covid_deaths
union
(select location,source_date from covid_vaccination)
minus
select location,source_date from covid_deaths
intersect
(select location,source_date from covid_vaccination);


-- select data that is going to be used
select
    location,
    source_date,
    total_cases,
    new_cases,
    coalesce(total_deaths,0),
    population
from covid_deaths
order by 1,2;
-- Looking at total cases vs total deaths
select
    location,
    source_date,
    total_cases,
    coalesce((total_deaths/total_cases),0)*100 as deathpercentage,
    coalesce(total_deaths,0),
    population
from covid_deaths
where continent is not null
order by 1,2;

-- looking at total cases vs percentage
-- shows what percentage of population has covid
select
    location,
    source_date,
    total_cases,
    population,
    (total_cases/population)*100 as PercentPopulationInfected
from covid_deaths
where continent is not null
order by 1,2;

-- Looking at countries with highest infection rate compared to population
select
    location,
    population,
    coalesce(max(total_cases),0) as HighestInfectionCount,
    coalesce(max((total_cases/population)),0)*100 as PercentPopulationInfected
from covid_deaths
where continent is not null
Group by location,population
order by PercentPopulationInfected desc;

-- Showing countries with Highest Death Count per Population
select
    location,
    coalesce(max(total_deaths),0) as TotalDeathCount
from covid_deaths
where continent is not null
Group by location
order by TotalDeathCount desc;

-- Categorizing by continents
select
    location,
    max(total_deaths) as TotalDeathCount
from covid_deaths
where continent is null
group by location 
order by TotalDeathCount desc;
--  showing continents with the highest death count per population
select
    continent,
    max(total_deaths) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent 
order by TotalDeathCount desc;
--calculate numbers across the entire world

select
    source_date,
    coalesce(sum(new_cases),0) as TotalCases,
    coalesce(sum(new_deaths),0) as TotalDeaths,
    sum(new_deaths)/sum(new_cases) as DeathPercentage
from covid_deaths
where continent is not null
group by source_date
order by 1,2;
-- Looking at total population vs vaccination
Select 
    dea.continent,
    dea.location,
    dea.source_date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location,dea.source_date) as RollingPeopleVaccinated
from covid_deaths dea
join covid_vaccination vac 
on dea.location = vac.location and dea.source_date = vac.source_date
where dea.continent is not null and dea.location like 'Cana%'
order by 2,3;
-- Use Common Table Expression
With popvsvac (continent,location,source_date,population,new_vaccinations,rollingpeoplevaccinated)
as(
Select 
    dea.continent,
    dea.location,
    dea.source_date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location,dea.source_date) as RollingPeopleVaccinated
from covid_deaths dea
join covid_vaccination vac 
on dea.location = vac.location and dea.source_date = vac.source_date
where dea.continent is not null and dea.location like 'Cana%'
--order by 2,3)
)select *,(RollingPeopleVaccinated/population)*100
from popvsvac;
-- creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
select
    continent,
    max(total_deaths) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent 
order by TotalDeathCount desc;

select * from PercentPopulationVaccinated;




