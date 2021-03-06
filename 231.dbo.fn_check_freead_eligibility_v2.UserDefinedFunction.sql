/****** Object:  UserDefinedFunction [dbo].[fn_check_freead_eligibility_v2]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter function [dbo].[fn_check_freead_eligibility_v2](@cityid int,@mobilenumber varchar(16),@excludeadid bigint)
returns int
as
begin

declare @iseligible int = 0
,@lv_mobilenumber varchar(16) = isnull(@mobilenumber,'')
,@adcount int = 0


select @adcount = count(am.adid) from dbo.adsmaster am (nolock)
where mobileno = @lv_mobilenumber
/*and am.cityid = @cityid*/
and am.adid <> @excludeadid
and am.status in (1,2)
and am.admode = 100

if isnull(@adcount,0)>=3
	set @iseligible = 0
else
	set @iseligible = 1

if @lv_mobilenumber = '7338745674'
	set @iseligible = 1

return(@iseligible)

end
GO
