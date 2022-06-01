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



