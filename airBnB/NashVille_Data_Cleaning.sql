/*
Cleaning Data in SQL Queries
*/

Drop Database IF EXISTS NashVille
Create Database NashVille;

Use NashVille;

-- Using INSERT INTO ... SELECT
INSERT INTO NashVille..villeHousing
SELECT *
FROM covidStats..VilleHousing;

-- Using SELECT INTO
SELECT *
FROM covidStats..VilleHousing
Order By UniqueID desc;

SELECT *
FROM NashVille..villeHousing
Order By UniqueID desc;

-- Define the batch size
DECLARE @BatchSize INT = 10000;
DECLARE @RowCount INT;
DECLARE @MaxID INT;
DECLARE @CurrentID INT = 0;

-- Get the maximum ID from the source table
SELECT @MaxID = MAX(UniqueID) FROM covidStats..VilleHousing;

-- Insert data in batches
WHILE @CurrentID < @MaxID
BEGIN
    INSERT INTO NashVille..villeHousing
    SELECT *
    FROM covidStats..VilleHousing
    WHERE UniqueID > @CurrentID
    ORDER BY UniqueID
    OFFSET 0 ROWS FETCH NEXT @BatchSize ROWS ONLY;
    
    -- Update the current ID to the last inserted ID
    SELECT @CurrentID = MAX(UniqueID) FROM NashVille..villeHousing;
    
    -- Get the row count of the last inserted batch
    SELECT @RowCount = @@ROWCOUNT;
    
    -- Exit the loop if no rows were inserted
    IF @RowCount = 0
        BREAK;
END



Select *
From NashVille..VilleHousing;

-- Standardize Date Format

Select saleDate, CONVERT(date,SaleDate)
From NashVille..VilleHousing;

Update VilleHousing
SET SaleDate = CONVERT(date,saleDate);

-- Add new column
ALTER TABLE VilleHousing 
ADD saleDateUpdated date;

Update VilleHousing
SET saleDateUpdated = CONVERT(date,saleDate);

Select saleDateUpdated, CONVERT(date,SaleDate)
From NashVille..VilleHousing;

Select *
From NashVille..VilleHousing

-- Populate Property Address Data

Select PropertyAddress
From NashVille..VilleHousing
Where PropertyAddress is null;

-- Property with duplicate ParcelID has the same duplicate PropertyAddress
Select n.ParcelID, n.PropertyAddress, h.ParcelID, h.PropertyAddress
From NashVille..VilleHousing n
	JOIN NashVille..VilleHousing h
	ON n.ParcelID = h.ParcelID
	AND n.[UniqueID ] <> h.[UniqueID ]
Where n.PropertyAddress is null;


Update n 
SET PropertyAddress = ISNULL(n.PropertyAddress,h.PropertyAddress)
From NashVille..VilleHousing n
	JOIN NashVille..VilleHousing h
	ON n.ParcelID = h.ParcelID
	AND n.[UniqueID ] <> h.[UniqueID ]
Where n.PropertyAddress is null;


-- Populating out Property&Owner Address into individual columns (Address, City, State)
--Property Address

select PropertyAddress
from NashVille..VilleHousing
-- Where PropertyAddress is null
-- Order By ParcelID;

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as AddressCity
From NashVille..VilleHousing
Order By AddressCity asc;

ALTER TABLE NashVille..VilleHousing
ADD Address nvarchar(255);

Update NashVille..VilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABle NashVille..VilleHousing
ADD City nvarchar(255);

Update NashVille..VilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

Select *
From NashVille..VilleHousing

-- Owner Address

Select OwnerAddress
From NashVille..VilleHousing

Select
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From NashVille..VilleHousing
Where OwnerAddress is not null;

ALTER TABLE NashVille..VilleHousing
ADD Street nvarchar(255);

ALTER TABLE NashVille..VilleHousing
ADD OwnerCity nvarchar(255);

ALTER TABLE NashVille..VilleHousing
ADD State nvarchar(50);

Update NashVille..VilleHousing
SET Street = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3);

Update NashVille..VilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2);

Update NashVille..VilleHousing
SET State = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);

Select *
From NashVille..VilleHousing



-- Change Y and N to Yes and No in Sold as Vacant field

Select SoldAsVacant
From NashVille..VilleHousing

Select DISTINCT(SoldAsVacant)
From NashVille..VilleHousing

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From NashVille..VilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No' 
		 ELSE SoldAsVacant
		 END 
From NashVille..VilleHousing

Update NashVille..VilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No' 
		 ELSE SoldAsVacant
		 END 
From NashVille..VilleHousing



-- Removing duplicates


Select *,
	ROW_NUMBER() OVER (
	PARTITION By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
From NashVille..VilleHousing

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
From NashVille..VilleHousing
)
Select * --Delete
From RowNumCTE
Where row_num > 1
Order By PropertyAddress;

-- Delete unwanted columns

ALTER TABLE NashVille..VilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate;

Select *
From NashVille..VilleHousing;

-- Removing columns with Null values

Delete from NashVille..VilleHousing
Where OwnerName is null;