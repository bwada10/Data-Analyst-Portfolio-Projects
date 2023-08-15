-- Selecting all the data/columns from CovidDeaths Table:
select *
from [Project Portfolio].dbo.CovidDeaths --".dbo." and ".." are the same
where continent is not null
order by 3,4		-- By Default, the order by sorts the data in ascending order


-- Selecting all the data/columns from CovidVaccinations Table:
select *
from [Project Portfolio]..CovidVaccinations
order by 3,4


-- Selecting specific data from CovidDeaths Table, continents is not null displays countries instead of continents, and order by location and date:
select location, date, total_cases, new_cases, total_deaths, population
from [Project Portfolio]..CovidDeaths
where continent is not null		-- Displays countries instead of continents
order by 1,2


-- Looking at Total Cases vs Total Deaths:
-- Shows the likelihood of death if you contract covid in your country:
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Project Portfolio]..CovidDeaths
where location like '%states%'		-- Only looking for locations that has "states" in the name i.e. "United States"
and continent is not null		-- Displays countries instead of continents
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
group by location, population
order by Percent_Population_Infected desc	-- Order the table by descending order allows the highest Percent_Population_Infected at the top


-- Showing Countries with Highest Death Count per Population
select location, MAX(cast(Total_Deaths as int)) as Total_Death_Count -- Used Cast() function on Total Deaths as Int to display. Issue with data.
from [Project Portfolio]..CovidDeaths
where continent is not null		-- Displays countries instead of continents
group by location
order by Total_Death_Count desc		-- Displays the highest Total_Death_Count at the top


-- Let's break it down by continent:
-- Showing the continents with the highest death count per population:
select continent, MAX(cast(Total_Deaths as int)) as Total_Death_Count -- Used Cast() function on Total Deaths as Int to display. Issue with data.
from [Project Portfolio]..CovidDeaths
where continent is not null		-- Removes NULL Continent from the table
group by continent
order by Total_Death_Count desc


-- Global Numbers:
select SUM(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from [Project Portfolio]..CovidDeaths
where continent is not null
--group by date		-- Need to aggregate the numbers if I choose to "group by date"
order by Total_Cases, Total_Deaths


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated	-- We use PARTITION BY clause to specify the column on which we need to perform aggregation
from [Project Portfolio]..CovidDeaths dea		-- "dea" as an alias for CovidDeaths
Join [Project Portfolio]..CovidVaccinations vac		-- "vac" as an alias for CovidVaccinations
	On dea.location = vac.location		-- Inner Join between CovidDeaths and CovidVaccinations based on matching location and date
	and dea.date = vac.Date
where dea.continent is not null
order by 2,3	


-- Use CTE (Common Table Expression)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)		-- Temporary named result set that I can reference
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.Date
where dea.continent is not null
)
select *, (Rolling_People_Vaccinated/Population)*100 as Vaccinated_Percentage 
from PopvsVac


-- Temp Table
DROP Table if exists #PercentPopulationVaccinated	--Removes Temp Table so there isn't an error of an existing table within database
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


Select *
From PercentPopulationVaccinated
