select *
From [Portfolio Project]..CovidDeaths
where continent is not null
ORDER BY 3,4

--select *
--From [Portfolio Project]..CovidVaccinations
--where continent is not null
--ORDER BY 3,4

--Select the data we are going to be using

Select Location,date,total_cases, new_cases,total_deaths
,population
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country

Select Location,date,total_cases,total_deaths,
(cast(total_deaths as numeric)) / cast(total_cases as numeric)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%Nigeria%'
--where continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location,date,total_cases, population,
(cast(total_cases as numeric)) / cast(population as numeric)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
order by 1,2

-- Looking at countries with Highest infection rate compared to Population

Select Location, population, Max(total_cases) as HighestinfectionCount,
max(cast(total_cases as numeric)) / cast(population as numeric)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

-- Showing the countries with the Highest Death Count per Population

Select Location, Max(cast(total_Deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's break things down by continent

Select continent, Max(cast(total_Deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing the continents with the Highest Death per Population

Select continent, Max(cast(total_Deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Looking at Global Numbers

Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int)) /nullif (sum(new_cases),0)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccination

--use CTE

with popvsVac (continent, Location, Date, Population, new_vaccinations,  RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinate/Population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
from popvsVac


-- TEMP TABLE

Create Table #PercentPopulationVaccinated
( continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinate/Population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visaulisations



select * 
from PercentPopulationVaccinated