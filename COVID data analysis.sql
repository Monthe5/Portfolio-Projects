 --To select specific columns of the data for a particular country
Select location, date, total_cases, total_deaths
from PortfolioProject ..CovidDeaths
where location like '%Kenya%'

--To show what percentage of the population has gotten COVID
Select location, date, total_cases, population, (total_cases/population)*100 as PercentageCovidCases
from PortfolioProject ..CovidDeaths

-- Where location like '%Kenya%' (Using this command, it is possible to find information for a specific country)


--To assess which countries have the highest infection rates proportional to their population
Select location, Max(total_cases) as HighestCasesReported, population, (Max(total_cases)/population) as PopulationInfectionRate
from PortfolioProject ..CovidDeaths
Group by location, population
--To order them in descending order that is the highest infection rate proportional to the population being at the highest
Order by PopulationInfectionRate desc


--To assess which countries have the highest COVID related death count
select location, Max(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
--the previous command removes the data where the location is listed as a continent and not a country
group by location
order by DeathCount desc

--To evaluate which country has the highest COVID related deaths proportional to the population
Select location, Max(cast(total_deaths as int)) as HighestDeathsReported, population, (Max(cast(total_deaths as int))/population) as PopulationDeathRate
from PortfolioProject ..CovidDeaths
Group by location, population
--To order them in descending order that is the highest infection rate proportional to the population being at the highest
Order by PopulationDeathRate desc



--EVALUATING BY CONTINETNS

--To assess which continents had the highest COVID related deaths
select location, max(cast(total_deaths as int)) as DeathCount
from PortfolioProject ..CovidDeaths
where continent is null
group by location
order by DeathCount desc


--FOR GLOBAL INFORMATION
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentageDeaths
From PortfolioProject ..CovidDeaths
where continent is null


--To join the CovidDeaths and CovidVaccines tables
Select *
from PortfolioProject..CovidDeaths as dea
join PortfolioProject ..CovidVaccines as vac
	on dea.location = vac.location
	and dea.date = vac.date


--Evaluating the number of people vaccinated globally
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths as dea
join PortfolioProject ..CovidVaccines as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


--To assess the percentage of the population is fully vaccinated
Select dea.location, dea.date, vac.people_fully_vaccinated, dea.population, 
(vac.people_fully_vaccinated/dea. population)*100 as PercentagePopFullyVaccinated
from PortfolioProject..CovidVaccines as vac
join PortfolioProject..CovidDeaths as dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 5 desc


--finding the total number of vaccination in every country
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int))
OVER (Partition by  dea.location order by dea.location, dea.date) as CummulativeTotalVaccines
from PortfolioProject..CovidDeaths as dea
join PortfolioProject ..CovidVaccines as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--(and dea.location like '%Kenya%')--it is possible to choose which country's information should be displayed using this command


--To use the created coulumn of CummulativeTotalVaccines in order to evaluate the percentage of people vaccinated in various
--countries, use a CTE or temp table.

--USING CTE
With VacvsPop (Continent, Location, Date, Population, New_vaccinations, CummulativeTotalVaccines)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int))
OVER (Partition by  dea.location order by dea.location, dea.date) as CummulativeTotalVaccines
from PortfolioProject..CovidDeaths as dea
join PortfolioProject ..CovidVaccines as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *,(CummulativeTotalVaccines/Population)*100 as PercentageofPopVaccinated
from VacvsPop 


--using temp table
Drop table if exists #PercentagePopulationVaccinated
--To fix the "There is already an object named '#PercentagePopulationVaccinated' in the database." error, use the command above
Create table #PercentagePopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CummulativeTotalVaccines numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint))
OVER (Partition by  dea.location order by dea.location, dea.date) as CummulativeTotalVaccines
--converting the new_vaccinations to int was bringing about the "Arithmetic overflow error converting expression to data type int." error. 
--to fix this cast as bigint instead of int
from PortfolioProject..CovidDeaths as dea
join PortfolioProject ..CovidVaccines as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *,(CummulativeTotalVaccines/Population)*100 as PercentageofPopVaccinated
from #PercentagePopulationVaccinated


--CREATING VIEWS FOR VISUALIZATION

Create View PopulationWithCovid as
Select location, date, total_cases, population, (total_cases/population)*100 as PercentageCovidCases
from PortfolioProject ..CovidDeaths

Create View DeathRate as
Select location, Max(cast(total_deaths as int)) as HighestDeathsReported, population, (Max(cast(total_deaths as int))/population) as PopulationDeathRate
from PortfolioProject ..CovidDeaths
Group by location, population