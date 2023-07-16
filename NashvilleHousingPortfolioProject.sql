/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM NashvilleHousing

-------------------------------------------------------------------------------------

-- Standardize Date Format: Instead of CAST, CONVERT can also be used

SELECT SaleDateConverted, CAST(SaleDate AS DATE)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate AS DATE)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS DATE)

-------------------------------------------------------------------------------------

-- Populate Property Address Data: First, with ISNULL function, I checked how PropertyAddress is populated after the table is joined itself. 
-- Then, with UPDATE, NULL PropertyAddress is populated.

SELECT * 
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress, ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM NashvilleHousing NH1
INNER JOIN NashvilleHousing NH2 ON NH1.ParcelID = NH2.ParcelID AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL

UPDATE NH1
SET PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM NashvilleHousing NH1
INNER JOIN NashvilleHousing NH2 ON NH1.ParcelID = NH2.ParcelID AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL

-------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State): PARSENAME(REPLACE(...)...) seems more effective than SUBSTRING(CHARINDEX(...)...).
-- PARSENAME also works in reverse order.

SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) PropertySplitAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) PropertySplitCity
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) OwnerSplitAddress, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) OwnerSplitCity, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) OwnerSplitState 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field: Using of CASE and UPDATE statements.

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant 
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant 
	END

-------------------------------------------------------------------------------------

-- Remove Duplicates: Using CTE, ROW_NUMBER() to detect duplicated rows. After CTE, DELETE is used to remove duplicates. Then, SELECT statement is used for check if duplicated rows are removed.

WITH RowNumCTE AS (
SELECT ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) RowNum,
*
FROM NashvilleHousing)

SELECT * 
FROM RowNumCTE
WHERE RowNum > 1

-------------------------------------------------------------------------------------

-- Delete Unused Columns: Redundant columns are dropped via ALTER TABLE and DROP COLUMN.

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict 

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate