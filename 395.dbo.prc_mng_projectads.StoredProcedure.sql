/****** Object:  StoredProcedure [dbo].[prc_mng_projectads]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_projectads]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_projectads] AS'
END
GO
Alter procedure [dbo].[prc_mng_projectads]
@projectid bigint,
@businessid int,
@customerid int,
@campaignid int,
@mode int = 0,
@customertype int,
@contactname varchar(128),
@emailid varchar(128),
@mobileno varchar(16),
@status int,
@landingurl varchar(512)='projectbusinessmapping',
@currenturl varchar(512)='projectbusinessmapping',
@sourceurl varchar(512)='prc_mng_projectads',
@UserPid int = 0, /*Advertiser Pid or  Internal User Pid*/ 
@comments varchar(256) = '',
@areaid int = 0,
@areaname varchar(64)='',
@latitude float = 0,
@longitude float = 0,
@streetname varchar(512)='',
@zipcode varchar(64)='',
@landmark varchar(256)='',
@buildingname varchar(128)='',
@buildingno varchar(64)='',
@address varchar(256)=''
as
begin

begin try

declare @tvp_adids split_adsid, 
@modifieddate datetime = getdate(),
@lv_status int = @status,
@lv_projectid bigint = @projectid,
@lv_businessid int = @businessid,
@lv_campaignid int = @campaignid,
@lv_customerid int = @customerid,
@lv_mode int = @mode,
@lv_customertype int = @customertype,
@action varchar(64)='',
@lv_oldareaname varchar(64)='',
@lv_oldaltareaname varchar(64)='',
@lv_areaid int = isnull(@areaid,0),
@lv_areaname varchar(64)=isnull(@areaname,''),
@lv_latitude float = isnull(@latitude,0),
@lv_longitude float = isnull(@longitude,0),
@lv_streetname varchar(512)=isnull(@streetname,''),
@lv_zipcode varchar(64)=isnull(@zipcode,''),
@lv_landmark varchar(256)=isnull(@landmark,''),
@lv_buildingname varchar(128)=isnull(@buildingname,''),
@lv_buildingno varchar(64)=isnull(@buildingno,''),
@lv_address varchar(256)=isnull(@address,''),
@lv_contactname varchar(128)=isnull(@contactname,''),
@lv_emailid varchar(128)=isnull(@emailid,''),
@lv_mobileno varchar(16)=isnull(@mobileno,'')


/*Online page : update contact number*/
if isnull(@lv_areaid,0)>0 and isnull(@lv_mobileno,'') > '' and @lv_projectid > 0 and @lv_businessid > 0
		and not exists (select top 1 1 from dbo.adsmaster am (nolock)
							where am.projectid = @lv_projectid and am.businessid = @lv_businessid 
									and am.mobileno = @lv_mobileno)
begin
	set @comments = 'projectbusinessmobilenochange'
end
else if isnull(@lv_areaid,0)=0 and isnull(@lv_status,0) = 0 and isnull(@lv_contactname,'') = '' 
				and isnull(@lv_emailid,'') = '' and isnull(@lv_mobileno,'') = ''
begin
	set @comments = 'projectbusinessdisabled'
	set @lv_status = 6
	set @action = 'Project Business Disabled'
end
else if isnull(@lv_areaid,0)=0 and isnull(@lv_status,0) <> 0 
			and (isnull(@lv_contactname,'') > '' or isnull(@lv_emailid,'') > '' or isnull(@lv_mobileno,'') > '')
begin
	set @comments = 'projectbusinessenabled'
	set @lv_status = 1
end


if isnull(@lv_areaid,0) > 0 and @comments <> 'projectbusinessmobilenochange'
begin
	set @comments = 'projectlocationchange'
end
else if isnull(@lv_areaid,0) > 0 and @comments = 'projectbusinessmobilenochange'
begin
	set @comments = 'projectlocationchange_projectbusinessmobilenochange'
end


if @lv_businessid > 0 and @lv_projectid > 0 and @comments = 'projectbusinessdisabled'
	insert into @tvp_adids(adid)
		select am.adid from dbo.adsmaster am (nolock) 
			where am.businessid = @lv_businessid 
				and am.projectid = @lv_projectid 
				and am.status = 1
else if @lv_businessid > 0 and @lv_projectid > 0 and @comments = 'projectbusinessenabled'
	insert into @tvp_adids(adid)
		select am.adid from dbo.adsmaster am (nolock) 
			where am.businessid = @lv_businessid 
				and am.projectid = @lv_projectid 
				and am.status in (5,6) /*Disabled via Campaign Expiry/PBM tool*/
				and am.closedate > getdate()
else if @lv_projectid > 0 and @comments = 'projectlocationchange'
begin
	insert into @tvp_adids(adid)
		select am.adid from dbo.adsmaster am (nolock) 
			where am.projectid = @lv_projectid 
				and am.status = 1
				and am.areaid <> @lv_areaid

		select top 1 @lv_oldareaname = am.areaname,@lv_oldaltareaname = am.altareaname 
		from dbo.adsmaster am (nolock) 
			where am.projectid = @lv_projectid 
				and am.status = 1
				and am.areaid <> @lv_areaid
end
else if @lv_projectid > 0 and @comments = 'projectlocationchange_projectbusinessmobilenochange'
begin
	insert into @tvp_adids(adid)
		select am.adid from dbo.adsmaster am (nolock) 
			where am.projectid = @lv_projectid 
				and am.businessid = @lv_businessid
				and am.status = 1

		select top 1 @lv_oldareaname = am.areaname,@lv_oldaltareaname = am.altareaname 
		from dbo.adsmaster am (nolock) 
			where am.projectid = @lv_projectid 
				and am.businessid = @lv_businessid
				and am.status = 1
end


if exists (select top 1 1 from @tvp_adids)
begin

	/*Log AD History during update/delete*/
	exec dbo.prc_add_adshistory @userpid = 0,@action=@action,@tvp_adids=@tvp_adids,@comments=@comments
		,@landingurl=@landingurl,@currenturl=@currenturl,@sourceurl=@sourceurl,@ip=''
		,@UserDevice='',@devicetype=''
	

	/*Log AD Edit History during update/delete*/
	exec dbo.prc_add_adedithistory @tvp_adids=@tvp_adids,@businessid=@lv_businessid,@cityid=0
			,@modifiedpid=@UserPid,@modifiedemailid=''
			,@action=@action,@editedattributes='',@remarks=@comments



	update am 
		set 
			am.contactname = iif(@comments = 'projectbusinessenabled',@lv_contactname,am.contactname),
			am.emailid = iif(@comments = 'projectbusinessenabled',@lv_emailid,am.emailid),
			am.mobileno = iif(@comments in ('projectbusinessenabled','projectlocationchange_projectbusinessmobilenochange'),@lv_mobileno,am.mobileno),
			am.admode = iif(@comments = 'projectbusinessenabled',@lv_mode,am.admode),
			am.campaignid = iif(@comments = 'projectbusinessenabled',@lv_campaignid,am.campaignid),
			am.customerid = iif(@comments = 'projectbusinessenabled' and @lv_customerid > 0,@lv_customerid,am.customerid),
			am.adtitle = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_areaname > '',replace(am.adtitle,@lv_oldareaname,@lv_areaname),am.adtitle),
			am.adurl = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_areaname > '',replace(am.adurl,@lv_oldaltareaname,dbo.fn_get_titleurl(@lv_areaname,'-')),am.adurl),
			am.areaid = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_areaid > 0,@lv_areaid,am.areaid),
			am.areaname = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_areaname > '',@lv_areaname,am.areaname),
			am.altareaname = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and dbo.fn_get_titleurl(@lv_areaname,'-') > '',dbo.fn_get_titleurl(@lv_areaname,'-'),am.altareaname),
			am.displayarea = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_areaname > '',@lv_areaname,am.displayarea),
			am.latitude = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_latitude > 0,@lv_latitude,am.latitude),
			am.longitude = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_longitude > '',@lv_longitude,am.longitude),
			am.streetname = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_streetname > '',@lv_streetname,am.streetname),
			am.zipcode = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_zipcode > '',@lv_zipcode,am.zipcode),
			am.landmark = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_landmark > '',@lv_landmark,am.landmark),
			am.buildingname = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_buildingname > '',@lv_buildingname,am.buildingname),
			am.buildingno = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_buildingno > '',@lv_buildingno,am.buildingno),
			am.address = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_address > '',@lv_address,am.address),
			am.modifieddate = @modifieddate,
			am.status = @lv_status
		from dbo.adsmaster am (nolock)
			inner join @tvp_adids ta on ta.adid = am.adid
	
	update am 
		set am.modifieddate = @modifieddate,
			am.status = @lv_status
		from dbo.adsmedia am (nolock)
			inner join @tvp_adids ta on ta.adid = am.adid
	
	/*For Recent sorting we are updating crdate in adsneedmapping table*/
	update anm 
		set 
			anm.mode = iif(@comments = 'projectbusinessenabled',@lv_mode,anm.mode),
			anm.campaignid = iif(@comments = 'projectbusinessenabled',@lv_campaignid,anm.campaignid),
			anm.areaid = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_areaid > 0,@lv_areaid,anm.areaid),
			anm.areaname = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_areaname > '',@lv_areaname,anm.areaname),
			anm.crdate = @modifieddate,
			anm.modifieddate = @modifieddate,
			anm.status = @lv_status
		from dbo.adsneedmapping anm (nolock)
			inner join @tvp_adids ta on ta.adid = anm.adid
	
	update asam 
		set 
			asam.mode = iif(@comments = 'projectbusinessenabled',@lv_mode,asam.mode),
			asam.campaignid = iif(@comments = 'projectbusinessenabled',@lv_campaignid,asam.campaignid),
			asam.areaid = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_areaid > 0,@lv_areaid,asam.areaid),
			asam.modifieddate = @modifieddate,
			asam.status = @lv_status,
			asam.attributevalueid = iif(@comments = 'projectbusinessenabled' 
										and asam.attributeid = 286500 and isnull(@lv_customertype,0)>0,
										@lv_customertype,asam.attributevalueid)
		from dbo.adssubcatattributemapping asam (nolock)
			inner join @tvp_adids ta on ta.adid = asam.adid

	
	update asm 
		set 
			asm.mode = iif(@comments = 'projectbusinessenabled',@lv_mode,asm.mode),
			asm.campaignid = iif(@comments = 'projectbusinessenabled',@lv_campaignid,asm.campaignid),
			asm.areaid = iif(@comments in ('projectlocationchange','projectlocationchange_projectbusinessmobilenochange') and @lv_areaid > 0,@lv_areaid,asm.areaid),
			asm.modifieddate = @modifieddate,
			asm.status = @lv_status
		from dbo.adssubcatmapping asm (nolock)
			inner join @tvp_adids ta on ta.adid = asm.adid


end

end try

begin catch
	

	exec dbo.prc_insert_errorinfo

end catch 	

end
GO
