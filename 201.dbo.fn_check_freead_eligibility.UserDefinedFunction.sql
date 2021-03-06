/****** Object:  UserDefinedFunction [dbo].[fn_check_freead_eligibility]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER function [dbo].[fn_check_freead_eligibility](@cityid int,@mobilenumber varchar(16),@excludeadid bigint)
returns int
as
begin

declare @returnvalue int = 0
,@lv_mobilenumber varchar(16) = isnull(@mobilenumber,'')


select top 1 @returnvalue = am.adid  from dbo.adsmaster am (nolock)
where mobileno = @lv_mobilenumber
/*and am.cityid = @cityid*/
and am.adid <> @excludeadid
and am.status in (1,2)
and am.admode = 100


return(iif(isnull(@returnvalue,0)>0,0,1))

end
GO
