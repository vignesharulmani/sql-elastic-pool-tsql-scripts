/****** Object:  UserDefinedFunction [dbo].[fn_get_samerequirement_banners]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create function [dbo].[fn_get_samerequirement_banners](@cityid int,@areaid int			,@bannertypeid int,@subcategoryid int,@needid int,@addefid int
			,@excludeadid bigint)
returns varchar(max)
as
begin

declare @returnvalue varchar(max) = ''

select top 1 @returnvalue += convert(varchar(max),anm.adid)
from dbo.adsneedmapping anm (nolock)
	join dbo.bannermapping bm (nolock) on anm.adid = bm.bannerid
where anm.adid > 0
and anm.cityid = @cityid
and anm.areaid = @areaid
and anm.subcategoryid = @subcategoryid
and anm.needid = @needid 
and anm.addefid = @addefid
and anm.adclassification = 4
and anm.status = 1
and bm.bannertypeattributevalueid = @bannertypeid
and bm.isactive = 1
and exists (select top 1 1 from dbo.attributevaluepriority avp (nolock) 
				where avp.attributevalueid = bm.bannertypeattributevalueid)

return(isnull(@returnvalue,''))


end
GO