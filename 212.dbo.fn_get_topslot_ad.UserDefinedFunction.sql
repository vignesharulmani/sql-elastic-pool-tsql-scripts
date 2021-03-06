/****** Object:  UserDefinedFunction [dbo].[fn_get_topslot_ad]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_get_topslot_ad](@adid bigint,@subcategoryid int,@cityid int,@areaid int)
returns int
as
begin
	declare @returnvalue int = 0
	
	select top 1 @returnvalue = position 
	from dbo.topslot_listing bs (nolock) 
	where bs.adid = @adid and bs.subcategoryid = @subcategoryid
	and bs.cityid = @cityid and bs.areaid = @areaid

	return(isnull(@returnvalue,0))

end
GO
