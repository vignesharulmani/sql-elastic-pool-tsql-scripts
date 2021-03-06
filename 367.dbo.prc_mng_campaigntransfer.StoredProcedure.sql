/****** Object:  StoredProcedure [dbo].[prc_mng_campaigntransfer]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_campaigntransfer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_campaigntransfer] AS'
END
GO
Alter procedure prc_mng_campaigntransfer
@adid bigint,
@OldCampaignid int, 
@NewCampaignid int,
@Customerid int 
as
begin

begin try

set nocount on;

declare @tvp_adids	split_adsid


declare @msg varchar(max)='{"CampaignTransfer":{"CampaignId" :$CampaignId$,"NewCampaignId":$NewCampaignId$}}'
declare @editedattributes varchar(max) = ''

set @editedattributes = replace(replace(@msg,'$CampaignId$',@OldCampaignid),'$NewCampaignId$',@NewCampaignid)


insert into @tvp_adids(adid)
select a.adid
FROM adsmaster(NOLOCK) a 
JOIN adsneedmapping(NOLOCK) b 
ON a.adid = b.adid
WHERE a.campaignid = @OldCampaignid
AND a.customerid = @Customerid 
AND a.closedate > getdate() - 90
AND a.status = 5
AND (a.adid = @adid or @adid = 0)


/*Log AD History during update/delete*/
exec dbo.prc_add_adshistory @userpid = 0,@action='Transfered',@tvp_adids=@tvp_adids,@comments='Campaign Transfer'
		,@landingurl='',@currenturl='',@sourceurl='',@ip=''
		,@UserDevice='',@devicetype=''

/*Log AD Edit History during update/delete*/
exec dbo.prc_add_adedithistory @tvp_adids=@tvp_adids,@businessid=0,@cityid=0
            ,@modifiedpid=0,@modifiedemailid=''
            ,@action='Transfered',@editedattributes=@editedattributes,@remarks='Campaign Transfer'


UPDATE b 
SET b.campaignid = @NewCampaignid,
	b.modifieddate = GETDATE(),
	b.status = 1

FROM @tvp_adids  a 
JOIN adsneedmapping(NOLOCK) b 
ON a.adid = b.adid



UPDATE b 
SET b.campaignid = @NewCampaignid,
	b.modifieddate = GETDATE(),
	b.status = 1

FROM @tvp_adids a 
JOIN adssubcatmapping(NOLOCK) b 
ON a.adid = b.adid


UPDATE b 
SET b.modifieddate = GETDATE(),
	b.status = 1 

FROM @tvp_adids a 
JOIN adsmedia(NOLOCK) b 
ON a.adid= b.adid	   	



UPDATE b 
SET b.campaignid = @NewCampaignid,
	b.modifieddate = GETDATE(),
	b.status = 1

FROM @tvp_adids a 
INNER JOIN adssubcatattributemapping(NOLOCK) b 
ON a.adid = b.adid 		



UPDATE b 
SET b.campaignid = @NewCampaignid,
	b.modifieddate = GETDATE(),
	b.listdate = GETDATE(),
	b.closedate = GETDATE()+60,
	b.status = 1

FROM @tvp_adids a 
INNER JOIN adsmaster(NOLOCK) b 
ON a.adid = b.adid 


UPDATE b 
SET b.isactive=1,
	b.roundid = 0,
	b.modifieddate = GETDATE()

FROM @tvp_adids a 
INNER JOIN bannermapping(NOLOCK) b 
ON a.adid = b.bannerid 
WHERE b.isactive = 0


insert into campaignactivitylog(campaignid,activity,remarks,crdate)
	select @OldCampaignid,'Transferred - ' + convert(varchar,@NewCampaignid) ,'Transferred',getdate()
	

set nocount off;

end try
begin catch

exec prc_insert_errorinfo

end catch


end
GO
