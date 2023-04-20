create view covid death
as
select *
from [covid-death$']
where continent is not null
--order by 3,4

--select *
--from ['covid vaccinations$']
--order by 3,4
--select columns for covid deaths
create view covid_death_column
as
select location,date,total_cases,new_cases,total_deaths,population
from [covid-death$']
--order by 1,2
--total cases vs total deaths

Create procedure total_deaths_tablee
create view total_death
as
select location, date, total_cases, total_deaths
from [covid-death$']
where total_deaths is not null and continent is not null
--order by 1,2


-- total cases that resulted in death in %
create view death_cases
as
select continent, date, total_cases, total_deaths, (total_deaths/cast(total_cases as float))* 100 as death_percentage
from [covid-death$']
where continent is not null

--order by 1,2
-- % of cases that resulted in death in africa
create view covid_death_africa
as
select location, date, total_cases, total_deaths, (total_deaths/cast(total_cases as float))* 100 as death_percentage
from [covid-death$']
where location like '%africa%' and continent is not null
--order by 1,2

-- % of the population that contracted covid
create view count_covid_africa
as
select location, date, total_cases,population, (cast(total_cases as float)/population)* 100 as totalcase_percentage
from [covid-death$']
where location like '%africa%' and continent is not null
--order by 1,2
--countries with the highest covid infection
create view high_covid_country
as
select continent,population, max(total_cases) total , max(cast(total_cases as float)/population)* 100 as totalcase_percentage
from [covid-death$']
where continent is not null
group by continent,population
--order by  4 desc

--% of people that died per population
create view death_per_population
as
select continent,population, max(cast(total_deaths as int)) total , max(cast(total_deaths as float)/population)* 100 as totaldeaths_percentage
from [covid-death$']
where continent is not null
group by continent,population
--order by  3 desc
-- % of people that died per continent
create view death_per_continent
as
select continent, max(cast(total_deaths as int)) total , max(cast(total_deaths as float)/population)* 100 as totaldeaths_percentage
from [covid-death$']
where continent is not null
group by continent
--order by  2 desc
-- % of people that died per continent per population
create view cont_per_population
as
select continent, population, max(cast(total_deaths as int)) total , max(cast(total_deaths as float)/population)* 100 as totaldeaths_percentage
from [covid-death$']
where continent is not null
group by continent, population
--order by  3 desc
-- global numbers of deaths and cases
select sum(cast(new_cases as int)) as total_new_cases,sum(cast(new_deaths as int)) as total_new_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float)) ratio
from [covid-death$']
where continent is not null and new_deaths is not null and new_cases is not null

-- create procedure, join the covid death and covid vaccinations table to see the total population vs vacciantions

with popvac (continent,location,date,population,new_vaccinations,cummulative_new_vaccination)
as
(
select die.continent,die.location, die.date,die.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by die.location order by die.location, die. date) cummulative_new_vaccination 
from [covid-death$'] as die
join ['covid vaccinations$'] vac
	on die.location = vac.location
	and die.date = die.date
where die.continent is not null and die.location is not null and die.date is not null
      and die.population is not null and vac.new_vaccinations is not null

)
select continent,location,population,new_vaccinations,cummulative_new_vaccination,(cummulative_new_vaccination/population)* 100 as vaccinated_per_pop
from popvac

--exec popvac
--create temp table
drop table if exists #have_vaccinated
create table #have_vaccinated
(
continent nvarchar(100),
location nvarchar(100),
date datetime, 
population int,
new_vaccinations float,
cummulative_new_vaccination float,
)

insert into #have_vaccinated

select die.continent,die.location, die.date,die.population,vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by die.location order by die.location,die.date) as cummulative_new_vaccination
from [covid-death$'] as die
join ['covid vaccinations$'] vac
	on die.location = vac.location
	and die.date = die.date
where die.continent is not null and die.location is not null and die.date is not null
      and die.population is not null and vac.new_vaccinations is not null


select continent,location,date ,population,new_vaccinations,cummulative_new_vaccination,(cummulative_new_vaccination/population)* 100 as vaccinated_per_pop
from #have_vaccinated



-- create view to store data for visualizations
CREATE VIEW have_vaccinated
as
select die.continent,die.location, die.date,die.population,vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by die.location order by die.location,die.date) as cummulative_new_vaccination
from [covid-death$'] as die
join ['covid vaccinations$'] vac
	on die.location = vac.location
	and die.date = die.date
where die.continent is not null and die.location is not null and die.date is not null
      and die.population is not null and vac.new_vaccinations is not null
-- create view of the population that are vaccinated
create view pop_vac_table
as
select continent,location,date ,population,new_vaccinations,cummulative_new_vaccination,(cummulative_new_vaccination/population)* 100 as vaccinated_per_pop
from have_vaccinated




















