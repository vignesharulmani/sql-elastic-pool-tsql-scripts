/****** Object:  StoredProcedure [dbo].[prc_add_bannermapping]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_add_bannermapping]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_add_bannermapping] AS'
END
GO
Alter procedure prc_add_bannermapping
@bannerid bigint
,@adid bigint
,@bannertypeattributevalueid int
,@roundid int = 0
,@isactive int
as
begin

declare @cityid int = 0

set @roundid = dbo.fn_get_roundid(@bannertypeattributevalueid)
set @cityid = dbo.fn_get_cityid_adid(@bannerid)

	delete from bannermapping where bannerid = @bannerid
	
	/*To get Next value*/
	if 	@roundid = 0 
	set @roundid = (select top 1 1 + max(roundid) from dbo.bannermapping (nolock) where roundid > 0
		and bannertypeattributevalueid not in (973624,973625,973626,973627) /*exclude titanium & platinum*/ 
				   )

	if isnull(@roundid,0)=0
		set @roundid = 1

	insert into bannermapping(bannerid,adid,bannertypeattributevalueid,roundid,isactive,crdate,cityid)
		values (@bannerid,@adid,@bannertypeattributevalueid,@roundid,@isactive,getdate(),@cityid)


end
GO