/****** Object:  StoredProcedure [dbo].[prc_get_ad_images]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_ad_images]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_ad_images] AS'
END
GO
Alter PROCEDURE prc_get_ad_images
@adid		BIGINT
AS
BEGIN

SET NOCOUNT ON;

declare @lv_adid bigint = @adid
,@lv_projectid bigint = 0

if exists (select top 1 1 from dbo.adsmaster am (nolock) where am.adid = @lv_adid and am.projectid > 0)
begin
	select top 1 @lv_projectid = projectid from dbo.adsmaster am (nolock) 
		where am.adid = @lv_adid and am.projectid > 0

	select	@lv_adid adid,m.mediatypeid,m.mediaurl,m.mediacaption TagName,m.createddate
	from	dbo.adsmedia m(nolock)
	where	m.adid		=	@lv_projectid

	return;

end

	SELECT	m.adid,m.mediatypeid,m.mediaurl,m.mediacaption TagName,m.createddate
	FROM	dbo.adsmedia m(NOLOCK)
	WHERE	m.adid		=	@adid

SET NOCOUNT OFF;

END
GO
