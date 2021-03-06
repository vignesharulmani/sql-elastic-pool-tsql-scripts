/****** Object:  StoredProcedure [dbo].[prc_get_ad_details]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_ad_details]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_ad_details] AS'
END
GO
ALTER procedure prc_get_ad_details (
@fromdate datetime =null, 
@todate datetime =null,
@customerid int =null, 
@campaignid int =null, 
@businessid int =null,
@status int =-1,
@adclassification int = -1

) 
as 
begin
set nocount on; 

Declare @fromdate_gmt datetime, @todate_gmt datetime

set @fromdate_gmt = IIF(@fromdate is not null,dbo.fn_convert_to_gmt(@fromdate),null)
set @todate_gmt = IIF(@todate is not null,dbo.fn_convert_to_gmt(@todate),null)

IF @fromdate is not null and @todate is not null
begin
	;with cte as 
	(
	select adid,projectid,businessid,cityname,altcityname,areaname,altareaname,admode,adtitle,adurl,
		convert(bigint,price) price,campaignid,customerid,streetname,zipcode,contactname,emailid,mobileno,
		landmark,createddate,modifieddate,cityid,categoryid,subcategoryid,areaid,remarks,countrycode,buildingname,buildingno,
		address as [address],referenceid,advpid,posteduserpid,completionscore,landingurl,currenturl,
		sourceurl,sourcekeyword,ip as [Ip],listdate,closedate,netsalevalue,status as [status] 
	from adsmaster(nolock)ad where listdate >=@fromdate_gmt and listdate <=@todate_gmt and status = iif(@status=-1,ad.status,@status)
	) select ct.*,addefid,needid,adm.mode,adclassification,replace(DB_NAME(),'Ads_','') statecode
	  from cte ct join adsneedmapping(nolock)adm on ct.adid = adm.adid 
	  where adm.adclassification = iif(@adclassification=-1,adm.adclassification,@adclassification)
			
end
else if (@customerid >0)
begin
	;with cte as 
	(
	select adid,projectid,businessid,cityname,altcityname,areaname,altareaname,admode,adtitle,adurl,
		convert(bigint,price) price,campaignid,customerid,streetname,zipcode,contactname,emailid,mobileno,
		landmark,createddate,modifieddate,cityid,categoryid,subcategoryid,areaid,remarks,countrycode,buildingname,buildingno,
		address as [address],referenceid,advpid,posteduserpid,completionscore,landingurl,currenturl,
		sourceurl,sourcekeyword,ip as [Ip],listdate,closedate,netsalevalue,status as [status]  
	from adsmaster(nolock)ad where ad.customerid = @customerid and status = iif(@status=-1,ad.status,@status)
	) select ct.*,addefid,needid,adm.mode,adclassification,replace(DB_NAME(),'Ads_','') statecode 
	  from cte ct join adsneedmapping(nolock)adm on ct.adid = adm.adid 
	  where adm.adclassification = iif(@adclassification=-1,adm.adclassification,@adclassification)
end

else if (@campaignid >0)
begin
 	;with cte as (
	 select adid,projectid,businessid,cityname,altcityname,areaname,altareaname,admode,adtitle,adurl,
		convert(bigint,price) price,campaignid,customerid,streetname,zipcode,contactname,emailid,mobileno,
		landmark,createddate,modifieddate,cityid,categoryid,subcategoryid,areaid,remarks,countrycode,buildingname,buildingno,
		address as [address],referenceid,advpid,posteduserpid,completionscore,landingurl,currenturl,
		sourceurl,sourcekeyword,ip as [Ip],listdate,closedate,netsalevalue,status as [status]  
	from adsmaster(nolock)ad where ad.campaignid  = @campaignid and status = iif(@status=-1,ad.status,@status)
	)select ct.*,addefid,needid,adm.mode,adclassification,replace(DB_NAME(),'Ads_','') statecode 
	 from cte ct join adsneedmapping(nolock)adm on ct.adid = adm.adid
	 where adm.adclassification = iif(@adclassification=-1,adm.adclassification,@adclassification)
end
else if (@businessid >0)
begin
	;with cte as 
	(
	select adid,projectid,businessid,cityname,altcityname,areaname,altareaname,admode,adtitle,adurl,
		convert(bigint,price) price,campaignid,customerid,streetname,zipcode,contactname,emailid,mobileno,
		landmark,createddate,modifieddate,cityid,categoryid,subcategoryid,areaid,remarks,countrycode,buildingname,buildingno,
		address as [address],referenceid,advpid,posteduserpid,completionscore,landingurl,currenturl,
		sourceurl,sourcekeyword,ip as [Ip],listdate,closedate,netsalevalue,status as [status]  
	from adsmaster(nolock)ad where ad.businessid   = @businessid and status = iif(@status=-1,ad.status,@status)
	)select ct.*,addefid,needid,adm.mode,adclassification,replace(DB_NAME(),'Ads_','') statecode 
	from cte ct join adsneedmapping(nolock)adm on ct.adid = adm.adid 
	where adm.adclassification = iif(@adclassification=-1,adm.adclassification,@adclassification)	
end

set nocount off;

end
GO
