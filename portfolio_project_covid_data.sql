--COVID 19 DATA EXPLORATION

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

--SELECT *
--FROM portfolioproject.dbo.CovidDeaths$ CovidDeaths$
--ORDER BY 3,4

--SELECT * 
--FROM portfolioproject.dbo.CovidVaccinations$ CovidVaccinations$

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM portfolioproject..CovidDeaths$
ORDER BY 1,2

-- total cases vs total deaths
--shows likelyhood dying from covid

SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 AS death_percentage
FROM portfolioproject..CovidDeaths$
Where location like '%malaysia%'
ORDER BY 1,2

--total cases vs population, % of population that got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS population_infected
FROM portfolioproject..CovidDeaths$
Where location like '%malaysia%'
ORDER BY 1,2

--coutries with highest population infection rates

SELECT location,MAX(total_cases) as total_infection, population, Max ((total_cases/population))*100 AS population_infected_percent
FROM portfolioproject..CovidDeaths$
GROUP BY location, population
ORDER BY population_infected_percent desc

--countries with highest death count

SELECT location, MAX (cast (total_deaths as integer)) as total_death_count
FROM portfolioproject..CovidDeaths$
WHERE continent is not null
GROUP BY location
Order by total_death_count desc

-- by continent/ continent with highest death count

SELECT continent, MAX (cast (total_deaths as integer)) as total_death_count
FROM portfolioproject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
Order by total_death_count desc

-- world numbers & percentage

SELECT SUM (new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))
/ SUM (new_cases)* 100 as death_percentage
FROM portfolioproject..CovidDeaths$
--Where location like '%malaysia%'
where continent is not null
--GROUP BY date
Order by 1,2

--total vaccination vs total population

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (cast(vac.new_vaccinations as int)) over (partition by (dea.location) order by dea.location, dea.date) as rolling_vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--use CTE to calculate partition by in previous query
--to calculate percentage of population that receive vaccine

with PopsVac (Continent, Location, Date, Population, New_vaccinations, Rolling_vaccinated)
as 
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (cast(vac.new_vaccinations as int)) over (partition by (dea.location) order by dea.location, dea.date) as rolling_vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
select*, (Rolling_vaccinated/Population)* 100 as PercentPopVac
from PopsVac

-- create view to store data for dataviz

Create View PercentPopVac as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (cast(vac.new_vaccinations as int)) over (partition by (dea.location) order by dea.location, dea.date) as rolling_vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select * 
from PercentPopVac
