/****** Object:  StoredProcedure [dbo].[prc_mng_adsfeature]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_adsfeature]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_adsfeature] AS'
END
GO
Alter procedure prc_mng_adsfeature
@adid bigint,
@highlights varchar(max),
@localityhighlights varchar(max),
@longdesc varchar(max)=''
as
begin

if not exists (select top 1 1 from dbo.adsfeature af (nolock) where af.adid = @adid) and @adid > 0
begin
	insert into dbo.adsfeature(adid,highlights,localityhighlights,longdesc)
		values (@adid,@highlights,@localityhighlights,@longdesc)
end
else
begin
	update dbo.adsfeature
		set highlights = isnull(@highlights,highlights)
			,localityhighlights=isnull(@localityhighlights,localityhighlights)
			,longdesc=isnull(@longdesc,longdesc)
	where adid = @adid
end

end
GO
