/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [Nashville Housing Data].[dbo].[NashvilleHousingData]



  BEGIN TRAN

  /*
=======================================================================
	First, we remove the duplicates. 
	We partition the rows that have the same ParcelID, SaleDate, SalePrice, LegalReference
	Put the paritition in a CTE and then
	keep the first row in each partition and delete the remaining 
=======================================================================
  */	

  WITH CTEDuplicate AS
  (
  SELECT *, 
  	row_number () over (partition by ParcelID, SaleDAte, SalePRice, LegalReference order by ParcelID) row_num
  
  FROM 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData] 
   									)
   SELECT 
   	*  
   FROM 
   	CTEDuplicate
   WHERE 
   	row_num <> 1
   

  /*
=======================================================================
  PropertyAddress is null for some cells; this is how we are fixing it.
  We find out that the parcels with the same ParcelID share the PropertyAddress.
  So, we set the PropertyAddress of those that have the same ParcelID. 
  After making sure that PropertyAddress is not NULL for any cell, we convert it to stree and city
=======================================================================
  */

  -- check if the rows with the same ParcelID have the same PropertyAddress
  
  
  SELECT 
  	T1.ParcelID, 
  	T1.PropertyAddress, 
	T2.ParcelID, 
	T2.PropertyAddress 
  FROM 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData] T1
  JOIN 	
  	[Nashville Housing Data].[dbo].[NashvilleHousingData] T2
  
  ON 
  	T1.ParcelID = T2.ParcelID
  AND 
  	T1.UniqueID <> T2.UniqueID
  
  WHERE 
  	T1.PropertyAddress is null


  -- substituting the PropertyAddress from the rows with the same ParcelID

  UPDATE T1
  SET 	
  	T1.PropertyAddress = T2.PropertyAddress
  
 
  FROM 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData] T1
  JOIN 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData] T2
  
  ON 
  	T1.ParcelID = T2.ParcelID
  AND 
  	T1.UniqueID <> T2.UniqueID
  WHERE 
  	T1.PropertyAddress is null

  -- separating the stress and city from the address

  SELECT 
  	Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Adress, 
         Substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) AS City
  FROM 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData] 


  ALTER TABLE 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]
  ADD PropertyStreet nvarchar(255)

  UPDATE 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]
  SET 
  	PropertyStreet = Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

  ALTER TABLE 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]
  ADD 
  	PropertyCity nvarchar(255)

  UPDATE 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]
  SET 
  	PropertyCity = Substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))

  SELECT 
  	OwnerAddress, 
	ParcelID
  FROM 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]

  -- now delete the column PropertyAddress (It is better to copy the database before running this) 
  ALTER TABLE 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]
  DROP COLUMN 
  	PropertyAddress 
  
  /*
=======================================================================
	Now, we break the OwnerAddress to street, city, state 
=======================================================================
  */


ALTER TABLE 
	[Nashville Housing Data].[dbo].[NashvilleHousingData]
ADD 
	OwnerAddressStreet nvarchar(255)

 UPDATE 
 	[Nashville Housing Data].[dbo].[NashvilleHousingData]
 SET 
 	OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

  ALTER TABLE 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]
  ADD 
  	OwnerAddressCity nvarchar(255)

  UPDATE 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]
  SET 
  	OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

  ALTER TABLE 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]
  ADD 
  	OwnerAddressState nvarchar(255)

  UPDATE 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]
  SET 
  	OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 -- now delete the owneraddress (it is better to copy the dataset before running this line) 
  
  ALTER TABLE 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]
  DROP COLUMN 
  	OwnerAddress 


  /*
=======================================================================
	We then notice that SoldAsVacant column includes Yes and No as well as Y and N. 
	We first check which format is more common and then change all values to standardize   
=======================================================================
  */	

  -- check which format is more common 

  SELECT 
  	SoldAsVacant, 
	count(SoldAsVacant)
  FROM 
  	[Nashville Housing Data].[dbo].[NashvilleHousingData]

  GRPUP BY 
  	SoldAsVacant
  ORDER BY 
  	count(SoldAsVacant)

 -- make the format consisten 

 
 UPDATE 
 	[Nashville Housing Data].[dbo].[NashvilleHousingData]
 SET 
 	SoldAsVacant = 	Case 
				When SoldAsVacant = 'Y' then 'Yes'
				When SoldAsVacant = 'N' then 'No'
				Else SoldAsVacant
			End
 


 SELECT *
 FROM
 	[Nashville Housing Data].[dbo].[NashvilleHousingData]
