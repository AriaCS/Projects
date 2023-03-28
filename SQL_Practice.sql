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

/* SQL Intermediate: Joins, Unions, Case Statements, Updating/Deleting Data, Partition By, Data Types,
Aliasing, Creating Views, Have vs Group By Statement, GETDATE(), Primary Key vs Foreign Key */

SELECT *
FROM EmployeeDemographics

SELECT *
FROM EmployeeSalary

-- Inner Join EmployeeDemographics and EmployeeSalary Tables
-- Filter out Accountants w/ Salaries in DESC order

SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, JobTitle, Salary
FROM EmployeeDemographics
INNER JOIN EmployeeSalary
   ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
WHERE JobTitle <> 'Accountant'
ORDER BY Salary DESC

-- Calculate AVG salary in Sales

SELECT JobTitle, AVG(Salary)
FROM EmployeeDemographics
INNER JOIN EmployeeSalary
   ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
WHERE JobTitle = 'Salesman'
GROUP BY JobTitle

-- Union, Union All example (must have same # columns, data types, and in same order)

SELECT EmployeeID, FirstName, Age
FROM EmployeeDemographics
UNION
SELECT EmployeeID, JobTitle, Salary
FROM EmployeeSalary
ORDER BY EmployeeID

-- Case Statements

SELECT FirstName, LastName, Age,
CASE
	WHEN Age > 30 THEN 'Old'
	WHEN Age BETWEEN 27 AND 30 THEN 'Young'
	ELSE 'Very Young'
END
FROM EmployeeDemographics
WHERE Age is NOT NULL
ORDER BY Age


SELECT FirstName, LastName, JobTitle, Salary,
CASE 
	WHEN JobTitle = 'Salesman' THEN Salary + (Salary * .10)
	WHEN JobTitle = 'Accountant' THEN Salary + (Salary * .05)
	WHEN JobTitle = 'HR' THEN Salary + (Salary * .000001)
	ELSE Salary + (Salary * .03)
END AS SalaryAfterRaise
FROM EmployeeDemographics
JOIN EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

-- Having Clause

SELECT JobTitle, COUNT(JobTitle)
FROM EmployeeDemographics
JOIN EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
GROUP BY JobTitle
HAVING COUNT(JobTitle) > 1

SELECT JobTitle, AVG(Salary) AS AvgSalary
FROM EmployeeDemographics
JOIN EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
GROUP BY JobTitle
HAVING AVG(Salary) > 45000
ORDER BY AVG(Salary) DESC


-- Updating Null EmployeeID Data with functions 'UPDATE' and 'SET'

SELECT *
FROM EmployeeDemographics

UPDATE EmployeeDemographics
SET Age = 31, Gender = 'Female'
WHERE EmployeeID = 1012

-- Deleting entire row from table **Cannot retrieve data back
-- View entire row before deleting data

SELECT *
FROM EmployeeDemographics
WHERE EmployeeID = 1005

DELETE FROM EmployeeDemographics
WHERE EmployeeID = 1005

-- Aliasing
-- Combining FirstName and LastName columns

SELECT FirstName + ' ' + LastName AS FullName
FROM EmployeeDemographics

-- Aliasing table names (understand where columns are coming from each alias table name)

SELECT Demo.EmployeeID, Sal.Salary
FROM EmployeeDemographics AS Demo
JOIN EmployeeSalary AS Sal
	ON Demo.EmployeeID = Sal.EmployeeID
	
-- Partition By (isolating entire column to perform aggregate function on) VS 'Group by'

SELECT FirstName, LastName, Gender, Salary
, COUNT(Gender) OVER (PARTITION BY Gender) as TotalGender
FROM EmployeeDemographics AS Dem
JOIN EmployeeSalary AS Sal
	ON Dem.EmployeeID = Sal.EmployeeID

-- Partition VS. Group by example

SELECT FirstName, LastName, Gender, Salary, COUNT(Gender)
FROM EmployeeDemographics AS Dem
JOIN EmployeeSalary AS Sal
	ON Dem.EmployeeID = Sal.EmployeeID
GROUP BY FirstName, LastName, Gender, Salary

-- Group by

SELECT Gender, COUNT(Gender)
FROM EmployeeDemographics AS Dem
JOIN EmployeeSalary AS Sal
	ON Dem.EmployeeID = Sal.EmployeeID
GROUP BY Gender

/* SQL BASICS: Creating tables, Inserting values, Top, Distinct, Count, As, Max, Min, Avg, Group By, Order By
Where Statement =, <>, <, >, And, Or, Like, Null, Not Null, In */ 

--1. Creating Tables

CREATE TABLE EmployeeDemographics
(EmployeeID int,
FirstName varchar(50),
LastName varchar(50),
Age int,
Gender varchar(50)
)

Create Table EmployeeSalary 
(EmployeeID int, 
JobTitle varchar(50), 
Salary int
)

-- 2. Inserting values into tables

Insert into EmployeeDemographics VALUES
(1001, 'Jim', 'Halpert', 30, 'Male'),
(1002, 'Pam', 'Beasley', 30, 'Female'),
(1003, 'Dwight', 'Schrute', 29, 'Male'),
(1004, 'Angela', 'Martin', 31, 'Female'),
(1005, 'Toby', 'Flenderson', 32, 'Male'),
(1006, 'Michael', 'Scott', 35, 'Male'),
(1007, 'Meredith', 'Palmer', 32, 'Female'),
(1008, 'Stanley', 'Hudson', 38, 'Male'),
(1009, 'Kevin', 'Malone', 31, 'Male')

Insert Into EmployeeSalary VALUES
(1001, 'Salesman', 45000),
(1002, 'Receptionist', 36000),
(1003, 'Salesman', 63000),
(1004, 'Accountant', 47000),
(1005, 'HR', 50000),
(1006, 'Regional Manager', 65000),
(1007, 'Supplier Relations', 41000),
(1008, 'Salesman', 48000),
(1009, 'Accountant', 42000)

-- 3. Selecting small row sample from table using 'Top' function

SELECT Top 5 *
FROM EmployeeSalary

-- 4. Looking for duplicates using 'Distinct' function

SELECT DISTINCT(EmployeeID)
FROM EmployeeSalary

-- 5. Counting all non-null values in a column 

SELECT COUNT(LastName) AS LastNameCount
FROM EmployeeDemographics

-- 6. Looking at Max, Min, and Avg values

SELECT MAX(salary) AS MaxSalary
FROM EmployeeSalary

SELECT MIN(salary) AS MinSalary
FROM EmployeeSalary

SELECT AVG(salary) AS AvgSalary
FROM EmployeeSalary

-- 7. Where Statements: does not equal <>, greater/equal to, And, Like %,   

SELECT *
FROM EmployeeDemographics
WHERE FirstName <> 'Jim'


SELECT *
FROM EmployeeDemographics
WHERE Age >= 30 AND Gender = 'Male'

-- Filter all last names that start with letter 'S'

SELECT *
FROM EmployeeDemographics
WHERE LastName LIKE 'S%'

-- Filter all last names that have letter 'S' in name

SELECT *
FROM EmployeeDemographics
WHERE LastName LIKE '%S%'

-- Filter last names that start with letter 'S' and has letter 'O' within last name

SELECT *
FROM EmployeeDemographics
WHERE LastName LIKE 'S%O%'

-- Filter last names using NOT NULL function

SELECT *
FROM EmployeeDemographics
WHERE LastName is NOT NULL

-- Filtering multiple "equal" statement using IN function

SELECT *
FROM EmployeeDemographics
WHERE FirstName IN ('Jim', 'Michael')

-- 8. Group By and Order By statements

SELECT Gender, Age, COUNT(Gender) AS CountGender
FROM EmployeeDemographics
GROUP BY Gender, Age

SELECT Gender, COUNT(Gender) AS CountGender
FROM EmployeeDemographics
WHERE Age > 31
GROUP BY Gender

SELECT Gender, COUNT(Gender) AS CountGender
FROM EmployeeDemographics
WHERE Age > 31
GROUP BY Gender
ORDER BY CountGender DESC

-- Order by column numbers instead of column names 'Age' and 'Gender'

SELECT *
FROM EmployeeDemographics
ORDER BY 4 Desc, 5 Desc
