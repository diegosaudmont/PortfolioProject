Select *
from [Project Data]..CovidVaccinations
group by 3,4 

select * 
from [Project Data]..CovidDeaths
where continent is not null


--Looking at total cases vs population (shows the %)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Project Data]..CovidDeaths
where continent is not null 
-- where location = 'Belgium'
order by 1,2

-- Looking at countries with highest infection rate compared to Population 
select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from [Project Data]..CovidDeaths
where continent is not null 
Group by location, population 
order by PercentPopulationInfected desc

-- Looking at countries with the highest death count per population 

select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from [Project Data]..CovidDeaths
where continent is not null 
Group by location
order by TotalDeathCount desc

-- Lets break things down by continent 
select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from [Project Data]..CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global numbers 
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Project Data]..CovidDeaths
Where continent is not null 
Group by date
order by 1,2


-- Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Project Data]..CovidDeaths dea
Join [Project Data]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- Use CTE 

With PopvsVac (Continent, Date, Location, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Project Data]..CovidDeaths dea
Join [Project Data]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp Table

Drop table if exists #PercentPopulatedVaccinated
Create Table #PercentPopulatedVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulatedVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Project Data]..CovidDeaths dea
Join [Project Data]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulatedVaccinated

-- Create view to store data for later visualisation

Create view PercentPopulatedVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Project Data]..CovidDeaths dea
Join [Project Data]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
from PercentPopulatedVaccinated