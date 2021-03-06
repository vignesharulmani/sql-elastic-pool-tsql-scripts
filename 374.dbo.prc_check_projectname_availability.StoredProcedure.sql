/****** Object:  StoredProcedure [dbo].[prc_check_projectname_availability]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_check_projectname_availability]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_check_projectname_availability] AS'
END
GO
Alter procedure prc_check_projectname_availability
( @cityid int = 0,  @areaid int=0, @projectname varchar(256)='',@projectid bigint = 0)
as 
begin

declare @isexists int = 0
	
	if dbo.fn_get_samerequirement_project(@cityid,@areaid,@projectname,@projectid) > 0
		set @isexists = 1
	
  select @isexists isexists

end
GO
