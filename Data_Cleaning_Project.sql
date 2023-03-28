
#Cleaning data in SQL queries 

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- 1. Standardize Date Format in SaleDate Column


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- 2. Populate Property Address Data without ParcelID duplicates while keeping UniqueID
-- Joining same table together to identify/label Property Address duplicates


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.parcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.parcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


-- 3. Breaking out Property Address into individaul columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Seperate Owner Address into Address, City, State

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



--4. Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- 5. Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- 6. Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

-- Data Cleaning functions BigQuery

--1. Finding duplicatcates using DISTINCT

SELECT DISTINCT customer_id
FROM customer_data.customer_address

--2. LENGTH function (> # of length) 

SELECT state
FROM customer_data.customer_address
WHERE LENGTH (state) > 2

--3. Extra spaces using TRIM

SELECT DISTINCT customer_id
FROM customer_data.customer_address
WHERE TRIM(state) = 'OH'

--4. Filtering substring for first 2 letters using SUBSTR(column, 1, 2) first 3 letters SUBSTR(column, 1, 3)

SELECT customer_id
FROM customer_data.customer_address
WHERE
  SUBSTR(country, 1, 2) = 'US'
  
--5. Extraneous variables using MIN and MAX

SELECT
  MIN(length) AS min_length
  MAX(length) AS max_length
FROM cars.car_info

--6. Finding NUll Values

SELECT *
FROM cars.car_info
WHERE column_name is NULL

--7. Update cell

UPDATE table_name
SET
  column_name = "four"
WHERE
  make = "dodge"
  AND fuel_type = "gas"
  AND body_style = "sedan";
  
--8. Mispelling changing "tow" to two

UPDATE table_name
SET
  column_name = "two"
WHERE
  column_name = "tow";
  
--9. Converting one type of data to another using CAST

SELECT CAST (column_name AS FLOAT64)
FROM customer_data.customer_table
ORDER BY
  CAST (purchase_price AS FLOAT64) DESC

--10. Pulling columns b/t certain dates

SELECT date, purchase_price
FROM table.name
WHERE date BETWEEN '2020-12-01' AND '2020-12-31'

--11. Adding strings together with CONCAT

SELECT
  CONCAT(product_code, product_color) AS new_product_code
FROM table_name

SELECT
  CONCAT('first_name', ", 'last_name') AS full_name
FROM table_name
	 
--12. COALESCE() skipping null values in calcs / returns only non-null values in a list
-- ex. pull up procut_names, but if certain names are "null" pull up product_code

SELECT 
  COALESCE(product, product_code) AS product_info
FROM table.name
	 
--13. Mispelling CASE statement

SELECT customer_id
  CASE
  WHEN first_name = 'Tnoy' THEN 'Tony'
  ELSE first_name
  END AS cleaned_name
	 
--14. DELETE unused columns

ALTER TABLE name
DROP COLUMN owneraddress, name, sale
	 
	 

	 


















