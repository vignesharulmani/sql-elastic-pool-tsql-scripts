/****** Object:  UserDefinedFunction [dbo].[fn_get_attribute_validateattribute]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter function fn_get_attribute_validateattribute(@addefid int,@validatingfor varchar(128))
returns @returntable table (attributeid int,sortindex int)
as
begin
	
	if @addefid = 51900 and @validatingfor= 'recommendation'
		insert into @returntable(attributeid)
			select attributeid from (values(53188),(161800),(251200),(253126))x(attributeid)
	else if @addefid = 52002 and @validatingfor= 'recommendation'
		insert into @returntable(attributeid)
			select attributeid from (values(53188),(251200),(253123),(253126),(253127))x(attributeid)
	return
end
GO
