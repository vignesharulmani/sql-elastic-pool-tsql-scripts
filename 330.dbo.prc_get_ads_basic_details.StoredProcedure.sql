/****** Object:  StoredProcedure [dbo].[prc_get_ads_basic_details]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_ads_basic_details]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_ads_basic_details] AS'
END
GO
ALTER PROCEDURE prc_get_ads_basic_details
@adid		BIGINT,
@projectid  BIGINT = 0,
@includeimages int = 0
AS
BEGIN

SET NOCOUNT ON;

DECLARE @lv_adid bigint = @adid

if isnull(@lv_adid,0)=0 and @projectid > 0
	set @lv_adid = @projectid

--ADS BASIC DETAIL
SELECT TOP 1 am.contactname [name] 
,am.emailid [email],am.countrycode,am.mobileno mobile
,am.adtitle title
,'https://www.sulekha.com' + am.adurl url
,am.areaid
,am.areaname
,am.cityname
,cast(am.listdate as date) crdate
,cast(am.closedate as date) expirydate
,am.businessid,am.customerid
,am.campaignid,anm.needid
,anm.subcategoryid
,convert(bigint,am.price) price,am.custominfo
,am.buildingname [projectname]
,dbo.fn_get_projecturl('','','',am.projectid,am.businessid) projecturl
,dbo.fn_get_displayattributes(am.adtitle,am.buildingname,am.price,am.areaname,am.cityname)displayattributes
,am.projectid
FROM dbo.adsmaster am (NOLOCK) 
	JOIN dbo.adsneedmapping anm (NOLOCK) on am.adid = anm.adid
WHERE am.adid = @lv_adid


--ADS MEDIA
if @includeimages = 1
	EXEC dbo.prc_get_ad_images @adid = @lv_adid

SET NOCOUNT OFF;

END
GO
