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
@adid int,
@mediatypeid int = 1
as
begin

set nocount on;

select 
	adid
	,mediatypeid as BusinessMediaType
	,replace(replace(MediaUrl,'/thumbnail/','/full/'),'http://','https://') MediaUrl
	,'' as MediaCover
	,MediaCaption                                                                                                                 
	,createddate as AddedDate
	,mediaid MediaId                                                                                
	,MediaCaption TagName                                                                                              
	,''  Description 
	--,0 attributeid
from adsmedia (nolock)
where adid = @adid
and (mediatypeid = @mediatypeid or isnull(@mediatypeid,0)=0)

set nocount off;

end
GO
