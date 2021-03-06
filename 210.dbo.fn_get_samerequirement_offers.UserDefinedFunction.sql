/****** Object:  UserDefinedFunction [dbo].[fn_get_samerequirement_offers]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER function [dbo].[fn_get_samerequirement_offers](@cityid int,@areaid int    
   ,@mobilenumber varchar(16),@customerid int,@businessid int,@price money  
   ,@subcategoryid int,@needid int,@addefid int,@excludeadid bigint  
   ,@tvp_needidattribute split_needidattribute_v2 readonly)    
returns varchar(max)    
as    
begin    
    
declare @returnvalue varchar(max) = ''    
,@lv_mobilenumber varchar(16) = isnull(@mobilenumber,'')    
,@lv_customerid int = isnull(@customerid,0)    
,@total_distribution_attributes int = 0   
  
select @total_distribution_attributes = count(1) from @tvp_needidattribute where isdistribution = 1    
    
if isnull(@total_distribution_attributes,0)=0    
 set @total_distribution_attributes = 0   
    
;with get_customer_ads    
as    
(    
select am.adid from dbo.adsmaster am (nolock)    
 join dbo.adsneedmapping anm (nolock) on am.adid = anm.adid    
where     
(    
am.mobileno = @lv_mobilenumber    
or ((exists (select 1 where am.customerid = @lv_customerid and @lv_customerid > 0)))    
)    
and am.cityid = @cityid    
and am.areaid = @areaid    
and am.adid <> @excludeadid    
and am.price = @price    
and am.price > 0    
and am.status in (1,2,4)    
and anm.subcategoryid = @subcategoryid    
and anm.needid = @needid    
and anm.addefid = @addefid    
),    
get_dupe_ads    
as    
(    
select top 1 gc.adid,count(asam.adid) attributecounts    
from get_customer_ads gc   
 left join adssubcatattributemapping asam (nolock)  on gc.adid = asam.adid  
     and exists (select top 1 1 from @tvp_needidattribute na  where na.attributevalueid = asam.attributevalueid and na.isdistribution = 1)  
     --count(asam.adid) = @total_distribution_attributes  
group by gc.adid  
)    
select @returnvalue = convert(varchar(max),adid) from get_dupe_ads      
    
return(isnull(@returnvalue,''))    
    
    
end
GO
