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
,@startdate datetime = null
,@enddate datetime = null
as
begin

declare @cityid int = 0

set @roundid = dbo.fn_get_roundid(@bannertypeattributevalueid)
set @cityid = dbo.fn_get_cityid_adid(@bannerid)

	delete from bannermapping where bannerid = @bannerid

	/*To get Next value for premium gallery banners*/ 
	if exists (select top 1 1 from dbo.attributevaluepriority avp (nolock) 
					where avp.attributevalue = 'Premium Gallery' 
						and avp.attributevalueid = @bannertypeattributevalueid)
	set @roundid = (
						select top 1 1 + max(bm.roundid) from dbo.bannermapping bm (nolock) 
							where bm.roundid > 0
								and exists (select top 1 1 from attributevaluepriority avp (nolock) 
											where avp.attributevalueid = bm.bannertypeattributevalueid 
											and avp.isactive = 1 
											and bm.bannertypeattributevalueid = @bannertypeattributevalueid) 
				   )

	if isnull(@roundid,0)=0 and exists (select top 1 1 from dbo.attributevaluepriority avp (nolock) 
											where avp.attributevalue = 'Premium Gallery' 
												and avp.attributevalueid = @bannertypeattributevalueid)
	begin
		set @roundid = 5
	end

	insert into bannermapping(bannerid,adid,bannertypeattributevalueid
				,roundid,isactive,crdate,cityid,startdate,enddate)
		values (@bannerid,@adid,@bannertypeattributevalueid
				,@roundid,@isactive,getdate(),@cityid,@startdate,@enddate)


end
GO