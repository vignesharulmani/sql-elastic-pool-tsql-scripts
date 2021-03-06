/****** Object:  StoredProcedure [dbo].[prc_campaignlive_process]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_campaignlive_process]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_campaignlive_process] AS'
END
GO
ALTER procedure [dbo].[prc_campaignlive_process]
@campaignid int,
@businessid int = 0,
@customerid int = 0
as
begin

declare @tvp_adids split_adsid

insert into @tvp_adids (adid)
	select am.adid from adsmaster am (nolock) 
		where am.campaignid > 0
			and am.campaignid = @campaignid
			and am.listdate < getdate() 
			and am.closedate > getdate() 
			and am.status = 5
			and am.closedate <> '1900-01-01'

	exec prc_mng_ads_status @tvp_adids = @tvp_adids
	,@landingurl = 'prc_campaignlive_process',@currenturl = 'prc_campaignlive_process'
	,@sourceurl = 'prc_campaignlive_process',@sourcekeyword = '',@ip = '',@UserDevice=''
	,@devicetype='',@UserPid='',@action='Live',@status=1,@comments='Campaign Live Process'
	,@IsSuccess=1


end
GO
