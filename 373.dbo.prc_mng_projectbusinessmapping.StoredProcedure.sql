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
@projectminprice money = 0,
@projectmaxprice money = 0,
@projectminareavalue int = 0,
@projectmaxareavalue int = 0,
@displayprice varchar(128),
@displayarea varchar(64),
@displaybedroom varchar(64),
@displaypropertytype varchar(512),
@contactname varchar(128),
@emailid varchar(128),
@mobileno varchar(16),
@status int,
@businessname varchar(128),
@businessurl varchar(128),
@postedby varchar(128)='',
@mapid int = 0,
@UserPid int = 0, /*Advertiser Pid or  Internal User Pid*/ 
@comments varchar(256) = '',
@isSuccess int = 0 output
as
begin

begin try

declare @businesstitleurl varchar(128)

set @businesstitleurl = dbo.fn_get_titleurl(@businessname,'-')
/*Online Project Posting & ProjectBusinessMapping tool*/
if  @projectid > 0 and not exists (select top 1 1 from dbo.projectbusinessmapping pbm (nolock) 
					where pbm.projectid = @projectid and pbm.businessid = @businessid 
					and pbm.customerid = @customerid and pbm.campaignid = @campaignid
					and pbm.status = 1) and @mapid = 0
begin
	insert into projectbusinessmapping(projectid,businessid,customerid,campaignid	
							,customertype,minprice,maxprice,minareavalue,maxareavalue
							,displayprice,displayarea,displaybedroom,displaypropertytype
							,crdate,contactname,emailid,mobileno,status
							,businessname,businesstitleurl,businessurl,createdby)
		select @projectid,@businessid,@customerid,@campaignid	
						,@customertype,@projectminprice,@projectmaxprice,@projectminareavalue,@projectmaxareavalue
						,@displayprice,@displayarea,@displaybedroom,@displaypropertytype
						,getdate(),@contactname,@emailid,@mobileno,@status
						,@businessname,@businesstitleurl,@businessurl,@postedby


	set @isSuccess = 1

end
else if @mapid = 0 /*Online project Ad posting*/
begin
	
	update projectbusinessmapping
		set minprice = isnull(nullif(@projectminprice,0),minprice),
			maxprice = isnull(nullif(@projectmaxprice,0),maxprice),
			minareavalue = isnull(nullif(@projectminareavalue,0),minareavalue),
			maxareavalue = isnull(nullif(@projectmaxareavalue,0),maxareavalue),
			displayprice = isnull(nullif(@displayprice,''),displayprice),
			displayarea = isnull(nullif(@displayarea,''),displayarea),
			displaybedroom = isnull(nullif(@displaybedroom,''),displaybedroom),
			displaypropertytype = isnull(nullif(@displaypropertytype,''),displaypropertytype),
			modifieddate = getdate(),
			status = @status,
			modifiedby = @postedby
	where projectid = @projectid and businessid = @businessid
	and customerid = @customerid and campaignid = @campaignid
	and status = 1

	set @isSuccess = 1

end
else if @mapid > 0 /*Disable in projectbusinessmapping tool*/
begin

	update projectbusinessmapping
		set modifieddate = getdate(),
			status = @status,
			modifiedby = @postedby
	where rowid = @mapid

	set @isSuccess = 1

end

end try
begin catch
	
	set @isSuccess = 0

	exec dbo.prc_insert_errorinfo

end catch

end
GO
