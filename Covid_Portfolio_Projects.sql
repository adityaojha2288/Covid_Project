select *
from project_portfolio.coviddeaths
where continent is not null
order by 3,4;

#Looking at Total Cases vs New Cases(Shows the Likelyhood of Dying)

select location, date , total_cases ,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from project_portfolio.coviddeaths
where location ='India'
order by 1,2;

#Looking at Total Case vs Population (Shows how much population is affected)

select location, date , total_cases ,  population, (total_cases/population)*100 as PercentagePopulationaffected
from project_portfolio.coviddeaths
where location ='India'
order by 1,2;

#Countries with highest infection rate to population

select location,  MAX(total_cases) as Highest_Infect_count ,  population, MAX((total_cases/population))*100 as PercentagePopulationaffected
from project_portfolio.coviddeaths
group by location, population
order by PercentagePopulationaffected desc;

#Countries with highest death count per population
select location,  max(cast(total_deaths as decimal)) as Total_death_count
from project_portfolio.coviddeaths
where continent is not null
group by location
order by  Total_death_count desc;

#Continent with deathcounts
select continent, max(cast(total_deaths as decimal)) as Total_death_count
from project_portfolio.coviddeaths
where continent is not null
group by continent
order by  Total_death_count desc;

# Global numbers
select  sum(new_cases) as totalcases,sum(cast(new_deaths as decimal)) as totaldeaths, sum(cast(new_deaths as decimal))/sum(new_cases)*100 as Deathpercentage
from project_portfolio.coviddeaths
where continent is not null
#group by date
order by 1,2;

#Total Population vs Vacc
select dea.continent, dea.location,dea.population,dea.date,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location,dea.date) as
RollingpeopleVaccinated
from project_portfolio.coviddeaths dea
Join project_portfolio.covidvaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

#Use CTE
with PopvsVac (continent, location,population, date,new_vaccinations,RollingpeopleVaccinated)
as
(
select dea.continent, dea.location,dea.population,dea.date,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location,dea.date) as
RollingpeopleVaccinated
from project_portfolio.coviddeaths dea
Join project_portfolio.covidvaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
select *,(RollingpeopleVaccinated/population)*100
from PopvsVac;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'; 
drop table if exists PercentpeopleVAccinated;
#Temp Table
create table PercentpeopleVAccinated
(
continent varchar(255),
location varchar(255),
population decimal,
date date,
new_vaccinations decimal,
RollingPeopleVaccinated decimal
);
insert into PercentpeopleVAccinated(continent,location,population,date,new_vaccinations,RollingPeopleVaccinated)
select dea.continent, dea.location ,dea.population,cast(str_to_date(dea.date, "%d-%m-%y") as date) as Date,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location,dea.date) as
RollingpeopleVaccinated
from project_portfolio.coviddeaths dea
Join project_portfolio.covidvaccinations vac  
on dea.location = vac.location
and dea.date = vac.date;
#where dea.continent is not null;
#order by 2,3
select *,(RollingpeopleVaccinated/population)*100
from PercentpeopleVAccinated;

#Creating view to store data for viz
create view PercentpopulationVaccinated as
select dea.continent, dea.location ,dea.population,cast(str_to_date(dea.date, "%d-%m-%y") as date) as Date,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location,dea.date) as
RollingpeopleVaccinated
from project_portfolio.coviddeaths dea
Join project_portfolio.covidvaccinations vac  
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
#order by 2,3;
drop view PercentpopulationVaccinated ;
Select *
from PercentpopulationVaccinated 
