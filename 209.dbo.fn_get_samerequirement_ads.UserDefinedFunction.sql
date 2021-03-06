/****** Object:  UserDefinedFunction [dbo].[fn_get_samerequirement_ads]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter function [dbo].[fn_get_samerequirement_ads](@cityid int,@areaid int
			,@mobilenumber varchar(16),@customerid int,@businessid int,@price money			,@tvp_needidattribute split_needidattribute_v2 readonly
			,@excludeadid bigint)
returns varchar(max)
as
begin

declare @returnvalue varchar(max) = ''
,@lv_mobilenumber varchar(16) = isnull(@mobilenumber,'')
,@lv_customerid int = isnull(@customerid,0)
,@total_distribution_attributes int = 0

/*Exclude Rent/Price Range attribute*/
select @total_distribution_attributes = count(1) from @tvp_needidattribute where isdistribution = 1
and attributeid not in (283001,256200)

if isnull(@total_distribution_attributes,0)=0
	set @total_distribution_attributes = 0

;with get_customer_ads
as
(
select am.adid from dbo.adsmaster am (nolock)
where 
(
mobileno = @lv_mobilenumber
or ((exists (select 1 where am.customerid = @lv_customerid and @lv_customerid > 0)))
)
and am.cityid = @cityid
and am.areaid = @areaid
and am.price = @price
and am.adid <> @excludeadid
and am.status in (1,2)
),
get_dupe_ads
as
(
select top 1 asam.adid,count(1) attributecounts  from adssubcatattributemapping asam (nolock)
where exists (select top 1 1 from get_customer_ads gc where gc.adid = asam.adid)
and exists (select top 1 1 from @tvp_needidattribute na 
						where na.attributevalueid = asam.attributevalueid
						and na.isdistribution = 1
						and na.attributeid not in (283001,256200))
group by asam.adid
having count(1) = @total_distribution_attributes
)
select @returnvalue = convert(varchar(max),adid) from get_dupe_ads

return(isnull(@returnvalue,''))

end
GO
