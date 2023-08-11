/*
Cleaning Data in SQL Queries
*/

-- Standardize Date Format
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [Project Portfolio].dbo.NashvilleHousing


-- Populate Property Address Data
SELECT *
FROM [Project Portfolio].dbo.NashvilleHousing
ORDER BY ParcelID

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)	-- Using the ISNULL() Clause we check if the address is NULL and update the PropertyAddress with the address that is associated with the Parcel ID. There are mutliple Parcel ID that is associated with the same address that we can to repalce NULL.
FROM [Project Portfolio].dbo.NashvilleHousing A
JOIN [Project Portfolio].dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM [Project Portfolio].dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,	-- Using the SUBSTRING() clause, we look in the PropertyAddress column starting at index 1 and stop at ',' using CHARINDEX(). The "-1" is to exclude the "," in our Address column.
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City	--Using the SUBSTRING() clause, we start from where the "," starts using CHARINDEX() with "+1" to exlcude the "," in our City column. The LEN() clause is where we stop.
FROM [Project Portfolio].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);		-- Add column PropertySplitAddress to our table and update the column with the address

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);		-- Add column PropertySplitCity to our table and update the column with the city

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *		-- Check to see if it worked 
FROM [Project Portfolio].dbo.NashvilleHousing		-- Two new columns are added to our table

-- The easier method of splitting address using the PARSENAME() clause.
SELECT OwnerAddress
FROM [Project Portfolio].dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS Address,	-- The numbers are reversed since it reads the address backwards.
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS State
FROM [Project Portfolio].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);		-- Add column OwnerSplitAddress to our table and update the column with the address

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);		-- Add column OwnerSplitCity to our table and update the column with the city

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);		-- Add column OwnerSplitState to our table and update the column with the state

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT *		-- Check to see if it worked
FROM [Project Portfolio].dbo.NashvilleHousing	-- 3 New columns are added to the table.


-- Change "Y" and "N" to "Yes" and "No" in "Sold as Vacant" field
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Project Portfolio].dbo.NashvilleHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)	-- Check to see if it worked.
FROM [Project Portfolio].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2		-- "Y" and "N" are removed from the table.


-- Removing Duplicates (Not the best standard practice to modify raw data. Just showing I have the knowledge to do so.)
WITH RowNumCTE AS (		-- We use CTE to simplify our query
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num
FROM [Project Portfolio].dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns (Not the best standard practice to modify raw data. Just showing I have the knowledge to do so.)
ALTER TABLE [Project Portfolio].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM [Project Portfolio].dbo.NashvilleHousing	-- Check to see if it removed the selected columns from the raw data.




