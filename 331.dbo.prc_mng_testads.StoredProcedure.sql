/****** Object:  StoredProcedure [dbo].[prc_mng_testads]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_testads]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_testads] AS'
END
GO
Alter procedure prc_mng_testads
@adid bigint,
@mobileno varchar(16),
@status int,
@copyadid bigint = 0
as
begin

declare @tvp_adids split_adsid
,@action varchar(32)
,@scopeidentity int = 0
,@adcitycode varchar(4)=''
,@crdate datetime = getdate()


if @copyadid > 0
begin

set @adcitycode = left(convert(varchar,@copyadid),4)

/*insert adsmaster*/
insert into adsmaster
(projectid,businessid,cityname,altcityname,areaname,altareaname,admode,adtitle,adurl
,shortdesc,price,displayarea,campaignid,customerid,latitude
,longitude,streetname,zipcode,contactname
,emailid,mobileno,phoneno,ctcphone,landmark,createddate,modifieddate,cityid,categoryid
,subcategoryid,areaid,remarks,countrycode,subarea,buildingname,buildingno,address,paymentmode
,offer,custominfo,advpid,posteduserpid,posteduseremailid,completionscore,landingurl,currenturl,sourceurl
,sourcekeyword,ip,useragent,devicetype,clienttype,pagesource,listdate,closedate,netsalevalue,status,spadid)
select top 1 projectid,businessid,cityname,altcityname,areaname,altareaname,'105' admode,adtitle,adurl
,shortdesc,price,displayarea,0 campaignid,0 customerid,latitude
,longitude,streetname,zipcode,'ahkelus'contactname
,'ganesunisan@gmail.com' emailid,'7338852451'mobileno,'7338852451'phoneno,'' ctcphone,landmark
,@crdate createddate,null modifieddate,cityid,categoryid
,subcategoryid,areaid,remarks,countrycode,subarea,buildingname,buildingno,address,'' paymentmode
,offer,custominfo,16489184 advpid,0 posteduserpid,'' posteduseremailid,completionscore,'Manage Test Ads API' landingurl
,'' currenturl,'Copyadid' sourceurl,'' sourcekeyword,'127.0.0.1'ip,''useragent,'' devicetype,'' clienttype
,'' pagesource,@crdate listdate,@crdate + 30 closedate,0 netsalevalue,1 status,0 spadid
from adsmaster (nolock) where adid = @copyadid

set @scopeidentity = scope_identity()
set @adid = @adcitycode + convert(varchar,@scopeidentity)

update top(1) adsmaster
	set adid = @adid
where contentid = @scopeidentity


/*insert adsneedmapping*/
insert into adsneedmapping
(adid,subcategoryid,addefid,needid,cityid,areaid,minprice
,crdate,mode,modifieddate,campaignid,netsalevalue,status)
select top 1 @adid,subcategoryid,addefid,needid,cityid,areaid,minprice
,@crdate,'105' mode,null modifieddate,0 campaignid,0 netsalevalue,1 status
from adsneedmapping (nolock) where adid = @copyadid

/*insert adssubcatmapping*/
insert into adssubcatmapping(adid,categoryid,subcategoryid,cityid,areaid
,mode,price,createddate,modifieddate,campaignid,spcategoryid,netsalevalue,status)
select top 1 @adid,categoryid,subcategoryid,cityid,areaid
,'105' mode,price,@crdate createddate,null modifieddate,0 campaignid,spcategoryid,0 netsalevalue,1 status
from adssubcatmapping (nolock) where adid = @copyadid

/*insert adsmedia*/
insert	into adsmedia
(adid,medianame,mediatypeid,mediaurl,mediacaption,tag,createddate,ishidden
,isfeatured,isverified,modifieddate,mediatagid,subcatattributemediatagid,attributeid,status)
select @adid,medianame,mediatypeid,mediaurl,mediacaption,tag,@crdate createddate,ishidden
,isfeatured,isverified,null modifieddate,mediatagid,subcatattributemediatagid,attributeid,1 status
from adsmedia (nolock) where adid = @copyadid

/*insert adssubcatattributemapping*/
insert into adssubcatattributemapping(
adid,subcategoryid,cityid,areaid,price,mode
,createddate,modifieddate,isautomapped,campaignid,isexclude
,adattributemapid,attributeid,attributevalueid,netsalevalue
,status)
select @adid,subcategoryid,cityid,areaid,price,'105' mode
,@crdate createddate,null modifieddate,isautomapped,0 campaignid,isexclude
,adattributemapid,attributeid,attributevalueid,0 netsalevalue
,1 status
from adssubcatattributemapping (nolock) where adid = @copyadid

select 'Inserted Adid : ' + convert(varchar,@adid) [result]
return;

end


if not exists (select top 1 1 from adsmaster (nolock)
					where mobileno = @mobileno and adid = @adid)
begin
	select 'Unauthorized Access' [result]
	return;
end


insert into @tvp_adids
select adid from adsmaster (nolock)
where mobileno = @mobileno and adid = @adid

if @status = 1
	set @action = 'Live'
else if @status = 0
	set @action = 'Disabled'
else if @status = 2
	set @action = 'Deleted'

exec prc_mng_ads_status @tvp_adids = @tvp_adids
	,@landingurl = 'prc_mng_testads',@currenturl = 'prc_mng_testads'
	,@sourceurl = 'prc_mng_testads',@sourcekeyword = '',@ip = '',@UserDevice=''
	,@devicetype='',@UserPid='',@action=@action,@status=@status,@comments='Manage Test Ads'
	,@IsSuccess=1


select 'Updated Adid : ' + convert(varchar,@adid) + ' with status : ' + convert(varchar,@status) [result]
end
GO
