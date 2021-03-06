/****** Object:  StoredProcedure [dbo].[prc_get_ads_dcp]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_ads_dcp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_ads_dcp] AS'
END
GO
Alter procedure prc_get_ads_dcp
as       
begin      
      
set nocount on;      
      
 declare @getdate datetime = getdate()      
 declare @fromdatetime datetime       
 set @fromdatetime = dateadd(hh,-3,@getdate)      
 --set @fromdatetime = dateadd(minute,-15,@getdate)      
    
 declare @tblads table (adid bigint primary key with(ignore_dup_key = on))    
       
 insert into @tblads(adid)      
 select  am.adid    
 from dbo.adsmaster am(nolock)      
 where am.adid > 0    
 and am.createddate > @fromdatetime      
 and am.businessid = 0    
 and am.subcategoryid in (951,9000,9600)
      
 insert into @tblads(adid)      
 select  am.adid    
 from dbo.adsmaster am(nolock)      
 where am.adid > 0    
 and am.modifieddate > @fromdatetime      
 and am.businessid = 0    
 and am.subcategoryid in (951,9000,9600)
      
 select  am.adid,am.cityid,am.cityname,am.areaid,am.areaname,am.admode,am.price,      
  am.contactname,am.emailid,am.mobileno,am.countrycode,am.createddate,am.modifieddate,  
  am.categoryid,am.subcategoryid,am.listdate,am.closedate,am.status,      
  f.attributevalueid propertytype_attributevalueid,am.pagesource,am.adtitle,
  b.attributevalueid bedroom_attributevalueid    
      
 from dbo.adsmaster am(nolock)     
  join @tblads ta on ta.adid = am.adid     
        cross apply dbo.fn_get_ad_attributevalueid(am.adid,'Property Type')f      
		outer apply dbo.fn_get_ad_attributevalueid(am.adid,'Bedrooms')b
      
set nocount off;      
      
end  
GO
