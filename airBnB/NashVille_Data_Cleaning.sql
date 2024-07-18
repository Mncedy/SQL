/*

Cleaning Data in SQL Queries

*/

Use covidStats;

Select *
From covidStats..VilleHousing;

-- Standardize Date Format

Select saleDate, CONVERT(date,SaleDate)
From covidStats..VilleHousing;

Update VilleHousing
SET SaleDate = CONVERT(date,saleDate);

-- Add new column
ALTER TABLE VilleHousing 
ADD saleDateUpdated date;

Update VilleHousing
SET saleDateUpdated = CONVERT(date,saleDate);

Select saleDateUpdated, CONVERT(date,SaleDate)
From covidStats..VilleHousing;

Select *
From covidStats..VilleHousing

-- Populate Property Address Data

Select PropertyAddress
From covidStats..VilleHousing
Where PropertyAddress is null;

-- Property with duplicate ParcelID has the same duplicate PropertyAddress
Select n.ParcelID, n.PropertyAddress, h.ParcelID, h.PropertyAddress
From covidStats..VilleHousing n
	JOIN covidStats..VilleHousing h
	ON n.ParcelID = h.ParcelID
	AND n.[UniqueID ] <> h.[UniqueID ]
Where n.PropertyAddress is null;


Update n 
SET PropertyAddress = ISNULL(n.PropertyAddress,h.PropertyAddress)
From covidStats..VilleHousing n
	JOIN covidStats..VilleHousing h
	ON n.ParcelID = h.ParcelID
	AND n.[UniqueID ] <> h.[UniqueID ]
Where n.PropertyAddress is null;


-- Populating out Property&Owner Address into individual columns (Address, City, State)
--Property Address

select PropertyAddress
from covidStats..VilleHousing
-- Where PropertyAddress is null
-- Order By ParcelID;

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as AddressCity
From covidStats..VilleHousing
Order By AddressCity asc;

ALTER TABLE covidStats..VilleHousing
ADD Address nvarchar(255);

Update covidStats..VilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABle covidStats..VilleHousing
ADD City nvarchar(255);

Update covidStats..VilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

Select *
From covidStats..VilleHousing

-- Owner Address

Select OwnerAddress
From covidStats..VilleHousing

Select
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From covidStats..VilleHousing
Where OwnerAddress is not null;

ALTER TABLE covidStats..VilleHousing
ADD Street nvarchar(255);

ALTER TABLE covidStats..VilleHousing
ADD OwnerCity nvarchar(255);

ALTER TABLE covidStats..VilleHousing
ADD State nvarchar(50);

Update covidStats..VilleHousing
SET Street = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3);

Update covidStats..VilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2);

Update covidStats..VilleHousing
SET State = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);

Select *
From covidStats..VilleHousing



-- Change Y and N to Yes and No in Sold as Vacant field

Select SoldAsVacant
From covidStats..VilleHousing

Select DISTINCT(SoldAsVacant)
From covidStats..VilleHousing

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From covidStats..VilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No' 
		 ELSE SoldAsVacant
		 END 
From covidStats..VilleHousing

Update covidStats..VilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No' 
		 ELSE SoldAsVacant
		 END 
From covidStats..VilleHousing



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
From covidStats..VilleHousing

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
From covidStats..VilleHousing
)
Select * --Delete
From RowNumCTE
Where row_num > 1
Order By PropertyAddress;

-- Delete unwanted columns

ALTER TABLE covidStats..VilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate;

Select *
From covidStats..VilleHousing;

-- Removing columns with Null values

Delete from covidStats..VilleHousing
Where OwnerName is null;