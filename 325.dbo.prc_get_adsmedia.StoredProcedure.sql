	/****** Object:  StoredProcedure [dbo].[prc_get_adsmedia]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_adsmedia]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_adsmedia] AS'
END
GO
Alter procedure prc_get_adsmedia
@adid bigint,
@mediatypeid int = 1
as
begin

set nocount on;

declare @lv_adid bigint = @adid
,@lv_projectid bigint = 0

if exists (select top 1 1 from dbo.adsmaster am (nolock) where am.adid = @lv_adid and am.projectid > 0)
begin
	select top 1 @lv_projectid = projectid from dbo.adsmaster am (nolock) 
		where am.adid = @lv_adid and am.projectid > 0

	select	@lv_adid adid
	,mediatypeid as BusinessMediaType
	,replace(replace(MediaUrl,'/thumbnail/','/full/'),'http://','https://') MediaUrl
	,'' as MediaCover
	,MediaCaption                                                                                                                 
	,createddate as AddedDate
	,mediaid MediaId                                                                                
	,isnull(nullif(MediaCaption,''),'Others') TagName
	,''  Description 
	from	dbo.adsmedia m(nolock)
	where	m.adid		=	@lv_projectid

	return;

end

	SELECT	
	adid
	,mediatypeid as BusinessMediaType
	,replace(replace(MediaUrl,'/thumbnail/','/full/'),'http://','https://') MediaUrl
	,'' as MediaCover
	,MediaCaption                                                                                                                 
	,createddate as AddedDate
	,mediaid MediaId                                                                                
	,isnull(nullif(MediaCaption,''),'Others') TagName
	,''  Description 
	FROM	dbo.adsmedia m(NOLOCK)
	WHERE	m.adid		=	@lv_adid

set nocount off;

end
GO
