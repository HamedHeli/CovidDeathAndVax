/*
===========================================
Data Cleaning Portfolio Poject

The project includes the following:
	- Data cleaning and creating a pivot table
	- Defining new metrics and data manipulation for initial data insights
	- Joining two tables to complete the data
	- Creating a CTE
	- Creating a new table from the created CTE
	- Creating a view from CTE


Dat Source: https://ourworldindata.org/covid-deaths
The data are stored in Covid19 database in two tables: 
	1. CovidDeaths: demonstrating the number of people who have died
	2. CovidVax: demonstrating the vaccination progress 
============================================
*/


/*
===========================================
First start with CovidDeaths table 
============================================
*/


Select *
from Covid19..CovidVax
where continent <> ' ' 
order by 3,4

/*
===========================================
Making the pivot table including
Location, population, total cases of covid, and total deaths of covid
===========================================
*/
Select location, population, date, total_cases, total_deaths
from Covid19..CovidDeaths
where continent <> ' ' 
order by 1

/*
===========================================
Defining metric for initial data insights
===========================================
*/

	-- mortality_ratio ( = total_deaths / total_cases)

	Select location, population, date, total_cases, total_deaths, (try_cast(total_deaths as float)/nullif(try_cast(total_cases as float),0))*100 as mortality_rate
	from Covid19..CovidDeaths
	where continent <> ' '  
	order by 1

	--  infection ratio (= total_cases / population)
	
	Select location, population, date, total_cases, total_deaths, (try_cast(total_cases as float)/nullif(try_cast(population as float),0))*100 as infection_ratio
	from Covid19..CovidDeaths
	where continent <> ' ' 
	order by 1

/*
===========================================
Initial data insights
===========================================
*/


	-- countries with the highest number of total_cases 
	select location, population, MAX(cast(total_cases as float)) as max_total_cases, MAX(cast (total_cases as float)/nullif(cast(population as float),0))*100 as max_infection_ratio_percent
	from Covid19..CovidDeaths
	where continent <> ' '  
	group by location, population
	order by 4 desc
	 

	 -- countries with the highest number of total_deaths 
	select location, population, MAX(cast(total_deaths as float)) as max_total_deaths, MAX(cast (total_deaths as float)/nullif(cast(population as float),0))*100 as max_total_deaths_per_population_percent
	from Covid19..CovidDeaths
	where continent <> ' '  
	group by location, population
	order by 4 desc

	-- regions with the highest number of total_deaths
	select Location, MAX(cast(total_deaths as float)) as max_total_deaths, MAX(cast (total_deaths as float)/nullif(cast(population as float),0))*100 as max_total_deaths_per_population_percent
	from Covid19..CovidDeaths
	where continent = ' '  
	group by location
	order by 3 desc

	-- Global data over time
	select date, SUM(cast(total_cases as float)) as total_cases_global, SUM(cast(total_cases as float))/MAX(cast(population as float))*100 as total_cases_per_population_percentage,
	SUM(cast(total_deaths as float)) as total_death_global, SUM(cast(total_deaths as float))/MAX(cast(population as float))*100 as total_death_per_population_global
	FROM Covid19..CovidDeaths
	where continent = ' '  and location = 'World'
	group by date
	order by 1

/*
===========================================
Now we join the information from CovidVax table using two keys
	1. location
	2. date

And then continue deriving initial insights
============================================
*/


	-- Vaccination Per Country

	select dea.continent, dea.location, dea.date, dea.population, vax.people_vaccinated, 
	cast(people_vaccinated as float)/nullif(cast(dea.population as float),0)*100 as percent_of_vaccinated_per_population
	From Covid19..CovidDeaths dea
	Join Covid19..CovidVax vax
	on dea.location = vax.location
	AND dea.date = vax.date 
	order by 2


	
	-- Vaccination in Global

	select dea.continent,  MAX(cast(vax.people_vaccinated as float))/nullif(MAX(cast(dea.population as float)),0)*100 as percent_of_vaccinated_per_population
	From Covid19..CovidDeaths dea
	Join Covid19..CovidVax vax
	on dea.location = vax.location
	AND dea.date = vax.date 
	where dea.continent <> ''
	group by dea.continent

/*
===========================================
Then we make a CTE that includes our selected columns from the table
Later on, we will create a table from this CTE
============================================
*/


	with Population_death_vaccination (location, population, date, new_daths, total_deaths, new_vaccination, total_vaccination, percentage_of_vaccination)
	as
	(
	select dea.location, dea.population, dea.date, dea.new_deaths, dea.total_deaths, vax.new_vaccinations,  
	sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date) as total_vaccination, 
	(sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date)) / nullif(cast (dea.population as float),0)*100 as 
	percentage_of_vaccination
	
	From Covid19..CovidDeaths dea
	Join Covid19..CovidVax vax
	on dea.location = vax.location
	AND dea.date = vax.date 
	where dea.continent <> ''
	)
	select *
	from Population_death_vaccination

	-- creating a table

	drop table if exists PopVsDeathVsVax
	create table PopVsDeathVsVax (
	location nvarchar(225), population nvarchar(225), date date, new_deaths numeric, total_deaths numeric, new_vaccination numeric, total_vaccination numeric, percentage_of_vaccination numeric)

	Insert into PopVsDeathVsVax
	
	select dea.location, dea.population, dea.date, cast(dea.new_deaths as float), cast( dea.total_deaths as float), cast( vax.new_vaccinations as float),  
	sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date) as total_vaccination, 
	(sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date)) / nullif(cast (dea.population as float),0)*100 as 
	percentage_of_vaccination
	
	From Covid19..CovidDeaths dea
	Join Covid19..CovidVax vax
	on dea.location = vax.location
	AND dea.date = vax.date 
	where dea.continent <> ''
	
/*
===========================================
Finally we make a view that includes the information we want to visualize later on
============================================
*/


	-- creating a veiw
	
	
	drop view if exists Population_death_vaccination
	Go
	create view Population_death_vaccination as 
	select dea.location, dea.population, dea.date, cast(vax.new_vaccinations as float) as new_vaccination,  
	sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date) as total_vaccination, 
	(sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date)) / nullif(cast (dea.population as float),0)*100 as 
	percentage_of_vaccination
	
	From Covid19..CovidDeaths dea
	Join Covid19..CovidVax vax
	on dea.location = vax.location
	AND dea.date = vax.date 
	where dea.continent <> ''
