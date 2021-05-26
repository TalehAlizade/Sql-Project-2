Select * 
from SqlProject..Housing

-- okay it's working

Select saledateconverted, CONVERT(date, saledate)
from SqlProject..Housing

update Housing
set saledateconverted = CONVERT(date,SaleDate)

alter table Housing
add saledateconverted date;

-- Populate Property address data

Select PropertyAddress
from SqlProject..Housing
where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.Propertyaddress, b.PropertyAddress)
from SqlProject..Housing as a
Join SqlProject..Housing as b
On a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is not null

Update a
set PropertyAddress = ISNULL(a.Propertyaddress, b.PropertyAddress)
from SqlProject..Housing as a
Join SqlProject..Housing as b
On a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--  breaking out Address into individual columns

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1) as Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) as Address
from SqlProject..Housing

ALter table Housing
Add propertySplitAddress Nvarchar(255);

Update Housing
Set propertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1)

Alter table Housing
Add propertySplitCity Nvarchar(255);

Update Housing
SET propertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))

-- same process but a lot easier 

Select Owneraddress 
From SqlProject..Housing

Select PARSENAME(REPLACE(owneraddress, ',', '.'), 3),
PARSENAME(REPLACE(owneraddress, ',', '.'), 2),
PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
from SqlProject..Housing

Alter table housing
add OwnerSplitAddress Nvarchar(255)

Update Housing
Set OwnerAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3)

Alter table housing
add Ownersplitcity Nvarchar(255)

Update Housing
set Ownersplitcity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2)

Alter table housing
add OwnersplitState Nvarchar(255)

Update Housing
Set OwnersplitState = PARSENAME (REPLACE(owneraddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "sold as Vacant" field

Select soldasvacant, 
case when soldasvacant = 'Y' Then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant end
from SqlProject..Housing

update Housing
set SoldAsVacant = case when soldasvacant = 'Y' Then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant end


-- Remove Duplicates

with rownumCTE as (
Select *, 
ROW_NUMBER() Over(Partition by ParcelID, PropertyAddress, saleprice, saledate, legalreference order by uniqueID) row_num
from SqlProject..Housing)
Delete
from rownumCTE
where row_num > 1

-- delete useless columns

Alter table SqlProject..Housing
drop column Owneraddress, Taxdistrict, PropertyAddress, Saledate


