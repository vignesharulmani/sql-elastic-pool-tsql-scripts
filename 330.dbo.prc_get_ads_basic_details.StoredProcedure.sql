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
Alter PROCEDURE prc_get_ads_basic_details
@adid		BIGINT,
@includeimages int = 0
AS
BEGIN

SET NOCOUNT ON;

--ADS BASIC DETAIL
SELECT TOP 1 am.contactname [name] 
,am.emailid [email],am.mobileno mobile
,am.adtitle title
,'https://www.sulekha.com' + am.adurl url
,am.areaname
,am.cityname
,cast(am.listdate as date) crdate
,cast(am.closedate as date) expirydate
,am.businessid,am.customerid
,am.campaignid,anm.needid
,anm.subcategoryid
,convert(bigint,am.price) price,am.custominfo
FROM dbo.adsmaster am (NOLOCK) 
	JOIN dbo.adsneedmapping anm (NOLOCK) on am.adid = anm.adid
WHERE am.adid = @adid


--ADS MEDIA
if @includeimages = 1
	EXEC dbo.prc_get_ad_images @adid = @adid

SET NOCOUNT OFF;

END
GO
