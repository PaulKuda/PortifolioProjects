SELECT *
From PortifolioProject..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--From PortifolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortifolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercetange
From PortifolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPolutionInfected
From PortifolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as  HighestInfectionCount, MAX((total_cases/population))*100 as PercentPolutionInfected
From PortifolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location, population
order by PercentPolutionInfected desc


--Showing Countries with Highest Death Count per Population


Select location, MAX( cast(total_deaths as int)) as TotalDeathCount
From PortifolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continents with the highest death counts

Select continent, MAX( cast(total_deaths as int)) as TotalDeathCount
From PortifolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercetange
From PortifolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group By date
order by 1,2

--Looking as Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From PortifolioProject..CovidDeaths dea
Join PortifolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopsvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From PortifolioProject..CovidDeaths dea
Join PortifolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopsvsVac


--TEMP TABLE 
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From PortifolioProject..CovidDeaths dea
Join PortifolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From PortifolioProject..CovidDeaths dea
Join PortifolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
