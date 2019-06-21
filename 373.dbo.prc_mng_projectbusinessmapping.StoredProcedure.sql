/****** Object:  StoredProcedure [dbo].[prc_mng_projectbusinessmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_projectbusinessmapping]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_projectbusinessmapping] AS'
END
GO
Alter procedure prc_mng_projectbusinessmapping
@projectid bigint,
@businessid int,
@customerid int,
@campaignid int,
@customertype int,
@displayprice varchar(128),
@displayarea varchar(64),
@displaybedroom varchar(64),
@displaypropertytype varchar(512),
@contactname varchar(128),
@emailid varchar(128),
@mobileno varchar(16),
@status int
as
begin

if not exists (select top 1 1 from dbo.projectbusinessmapping pbm (nolock) 
					where pbm.projectid = @projectid and pbm.businessid = @businessid) and @projectid > 0
begin
	insert into projectbusinessmapping(projectid,businessid,customerid,campaignid	
							,customertype,displayprice,displayarea,displaybedroom
							,displaypropertytype,crdate,contactname,emailid,mobileno,status)
		select @projectid,@businessid,@customerid,@campaignid	
						,@customertype,@displayprice,@displayarea,@displaybedroom
						,@displaypropertytype,getdate(),@contactname,@emailid,@mobileno,@status



end
else
begin
	
	update projectbusinessmapping
		set displayprice = @displayprice,
			displayarea = @displayarea,
			displaybedroom = @displaybedroom,
			displaypropertytype = @displaypropertytype,
			modifieddate = getdate(),
			status = @status
	where projectid = @projectid and businessid = @businessid and campaignid = @campaignid


end

end
GO
