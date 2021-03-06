/****** Object:  StoredProcedure [dbo].[prc_campaignexpiry_process]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_campaignexpiry_process]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_campaignexpiry_process] AS'
END
GO
Alter procedure prc_campaignexpiry_process
@campaignid int,
@businessid int = 0,
@customerid int = 0
as
begin

declare @tvp_adids split_adsid
declare @tvp_bannerids split_adsid

if @campaignid > 0
insert into @tvp_adids (adid)
	select asm.adid from dbo.adssubcatmapping asm (nolock) 
		where asm.campaignid = @campaignid
			and asm.status = 1
			and asm.campaignid > 0
			and not exists (select top 1 1 from dbo.adsneedmapping anm 
								where anm.adid = asm.adid and anm.adclassification = 7)
else if @businessid > 0
insert into @tvp_adids (adid)
	select asm.adid from dbo.adssubcatmapping asm (nolock) 
		where asm.businessid = @businessid
			and asm.status = 1
			and asm.businessid > 0
			and not exists (select top 1 1 from dbo.adsneedmapping anm 
								where anm.adid = asm.adid and anm.adclassification = 7)
else if @customerid > 0
insert into @tvp_adids (adid)
	select am.adid from dbo.adsmaster am (nolock) 
		where am.customerid = @customerid
			and am.status = 1
			and am.closedate <> '1900-01-01'
			and am.customerid > 0
			and not exists (select top 1 1 from dbo.adsneedmapping anm 
								where anm.adid = am.adid and anm.adclassification = 7)

insert into @tvp_bannerids(adid)
	select anm.adid from dbo.adsneedmapping anm (nolock)
		join @tvp_adids ta on anm.adid = ta.adid
		where anm.adclassification = 4


	exec dbo.prc_mng_ads_status @tvp_adids = @tvp_adids
	,@landingurl = 'prc_campaignexpiry_process',@currenturl = 'prc_campaignexpiry_process'
	,@sourceurl = 'prc_campaignexpiry_process',@sourcekeyword = '',@ip = '',@UserDevice=''
	,@devicetype='',@UserPid='',@action='Expired',@status=5,@comments='Campaign Expiry Process'
	,@IsSuccess=1

	exec dbo.prc_delete_bannermapping @tvp_bannerids = @tvp_bannerids

	/*Update Mode=0 and campaignid = 0 in projectbusinessmapping*/

	update pbm
		set pbm.campaignid = 0,
			pbm.mode = 0,
			pbm.modifieddate = getdate(),
			pbm.modifiedby = 'prc_campaignexpiry_process'
	from dbo.projectbusinessmapping pbm (nolock)
	where pbm.campaignid = @campaignid
	and pbm.status = 1



end
GO
