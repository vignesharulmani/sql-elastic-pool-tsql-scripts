/****** Object:  UserDefinedFunction [dbo].[fn_get_ad_singleimage_bytag]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_get_ad_singleimage_bytag](@adid bigint,@tagurl varchar(64))
returns varchar(512)
as
begin

declare @returnvalue varchar(512)=''

select top 1 @returnvalue = mediaurl 
	from adsmedia (nolock) where adid = @adid and tag = @tagurl and mediatypeid = 1

if isnull(@returnvalue,'')=''
	select top 1 @returnvalue = mediaurl 
		from adsmedia (nolock) where adid = @adid and mediatypeid = 1

return(@returnvalue)
end
GO
