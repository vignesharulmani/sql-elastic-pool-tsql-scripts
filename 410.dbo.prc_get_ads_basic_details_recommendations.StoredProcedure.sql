/****** Object:  StoredProcedure [dbo].[prc_get_ads_basic_details_recommendations]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_ads_basic_details_recommendations]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_ads_basic_details_recommendations] AS'
END
GO
Alter PROCEDURE prc_get_ads_basic_details_recommendations
@adid		BIGINT,
@projectid  BIGINT = 0,
@includeimages int = 0,
@attributeidlist varchar(1024)=''
AS
BEGIN

SET NOCOUNT ON;

exec prc_get_ads_basic_details_response @adid =  @adid,@projectid=@projectid,@attributeidlist=@attributeidlist

exec prc_get_recommendation_ads @adid = @adid,@rowstofetch=6

SET NOCOUNT OFF;

END
GO
