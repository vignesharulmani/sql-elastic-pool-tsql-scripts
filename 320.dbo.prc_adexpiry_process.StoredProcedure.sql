/****** Object:  StoredProcedure [dbo].[prc_adexpiry_process]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure prc_adexpiry_process
@rowstofetch int = 100000
as
begin

declare @tvp_adids split_adsid
declare @tvp_bannerids split_adsid

insert into @tvp_adids (adid)
	select top(@rowstofetch) am.adid from dbo.adsmaster am (nolock) 
		where am.closedate < getdate() 
			and am.status = 1
			and am.closedate <> '1900-01-01'

insert into @tvp_bannerids(adid)
	select anm.adid from dbo.adsneedmapping anm (nolock)
		join @tvp_adids ta on anm.adid = ta.adid
		where anm.adclassification = 4
	

	exec dbo.prc_mng_ads_status @tvp_adids = @tvp_adids
	,@landingurl = 'prc_adexpiry_process',@currenturl = 'prc_adexpiry_process'
	,@sourceurl = 'prc_adexpiry_process',@sourcekeyword = '',@ip = '',@UserDevice=''
	,@devicetype='',@UserPid='',@action='Expired',@status=3,@comments='Expiry Process'
	,@IsSuccess=1

	exec dbo.prc_delete_bannermapping @tvp_bannerids = @tvp_bannerids

	exec dbo.prc_adlive_process @rowstofetch = @rowstofetch

end
GO
