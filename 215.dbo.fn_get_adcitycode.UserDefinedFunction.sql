/****** Object:  UserDefinedFunction [dbo].[fn_get_adcitycode]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter function fn_get_adcitycode(@cityid int)
returns varchar(4)
as
begin

declare @outputvalue varchar(4)=''

if @cityid > 0 and @cityid <> 9999
	set @outputvalue = @cityid + 1000 
else
	set @outputvalue  = @cityid	

return(@outputvalue)

end
GO
