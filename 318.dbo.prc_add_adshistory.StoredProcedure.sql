/****** Object:  StoredProcedure [dbo].[prc_add_adshistory]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[prc_add_adshistory]
@userpid int /*Advertiser Pid or  Internal User Pid*/ 
,@action varchar(32)
,@tvp_adids split_adsid readonly
,@comments varchar(512)
,@landingurl varchar(512)
,@currenturl varchar(512)
,@sourceurl varchar(512)
,@ip varchar(16)
,@UserDevice varchar(512) /*useragent*/
,@devicetype varchar(128) /*Desktop,Tablet,Mobile*/
as
begin

begin try

insert into adshistory(userpid,[action],AdId,versionno,comments,jsondata
				,landingurl,currenturl,sourceurl,ip,userdevice,devicetype)
	select @userpid,@action,ta.adid,isnull(max(ah.versionno),0)+1,@comments,dbo.fn_convert_ads_json(ta.adid)
			,@landingurl,@currenturl,@sourceurl,@ip,@userdevice,@devicetype
		from @tvp_adids ta 
			left join adshistory ah (nolock) on ta.adid = ah.AdId
	group by ta.adid

end try
begin catch

	exec prc_insert_errorinfo

end catch

end

GO
