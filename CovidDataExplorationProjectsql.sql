
Select top 10 * from CovidDeaths
order by location, date

Select top 10 * from CovidVaccinations
order by 3,4


-- Select the columns to be used for now 

Select location, date, new_cases, total_cases, total_deaths, population
From CovidDeaths
Order by location, date


-- Counting data raws 
Select Count(*) dataCount
From CovidDeaths 

-->> Total raws = 218202 by the date : 22/09/2022


-- Total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_of_deaths
From CovidDeaths
where total_deaths is not null
and continent is not null 
--and location like 'Morocco'
Order by 2
 
-->> First reported deaths in the world was in china at 22-01-2020 With a percentage of 3.10
-->> First reported death in Morocco was at 10-03-2020 With a percentage of 33.3


-- total cases vs the population 

Select location, date, total_cases, population, (total_cases/population)*100 as percentage_of_infection
From CovidDeaths
Order by 1, 2

-- Looking for Countries with highest infection rate compared to population

Select location, population, Max(total_cases) as maxTotalCases , Max(total_cases/population)*100 as infectionRate
From CovidDeaths
where continent is not null
group by location, population
order by infectionRate desc

-->> Faeroe Islands records the Highest infection rate that is = 65.53%

-- Looking for Countries with highest death count per population

Select location, Max(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

-->> The United States records the Highest Death Count that is = 1.055.195


-- Looking for Continents with highest death count per population

Select location, Max(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc;

------------ separeting only real continents using ctes
--with cte as 
--(
--Select continent ,location, Max(cast(total_deaths as int)) as HighestDeathCount
--From CovidDeaths
--where continent is not null
--group by location, continent
--)

--select continent, Sum(HighestDeathCount) as HighestDeathCountByContinent
--from cte 
--group by continent
--order by HighestDeathCountByContinent desc


-- Looking at Vaccinations

Select Deaths.location, Deaths.date, new_vaccinations
From CovidDeaths Deaths
Join CovidVaccinations Vaccinations
	On Deaths.location = Vaccinations.location
	and Deaths.date = Vaccinations.date
Where Deaths.continent is not null
order by location, date

-- Total Vaccinations vs Population

Select Deaths.location, population, total_vaccinations, (total_vaccinations/population) VaccinationRate
From CovidDeaths Deaths
Join CovidVaccinations Vaccinations
	On Deaths.location = Vaccinations.location
	and Deaths.date = Vaccinations.date
Where Deaths.continent is not null
and total_vaccinations is not null
order by location

-- Using only new_vaccinations and Temp Tables

Drop table if exists #VaccinatedPoepleRate

Create table #VaccinatedPoepleRate(
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
totalPeopleVaccinated numeric
)

Insert into #VaccinatedPoepleRate
Select Vaccinations.location, Vaccinations.date, population, new_vaccinations, 
sum(cast(new_vaccinations as numeric)) over (Partition by Vaccinations.location order by Vaccinations.location, cast(Vaccinations.date as date))
From CovidDeaths Deaths
Join CovidVaccinations Vaccinations
	On Deaths.location = Vaccinations.location
	and Deaths.date = Vaccinations.date
Where Vaccinations.continent is not null


select *, (totalPeopleVaccinated/population) as VaccinatedPoepleRate
from #VaccinatedPoepleRate