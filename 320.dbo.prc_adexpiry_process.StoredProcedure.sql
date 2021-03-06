/****** Object:  StoredProcedure [dbo].[prc_adexpiry_process]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter procedure prc_adexpiry_process
@rowstofetch int = 100000
as
begin

begin try

declare @tvp_adids split_adsid
declare @tvp_bannerids split_adsid


insert into @tvp_adids (adid)
	select top(@rowstofetch) am.adid from dbo.adsmaster am (nolock) 
		where am.closedate < getdate() 
			and am.status = 1
			and am.closedate <> '1900-01-01'
			and am.subcategoryid in (951,9000,9600) /* PG/Rental/Realestate */
			and am.campaignid = 0 /*Block Customer Ads from Expiry*/
			and not exists (select top 1 1 from dbo.adsneedmapping anm (nolock)
								where anm.adid = am.adid and anm.adclassification = 7)

insert into @tvp_adids (adid)
	select top(@rowstofetch) am.adid from dbo.adsmaster am (nolock) 
		join dbo.adsneedmapping anm (nolock) on am.adid = anm.adid
		where am.closedate < getdate() 
			and am.status = 1
			and am.closedate <> '1900-01-01'
			and am.subcategoryid not in (951,9000,9600) /* Other than Sulekha Property categories */
			and anm.adclassification = 2


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
	
	exec dbo.prc_process_auto_adextension

end try
begin catch

	exec dbo.prc_insert_errorinfo

end catch

end
GO
