/****** Object:  StoredProcedure [dbo].[prc_process_campaigns_adextension]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_process_campaigns_adextension]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_process_campaigns_adextension] AS'
END
GO
Alter procedure prc_process_campaigns_adextension
@tvp_campaignids as split_campaignid readonly,
@duration int = 1
as
begin

begin try

declare @tvp_adids split_adsid
declare @processdatetime datetime = getdate() + @duration

insert into @tvp_adids(adid)
select am.adid from dbo.adsmaster am (nolock)
	join dbo.adsneedmapping anm (nolock) on am.adid = anm.adid
where am.status in (1,3,5) /*Live,Expired,CampaignExpired*/
and am.campaignid > 0
and anm.adclassification in (3,4,5,6,7) /*PG,Banner,Rental,Realestate,Project*/
and exists (select top 1 1 from @tvp_campaignids c where c.campaignid = am.campaignid)

	/*Log AD History during update/delete*/
	exec dbo.prc_add_adshistory @userpid = 0,@action='Live',@tvp_adids=@tvp_adids
		,@comments='Campaign Ad Extension',@landingurl='prc_process_campaigns_adextension'
		,@currenturl='prc_process_campaigns_adextension',@sourceurl='prc_process_campaigns_adextension'
		,@ip='',@UserDevice='',@devicetype=''

	/*Log AD Edit History during update/delete*/
	exec dbo.prc_add_adedithistory @tvp_adids=@tvp_adids,@businessid=0,@cityid=0
			,@modifiedpid=0,@modifiedemailid=''
			,@action='Live',@editedattributes=''
			,@remarks='Campaign Ad Extension'

update am
	set am.listdate = getdate(),
		am.closedate = am.closedate + dbo.fn_get_duration(anm.subcategoryid,anm.needid,anm.addefid,anm.mode),
		am.modifieddate = getdate(),
		am.status = 1
from dbo.adsmaster am (nolock)
	join dbo.adsneedmapping anm (nolock) on am.adid = anm.adid
	join @tvp_adids ta on am.adid = ta.adid

/*For Recent sorting we are updating crdate in adsneedmapping table*/
update anm
	set anm.crdate = getdate(),
		anm.modifieddate = getdate(),
		anm.status = 1
from dbo.adsneedmapping anm (nolock) 
	join @tvp_adids ta on anm.adid = ta.adid

update asm
	set asm.modifieddate = getdate(),
		asm.status = 1
from dbo.adssubcatmapping asm (nolock) 
	join @tvp_adids ta on asm.adid = ta.adid

update asam
	set asam.modifieddate = getdate(),
		asam.status = 1
from dbo.adssubcatattributemapping asam (nolock) 
	join @tvp_adids ta on asam.adid = ta.adid

update ama
	set ama.modifieddate = getdate(),
		ama.status = 1
from dbo.adsmedia ama (nolock) 
	join @tvp_adids ta on ama.adid = ta.adid


insert into campaignactivitylog(campaignid,activity,remarks,crdate)
	select c.campaignid,'Campaign Ad Extension','AdExtension',getdate() 
	from @tvp_campaignids c where c.campaignid > 0

end try
begin catch
	
	exec dbo.prc_insert_errorinfo

end catch

end
GO
