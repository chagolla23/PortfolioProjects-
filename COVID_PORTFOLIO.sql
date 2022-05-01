Select *
From PortfolioProject..COVID_DEATHS$
where continent is not null
order by 3, 4

--select *
--from PortfolioProject..COVID_VAXS$
--order by 3, 4


select Location, date, total_cases, total_deaths, population
from PortfolioProject..COVID_DEATHS$
order by 1,2


-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in the USA 

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..COVID_DEATHS$
where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population 
-- Shows what percentage of population got COVID 

select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..COVID_DEATHS$
where location like '%states%'
order by 1,2

-- Looking at countires with highest infection rate compared to population 

select Location, MAX(total_cases) as HighestInfectionCount , Population, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..COVID_DEATHS$
--where location like '%states%'
group by location, population 
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population 

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..COVID_DEATHS$
--where location like '%states%'
where continent is not null
group by location 
order by TotalDeathCount desc

-- Let's break things down by continent 

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..COVID_DEATHS$
--where location like '%states%'
where continent is not null
group by continent 
order by TotalDeathCount desc


-- Showing the continents with the highest death counts 

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..COVID_DEATHS$
--where location like '%states%'
where continent is not null
group by continent 
order by TotalDeathCount desc


-- Global Numbers 

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from PortfolioProject..COVID_DEATHS$
--where location like '%states%'
where continent is not null
group by date
order by 1,2 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from PortfolioProject..COVID_DEATHS$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2 


-- Looking at total popoulation vs vaccinations 


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..COVID_DEATHS$ dea
Join PortfolioProject..COVID_VAXS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- CTE

With PopvsVac (Contintent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..COVID_DEATHS$ dea
Join PortfolioProject..COVID_VAXS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..COVID_DEATHS$ dea
Join PortfolioProject..COVID_VAXS$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data later for visualizations 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..COVID_DEATHS$ dea
Join PortfolioProject..COVID_VAXS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


