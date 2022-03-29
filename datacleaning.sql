---convert data format

select SaleDateconverted,convert(date,SaleDate)
from Nashville

alter table Nashville
add Saledateconverted date 

update Nashville
set Saledateconverted=convert(date,SaleDate)

---populate properte address date 
select *
from Nashville
where propertyaddress is null
order by parcelid
---propertyaddress is null
select a.parcelid,b.parcelid,a.propertyaddress,b.propertyaddress,ISNULL(a.propertyaddress,b.propertyaddress)
from Nashville a 
     join Nashville b
     on a.parcelid=b.parcelid
     and a.[uniqueid]<> b.[uniqueid]
     where a.propertyaddress is null

update a
set  propertyaddress=ISNULL(a.propertyaddress,b.propertyaddress)
from Nashville a 
     join Nashville b
     on a.parcelid=b.parcelid
     and a.[uniqueid]<> b.[uniqueid]
     where a.propertyaddress is null

--breaking address into columns(address,city,state)
select
SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as addresss  
,  SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress)) as addresss
from Nashville


alter table Nashville
add propertysplitaddress nvarchar(255)

update Nashville
set propertysplitaddress=SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

alter table Nashville
add propertysplitcity nvarchar(255)

update Nashville
set propertysplitcity= SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress))



----- break owner addrese into(address,city,state)

select 
parsename(replace(owneraddress,',','.'),3)
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)

from Nashville


alter table Nashville
add OwnerSplitAddress nvarchar(255)

update Nashville
set OwnerSplitAddress=parsename(replace(owneraddress,',','.'),3)

alter table Nashville
add OwnerSplitcity nvarchar(255)

update Nashville
set OwnerSplitcity=parsename(replace(owneraddress,',','.'),2)

alter table Nashville
add OwnerSplitstate nvarchar(255)

update Nashville
set OwnerSplitstate=parsename(replace(owneraddress,',','.'),1)

---change y and n to yes and no in 'sold as vacant' field


select distinct(soldasvacant),count(soldasvacant)
from Nashville
group by soldasvacant
order by 2


select soldasvacant
case when soldasvacant='N' then 'NO'
     when soldasvacant='Y' then 'YES'
	 else soldasvacant
	 end

from Nashville
group by soldasvacant
order by 2

update Nashville
set   soldasvacant = case when soldasvacant='N' then 'NO'
     when soldasvacant='Y' then 'YES'
	 else soldasvacant
	 end
---------remove duplicates
with RowNumCTE as(
     select *,
     row_number() over(
	 PARTITION by parcelid,
	              propertyaddress,
				  saleprice,
				  saledate,
				  legalreference
				  order by 
				  uniqueid
	                   ) row_num 
	 from Nashville
)
delete 
from  RowNumCTE
where row_num >1


----remove columns unused
alter table Nashville
drop column owneraddress,taxdistrict,propertyaddress,saledate


select* from Nashville















































