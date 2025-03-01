-- Data Cleaning using SQL

SELECT * 
FROM NashvilleHousing

-- Standardize Date Format

SELECT SaleDate
FROM NashvilleHousing

SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousing

-- This is not working 
UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

-- If the above code does not work we will use ALTER 
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing

-- Populate Property Address Data

SELECT * 
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

-- Property Address

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS PropertySplitAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS PropertySplitCity
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Owner Address

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Changing Y to Yes and N to No in 'Sold as Vacant' column / field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END

-- Remove Duplicates
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY ParcelID, 
                               PropertyAddress, 
							   SalePrice, 
							   SaleDate, 
							   LegalReference
							   ORDER BY UniqueID) AS row_num
FROM NashvilleHousing

-- Using CTE to know the Duplicate Entries. Entries where the row_num > 1

WITH RowNumCTE
AS (SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY ParcelID, 
								   PropertyAddress, 
								   SalePrice, 
								   SaleDate, 
								   LegalReference
								   ORDER BY UniqueID) AS row_num
	FROM NashvilleHousing)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1

-- Using CTE to DELETE the Duplicate Entries. Entries where the row_num > 1

WITH RowNumCTE
AS (SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY ParcelID, 
								   PropertyAddress, 
								   SalePrice, 
								   SaleDate, 
								   LegalReference
								   ORDER BY UniqueID) AS row_num
	FROM NashvilleHousing)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

-- DELETE Unused Columns

SELECT * 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict

