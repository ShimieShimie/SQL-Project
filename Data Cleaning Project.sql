use PortfolioProject

--------------------------------------------------------------------------------------------------
--look at data

select *
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------

--Standardizing Date Format
--converted saledate column data type from dateTime to Date

select saledate
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
alter column saledate date

--------------------------------------------------------------------------------------------------

--Populate Property Address data

--checking for empty addresses
select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is NULL

--figuring out the script for the update script
select A.ParcelID, A.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
from PortfolioProject..NashvilleHousing as A, PortfolioProject..NashvilleHousing as B
where A.ParcelID = B.ParcelID
and A.[UniqueID ] <> B.[UniqueID ]
and b.PropertyAddress is null

--update script

update A
set propertyaddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
from PortfolioProject..NashvilleHousing as A, PortfolioProject..NashvilleHousing as B
where A.ParcelID = B.ParcelID
and A.[UniqueID ] <> B.[UniqueID ]
and a.PropertyAddress is null


--------------------------------------------------------------------------------------------------

-- Separating addess into separate columns (address, city, state)
--this section is for splitting the property address


select 
--note on how to use this part of the script : substring(column, starting position from 1, where to stop) 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress)) as city
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress))

--this section is for spltting the owner address

select 
PARSENAME(replace(OwnerAddress, ',','.'),3),
PARSENAME(replace(OwnerAddress, ',','.'),2),
PARSENAME(replace(OwnerAddress, ',','.'),1)
from NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',','.'),1)

--------------------------------------------------------------------------------------------------

--check for distinct values in "SoldAsVacant"
select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

--change Y and N to Yes and No in "Sold as Vacant"

select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = 
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end

--------------------------------------------------------------------------------------------------

--Delete Unused Columns

alter table NashvilleHousing
drop column OwnerAddress, PropertyAddress, SaleDate, TaxDistrict

