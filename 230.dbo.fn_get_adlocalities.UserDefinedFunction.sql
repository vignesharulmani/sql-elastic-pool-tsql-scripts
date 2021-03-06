/****** Object:  UserDefinedFunction [dbo].[fn_get_adlocalities]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function fn_get_adlocalities(@adid bigint)
returns varchar(1024)
as
begin

declare @areanames varchar(1024) = '',
@returnvalue varchar(1024)=''

select @areanames = areaname + ',' + @areanames 
from dbo.adsneedmapping anm (nolock) where anm.adid = @adid

if charindex(',',@areanames) > 0
	set @returnvalue = (left(@areanames,len(@areanames)-1))
else
	set @returnvalue = @areanames

	return(@returnvalue)
end
GO