/****** Object:  StoredProcedure [dbo].[prc_mng_offers]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_offers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_offers] AS'
END
GO
Alter procedure [dbo].[prc_mng_offers]
 @tvp_adids split_adsid readonly
,@landingurl varchar(512)
,@currenturl varchar(512)
,@sourceurl varchar(512)
,@sourcekeyword varchar(128)
,@ip varchar(16)
,@UserDevice varchar(512) /*useragent*/
,@devicetype varchar(128) /*Desktop,Tablet,Mobile*/
,@UserPid int /*Advertiser Pid or  Internal User Pid*/ 
,@useremailid varchar(128)='' /*Advertiser email or internal user email*/
,@comments varchar(256)
,@status int = 1
,@action varchar(32)='Live'
,@pagetype varchar(64)='Manual'
,@businessid int = 0
,@cityid int = 0
,@IsSuccess bit output 
as
begin

begin try

declare @modifieddate datetime = getdate()
declare @offer varchar(256)='1' /*Default : Book Now Option*/

if @action not in ('Live','LeadStart') /*'Expired','Pause','Paused','LeadStop'*/
	set @offer = 'hide'


if exists (select top 1 1 from @tvp_adids)
begin

	/*Log AD History during update/delete*/
	exec dbo.prc_add_adshistory @userpid = @UserPid,@action=@action,@tvp_adids=@tvp_adids,@comments=@comments
		,@landingurl=@landingurl,@currenturl=@currenturl,@sourceurl=@sourceurl,@ip=@ip
		,@UserDevice=@UserDevice,@devicetype=@devicetype
	

	/*Log AD Edit History during update/delete*/
	exec dbo.prc_add_adedithistory @tvp_adids=@tvp_adids,@businessid=@businessid,@cityid=@cityid
			,@modifiedpid=@UserPid,@modifiedemailid=@useremailid
			,@action=@action,@editedattributes='Manage Avail/Book Option',@remarks=@comments

	
	update am 
		set am.modifieddate = @modifieddate,
			am.offer = @offer
		from dbo.adsmaster am (nolock)
			inner join @tvp_adids ta on ta.adid = am.adid
	
	update am 
		set am.modifieddate = @modifieddate
		from dbo.adsmedia am (nolock)
			inner join @tvp_adids ta on ta.adid = am.adid
	
	/*For Recent sorting we are updating crdate in adsneedmapping table*/
	update anm 
		set anm.crdate = iif(@action = 'Live',@modifieddate,anm.crdate),
			anm.modifieddate = @modifieddate
		from dbo.adsneedmapping anm (nolock)
			inner join @tvp_adids ta on ta.adid = anm.adid
	
	update asam 
		set asam.modifieddate = @modifieddate
		from dbo.adssubcatattributemapping asam (nolock)
			inner join @tvp_adids ta on ta.adid = asam.adid
	
	update asm 
		set asm.modifieddate = @modifieddate
		from dbo.adssubcatmapping asm (nolock)
			inner join @tvp_adids ta on ta.adid = asm.adid

	if @@rowcount > 0
		set @IsSuccess = 1
	else
		set @IsSuccess = 0


end

end try

begin catch
	

	exec dbo.prc_insert_errorinfo

end catch 	

end
GO
