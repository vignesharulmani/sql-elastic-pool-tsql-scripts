/****** Object:  StoredProcedure [dbo].[prc_process_manageads]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_process_manageads]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_process_manageads] AS'
END
GO
Alter procedure prc_process_manageads
@adid bigint,
@newmode int = -2,
@newcampaignid int = -2,
@newbusinessid int = -2,
@newareaid int = -2,
@newareaname varchar(64) = '',
@newcityid int = -2,
@newcity varchar(64) = '',
@newstartdate datetime = null,
@newenddate datetime = null,
@newstatus int = -2
as
begin

declare @modifieddate datetime = getdate()
declare @tvp_adids as split_adsid
declare @oldareaid int, @oldareaname varchar(64),@oldaltareaname varchar(64)

begin try

if exists (select top 1 1 from dbo.adsneedmapping anm (nolock) where anm.adid = @adid and anm.adclassification = 7)
begin

select 2 status,'This is Project' comments

return

end


select top 1 @oldareaid = am.areaid,@oldareaname = am.areaname,@oldaltareaname = am.altareaname 
		from dbo.adsmaster am (nolock) 
			where am.adid = @adid

insert into @tvp_adids(adid) values (@adid)

/*Log AD History during update/delete*/
	exec dbo.prc_add_adshistory @userpid = 0,@action='',@tvp_adids=@tvp_adids,@comments='prc_process_manageads'
		,@landingurl='prc_process_manageads',@currenturl='prc_process_manageads',@sourceurl='prc_process_manageads'
		,@ip='127.0.0.1',@UserDevice='',@devicetype=''
	

	/*Log AD Edit History during update/delete*/
	exec dbo.prc_add_adedithistory @tvp_adids=@tvp_adids,@businessid=0,@cityid=0
			,@modifiedpid=0,@modifiedemailid=''
			,@action='',@editedattributes='',@remarks='prc_process_manageads'

	update am 
		set am.modifieddate = @modifieddate,
			am.admode = iif(@newmode>-2,@newmode,am.admode),
			am.campaignid = iif(@newcampaignid>-2,@newcampaignid,am.campaignid),
			am.businessid = iif(@newbusinessid>-2,@newbusinessid,am.businessid),
			am.listdate = iif(@newstartdate is not null,@newstartdate,am.listdate),
			am.closedate = iif(@newenddate is not null,@newenddate,am.closedate),
			am.areaid = iif(@newareaid > -2 and @newareaid <> @oldareaid,@newareaid,am.areaid),
			am.areaname = iif(@newareaid > -2 and @newareaid <> @oldareaid and isnull(@newareaname,'') > '',@newareaname,am.areaname),
			am.altareaname = iif(@newareaid > -2 and @newareaid <> @oldareaid and isnull(@newareaname,'') > '',dbo.fn_get_titleurl(@newareaname,'-'),am.altareaname),
			am.adtitle = iif(@newareaid > -2 and @newareaid <> @oldareaid and isnull(@newareaname,'') > '',replace(am.adtitle,@oldareaname,@newareaname),am.adtitle),
			am.adurl = iif(@newareaid > -2 and @newareaid <> @oldareaid and isnull(@newareaname,'') > '',replace(am.adurl,@oldaltareaname,dbo.fn_get_titleurl(@newareaname,'-')),am.adurl),
			am.status = iif(@newstatus>-2,@newstatus,am.status)
		from dbo.adsmaster am (nolock)
			inner join @tvp_adids ta on ta.adid = am.adid
	
	update am 
		set am.modifieddate = @modifieddate,
			am.status = iif(@newstatus>-2,@newstatus,am.status)
		from dbo.adsmedia am (nolock)
			inner join @tvp_adids ta on ta.adid = am.adid
	
	/*For Recent sorting we are updating crdate in adsneedmapping table*/
	update anm 
		set anm.modifieddate = @modifieddate,
			anm.mode = iif(@newmode>-2,@newmode,anm.mode),
			anm.campaignid = iif(@newcampaignid>-2,@newcampaignid,anm.campaignid),
			anm.areaid = iif(@newareaid > -2 and @newareaid <> @oldareaid,@newareaid,anm.areaid),
			anm.areaname = iif(@newareaid > -2 and @newareaid <> @oldareaid and isnull(@newareaname,'') > '',@newareaname,anm.areaname),
			anm.status = iif(@newstatus>-2,@newstatus,anm.status)
		from dbo.adsneedmapping anm (nolock)
			inner join @tvp_adids ta on ta.adid = anm.adid
	
	update asam 
		set asam.modifieddate = @modifieddate,
			asam.mode = iif(@newmode>-2,@newmode,asam.mode),
			asam.campaignid = iif(@newcampaignid>-2,@newcampaignid,asam.campaignid),
			asam.areaid = iif(@newareaid > -2 and @newareaid <> @oldareaid,@newareaid,asam.areaid),
			asam.status = iif(@newstatus>-2,@newstatus,asam.status)
		from dbo.adssubcatattributemapping asam (nolock)
			inner join @tvp_adids ta on ta.adid = asam.adid
	
	update asm 
		set asm.modifieddate = @modifieddate,
			asm.mode = iif(@newmode>-2,@newmode,asm.mode),
			asm.campaignid = iif(@newcampaignid>-2,@newcampaignid,asm.campaignid),
			asm.businessid = iif(@newbusinessid>-2,@newbusinessid,asm.businessid),
			asm.areaid = iif(@newareaid > -2 and @newareaid <> @oldareaid,@newareaid,asm.areaid),
			asm.status = iif(@newstatus>-2,@newstatus,asm.status)
		from dbo.adssubcatmapping asm (nolock)
			inner join @tvp_adids ta on ta.adid = asm.adid

	
	select 1 status,'Success' comments

end try
begin catch

	exec prc_insert_errorinfo

	select -1 status,'Fail' comments

end catch

end
GO
