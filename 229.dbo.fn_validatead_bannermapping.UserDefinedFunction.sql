/****** Object:  UserDefinedFunction [dbo].[fn_validatead_bannermapping]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER function [dbo].[fn_validatead_bannermapping](@cityid int,@areaid int
,@businessid int,@validateadid bigint,@needid int,@addefid int
,@tvp_needidattribute split_needidattribute_v2 readonly)
returns int
as
begin

declare @isvalidationpassed int = 0

if exists (select top 1 1 from dbo.adsneedmapping anm (nolock) 
						join dbo.adssubcatmapping asm (nolock) on anm.adid = asm.adid
				where asm.adid = @validateadid and asm.status = 1 and asm.cityid = @cityid 
				and asm.areaid = @areaid and asm.businessid = @businessid
				and anm.needid = @needid)
begin
	set @isvalidationpassed = 1
end

return(@isvalidationpassed)

end
GO