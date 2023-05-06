use PortfolioProject

--select * from PortfolioProject..CovidDeaths$
--order by 3, 4

--select * from PortfolioProject..CovidVaccinations$
--order by 3, 4



-- select the data that we will be using

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1, 2

-- Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathRate
From PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1, 2



--Looking at Total Cases vs Population
-- Shows the percentage of the population got Covid

select location, date, total_cases, population, (total_cases/population) * 100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1, 2



-- Looking at Countries with the Highest Infection Rate compared to Population

Select location, population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as InfectionRate
From PortfolioProject..CovidDeaths$
group by location, population
order by 4 desc


-- Showing Countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by location
order by 2 desc

-- Showing the Continents Death Count

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by continent
order by 2 desc

-- Global Numbers for New Cases and Deaths

select date, SUM(new_cases) as SumOfNewCases, SUM(cast(new_deaths as int)) SumOfNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentOfDeathToNewCases
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by date
order by 1


--Look at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
order by 2, 3


-- Use CTE
With PopVsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2, 3
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercenteOfPeopleVaccinated
From PopVsVac



--Using Temp Table
--This is another way for the above CTE script but using a Temp Table


Drop table if exists #PercenteOfPeopleVaccinated
Create table #PercenteOfPeopleVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercenteOfPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100 as PercenteOfPeopleVaccinated
From #PercenteOfPeopleVaccinated


-- Creating View to Store Data for Later Visualization

Create View PercenteOfPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations


------------------------------------------------------------------------------------------------------------------
--!!!!!!!!!!This is to create the above view using CTE and does not need to be ran !!!!!!!!!

Create View PopVsVac as 
With PopVsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2, 3
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercenteOfPeopleVaccinated
From PopVsVac


------------------------------------------------------------------------------------------------------------------
Create View RollingPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations



------------------------------------------------------------------------------------------------------------------
Create View PercentOfDeathToNewCases as 
select date, SUM(new_cases) as SumOfNewCases, SUM(cast(new_deaths as int)) SumOfNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentOfDeathToNewCases
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by date



------------------------------------------------------------------------------------------------------------------
Create View InfectionRate as
Select location, population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as InfectionRate
From PortfolioProject..CovidDeaths$
group by location, population


------------------------------------------------------------------------------------------------------------------
Create View TotalDeathCount as
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by continent

------------------------------------------------------------------------------------------------------------------
Create View ContinentTotalDeathCount as
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by location


------------------------------------------------------------------------------------------------------------------
Create View CountriesTotalDeathCount as
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by location



------------------------------------------------------------------------------------------------------------------
Create View DeathRate as
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathRate
From PortfolioProject..CovidDeaths$
where location like '%states%'


------------------------------------------------------------------------------------------------------------------
Create View InfectedPercentage as
select location, date, total_cases, population, (total_cases/population) * 100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'