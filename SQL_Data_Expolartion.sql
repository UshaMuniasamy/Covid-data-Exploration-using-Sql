
select * 
from PortfolioProject..[Covid-data]

--select *
--from PortfolioProject..[covid-vaccination]


-- here using orderby clauses
select *
from PortfolioProject..[Covid-data]
where continent is not NULL
order by 3,4


---- select data thet we are using to be  selective information like only view the data date, populatio etc,.
select location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject..[Covid-data]
where continent is not NULL
order by 1,2

--looking at total cases vs total deaths
-- shows likelihood  of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[Covid-data]
where location like '%india'
order by 1,2

--looking at total cases vs population
-- shows what percent of population got covid
select location, date, population, total_cases,  (total_cases/population)*100 as DeathPercentage
from PortfolioProject..[Covid-data]
where location like '%india'
order by 1,2


--Looking at countries with Highest Infection rate compared to population (highest -MAX())
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100as PercentPopulationInfected
from PortfolioProject..[Covid-data]
Group by location, population
--where location like '%India%'
order by 1,2 desc

--Showing countries  with Highest Death Count per Population

select location, MAX(cast(Total_deaths as int))as TotalDeathCount
from PortfolioProject..[Covid-data]
--where location like '%India'
where continent is not NULL
group by location
order by TotalDeathCount desc



--LET'S BREAK THING DOWN  BY CONTINENT
select continent, MAX(cast(Total_deaths as int))as TotalDeathCount
from PortfolioProject..[Covid-data]
--where location like '%India'
where continent is not NULL
group by continent
order by TotalDeathCount desc

select location, MAX(cast(Total_deaths as int))as TotalDeathCount
from PortfolioProject..[Covid-data]
--where location like '%India'
where continent is  NULL
group by location
order by TotalDeathCount desc

--showing continents with the highest death count per population
select continent, MAX(cast(Total_deaths as int))as TotalDeathCount
from PortfolioProject..[Covid-data]
--where location like '%India'
where continent is not NULL
group by continent
order by TotalDeathCount desc


--Global Number
select   sum(new_cases) as total_New_Cases, sum(cast(new_deaths as int))as total_new_deaths, (sum(cast(new_deaths as int))/ sum(new_cases))*100 as DeathPercentage 
from PortfolioProject..[Covid-data]
where  continent is not null
--group by date
order by 1,2 



--- join two tables in one sheet

select*
from PortfolioProject..[Covid-data] dea
join PortfolioProject..[covid-vaccination] vac
on dea.location = vac.location
and dea.date = vac.date


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..[Covid-data]  dea
join PortfolioProject..[covid-vaccination]  vac
on dea.location = vac.location
and dea.date = dea.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
with PopvsVac (continent, location, new_vaccinations, date, population, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..[Covid-data]  dea
join PortfolioProject..[covid-vaccination]  vac
on dea.location = vac.location
and dea.date = dea.date
where dea.continent is not null
--order by 2,3
)
select* , (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table   #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated   
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into  #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..[Covid-data]  dea
join PortfolioProject..[covid-vaccination]  vac
on dea.location = vac.location
and dea.date = dea.date
where dea.continent is not null
--order by 2,3
select* , (RollingPeopleVaccinated/population)*100
from  #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated1 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..[Covid-data]  dea
join PortfolioProject..[covid-vaccination]  vac
on dea.location = vac.location
and dea.date = dea.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated