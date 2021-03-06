/****** Object:  StoredProcedure [dbo].[prc_mng_ad_upgrade]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_ad_upgrade]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_ad_upgrade] AS'
END
GO
Alter procedure prc_mng_ad_upgrade
@adid bigint,
@mode tinyint,
@userpid int,
@ip varchar(16),
@issuccess int output,
@comments varchar(64) output
as
begin

begin try

declare @closedate datetime 
,@getdate datetime = getdate()
,@modifieddate datetime = getdate()
,@existingdays int = 0
,@adurl varchar(256)=''
,@duration int
,@cityid int = 0

declare @tvp_adids as split_adsid

if not exists (select top 1 1 from dbo.adssubcatmapping (nolock) where adid = @adid)
begin
	select @issuccess = 0,@comments='Ad Not Exists' 
	return;
end

if @adid > 0
	set @cityid = left(@adid,4) - 1000

/*Retreiving paid pending days*/
set @existingdays = (select datediff(dd,getdate(),am.closedate) 
						from adsmaster am (nolock) 
						where adid = @adid 
						and am.status = 1 and am.admode in (3,4,105,110)
						and am.closedate > @getdate) 

select top 1 @duration = dbo.fn_get_duration(subcategoryid,needid,addefid,@mode) 
from dbo.adsneedmapping anm (nolock)
where anm.adid = @adid

set @closedate = @getdate + isnull(@duration,0) + isnull(@existingdays,0)

if @adid > 0
	insert into @tvp_adids values (@adid)

/*Log AD History during update*/
	exec dbo.prc_add_adshistory @userpid = @userpid,@action='Update',@tvp_adids=@tvp_adids
			,@comments='Ad Upgrade',@landingurl='prc_mng_ad_upgrade'
			,@currenturl='prc_mng_ad_upgrade',@sourceurl='prc_mng_ad_upgrade'
			,@ip=@ip,@UserDevice='',@devicetype=''

/*Log AD Edit History during update/delete*/
	exec dbo.prc_add_adedithistory @tvp_adids=@tvp_adids,@businessid=0,@cityid=@cityid
			,@modifiedpid=@UserPid,@modifiedemailid=''
			,@action='Upgrade',@editedattributes='',@remarks='Ad Upgrade'

update top(1) adsmaster 
	set listdate = @getdate,
		closedate =  @closedate,
		admode = @mode,
		modifieddate = @modifieddate,
		status=1
where adid = @adid

update top(1) adsneedmapping
	set mode = @mode,
		modifieddate = @modifieddate,
		status=1
where adid = @adid 

update top(1) adssubcatmapping
	set mode = @mode,
		modifieddate = @modifieddate,
		status=1		
where adid = @adid 

update adsmedia
	set modifieddate = @modifieddate,
		status=1
where adid = @adid

update adssubcatattributemapping 
	set mode = @mode,
		modifieddate = @modifieddate,
		status=1
where adid = @adid


select @issuccess = 1,@comments='Success' 

end try
begin catch

select @issuccess = 0,@comments='Fail' 

	exec dbo.prc_insert_errorinfo
end catch

end
GO
