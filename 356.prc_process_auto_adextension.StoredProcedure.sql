/****** Object:  StoredProcedure [dbo].[prc_process_auto_adextension]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_process_auto_adextension]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_process_auto_adextension] AS'
END
GO
ALTER procedure prc_process_auto_adextension
@duration int = 1
as
begin

begin try

declare @tvp_adids split_adsid
declare @processdatetime datetime = getdate() + @duration

insert into @tvp_adids(adid)
select am.adid from dbo.adsmaster am (nolock)
	join dbo.adsneedmapping anm (nolock) on am.adid = anm.adid
where am.closedate < @processdatetime
and am.status = 1
and am.campaignid > 0
and anm.adclassification in (3,5,6,7) /*PG,Rental,Realestate,Project*/


	/*Log AD History during update/delete*/
	exec dbo.prc_add_adshistory @userpid = 0,@action='Live',@tvp_adids=@tvp_adids
		,@comments='Auto Ad Extension',@landingurl='prc_process_auto_adextension'
		,@currenturl='prc_process_auto_adextension',@sourceurl='prc_process_auto_adextension'
		,@ip='',@UserDevice='',@devicetype=''

	/*Log AD Edit History during update/delete*/
	exec dbo.prc_add_adedithistory @tvp_adids=@tvp_adids,@businessid=0,@cityid=0
			,@modifiedpid=0,@modifiedemailid=''
			,@action='Live',@editedattributes=''
			,@remarks='Auto Ad Extension'

update am
	set am.listdate = getdate(),
		am.closedate = am.closedate + dbo.fn_get_duration(anm.subcategoryid,anm.needid,anm.addefid,anm.mode),
		am.modifieddate = getdate()
from dbo.adsmaster am (nolock)
	join dbo.adsneedmapping anm (nolock) on am.adid = anm.adid
	join @tvp_adids ta on am.adid = ta.adid

/*For Recent sorting we are updating crdate in adsneedmapping table*/
update anm
	set anm.crdate = getdate(),
		anm.modifieddate = getdate()
from dbo.adsneedmapping anm (nolock) 
	join @tvp_adids ta on anm.adid = ta.adid

update asm
	set asm.modifieddate = getdate()
from dbo.adssubcatmapping asm (nolock) 
	join @tvp_adids ta on asm.adid = ta.adid

update asam
	set asam.modifieddate = getdate()
from dbo.adssubcatattributemapping asam (nolock) 
	join @tvp_adids ta on asam.adid = ta.adid

update ama
	set ama.modifieddate = getdate()
from dbo.adsmedia ama (nolock) 
	join @tvp_adids ta on ama.adid = ta.adid

end try

begin catch

	exec dbo.prc_insert_errorinfo

end catch


end
GO
