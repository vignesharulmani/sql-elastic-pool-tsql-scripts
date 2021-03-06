/****** Object:  StoredProcedure [dbo].[prc_get_ad_details_tool]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_ad_details_tool]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_ad_details_tool] AS'
END
GO
Alter procedure prc_get_ad_details_tool
@businessid int,
@projectid bigint,
@campaignid int, 
@adclassification int = -1

as 
begin
set nocount on; 

declare @lv_businessid int = isnull(@businessid,0),
@lv_projectid bigint = isnull(@projectid,0),
@lv_campaignid int = isnull(@campaignid,0),
@lv_adclassification int = isnull(@adclassification,-1)


if @lv_businessid > 0 and @lv_projectid > 0
	select am.adid,am.adtitle,am.areaname,am.cityname,am.price 
	from dbo.adsmaster am (nolock)
	where am.projectid = @lv_projectid
	and am.businessid = @lv_businessid
	and am.status = 1
else if @lv_campaignid > 0 and @lv_adclassification > 0
	select am.adid,am.adtitle,am.areaname,am.cityname,am.price 
	from dbo.adsmaster am (nolock)
	where am.status = 1
	and exists (select top 1 1 from dbo.adsneedmapping anm (nolock) 
					where anm.adid = am.adid and anm.campaignid = @lv_campaignid 
						and anm.adclassification = @lv_adclassification)

set nocount off;

end
GO
