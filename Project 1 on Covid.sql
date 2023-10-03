
SELECT * FROM covid_deaths
order by 3,4;
Select * from covid_vaccinations
order by 3,4;

desc covid_deaths;  
-- describe  the tables 

Select location,date,total_cases,new_cases, total_deaths,population
from covid_deaths
order by location,date;

-- looking at total cases vs total deaths
-- likelihood of dying in a country if you get in contact with covid 

Select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_percentage
from covid_deaths
where location like '%states%'
order by location,date;

-- Total cases vs population 
-- percentage of people contacting covid in a country at a given day

Select location,date, population,total_cases,(total_cases/population)*100 as percentpopulationinfected
from covid_deaths
-- where location like '%states%'
order by location,date;

-- Countries with highest infection rate w.r.t population
Select location, population, max(total_cases) as Highestinfectioncount,Max((total_cases/population))*100 as percentpopulationinfected
from covid_deaths
-- where location like '%states%'
group by location,population
order by percentpopulationinfected desc;


-- infection rate w.r.t population for India and USA

Select location, population, max(total_cases) as Highestinfectioncount,Max((total_cases/population))*100 as percentpopulationinfected
from covid_deaths
where location in ('India','United States')
-- where location like '%states%'
group by location,population;

-- countries with highest death count per poplation as per location

Select location, max(total_deaths) as TotalDeathcount
from covid_deaths
-- where location like '%states%'
where continent != ("") -- (removing grouped data like asia,europe,africa which are continent
                            --  and not a country/location)
group by location
order by TotalDeathcount desc; 



-- lets break things down by continent
-- showing continents with highest death count  per population 


Select continent, max(total_deaths) as TotalDeathcount
from covid_deaths
-- where location like '%states%'
where continent != ("") -- (removing grouped data like asia,europe,africa which are continent
                            --  and not a country/location)
group by continent
order by TotalDeathcount desc; 

--  Global numbers
-- deaths percentage wrt to new cases

Select date,sum(new_cases) as total_cases ,sum(new_deaths) as total_deaths,sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from covid_deaths
-- where location like '%states%'
where continent != ("")
group by date
order by 1,2;  

-- total deaths percentage wrt to new cases

Select sum(new_cases) as total_cases ,sum(new_deaths) as total_deaths,sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from covid_deaths
-- where location like '%states%'
where continent != (""); 

--  using 2nd table for exploration of data
-- Looking at total population vs vaccinated population
-- (partition by)

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingpopulationvaccinated
-- rollingpopulationvaccinated/population * 100
from covid_deaths dea
join covid_vaccinations vac using (location,date)
where dea.continent !=('')
order by 2,3; 
 
-- using cte 

with popvsvac as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingpopulationvaccinated
-- rollingpopulationvaccinated/population * 100
from covid_deaths dea
join covid_vaccinations vac using (location,date)
where dea.continent !=('')
order by 2,3
 )
 select *,(rollingpopulationvaccinated/population)*100 
 from popvsvac; 
 
 -- temp table
 /*
 Create temporary table percentpopulationvaccinated(
 continent varchar(255),
 location varchar(255),
 date datetime,
population int,
new_vaccinations int,
rollinpopulationvaccinated decimal(6,4)
); 
 
 insert into percentpopulationvaccinated 
 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingpopulationvaccinated
-- rollingpopulationvaccinated/population * 100
from covid_deaths dea
join covid_vaccinations vac using (location,date)
where dea.continent !=('')
order by 2,3
  
 */
Drop table if exists percentpopulationvaccinated;

Create table percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingpopulationvaccinated
-- rollingpopulationvaccinated/population * 100
from covid_deaths dea
join covid_vaccinations vac using (location,date)
where dea.continent !=('')
order by 2,3;
  
 select *,(rollingpopulationvaccinated/population)*100 
 from percentpopulationvaccinated; 

-- creating view to stode data fro later visualizations

create view percentpopulationvaccinated_1 as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingpopulationvaccinated
-- rollingpopulationvaccinated/population * 100
from covid_deaths dea
join covid_vaccinations vac using (location,date)
where dea.continent !=('')
order by 2,3;

SELECT * FROM covid.percentpopulationvaccinated_1
limit 100;


-- queries for visulaizations
-- 1st

Select sum(new_cases) as total_cases ,sum(new_deaths) as total_deaths,sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from covid_deaths
-- where location like '%states%'
where continent != ("")
-- group by date
order by 1,2;  

-- 2nd (Death continent wise)

Select location, sum(new_deaths) as TotalDeathcount
from covid_deaths
-- where location like '%states%'
where continent = ("") and location not in ('World','European Union','International')
 -- (removing grouped data like asia,europe,africa which are continent
                            --  and not a country/location)
group by location
order by TotalDeathcount desc; 


-- 3rd
Select location, population, max(total_cases) as Highestinfectioncount,Max((total_cases/population))*100 as percentpopulationinfected
from covid_deaths
-- where location like '%states%'
group by location,population
order by percentpopulationinfected desc;

-- 4th
Select location, population,date, max(total_cases) as Highestinfectioncount,Max((total_cases/population))*100 as percentpopulationinfected
from covid_deaths
-- where location like '%states%'
group by location,population,date
order by percentpopulationinfected desc;
