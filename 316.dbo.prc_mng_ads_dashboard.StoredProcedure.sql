/****** Object:  StoredProcedure [dbo].[prc_mng_ads_dashboard]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_ads_dashboard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_ads_dashboard] AS'
END
GO
Alter procedure prc_mng_ads_dashboard
@adid bigint 
,@projectid bigint
,@businessid int
,@customerid int
,@cityid int
,@posteduserpid int /*Internal User Pid*/
,@UserPid int /*Advertiser Pid*/
,@useremailid varchar(128)='' /*Advertiser or Internal email*/
,@status int 
,@comments varchar(512)='Dashboard'
,@landingurl varchar(512)='Dashboard'
,@currenturl varchar(512)='Dashboard'
,@sourceurl varchar(512)='Dashboard' 
,@ip varchar(16)= '127.0.0.1'
,@UserDevice varchar(512)= ''
,@devicetype varchar(128)= ''
,@IsSuccess bit = 0 output 
,@remarks varchar(64)='' output
as
begin

begin try

declare @modifiedpid int
,@action varchar(32)=''
,@modifieddate datetime = getdate()
,@advpid	int = @UserPid
,@Internaluserpid	int = @posteduserpid
--,@IsSuccess bit

declare @tvp_adids split_adsid

declare @isaccessdenied int = 0
                                                  
if exists (select top 1 1 from adsmaster (nolock) 
				where advpid = @advpid and adid = @adid) or @internaluserpid > 0
	set @isaccessdenied = 0 
else if @adid > 0 and @advpid = 0 and @internaluserpid = 0
	set @isaccessdenied = 0 
else
	set @isaccessdenied = 1

if @businessid > 0  
	and exists (select top 1 1 from adsmaster (nolock) where adid = @adid and businessid = @businessid)
	set @isaccessdenied = 0


if @isaccessdenied = 1
begin
	--select 'access denied' [result]
	set @IsSuccess = 0
	set @remarks = 'access denied'
	return;
end


if @adid > 0
	insert into @tvp_adids(adid) values (@adid)

if @posteduserpid > 0
	set @modifiedpid = @posteduserpid
else 
	set @modifiedpid = @UserPid

if @status = 0
	set @action = 'Dashboard Disabled'
else if @status = 1
	set @action = 'Dashboard Enabled'
else if @status = 2
	set @action = 'Dashboard Deleted'

if @landingurl like '%projectmapping%'
	set @action = 'projectbusinessmapping'

	exec dbo.prc_mng_ads_status @tvp_adids = @tvp_adids
	,@landingurl = @landingurl,@currenturl = @currenturl,@sourceurl = @sourceurl
	,@sourcekeyword = 'Dashboard',@ip = @ip,@UserDevice='',@devicetype=''
	,@UserPid=@modifiedpid,@useremailid=@useremailid,@action=@action,@status=@status
	,@comments=@comments,@businessid=@businessid,@cityid=@cityid,@IsSuccess=@IsSuccess out

--select @action [result],@IsSuccess [IsSuccess]

set @IsSuccess = @IsSuccess
set @remarks = @action

end try
begin catch

	exec dbo.prc_insert_errorinfo

--select 'Fail' [result],0 [IsSuccess]

set @IsSuccess = 0
set @remarks = 'Fail'

end catch

end
GO