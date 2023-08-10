select *
from [Project Portfolio].dbo.CovidDeaths --".dbo." and ".." are the same
where continent is not null
order by 3,4

--select *
--from [Project Portfolio]..CovidVaccinations
--order by 3,4

-- Selecting the Data that we are going to be using:

select location, date, total_cases, new_cases, total_deaths, population
from [Project Portfolio]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths:
-- Shows the likelihood of death if you contract covid in your country:

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Project Portfolio]..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population:
-- Shows the percentage of population contracted Covid

select location, date, population, total_cases, (total_cases/population)*100 as Percent_Population_Infected
from [Project Portfolio]..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population:

select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
from [Project Portfolio]..CovidDeaths
--where location like '%states%'
group by location, population
order by Percent_Population_Infected desc

-- Showing Countires with Highest Death Count per Population

select location, MAX(cast(Total_Deaths as int)) as Total_Death_Count -- Used Cast() function on Total Deaths as Int to display. Issue with data.
from [Project Portfolio]..CovidDeaths
--where location like '%states%'
where continent is not null		-- Displays countries instead of continents
group by location
order by Total_Death_Count desc 


-- Let's break it down by continent:

 
-- Showing the continents with the highest death count per population:

select continent, MAX(cast(Total_Deaths as int)) as Total_Death_Count -- Used Cast() function on Total Deaths as Int to display. Issue with data.
from [Project Portfolio]..CovidDeaths
--where location like '%states%'
where continent is not null		
group by continent
order by Total_Death_Count desc


-- Global Numbers:

select SUM(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from [Project Portfolio]..CovidDeaths
where continent is not null
--group by date		-- Need to aggregate the numbers if I choose to "group by date"
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.Date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.Date
where dea.continent is not null
--order by 2,3
)
select *, (Rolling_People_Vaccinated/Population)*100 as Vaccinated_Percentage 
from PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated	--Removes Temp Table so there isn't an error
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.Date
where dea.continent is not null
--order by 2,3

select *, (Rolling_People_Vaccinated/Population)*100 as Vaccinated_Percentage 
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.Date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated