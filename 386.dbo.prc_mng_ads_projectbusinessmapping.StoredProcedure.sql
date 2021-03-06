/****** Object:  StoredProcedure [dbo].[prc_mng_ads_projectbusinessmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_ads_projectbusinessmapping]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_ads_projectbusinessmapping] AS'
END
GO
Alter procedure [dbo].[prc_mng_ads_projectbusinessmapping]
@mapid int
,@UserPid int /*Advertiser Pid or  Internal User Pid*/ 
,@comments varchar(256)
as
begin

begin try

declare @modifieddate datetime = getdate()
declare @tvp_adids split_adsid 

declare @lv_projectid bigint
,@lv_businessid int
,@lv_customerid int
,@lv_campaignid int
,@lv_customertypevalueid int
,@lv_status int
,@cityid int

select @lv_projectid = pbm.projectid,@lv_businessid = pbm.businessid,@lv_customerid = pbm.customerid
,@lv_campaignid = pbm.campaignid,@lv_customertypevalueid= pbm.customertype,@lv_status = pbm.status 
from dbo.projectbusinessmapping pbm (nolock) 
where pbm.rowid = @mapid

set @cityid = left(@lv_projectid,4) - 1000

insert into @tvp_adids(adid)
select am.adid 
from dbo.adsmaster am (nolock)
where am.contentid > 0
and am.projectid = @lv_projectid
and am.businessid = @lv_businessid
and am.status = 1


if exists (select top 1 1 from @tvp_adids)
begin

	/*Log AD History during update/delete*/
	exec dbo.prc_add_adshistory @userpid = @UserPid,@action='Update',@tvp_adids=@tvp_adids,@comments=@comments
		,@landingurl='prc_mng_ads_projectbusinessmapping',@currenturl='prc_mng_ads_projectbusinessmapping'
		,@sourceurl='prc_mng_ads_projectbusinessmapping',@ip='127.0.0.1'
		,@UserDevice='',@devicetype=''
	

	/*Log AD Edit History during update/delete*/
	exec dbo.prc_add_adedithistory @tvp_adids=@tvp_adids,@businessid=@lv_businessid,@cityid=@cityid
			,@modifiedpid=@UserPid,@modifiedemailid=''
			,@action='Update',@editedattributes='',@remarks=@comments

	update am 
		set am.modifieddate = @modifieddate,
			am.status = @lv_status,
			am.campaignid = @lv_campaignid,
			am.listdate = @modifieddate,
			am.closedate = @modifieddate + 60
		from dbo.adsmaster am (nolock)
			inner join @tvp_adids ta on ta.adid = am.adid
	
	update am 
		set am.modifieddate = @modifieddate,
			am.status = @lv_status
		from dbo.adsmedia am (nolock)
			inner join @tvp_adids ta on ta.adid = am.adid
	
	/*For Recent sorting we are updating crdate in adsneedmapping table*/
	update anm 
		set anm.crdate = @modifieddate,
			anm.modifieddate = @modifieddate,
			anm.campaignid = @lv_campaignid,
			anm.status = @lv_status
		from dbo.adsneedmapping anm (nolock)
			inner join @tvp_adids ta on ta.adid = anm.adid
	
	update asam 
		set asam.modifieddate = @modifieddate,
			asam.campaignid = @lv_campaignid,
			asam.status = @lv_status
		from dbo.adssubcatattributemapping asam (nolock)
			inner join @tvp_adids ta on ta.adid = asam.adid

	/*To change advertiser type*/
	update asam 
		set asam.modifieddate = @modifieddate,
			asam.campaignid = @lv_campaignid,
			asam.attributevalueid = @lv_customertypevalueid,
			asam.status = @lv_status
		from dbo.adssubcatattributemapping asam (nolock)
			inner join @tvp_adids ta on ta.adid = asam.adid
		where asam.attributeid = 286500

	update asm 
		set asm.modifieddate = @modifieddate,
			asm.campaignid = @lv_campaignid,
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
