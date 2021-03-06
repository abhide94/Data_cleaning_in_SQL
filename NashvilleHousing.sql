/* Cleaning Data in SQL */

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format


/* Adding a Column */

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing



-- Populate Property Address Data


/* Checking for the NULL values */

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL


/* There are duplicates in the ParcelID and Null values in the Property Address, so in-order to unduplicate it we need to 
Self-Join with the Table and to check with the ParcelID whether the value's are equal and if there's a null in the Property Address with the one
having the Same ParcelID with Property Address, will Populate the NULL value with the given Property Address. */

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
	JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


/* Updating the column to replace it with the NULL values */

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
	JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


/* Checking with the data */

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
	JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

/* Searching for the ',' in the PropertyAddress */

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing


/* Displaying string before ',' | It will stop till ',' | Hover over SUBSTRING to know the attributes it takes 
| Here, Starting_pos is 1 and Ending_pos is to stop till ','.  */

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM PortfolioProject.dbo.NashvilleHousing


/* Extracting the City names */

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City_name
FROM PortfolioProject.dbo.NashvilleHousing

/* Updating the columns with the values */

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Varchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Varchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


/* Checking the Data */

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

/* Checking the OwnerAddress */

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

/* Parse Names, acts backward here 1 will be the State Part, 2 will be the City and 3 will be the Address. */

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing


/* Updating the table */

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Varchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Varchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Varchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



-- Changing the Y/N to Yes/No in Sold As Vacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

/* Changing with the help of CASE WHEN */

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END AS SoldAsVacantCorr
FROM PortfolioProject.dbo.NashvilleHousing


/* Updating the column */

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

/* Checking the column */

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



-- Removing Duplicates

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

/* With the help of ROW_Number to detect if there is any duplicates, if there are duplicates then there will be row_numbering 1,2 and 
if not then it'll have 1's. */


WITH RowNumCTE AS
	(
	SELECT *,
			ROW_NUMBER() OVER(
								PARTITION BY ParcelID,
								PropertyAddress,
								SaleDate,
								SalePrice,
								LegalReference
								ORDER BY UniqueID
								) row_num
	FROM PortfolioProject.dbo.NashvilleHousing
--	ORDER BY ParcelID
	)

DELETE
FROM RowNumCTE
WHERE row_num > 1
-- ORDER BY PropertyAddress




-- Deleting Unused Column

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate