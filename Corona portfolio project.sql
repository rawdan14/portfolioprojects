Select * 
From project1.dbo.CoronaDeaths
where continent is not null
order by 3,4

--Select * 
--From project1.dbo.CoronaVacsinates
--order by 3,4

--Select Data that we are going to be using

Select Location,date,total_cases,new_cases,total_deaths,population
From project1.dbo.CoronaDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location,date,total_cases,total_deaths,(convert(decimal,total_deaths)/convert(decimal,total_cases))*100 as deathpercentage
From project1.dbo.CoronaDeaths
where location like '%egypt%'
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid

Select Location,date,population,total_cases,(total_cases/population)*100 as populationpercentage
From project1.dbo.CoronaDeaths
--where location like '%egypt%'
order by 1,2

-- looking at countries with highest infection rate compared to population

Select Location,population,MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as percentageofpopulationinfected
From project1.dbo.CoronaDeaths
--where location like '%states%'
group by location,population
order by percentageofpopulationinfected desc


-- showing countries with highest death count per population

Select Location,MAX(cast(total_deaths as int)) as totaldeathcount
From project1.dbo.CoronaDeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

-- showing continents with the highest death count per population

Select continent,MAX(cast(total_deaths as int)) as totaldeathcount
From project1.dbo.CoronaDeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc

-- Global numbers 

Select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From project1.dbo.CoronaDeaths
--where location like '%egypt%'
where continent is not null
group by date
order by 1,2

-- join both tables
Select * 
From project1.dbo.CoronaDeaths dea
join project1.dbo.CoronaVacsinates vac
  on dea.location = vac.location
  and dea.date = vac.date

  --looking ata total population vs vaccinations
 Select dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as decimal)) OVER (partition by dea.location order by dea.location,dea.date)
 as rollingpeoplevaccinated
From project1.dbo.CoronaDeaths dea
join project1.dbo.CoronaVacsinates vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE

with PopvsVac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as(
 Select dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as decimal)) OVER (partition by dea.location order by dea.location,dea.date)
 as rollingpeoplevaccinated
From project1.dbo.CoronaDeaths dea
join project1.dbo.CoronaVacsinates vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(rollingpeoplevaccinated/population)*100
from PopvsVac


--Creating view to store data for later visualization

create view percentpopulationvaccinated as
Select dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as decimal)) OVER (partition by dea.location order by dea.location,dea.date)
 as rollingpeoplevaccinated
From project1.dbo.CoronaDeaths dea
join project1.dbo.CoronaVacsinates vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null