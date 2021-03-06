/****** Object:  StoredProcedure [dbo].[sp]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_ad_paymentstatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_ad_paymentstatus] AS'
END
GO
Alter procedure prc_mng_ad_paymentstatus
@adid bigint,
@status int,
@duration int,
@mode tinyint,
@userpid int,
@ip varchar(16)
as
begin

begin try

declare @closedate datetime 
,@modifieddate datetime = getdate()
,@existingdays int = 0
,@adurl varchar(256)=''

declare @tvp_adids as split_adsid

/*Retreiving paid pending days*/
set @existingdays = (select datediff(dd,getdate(),am.closedate) 
						from adsmaster am (nolock) 
						where adid = @adid 
						and am.status = 1 and am.admode in (3,4,105,110)
						and am.closedate > getdate()) 

set @closedate = getdate() + isnull(@duration,0) + isnull(@existingdays,0)

if @adid > 0
	insert into @tvp_adids values (@adid)

/*Log AD History during update*/
	exec dbo.prc_add_adshistory @userpid = @userpid,@action='Update',@tvp_adids=@tvp_adids
			,@comments='payment attempted',@landingurl='prc_mng_ad_paymentstatus'
			,@currenturl='prc_mng_ad_paymentstatus',@sourceurl='prc_mng_ad_paymentstatus'
			,@ip=@ip,@UserDevice='',@devicetype=''

update top(1) adsmaster 
	set listdate = getdate(),
		closedate =  @closedate,
		admode = @mode,
		status = @status,
		modifieddate = @modifieddate
where adid = @adid

update top(1) adsneedmapping
	set mode = @mode,
		status = @status,
		modifieddate = @modifieddate
where adid = @adid 

update top(1) adssubcatmapping
	set mode = @mode,
		modifieddate = @modifieddate		
where adid = @adid 

update adsmedia
	set status = @status,
		modifieddate = @modifieddate
where adid = @adid

update adssubcatattributemapping 
	set mode = @mode,
		status = @status,
		modifieddate = @modifieddate
where adid = @adid

select top 1 @adurl = adurl from dbo.adsmaster am (nolock) where am.adid = @adid

select 1 [result],@adurl RedirectionUrl

end try
begin catch
	exec dbo.prc_insert_errorinfo
end catch

end
GO
