/****** Object:  StoredProcedure [dbo].[prc_get_ads_contact]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[prc_get_ads_contact]                                                 
@adid		BIGINT
AS
BEGIN

SET NOCOUNT ON;

SELECT TOP 1 am.contactname [name] 
,am.emailid [email],am.mobileno mobile
,am.adtitle title
,am.adurl url
,am.closedate expirydate
,am.businessid,am.customerid
,am.campaignid,anm.needid,anm.subcategoryid
FROM dbo.adsmaster am (NOLOCK) 
	JOIN dbo.adsneedmapping anm (NOLOCK) on am.adid = anm.adid
WHERE am.adid = @adid

SET NOCOUNT OFF;

END
GO
