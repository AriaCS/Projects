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