# CTEs, Temp Tables, String Functions and Use Cases - TRIM, LTRIM, RTRIM, Replace, Substring, Upper, Lower, 
Subqueries

-- CTEs (Common Table Expression) 

WITH CTE_Employee AS
(SELECT FirstName, LastName, Gender, Salary
, COUNT(Gender) OVER (PARTITION BY Gender) as TotalGender
, AVG(Salary) OVER (PARTITION BY Gender) as AvgSalary
FROM EmployeeDemographics AS Dem
JOIN EmployeeSalary AS Sal
	ON Dem.EmployeeID = Sal.EmployeeID
WHERE Salary > '45000'
)
SELECT *
FROM CTE_Employee

-- Creating Temp Tables

CREATE TABLE #temp_Employee (
Employee int,
JobTitle varchar(100),
Salary int
) 

SELECT *
FROM #temp_Employee 

INSERT INTO #temp_Employee VALUES (
'1001', 'HR', '45000'
)

-- Inserting a subset of values from a large table into a temp table
-- 'Drop Table If Exists' 

INSERT INTO #temp_Employee
SELECT *
FROM EmployeeSalary

DROP TABLE IF EXISTS #Temp_Employee2
CREATE TABLE #Temp_Employee2 (
JobTitle varchar(50),
EmployeesPerJob int,
AvgAge int,
AvgSalary int)

INSERT INTO #Temp_Employee2
SELECT JobTitle, Count(JobTitle), Avg(Age), Avg(salary)
FROM EmployeeDemographics AS EMP
JOIN EmployeeSalary AS Sal
	ON Emp.EmployeeID = Sal.EmployeeID
GROUP BY JobTitle

SELECT *
FROM #Temp_Employee2

-- String Functions and Use Cases - TRIM, LTRIM, RTRIM, Replace, Substring, Upper, Lower

CREATE TABLE EmployeeErrors (
EmployeeID varchar(50)
,FirstName varchar(50)
,LastName varchar(50)
)

Insert into EmployeeErrors Values 
('1001  ', 'Jimbo', 'Halbert')
,('  1002', 'Pamela', 'Beasely')
,('1005', 'TOby', 'Flenderson - Fired')

Select *
From EmployeeErrors

-- Using Trim, LTRIM, RTRIM

Select EmployeeID, TRIM(employeeID) AS IDTRIM
FROM EmployeeErrors 

Select EmployeeID, RTRIM(employeeID) as IDRTRIM
FROM EmployeeErrors 

Select EmployeeID, LTRIM(employeeID) as IDLTRIM
FROM EmployeeErrors 


-- Using Replace

Select LastName, REPLACE(LastName, '- Fired', '') as LastNameFixed
FROM EmployeeErrors


-- Using Substring

Select Substring(err.FirstName,1,3), Substring(dem.FirstName,1,3), Substring(err.LastName,1,3), Substring(dem.LastName,1,3)
FROM EmployeeErrors err
JOIN EmployeeDemographics dem
	on Substring(err.FirstName,1,3) = Substring(dem.FirstName,1,3)
	and Substring(err.LastName,1,3) = Substring(dem.LastName,1,3)


-- Using UPPER and lower

Select firstname, LOWER(firstname)
from EmployeeErrors

Select Firstname, UPPER(FirstName)
from EmployeeErrors

-- Subqueries

Select EmployeeID, JobTitle, Salary
From EmployeeSalary

-- Subquery in Select

Select EmployeeID, Salary, (Select AVG(Salary) From EmployeeSalary) as AllAvgSalary
From EmployeeSalary

-- How to do it with Partition By
Select EmployeeID, Salary, AVG(Salary) over () as AllAvgSalary
From EmployeeSalary

-- Why Group By doesn't work
Select EmployeeID, Salary, AVG(Salary) as AllAvgSalary
From EmployeeSalary
Group By EmployeeID, Salary
order by EmployeeID


-- Subquery in From (Create Temp Table instead)
Select a.EmployeeID, AllAvgSalary
From 
	(Select EmployeeID, Salary, AVG(Salary) over () as AllAvgSalary
	 From EmployeeSalary) a
Order by a.EmployeeID


-- Subquery in Where
Select EmployeeID, JobTitle, Salary
From EmployeeSalary
Where EmployeeID in (
	Select EmployeeID 
	From EmployeeDemographics
	Where Age > 30)

--Q1. Calculate the difference between the highest salaries found in the marketing and engineering departments.
-- Output the absolute difference in salaries.

SELECT ABS((Select max(salary)
FROM db_employee AS emp
JOIN db_dept AS dep ON emp.department_id = dep.id
WHERE deparment = 'engineering') -
(Select max(salary)
FROM db_employee AS emp
JOIN db_dept AS dep ON emp.department_id = dep.id
WHERE department = 'marketing')) AS difference_in_salary

--Q2. We have a table with employees and their salaries, however, some of the records contain outdated salary info.
--Find the current salary of each employee assuming salaries increase each year.
--Output their id, first name, last name, department ID, and current salary, and order id in ASC order.

SELECT id, first_name, last_name, department_id, max(salary)
FROM ms_employee_salary
GROUP BY id, first_name, last_name, department_id
ORDER BY id ASC;

