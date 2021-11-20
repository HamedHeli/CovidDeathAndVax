/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [Nashville Housing Data].[dbo].[NashvilleHousingData]



  begin tran

  /*
=======================================================================
	First, we remove the duplicates. 
	We partition the rows that have the same ParcelID, SaleDate, SalePrice, LegalReference
	Put the paritition in a CTE and then
	keep the first row in each partition and delete the remaining 
=======================================================================
  */	

  With CTEDuplicate as
  (
  Select *, row_number () over (partition by ParcelID, SaleDAte, SalePRice, LegalReference order by ParcelID) row_num
   FROM [Nashville Housing Data].[dbo].[NashvilleHousingData] 
   )

   select *  
   from CTEDuplicate
   where row_num <> 1





  /*
=======================================================================
  PropertyAddress is null for some cells; this is how we are fixing it.
  We find out that the parcels with the same ParcelID share the PropertyAddress.
  So, we set the PropertyAddress of those that have the same ParcelID. 
  After making sure that PropertyAddress is not NULL for any cell, we convert it to stree and city
=======================================================================
  */

  -- check if the rows with the same ParcelID have the same PropertyAddress
  select T1.ParcelID, T1.PropertyAddress, T2.ParcelID, T2.PropertyAddress 
  from [Nashville Housing Data].[dbo].[NashvilleHousingData] T1
  join [Nashville Housing Data].[dbo].[NashvilleHousingData] T2
  --where PropertyAddress is null
  on T1.ParcelID = T2.ParcelID
  AND T1.UniqueID <> T2.UniqueID
  where T1.PropertyAddress is null


  -- substituting the PropertyAddress from the rows with the same ParcelID

  update T1
  SET T1.PropertyAddress = T2.PropertyAddress
  from [Nashville Housing Data].[dbo].[NashvilleHousingData] T1
  join [Nashville Housing Data].[dbo].[NashvilleHousingData] T2
  --where PropertyAddress is null
  on T1.ParcelID = T2.ParcelID
  AND T1.UniqueID <> T2.UniqueID
  where T1.PropertyAddress is null

  -- separating the stress and city from the address

  SELECT Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Adress, 
         Substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) as City
  from [Nashville Housing Data].[dbo].[NashvilleHousingData] 


  Alter Table [Nashville Housing Data].[dbo].[NashvilleHousingData]
  add PropertyStreet nvarchar(255)

  Update [Nashville Housing Data].[dbo].[NashvilleHousingData]
  set PropertyStreet = Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

  Alter Table [Nashville Housing Data].[dbo].[NashvilleHousingData]
  add PropertyCity nvarchar(255)

  Update [Nashville Housing Data].[dbo].[NashvilleHousingData]
  set PropertyCity = Substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))

  select OwnerAddress, ParcelID
  from [Nashville Housing Data].[dbo].[NashvilleHousingData]

  -- now delete the column PropertyAddress (It is better to copy the database before running this) 
  Alter table  [Nashville Housing Data].[dbo].[NashvilleHousingData]
  drop column PropertyAddress 
  
  /*
=======================================================================
	Now, we break the OwnerAddress to street, city, state 
=======================================================================
  */


Alter Table [Nashville Housing Data].[dbo].[NashvilleHousingData]
  add OwnerAddressStreet nvarchar(255)

 Update [Nashville Housing Data].[dbo].[NashvilleHousingData]
  set OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

  Alter Table [Nashville Housing Data].[dbo].[NashvilleHousingData]
  add OwnerAddressCity nvarchar(255)

  Update [Nashville Housing Data].[dbo].[NashvilleHousingData]
  set OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

  Alter Table [Nashville Housing Data].[dbo].[NashvilleHousingData]
  add OwnerAddressState nvarchar(255)

  Update [Nashville Housing Data].[dbo].[NashvilleHousingData]
  set OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 -- now delete the owneraddress (it is better to copy the dataset before running this line) 
  
  Alter table  [Nashville Housing Data].[dbo].[NashvilleHousingData]
  drop column OwnerAddress 


  /*
=======================================================================
	We then notice that SoldAsVacant column includes Yes and No as well as Y and N. 
	We first check which format is more common and then change all values to standardize   
=======================================================================
  */	

  -- check which format is more common 

  Select SoldAsVacant, count(SoldAsVacant)
  FROM [Nashville Housing Data].[dbo].[NashvilleHousingData]

  group by SoldAsVacant
  order by count(SoldAsVacant)

 -- make the format consisten 

 
 Update [Nashville Housing Data].[dbo].[NashvilleHousingData]
 SET SoldAsVacant = 	Case 
								When SoldAsVacant = 'Y' then 'Yes'
								When SoldAsVacant = 'N' then 'No'
								Else SoldAsVacant
						End
 


 select *
 from [Nashville Housing Data].[dbo].[NashvilleHousingData]