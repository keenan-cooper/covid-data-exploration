# Covid-19 Data Exploration
#### _SQL and Data Visualization with Tableau and Power BI Project - Part 1_
## Table of Contents

1. [Project Overview](#project)
2. [Process](#process)
3. [Project Movtivation](#motivation)

### 1. Project Overview<a id="project"></a>
This project has two parts to demonstrate the type of queries possible with SQL and then, in the second part of the project, how the data can be visualized in Tableau and Power BI. 

### 2. Process<a id="process"></a>
- Data was downloaded from [_Our World in Data_](https://ourworldindata.org/covid-deaths) on July 12, 2022. 
- The data set was modified (deleted columns) and split into two files: _CovidDeaths.csv_ and _CovidVaccinations.csIv_. 
- Primary key fields were kept between the two datasets (location, date, continent, etc) in order to properly perform joins during the SQL data exploration process. However, data not related to deaths or vaccinations were left out of each respective file. 
- Each dataset was loaded into Microsoft SQL Server Management Studio.
- Performed various queries that will then form the basis of the data used in the visualizations.
- Visualizations to be shared on my personal tableau and Power BI accounts. 

### 3. Project Motivation<a id="motivation"></a>
- I've used the dashboards and data on the Our World in Data website but never tried playing with the data myself. I thought I should remedy that asap. Plus I could configure some queries to focus on Canada (my home country) and Japan (my place of residence). It was interesting exploring the data even in a SQL table.
- These projects -- this SQL project then the tableau and Power BI dashboard -- will form a part of my portfolio and with aim to demonstate to future employers my ability and potential. It was good practice to apply what I've learned through Datacamp and Udacity and have a set of queries I can refer to in the future. Skills used: joins, CTE's, temp tables, window functions, aggregate functions, views, data type conversion.
