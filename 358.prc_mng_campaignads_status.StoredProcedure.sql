/****** Object:  StoredProcedure [dbo].[prc_mng_campaignads_status]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_campaignads_status]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_campaignads_status] AS'
END
GO
Alter procedure prc_mng_campaignads_status
@campaignid int,
@campaignstatus varchar(32),
@adclassification int = 0
as
begin

begin try

declare @tvp_adids split_adsid
declare @tvp_bannerids split_adsid
declare @oldadstatus int,@newadstatus int,@adscount int = 0,@getdate date 

set @getdate = getdate()

if @campaignstatus in ('Expired','Pause','Paused')
	select @oldadstatus = 1, @newadstatus=5
else if @campaignstatus in ('Live','New','Cleared')
	select @oldadstatus = 5, @newadstatus=1

if @campaignid > 0
insert into @tvp_adids (adid)
	select am.adid from dbo.adsmaster am (nolock) 
		where am.adid > 0
			and am.campaignid > 0
			and am.campaignid = @campaignid
			and am.closedate >= @getdate 
			and am.status = @oldadstatus

	select @adscount = count(1) from @tvp_adids

	exec dbo.prc_mng_ads_status @tvp_adids = @tvp_adids
	,@landingurl = 'prc_mng_campaignads_status',@currenturl = 'prc_mng_campaignads_status'
	,@sourceurl = 'prc_mng_campaignads_status',@sourcekeyword = '',@ip = '',@UserDevice=''
	,@devicetype='',@UserPid='',@action=@campaignstatus,@status=@newadstatus
	,@comments='Manage Campaign Ad Status',@IsSuccess=1

	if @campaignstatus in ('Expired','Pause','Paused')
	begin

		insert into @tvp_bannerids(adid)
		select anm.adid from dbo.adsneedmapping anm (nolock)
			join @tvp_adids ta on anm.adid = ta.adid
			where anm.adclassification = 4

		exec dbo.prc_delete_bannermapping @tvp_bannerids = @tvp_bannerids
	end

	select isnull(@adscount,0) [adscount]

end try

begin catch

	exec dbo.prc_insert_errorinfo

end catch

end
GO