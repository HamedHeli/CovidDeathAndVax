Select *
from PortfolioProject..CovidDeaths
where continent <> ' ' 
order by 3,4


-- Making the pivot table

Select location, population, date, total_cases, total_deaths
from PortfolioProject..CovidDeaths
where continent <> ' ' 
order by 1

	-- finding the mortality_ratio ( = total_deaths / total_cases)

	Select location, population, date, total_cases, total_deaths, (try_cast(total_deaths as float)/nullif(try_cast(total_cases as float),0))*100 as mortality_rate
	from PortfolioProject..CovidDeaths
	where continent <> ' '  
	order by 1

	-- finding the cases_population (= total_cases / population)
	
	Select location, population, date, total_cases, total_deaths, (try_cast(total_cases as float)/nullif(try_cast(population as float),0))*100 as cases_per_population
	from PortfolioProject..CovidDeaths
	where continent <> ' ' 
	order by 1


	-- countries with the highest number of total_cases 
	select location, population, MAX(cast(total_cases as float)) as max_total_cases, MAX(cast (total_cases as float)/nullif(cast(population as float),0))*100 as max_total_cases_per_population_percent
	from PortfolioProject..CovidDeaths
	where continent <> ' '  
	group by location, population
	order by 4 desc
	 

	 -- countries with the highest number of total_deaths 
	select location, population, MAX(cast(total_deaths as float)) as max_total_deaths, MAX(cast (total_deaths as float)/nullif(cast(population as float),0))*100 as max_total_deaths_per_population_percent
	from PortfolioProject..CovidDeaths
	where continent <> ' '  
	group by location, population
	order by 3 desc

	-- continents with the highest number of total_deaths
	select Location, MAX(cast(total_deaths as float)) as max_total_deaths, MAX(cast (total_deaths as float)/nullif(cast(population as float),0))*100 as max_total_deaths_per_population_percent
	from PortfolioProject..CovidDeaths
	where continent = ' '  
	group by location
	order by 2 desc

	-- Global data
	select date, SUM(cast(new_cases as float)) as total_death_global, SUM(cast(new_cases as float))/SUM(cast(population as float)) as total_death_per_population_global
	from PortfolioProject..CovidDeaths
	where continent <> ' '  
	group by date
	order by 1

	-- Vaccination Per Country

	select dea.continent, dea.location, dea.date, dea.population, vax.people_vaccinated, 
	cast(people_vaccinated as float)/nullif(cast(dea.population as float),0)*100 as percent_of_vaccinated_per_population
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	AND dea.date = vax.date 


	
	-- Vaccination in Global

	select dea.continent,  MAX(cast(vax.people_vaccinated as float))/nullif(MAX(cast(dea.population as float)),0)*100 as percent_of_vaccinated_per_population
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	AND dea.date = vax.date 
	where dea.continent <> ''
	group by dea.continent

	-- Vaccination in Global_another way

	--- CTE
	with PopulationVsVaccination (location, population, date, new_vaccination, total_vaccination, percentage_of_vaccination)
	as
	(
	select dea.location, dea.population, dea.date, vax.new_vaccinations,  
	sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date) as total_vaccination, 
	(sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date)) / nullif(cast (dea.population as float),0)*100 as 
	percentage_of_vaccination
	
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	AND dea.date = vax.date 
	where dea.continent <> ''
	)
	select *
	from PopulationVsVaccination

	-- ctreating a table

	drop table if exists PopVsVax
	create table PopVsVax (
	location nvarchar(225), population nvarchar(225), date date, new_vaccination numeric, total_vaccination numeric, percentage_of_vaccination numeric)

	Insert into PopVsVax
	select dea.location, dea.population, dea.date, cast(vax.new_vaccinations as float),  
	sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date) as total_vaccination, 
	(sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date)) / nullif(cast (dea.population as float),0)*100 as 
	percentage_of_vaccination
	
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	AND dea.date = vax.date 
	where dea.continent <> ''
	
	SELECT *
	From PortfolioProject..PopVsVax


	-- creating a veiw

	create view PopVsVaxView as 
	select dea.location, dea.population, dea.date, cast(vax.new_vaccinations as float) as new_vaccination,  
	sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date) as total_vaccination, 
	(sum (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date)) / nullif(cast (dea.population as float),0)*100 as 
	percentage_of_vaccination
	
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	AND dea.date = vax.date 
	where dea.continent <> ''