/****** Object:  UserDefinedFunction [dbo].[fn_get_attribute_validateattribute]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter function fn_get_attribute_validateattribute(@addefid int,@validatingfor varchar(128))
returns @returntable table (attributeid int,sortindex int)
as
begin
	
	/*PG/Hostel*/
	if @addefid = 51900 and @validatingfor= 'recommendation'
		insert into @returntable(attributeid)
			select attributeid from (values(53188),(161800),(251200),(253126))x(attributeid)
	/*Flatmates*/
	else if @addefid = 52002 and @validatingfor= 'recommendation' 
		insert into @returntable(attributeid)
			select attributeid from (values(53188),(251200),(253123),(253126),(253127))x(attributeid)
	/*Residential Rental Ads*/
	else if @addefid = 59500 and @validatingfor= 'recommendation'
		insert into @returntable(attributeid)
			select attributeid from (values(256200),(256203),(256207),(270100))x(attributeid)
	/*Commercial Rental Ads*/
	else if @addefid = 59700 and @validatingfor= 'recommendation'
		insert into @returntable(attributeid)
			select attributeid from (values(256200),(256203),(270100))x(attributeid)
	/*Residential Realestate Ads/Resale Ads*/
	else if @addefid in (62500,67400) and @validatingfor= 'recommendation'
		insert into @returntable(attributeid)
			select attributeid from (values(281500),(281501),(281600),(293000))x(attributeid)
	/*Commercial Realestate Ads*/
	else if @addefid in (64200,67500) and @validatingfor= 'recommendation'
		insert into @returntable(attributeid)
			select attributeid from (values(281500),(281600),(293000))x(attributeid)
	/*Plots & Land Ads*/
	else if @addefid = 66500 and @validatingfor= 'recommendation'
		insert into @returntable(attributeid)
			select attributeid from (values(281500),(281600),(293000))x(attributeid)
	return
end
GO
