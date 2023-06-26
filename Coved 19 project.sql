select *
from CovidDeaths$
where continent is not null
order by location,date


select *
from CovidVaccinations$
order by location,date

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths$
where continent is not null
order by location,date

-- looking at Total Cases vs Total Deathscovid 
-- likelihood of dying if you contract in your country


select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 DeathPercent
from CovidDeaths$
where location like '%states%'
and continent is not null
order by location,date

--Looking at Total Cases vs Population
-- Shows what percent of population got coved

select location,date,total_cases,population, (total_cases/population)*100 CasesPercent
from CovidDeaths$
where continent is not null
--where location like '%states%'
order by location,date

-- Looking at countries with Highest Infection Rate compared to population


select location,population ,max(total_cases) HighiestInfCount, max(total_cases/population)*100 CasesPercent
from CovidDeaths$
group by population,location
order by CasesPercent desc

-- Showing Countries with Hieghst Death Count per Population
--convert(int,total_deaths)
--cast(total_deaths as int)

select location ,max(convert(int,total_deaths)) TotalDeathCount
from CovidDeaths$
where continent is not null
group by population,location
order by TotalDeathCount desc

-- Showing Countries with Hieghst Death Count per Population

select continent,max(convert(int,total_deaths)) TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL Numbers

select sum(new_cases) SumCases,sum(cast(new_deaths as int)) SumDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 DeathPercent
from CovidDeaths$
where continent is not null
--and location like '%states%'
--group by date
order by 1,2


select *
from CovidVaccinations$

select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location=vac.location
  and dea.date=vac.date

--Looking at Total Population vs Vaccination


select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date ) RollinPeopleVaccenated
--,(RollinPeopleVaccenated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location=vac.location
  and dea.date=vac.date
order by 2,3

--use Cte

with PopvsVac (continent,location,date,population,new_Vaccinations,RollinPeopleVaccenated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date ) as RollinPeopleVaccenated
--,(RollinPeopleVaccenated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select* ,(RollinPeopleVaccenated/population)*100
from PopvsVac

--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollinPeopleVaccenated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date ) as RollinPeopleVaccenated
--,(RollinPeopleVaccenated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select* ,(RollinPeopleVaccenated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for further visualisation

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date ) as RollinPeopleVaccenated
--,(RollinPeopleVaccenated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
