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


Data Source: https://ourworldindata.org/covid-deaths
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


SELECT 
	*
FROM 
	Covid19..CovidVax
WHERE 
	continent <> ' ' 
ORDER BY
	3,4

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

SELECT 
	location, 
	population, 
	date, 
	total_cases, 
	total_deaths, 
	(try_cast(total_deaths as float)/nullif(try_cast(total_cases as float),0))*100 as mortality_rate
FROM 
	Covid19..CovidDeaths
WHERE 
	continent <> ' '  
ORDER BY
	1

	--  infection ratio (= total_cases / population)
	
SELECT 
	location, 
	population, 
	date, 
	total_cases, 
	total_deaths, 
	(try_cast(total_cases as float)/nullif(try_cast(population as float),0))*100 AS infection_ratio
FROM 
	Covid19..CovidDeaths
WHERE 
	continent <> ' ' 
ORDER BY 
	1

/*
===========================================
Initial data insights
===========================================
*/


	-- countries with the highest number of total_cases 
SELECT 
	location, 
	population, 
	MAX(cast(total_cases as float)) AS max_total_cases, 
	MAX(cast (total_cases as float)/nullif(cast(population as float),0))*100 AS max_infection_ratio_percent
FROM 
	Covid19..CovidDeaths
WHERE 
	continent <> ' '  
GROUO BY 
	location, 
	population
ORDER BY 
	4 desc
	 

	 -- countries with the highest number of total_deaths 
SELECT 
	location, 
	population, 
	MAX(cast(total_deaths as float)) AS max_total_deaths, 
	MAX(cast (total_deaths as float)/nullif(cast(population as float),0))*100 AS max_total_deaths_per_population_percent
FROM 
	Covid19..CovidDeaths
WHERE 
	continent <> ' '  
GROUP BY 
	location, 
	population
ORDER BY 
	4 desc

	-- regions with the highest number of total_deaths
SELECT 
	Location, 
	MAX(cast(total_deaths as float)) AS max_total_deaths, 
	MAX(cast (total_deaths as float)/NULLIF(CAST(population AS float),0))*100 AS max_total_deaths_per_population_percent
FROM 
	Covid19..CovidDeaths
WHERE 
	continent = ' '  
GROUP BY 
	location
ORDER BY 
	3 desc

	-- Global data over time
SELECT 
	date, 
	SUM(cast(total_cases as float)) as total_cases_global, 
	SUM(cast(total_cases as float))/MAX(cast(population as float))*100 as total_cases_per_population_percentage,
	SUM(cast(total_deaths as float)) as total_death_global, SUM(cast(total_deaths as float))/MAX(cast(population as float))*100 as total_death_per_population_global
FROM 	
	Covid19..CovidDeaths
WHERE 
	continent = ' '  and location = 'World'
GROUP BY 
	date
ORDER BY 
	1

/*
===========================================
Now we join the information from CovidVax table using two keys
	1. location
	2. date

And then continue deriving initial insights
============================================
*/


	-- Vaccination Per Country

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vax.people_vaccinated, 
	CAST(people_vaccinated as float)/nullif(cast(dea.population as float),0)*100 AS percent_of_vaccinated_per_population
FROM 
	Covid19..CovidDeaths dea
JOIN 
	Covid19..CovidVax vax
ON
	dea.location = vax.location
AND 
	dea.date = vax.date 
ORDER BY 
	2


	
	-- Vaccination in Global

SELECT 
	dea.continent,  
	MAX(cast(vax.people_vaccinated as float))/nullif(MAX(cast(dea.population as float)),0)*100 as percent_of_vaccinated_per_population
FROM 
	Covid19..CovidDeaths dea
JOIN 
	Covid19..CovidVax vax
ON 
	dea.location = vax.location
AND 
	dea.date = vax.date 
WHERE 
	dea.continent <> ''
GROUP BY 
	dea.continent

/*
===========================================
Then we make a CTE that includes our selected columns from the table
Later on, we will create a table from this CTE
============================================
*/


WITH Population_death_vaccination (location, population, date, new_daths, total_deaths, new_vaccination, total_vaccination, percentage_of_vaccination)
	AS
	(
SELECT 
	dea.location, 
	dea.population, 
	dea.date, 
	dea.new_deaths, 
	dea.total_deaths, 
	vax.new_vaccinations,  
	SUM (cast (vax.new_vaccinations as float)) OVER (partition by dea.location order by dea.location,  dea.date) AS total_vaccination, 
	(SUM (cast (vax.new_vaccinations as float)) OVER (partition by dea.location order by dea.location,  dea.date)) / nullif(cast (dea.population as float),0)*100 AS percentage_of_vaccination
FROM 
	Covid19..CovidDeaths dea
JOIN 
	Covid19..CovidVax vax
ON 
	dea.location = vax.location
AND 
	dea.date = vax.date 
WHERE 
	dea.continent <> ''
	
	)
	
SELECT 
	*
FROM 
	Population_death_vaccination

	-- creating a table

DROP TABLE IF EXISTS PopVsDeathVsVax

CREATE TABLE 
	
	PopVsDeathVsVax (
	location nvarchar(225), 
	population nvarchar(225), 
	date date, 
	new_deaths numeric, 
	total_deaths numeric, 
	new_vaccination numeric, 
	total_vaccination numeric, 
	percentage_of_vaccination numeric)

INSERT INTO 
	PopVsDeathVsVax
	
SELECT 
	dea.location, 
	dea.population, 
	dea.date, 
	CAST(dea.new_deaths as float), 
	CAST( dea.total_deaths as float), 
	CAST( vax.new_vaccinations as float),  
	SUM (cast (vax.new_vaccinations as float)) OVER (partition by dea.location order by dea.location,  dea.date) AS total_vaccination, 
	(SUM (cast (vax.new_vaccinations as float)) OVER (partition by dea.location order by dea.location,  dea.date)) / nullif(cast (dea.population as float),0)*100 AS 
	percentage_of_vaccination
	
FROM 
	Covid19..CovidDeaths dea
JOIN 
	Covid19..CovidVax vax
ON 
	dea.location = vax.location
AND 
	dea.date = vax.date 
WHERE 
	dea.continent <> ''
	
/*
===========================================
Finally we make a view that includes the information we want to visualize later on
============================================
*/


	-- creating a veiw
	
	
DROP VIEW IF EXISTS Population_death_vaccination
	
GO
CREATE VIEW 
	Population_death_vaccination AS 
	
	SELECT 
		dea.location, 
		dea.population, 
		dea.date, 
		CAST(vax.new_vaccinations as float) AS new_vaccination,  
		SUM (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date) as total_vaccination, 
		(SUM (cast (vax.new_vaccinations as float)) over (partition by dea.location order by dea.location,  dea.date)) / nullif(cast (dea.population as float),0)*100 as percentage_of_vaccination
	
	FROM 
		Covid19..CovidDeaths AS dea
	JOIN 
		Covid19..CovidVax AS vax
	ON 
		dea.location = vax.location
	AND 
		dea.date = vax.date 
	WHERE 
		dea.continent <> ''
