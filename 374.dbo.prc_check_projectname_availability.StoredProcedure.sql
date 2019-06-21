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
ALTER procedure prc_check_projectname_availability
( @cityid int = 0,  @areaid int=0, @projectname varchar(256)='')
as 
begin
	Declare @projectid bigint 


	set @projectid = dbo.fn_get_samerequirement_project(@cityid,@areaid,@projectname,0)


  select iif(isnull(@projectid,0) > 0,1,0) isexists

end
GO
