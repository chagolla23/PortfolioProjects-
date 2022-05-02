select *
from PortfolioProject..[NashvilleHousing ]



-- Standardize Date Format 

 Select SaleDateConverted 
 From PortfolioProject..[NashvilleHousing ]


 Update [NashvilleHousing ]
 SET SaleDate = Convert(Date, SaleDate)

 Alter Table NashvilleHousing
 Add SaleDateConverted Date;

 Update [NashvilleHousing ]
 SET SaleDateConverted = Convert(Date,SaleDate)


 --Populate Property Adress Data 

 Select * 
 From PortfolioProject..[NashvilleHousing ]
 -- Where PropertyAddress is null
 Order By ParcelID

  Select a.ParcelID, a.PropertyAddress, B.PArcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 From PortfolioProject..[NashvilleHousing ] a
Join PortfolioProject..[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null 
 

 Update a
 SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  From PortfolioProject..[NashvilleHousing ] a
Join PortfolioProject..[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID

-- Breaking out Address into Individual columns (Address, City, State)

 Select *
 From PortfolioProject..[NashvilleHousing ]


 Select 
 Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
 ,  Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address


 From PortfolioProject..[NashvilleHousing ]


 Alter Table NashvilleHousing
 Add PropertySplitAddress NVarChar(255);

 Update [NashvilleHousing ]
 SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

 Alter Table NashvilleHousing
 Add PropertySplitCity NVarChar(255);

 Update [NashvilleHousing ]
 SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 



 
 Select OwnerAddress
 From PortfolioProject..[NashvilleHousing ]


 Select 
 Parsename(Replace(OwnerAddress, ',', '.'), 3)
 , Parsename(Replace(OwnerAddress, ',', '.'), 2)
 , Parsename(Replace(OwnerAddress, ',', '.'), 1)
  From PortfolioProject..[NashvilleHousing ]

 Alter Table NashvilleHousing
 Add OwnerSplitAddress NVarChar(255);

 Update [NashvilleHousing ]
 SET OwnerSplitAddress  = Parsename(Replace(OwnerAddress, ',', '.'), 3)

 Alter Table NashvilleHousing
 Add OwnerSplitCity NVarChar(255);

 Update [NashvilleHousing ]
 SET OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

 Alter Table NashvilleHousing
 Add OwnerSplitState NVarChar(255);

 Update [NashvilleHousing ]
 SET OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

 -- Change Y to N andf N to 'Sold as Vacant" field 


 Select Distinct(SoldAsVacant), Count(SoldAsVacant)
 From PortfolioProject..[NashvilleHousing ]
 Group by SoldAsVacant
 Order by 2

 Update [NashvilleHousing ]
 Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						 When SoldAsVacant = 'N' Then 'No'
						 Else SoldAsVacant
						 End


Select SoldAsVacant
From PortfolioProject..[NashvilleHousing ]


-- Remove Duplicates 
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num

From PortfolioProject..[NashvilleHousing ]
--ORDER BY ParcelID
)
Select *
From RowNumCTE
Where row_num > 1



-- Delete unused columns 

select *
from PortfolioProject..[NashvilleHousing ]


Alter table PortfolioProject..[NashvilleHousing ]
Drop column OwnerAddress, TaxDistrict, PropertyAddress 


Alter table PortfolioProject..[NashvilleHousing ]
Drop column SaleDate