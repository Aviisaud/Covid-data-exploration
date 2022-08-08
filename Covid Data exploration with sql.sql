select *
from CovidDeaths

--death percentage

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage
from CovidDeaths
order by 1

--looking at total cases vs population
select location,date,total_cases,population,(total_cases/population)*100 as total_case_percentage
from CovidDeaths
where continent is not null
order by 5 desc;

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as max_cases, max(total_cases/population)*100 as total_cases_percentage
from CovidDeaths
where continent is not null
group by location,population
order by 1


--showing the countries with highest death count 

select location, max(convert(bigint,total_deaths)) as Total_Death_counts
from CovidDeaths
where continent is not null
--where location like '%India%'
group by location
order by Total_Death_counts desc;

--highest death in every continent

select continent,max(cast(total_deaths as int)) as total_death_counts
from CovidDeaths
where continent is not null
group by continent
order by 2 desc

--Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage
from CovidDeaths
where continent is not null
group by date
order by 1;

--joining two tables

select cod.continent, cod.location, cod.date, cod.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by cod.location order by cod.location , cod.date) as total_vaccination
from CovidDeaths as cod
join Vaccination as vac
on cod.location=vac.location and 
   cod.date=vac.date
where cod.continent is not null 
--and cod.location like '%India%'
order by 2,3;

--use a CTE in a CREATE a view, as part of the view's SELECT query.

with vacpop (continent, location, date, population, new_vaccinations , total_vaccination)
as 
(
select cod.continent, cod.location, cod.date, cod.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by cod.location order by cod.location, cod.date) as total_vaccination
from CovidDeaths cod
join Vaccination vac
on cod.location=vac.location and 
   cod.date=vac.date
where cod.continent is not null 
)
select location, max(total_vaccination/population)*100 as vaccination_population
from vacpop
group by location
order by vaccination_population
--139.190992659784


--Temp table

drop table if exists ppvac
create table ppvac
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
total_vaccination numeric
)

insert into ppvac 

select cod.continent, cod.location, cod.date, cod.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by cod.location order by cod.location, cod.date) as total_vaccination
from CovidDeaths cod
join Vaccination vac
on cod.location=vac.location and 
   cod.date=vac.date
where cod.continent is not null 

select location, max(total_vaccination/population)*100 as vaccination_population
from ppvac
group by location
order by vaccination_population


--Creating View to store data for later

create view total_vaccinated as
select cod.continent, cod.location, cod.date, cod.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by cod.location order by cod.location , cod.date) as total_vaccination
from CovidDeaths as cod
join Vaccination as vac
on cod.location=vac.location and 
   cod.date=vac.date
where cod.continent is not null 