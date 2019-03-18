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
ALTER PROCEDURE prc_get_ad_images                                                 
@adid		BIGINT
AS
BEGIN

SET NOCOUNT ON;

	SELECT	m.adid,m.mediatypeid,m.mediaurl,m.mediacaption TagName,m.createddate
	FROM	dbo.adsmedia m(NOLOCK)
	WHERE	m.adid		=	@adid

SET NOCOUNT OFF;

END
GO
