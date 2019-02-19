/****** Object:  StoredProcedure [dbo].[prc_delete_bannermapping]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_delete_bannermapping]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_delete_bannermapping] AS'
END
GO
ALTER procedure [dbo].[prc_delete_bannermapping]
@tvp_bannerids split_adsid readonly
as
begin

begin try

delete bm from dbo.bannermapping bm (nolock)
where exists (select top 1 1 from @tvp_bannerids tb where tb.adid=bm.bannerid)

end try

begin catch
	
	exec dbo.prc_insert_errorinfo

end catch 	

end
GO
