use Portfolio_Project_2
select * from housing
-- Standardize the Date Format
select CAST(SaleDate as Date) as Converted_SaleDate
from housing

alter table housing add Converted_SaleDate Date

update housing set Converted_SaleDate = CAST(SaleDate as Date)

alter table housing drop column SaleDate

--Populate Property Address Data

select PropertyAddress from housing where PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from housing a
join housing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- Split up the components of PropertyAddress into (Address,City,State)

select
 SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address,
 from housing

 alter table housing add PropertySplitAddress nvarchar(255);

 update housing
 set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

 alter table housing add PropertySplitCity nvarchar(255);

 update housing
 set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

 select * from housing

 select OwnerAddress
 from housing

 select 
 PARSENAME(REPLACE(OwnerAddress,',','.'),3),
 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
 PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 from housing

 alter table housing add OwnerSplitAddress nvarchar(255)
 update housing
 set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

 alter table housing add OwnerSplitCity nvarchar(255)
 update housing
 set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

 alter table housing add OwnerSplitState nvarchar(255)
 update housing
 set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 select * from housing

 --Change 'Y' and 'N' to 'Yes' and 'No' in 'Sold as Vacant' Field
 select distinct(SoldAsVacant), count(SoldAsVacant)
 from housing
 group by SoldAsVacant
 order by 2 desc

 update housing
 set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END
--Removing Duplicates

with cte as(
select *,
ROW_NUMBER() over(partition by ParcelID,PropertyAddress,SalePrice,Converted_SaleDate,LegalReference order by UniqueID) as row_num
from housing
)
delete
from cte
where row_num>1
--order by PropertyAddress

-- Delete Unused columns

alter table housing drop column OwnerAddress,PropertyAddress,TaxDistrict
select * from housing