/****** Object:  UserDefinedFunction [dbo].[fn_convert_ads_json]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter function [dbo].[fn_convert_ads_json](@adid bigint)
returns nvarchar(max)
as
begin

declare @nvarchar nvarchar(max) = ''

set @nvarchar =
(
select 
adsmaster_outer.adid,
(
select 
adsmaster.projectid,adsmaster.businessid,adsmaster.cityname,adsmaster.altcityname
,adsmaster.areaname,adsmaster.altareaname,adsmaster.admode,adsmaster.adtitle,adsmaster.adurl
,adsmaster.shortdesc,adsmaster.price,adsmaster.displayarea,adsmaster.campaignid,adsmaster.customerid
,convert(varchar(64),adsmaster.latitude,128) latitude,convert(varchar(64),adsmaster.longitude,128) longitude
,adsmaster.streetname,adsmaster.zipcode,adsmaster.contactname,adsmaster.emailid,adsmaster.mobileno
,adsmaster.phoneno,adsmaster.ctcphone,adsmaster.landmark,adsmaster.createddate,adsmaster.modifieddate
,adsmaster.cityid,adsmaster.categoryid,adsmaster.subcategoryid,adsmaster.areaid,adsmaster.remarks
,adsmaster.countrycode,adsmaster.subarea,adsmaster.buildingname,adsmaster.buildingno,adsmaster.address
,adsmaster.paymentmode,adsmaster.offer,adsmaster.advpid,adsmaster.posteduserpid
,adsmaster.completionscore,adsmaster.landingurl,adsmaster.currenturl,adsmaster.sourceurl,adsmaster.ip
,adsmaster.sourcekeyword,adsmaster.useragent,adsmaster.devicetype,adsmaster.clienttype,adsmaster.pagesource
,adsmaster.listdate,adsmaster.closedate,adsmaster.netsalevalue,adsmaster.status
from adsmaster (nolock) where adsmaster_outer.adid = adsmaster.adid
for json path
)adsmaster,
(
select 
adsneedmapping.subcategoryid,adsneedmapping.addefid,adsneedmapping.needid
,adsneedmapping.cityid,adsneedmapping.areaid
from adsneedmapping (nolock) where adsmaster_outer.adid = adsneedmapping.adid
for json path
) adsneedmapping,
(
select 
adsmedia.medianame,adsmedia.mediatypeid,adsmedia.mediaurl,adsmedia.mediacaption
,adsmedia.tag,adsmedia.mediatagid,adsmedia.attributeid
from adsmedia (nolock) where adsmaster_outer.adid = adsmedia.adid
for json path
) adsmedia,
(
select 
adssubcatattributemapping.adattributemapid,adssubcatattributemapping.attributeid
,adssubcatattributemapping.attributevalueid
from adssubcatattributemapping (nolock) where adsmaster_outer.adid = adssubcatattributemapping.adid
for json path
) adssubcatattributemapping,
adsmaster_outer.custominfo
from adsmaster adsmaster_outer (nolock)
where adsmaster_outer.adid = @adid
for json path
)

return(@nvarchar)


end
GO
