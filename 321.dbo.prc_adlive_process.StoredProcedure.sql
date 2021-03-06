/****** Object:  StoredProcedure [dbo].[prc_adlive_process]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[prc_adlive_process]
@rowstofetch int = 50
as
begin

declare @tvp_adids split_adsid

insert into @tvp_adids (adid)
	select top(@rowstofetch) am.adid from adsmaster am (nolock) 
		where listdate < getdate() 
			and closedate > getdate() 
			and am.status = 4
			and am.closedate <> '1900-01-01'

	exec prc_mng_ads_status @tvp_adids = @tvp_adids
	,@landingurl = 'prc_adlive_process',@currenturl = 'prc_adlive_process'
	,@sourceurl = 'prc_adlive_process',@sourcekeyword = '',@ip = '',@UserDevice=''
	,@devicetype='',@UserPid='',@action='Live',@status=1,@comments='Live Process'
	,@IsSuccess=1


end
GO
