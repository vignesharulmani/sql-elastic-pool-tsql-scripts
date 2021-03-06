/****** Object:  StoredProcedure [dbo].[prc_add_adsmaster]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_add_adsmaster]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_add_adsmaster] AS'
END
GO
ALTER procedure [dbo].[prc_add_adsmaster]
@adid bigint 
,@projectid int
,@businessid int
,@customerid int
,@campaignid int
,@cityid int
,@cityname varchar(64)
,@localityid int
,@localityname varchar(128)
,@categoryid int
,@subcategoryid int
,@parentneedid int /*Needid*/
,@NeedDefinitionId int /*Addefid*/
,@lat float
,@lng float
,@formatted_address varchar(256) = ''
,@postal_code varchar(8)
,@UserName varchar(128)
,@UserEmail varchar(128)
,@UserMobileNo varchar(16)
,@countrycode int
,@custominfo nvarchar(max)
,@tvp_needidattribute split_needidattribute_v2 readonly
,@tvp_images split_image readonly
,@mode tinyint /*1-Response,2-Premium,3-Priority,4-Free*/
,@landingurl varchar(512)
,@currenturl varchar(512)
,@sourceurl varchar(512)
,@sourcekeyword varchar(128)
,@ip varchar(16)
,@UserDevice varchar(512) /*useragent*/
,@devicetype varchar(128) /*Desktop,Tablet,Mobile*/
,@posteduserpid int /*Internal User Pid*/
,@PostedUserEmail varchar(128)='' /*Internal User EmailId*/
,@UserPid int /*Advertiser Pid*/
,@adtitle varchar(256)=''
,@shortdesc varchar(4096)=''
,@price money = 0
,@netsalevalue smallint
,@status int = 1/*0-Disabled,1-Live,2-Deleted,3-Expired,4-Futuredate*/
,@completionscore int = 0
,@adtype varchar(32)=''
,@startdate datetime = null 
,@enddate datetime = null 
,@remarks varchar(512) = null
,@oldadid bigint = 0
,@hasduplicate bit output                                   
,@duplicatelistingids varchar(500) output  
,@IsSuccess bit output  
,@InsertedAdid bigint output
,@adstatus varchar(64) output
,@redirecturl varchar(512) output
,@actionstatus varchar(32) output
,@startdate_out datetime = null output 
,@expirydate datetime output
,@comments varchar(512) output
,@adtype_out varchar(32)='' output
,@mode_out tinyint = 0 output
,@businessid_out int = 0 output
,@UserPid_out int = 0 output
,@campaignid_out int = 0 output
,@customerid_out int = 0 output
,@cityid_out int = 0 output
,@cityname_out varchar(64) = '' output
as
begin

set nocount on;

begin try

begin transaction


insert into adpost_proc_param(
adid,projectid,businessid,customerid,campaignid,cityid
,cityname,localityid,localityname,categoryid,subcategoryid
,parentneedid,NeedDefinitionId,lat,lng,formatted_address
,postal_code,UserName,UserEmail,UserMobileNo,countrycode
,custominfo,mode,landingurl,currenturl,sourceurl,sourcekeyword
,ip,UserDevice,devicetype,posteduserpid,UserPid,adtitle,shortdesc
,price,netsalevalue,status,hasduplicate,duplicatelistingids
,IsSuccess,InsertedAdid,adstatus,redirecturl,actionstatus
,expirydate,comments,startdate,enddate
,tvp_needidattribute,tvp_images
)
select 
@adid,@projectid,@businessid,@customerid,@campaignid,@cityid
,@cityname,@localityid,@localityname,@categoryid,@subcategoryid
,@parentneedid,@NeedDefinitionId,@lat,@lng,@formatted_address
,@postal_code,@UserName,@UserEmail,@UserMobileNo,@countrycode
,@custominfo,@mode,@landingurl,@currenturl,@sourceurl,@sourcekeyword
,@ip,@UserDevice,@devicetype,@posteduserpid,@UserPid,@adtitle,@shortdesc
,@price,@netsalevalue,@status,@hasduplicate,@duplicatelistingids
,@IsSuccess,@InsertedAdid,@adstatus,@redirecturl,@actionstatus
,@expirydate,@comments,@startdate,@enddate
,(select * from @tvp_needidattribute for json path)
,(select * from @tvp_images for json path)


declare @crdate datetime = getdate()
,@modifieddate datetime = getdate()
,@contactname varchar(128) = @UserName
,@emailid varchar(128) = @UserEmail
,@posteduseremailid varchar(128) = @PostedUserEmail
,@mobileno varchar(16) = @UserMobileNo
,@phoneno varchar(16) 
,@ctcphone varchar(16)
,@areaid int = isnull(@localityid,0)
,@areaname varchar(128) = @localityname
,@areaurl varchar(128) 
,@cityurl varchar(64) 
,@address varchar(256) = @formatted_address
,@subarea varchar(128)
,@buildingno varchar(64)
,@buildingname varchar(128)
,@streetname varchar(512)
,@zipcode varchar(8) = @postal_code
,@needid int = @parentneedid
,@addefid int = @NeedDefinitionId
,@advpid int = @UserPid
,@useragent varchar(512) = @UserDevice
,@latitude float = @lat
,@longitude float = @lng
,@adtitleurl varchar(256)
,@landmark varchar(256)
,@paymentmode varchar(1024)
,@clienttype varchar(128)
,@pagesource varchar(64)
,@offer varchar(512)
,@mediatypeid int = 1
,@ishidden int = 0
,@isfeatured int = 0
,@isverified int = 0
,@tvp_adids as split_adsid
,@modifiedpid int = 0
,@adddays int = 60
,@isfuturedate int = 0
,@action varchar(32)=''
,@isfreeadeligible int = 0
,@scopeidentity int = 0
,@adcitycode varchar(4)=''
,@AdClassification int = 0


set @hasduplicate = 0
set @cityurl = dbo.fn_Get_TitleUrl(@cityname,'-')
set @areaurl = dbo.fn_Get_TitleUrl(@areaname,'-')
set @adtitleurl = dbo.fn_Get_TitleUrl(@adtitle,'-')
set @AdClassification = dbo.fn_get_adclassification(@adtype)

if @startdate is null or @startdate = '1900-01-01'
	set @startdate = @crdate

if @enddate is null or @enddate = '1900-01-01'
	set @enddate = @startdate + @adddays

if @status = 1 and cast(@startdate as date) > cast(@crdate as date) and @adtype = 'OfferPost'
	select @status = 4,@isfuturedate = 1

if @cityid > 0
	set @adcitycode = dbo.fn_get_adcitycode(@cityid)
	
if (@adtype = 'AdPost') and (@cityid = 0 or @categoryid = 0 or @subcategoryid = 0 or @needid = 0 
						or @addefid = 0 or @areaid = 0) 
begin
	set @hasduplicate =0                                        
	set @duplicatelistingids='' 
	set @IsSuccess = 0
	set @InsertedAdid = 0
	set @adstatus = 'Invalid Data'
	set @redirecturl = '' 
	set @actionstatus = 'Invalid Data'
	set @comments = 'Invalid Data'
	set @startdate_out = cast(@startdate as date)
	set @expirydate = cast(@enddate as date)
	set @adtype_out = @adtype
	set @mode_out = @mode
	set @businessid_out = @businessid
	set @UserPid_out = @UserPid
	set @campaignid_out = @campaignid
	set @customerid_out= @customerid
	set @cityid_out = @cityid
	set @cityname_out = @cityname

	commit transaction
	return; 
end


if (@adtype = 'OfferPost') and (@cityid = 0 or @categoryid = 0 or @subcategoryid = 0 or @needid = 0 
						or @addefid = 0) 
begin
	set @hasduplicate =0                                        
	set @duplicatelistingids='' 
	set @IsSuccess = 0
	set @InsertedAdid = 0
	set @adstatus = 'Invalid Data'
	set @redirecturl = '' 
	set @actionstatus = 'Invalid Data'
	set @comments = 'Invalid Data'
	set @startdate_out = cast(@startdate as date)
	set @expirydate = cast(@enddate as date)
	set @adtype_out = @adtype
	set @mode_out = @mode
	set @businessid_out = @businessid
	set @UserPid_out = @UserPid
	set @campaignid_out = @campaignid
	set @customerid_out= @customerid
	set @cityid_out = @cityid
	set @cityname_out = @cityname

	commit transaction
	return; 
end

if @adtype = 'AdPost'
	set @duplicatelistingids = dbo.fn_get_samerequirement_ads(@cityid,@areaid,@UserMobileNo
										,@customerid,@businessid,@tvp_needidattribute,@adid)
else if @adtype = 'OfferPost'
	set @duplicatelistingids = dbo.fn_get_samerequirement_offers(@cityid,@areaid,@UserMobileNo
										,@customerid,@businessid,@price,@subcategoryid,@needid,@addefid,@adid)

if @duplicatelistingids > '' and len(@duplicatelistingids)>3
	set @hasduplicate = 1

/*dupe ad*/
if @hasduplicate = 1 
begin

	/*assign output param values*/                              
	set @hasduplicate =1                                        
	set @duplicatelistingids = @duplicatelistingids
	set @IsSuccess = 0
	set @InsertedAdid = 0
	set @adstatus = 'Duplicate'
	set @redirecturl = '' 
	set @actionstatus = 'Duplicate'
	set @comments = 'Already posted Ad - ' + @duplicatelistingids + ' for this requirement.'
	set @startdate_out = cast(@startdate as date)
	set @expirydate = cast(@enddate as date)
	set @adtype_out = @adtype
	set @mode_out = @mode
	set @businessid_out = @businessid
	set @UserPid_out = @UserPid
	set @campaignid_out = @campaignid
	set @customerid_out= @customerid
	set @cityid_out = @cityid
	set @cityname_out = @cityname

	commit transaction
	return;

end


if @adcitycode = ''
begin
	set @hasduplicate = 0    
	set @duplicatelistingids = @duplicatelistingids
	set @IsSuccess = 0
	set @InsertedAdid = 0
	set @adstatus = 'City Unavailable'
	set @redirecturl = '' 
	set @actionstatus = 'City Unavailable'
	set @comments = 'City Unavailable'
	set @startdate_out = cast(@startdate as date)
	set @expirydate = cast(@enddate as date)
	set @adtype_out = @adtype
	set @mode_out = @mode
	set @businessid_out = @businessid
	set @UserPid_out = @UserPid
	set @campaignid_out = @campaignid
	set @customerid_out= @customerid
	set @cityid_out = @cityid
	set @cityname_out = @cityname

	commit transaction
	return;
end

if @businessid = 0 and @customerid = 0 and @campaignid = 0 and @adtype = 'AdPost'
	set @isfreeadeligible = dbo.fn_check_freead_eligibility(@cityid,@UserMobileNo,@adid)

if @businessid = 0 and @customerid = 0 and @campaignid = 0 and @isfreeadeligible = 0 and @adtype = 'AdPost'
begin
	set @status = 0 /*Post Ad/Offer in Disabled status*/
end
else if @businessid = 0 and @customerid = 0 and @campaignid = 0 and @adtype = 'OfferPost' 
begin
	set @status = 0 /*Post Ad/Offer in Disabled status*/
end


/*update functionality*/
if @hasduplicate=0 and @adid > 0
begin

insert into @tvp_adids(adid)
	select @adid

if @posteduserpid > 0
	set @modifiedpid = @posteduserpid
else 
	set @modifiedpid = @UserPid


/*Log AD History during update*/
	exec dbo.prc_add_adshistory @userpid = @modifiedpid,@action='Update',@tvp_adids=@tvp_adids
			,@comments=@comments,@landingurl=@landingurl,@currenturl=@currenturl,@sourceurl=@sourceurl
			,@ip=@ip,@UserDevice=@UserDevice,@devicetype=@devicetype

select top 1 @mode = admode
from adsmaster am (nolock)
where adid = @adid

/*update adsmaster*/
update top(1) am
	set shortdesc = isnull(@shortdesc,shortdesc)
		,price = isnull(@price,price)
		,landmark = isnull(@landmark,landmark)
		,modifieddate = @modifieddate
		,remarks = isnull(@remarks,remarks)
		,buildingname = isnull(@buildingname,buildingname)
		,buildingno = isnull(@buildingno,buildingno)
		,address = isnull(@address,address)
		,paymentmode = isnull(@paymentmode,paymentmode)
		,offer = isnull(@offer,offer)
		,custominfo = isnull(@custominfo,custominfo)
		,status = isnull(@status,status)
		,listdate=iif(@adtype = 'OfferPost',isnull(@startdate,listdate),listdate)
		,closedate=iif(@adtype = 'OfferPost',isnull(@enddate,closedate),closedate)
		,adtitle = iif(@adtype = 'OfferPost',isnull(@adtitle,adtitle),adtitle)
		,latitude = isnull(@latitude,latitude)
		,longitude = isnull(@longitude,longitude)
		,areaname = iif(@posteduserpid > 0,isnull(@areaname,areaname),areaname)
		,altareaname = iif(@posteduserpid > 0,isnull(@areaurl,altareaname),altareaname) 
		,areaid = iif(@posteduserpid > 0,isnull(@areaid,areaid),areaid) 
from adsmaster am (nolock)
where adid = @adid

/*update adsneedmapping*/
update top(1) anm
	set minprice = isnull(@price,minprice)
		,modifieddate = @modifieddate
		,status = isnull(@status,status)
from adsneedmapping anm (nolock)
where adid = @adid


/*update adssubcatmapping*/
update top(1) ascm
	set price = isnull(@price,price)
		,modifieddate = @modifieddate
		,status = isnull(@status,status)
from adssubcatmapping ascm
where adid = @adid


/*update - reload adsmedia*/
delete adsmedia where adid = @adid

insert	into adsmedia(adid,medianame,mediatypeid,mediaurl,mediacaption,tag,createddate,ishidden
			,isfeatured,isverified,modifieddate,mediatagid,subcatattributemediatagid,attributeid,status)
select @adid adid,'' medianame,@mediatypeid mediatypeid,imageurl mediaurl
,tag mediacaption,dbo.fn_get_titleurl(tag,'-') tag,@crdate,@ishidden 
,@isfeatured,@isverified,@modifieddate,dbo.fn_get_mediatagid(tag)
,0 subcatattributemediatagid,attributeid,@status 
from @tvp_images where len(imageurl) > 3

/*update - reload adssubcatattributemapping*/
delete adssubcatattributemapping where adid = @adid

insert into adssubcatattributemapping(
adid,subcategoryid,cityid,areaid,price,mode,createddate,modifieddate,isautomapped
,campaignid,isexclude,adattributemapid,attributeid,attributevalueid,netsalevalue,status)
select @adid,@subcategoryid,@cityid,@areaid,@price,@mode mode
,@crdate,@modifieddate,0 isautomapped
,@campaignid,0 isexclude
,0 attributemapid,na.attributeid,na.attributevalueid,@netsalevalue,@status
from @tvp_needidattribute na
where na.attributeid > 0



/*assign output param values*/
if @status = 1
begin
	set @hasduplicate =0                                        
	set @duplicatelistingids='' 
	set @IsSuccess = 1
	set @InsertedAdid = @adid
	set @adstatus = 'Live'
	set @redirecturl = '/'+@adtitleurl+'-' + convert(varchar,@adid) + '-ad' 
	set @actionstatus = 'Updated'
	set @comments = 'Your ad/offer updated successfully'
	set @startdate_out = cast(@startdate as date)
	set @expirydate = cast(@enddate as date)
	set @adtype_out = @adtype
	set @mode_out = @mode
	set @businessid_out = @businessid
	set @UserPid_out = @UserPid
	set @campaignid_out = @campaignid
	set @customerid_out= @customerid
	set @cityid_out = @cityid
	set @cityname_out = @cityname
end
else
begin
	set @hasduplicate =0                                        
	set @duplicatelistingids='' 
	set @IsSuccess = iif(@isfuturedate=0,0,1)
	set @InsertedAdid = @adid
	set @adstatus = iif(@isfuturedate=0,'Disabled','Live')
	set @redirecturl =  '/'+@adtitleurl+'-' + convert(varchar,@adid) + '-ad'
	set @actionstatus = 'Disabled'
	set @comments = iif(@isfuturedate=0,'Ad/Offer has been Disabled','Ad/Offer Will be Live on this date')
	set @startdate_out = cast(@startdate as date)
	set @expirydate = cast(@enddate as date)
	set @adtype_out = @adtype
	set @mode_out = @mode
	set @businessid_out = @businessid
	set @UserPid_out = @UserPid
	set @campaignid_out = @campaignid
	set @customerid_out= @customerid
	set @cityid_out = @cityid
	set @cityname_out = @cityname
end



end
/*insert functionality*/
else if @hasduplicate=0 and @adid = 0 
begin

/*insert adsmaster*/
insert into adsmaster
(projectid,businessid,cityname,altcityname,areaname,altareaname,admode,adtitle,adurl
,shortdesc,price,displayarea,campaignid,customerid,latitude
,longitude,streetname,zipcode,contactname
,emailid,mobileno,phoneno,ctcphone,landmark,createddate,modifieddate,cityid,categoryid
,subcategoryid,areaid,remarks,countrycode,subarea,buildingname,buildingno,address,paymentmode
,offer,custominfo,advpid,posteduserpid,posteduseremailid,completionscore,landingurl,currenturl,sourceurl
,sourcekeyword,ip,useragent,devicetype,clienttype,pagesource,listdate,closedate,netsalevalue,status,referenceid)
select @projectid,@businessid,@cityname,@cityurl,@areaname,@areaurl,@mode,@adtitle,@adtitleurl
,@shortdesc,@price,@areaname,@campaignid,@customerid,@latitude,@longitude,@streetname,@zipcode,@contactname
,@emailid,@mobileno,@phoneno,@ctcphone,@landmark,@crdate,null,@cityid,@categoryid
,@subcategoryid,@areaid,@remarks,@countrycode,@subarea,@buildingname,@buildingno,@address,@paymentmode
,@offer,@custominfo,@advpid,@posteduserpid,@posteduseremailid,@completionscore
,@landingurl,@currenturl,@sourceurl
,@sourcekeyword,@ip,@useragent,@devicetype,@clienttype,@pagesource,@startdate,@enddate,@netsalevalue,@status,@oldadid

set @scopeidentity = scope_identity()
set @adid = @adcitycode + convert(varchar,@scopeidentity)

update top(1) adsmaster
	set adid = @adid
where contentid = @scopeidentity


/*insert adsneedmapping*/
insert into adsneedmapping
(adid,subcategoryid,addefid,needid,cityid,areaid,minprice
,crdate,mode,modifieddate,campaignid,netsalevalue,status,adclassification)
select 
@adid,@subcategoryid,@addefid,@needid,@cityid,@areaid,@price
,@crdate,@mode mode,null,@campaignid,@netsalevalue,@status,@AdClassification 



/*insert adssubcatmapping*/
insert into adssubcatmapping(adid,categoryid,subcategoryid,cityid,areaid
,mode,price,createddate,modifieddate,campaignid,spcategoryid,netsalevalue,businessid,status)
select @adid,@categoryid,@subcategoryid,@cityid,@areaid,@mode mode,@price,@crdate
,null,@campaignid,null spcategoryid,@netsalevalue,@businessid,@status


/*insert adsmedia*/
insert	into adsmedia
(adid,medianame,mediatypeid,mediaurl,mediacaption,tag,createddate,ishidden
,isfeatured,isverified,modifieddate,mediatagid,subcatattributemediatagid,attributeid,status)
select @adid adid,'' medianame,@mediatypeid mediatypeid,imageurl mediaurl
,tag mediacaption,dbo.fn_get_titleurl(tag,'-') tag,@crdate,@ishidden 
,@isfeatured,@isverified,null,dbo.fn_get_mediatagid(tag)
,0 subcatattributemediatagid,attributeid,@status  
from @tvp_images where len(imageurl) > 3


/*insert adssubcatattributemapping*/
insert into adssubcatattributemapping(
adid,subcategoryid,cityid,areaid,price,mode
,createddate,modifieddate,isautomapped,campaignid,isexclude
,adattributemapid,attributeid,attributevalueid,netsalevalue
,status)
select @adid,@subcategoryid,@cityid,@areaid,@price,@mode mode
,@crdate,null,0 isautomapped
,@campaignid,0 isexclude
,0 attributemapid,na.attributeid,na.attributevalueid,@netsalevalue,@status
from @tvp_needidattribute na
where na.attributeid > 0


/*assign output param values*/
if @businessid = 0 and @customerid = 0 and @campaignid = 0 and @isfreeadeligible = 0
begin                          
	set @hasduplicate =0                                        
	set @duplicatelistingids = ''
	set @IsSuccess = 0
	set @InsertedAdid = @adid
	set @adstatus = 'Exceeds' 
	set @redirecturl = '' 
	set @actionstatus = 'Exceeds' 
	set @comments = 'Free Ad/Offer limit exceeds'
	set @startdate_out = cast(@startdate as date)
	set @expirydate = cast(@enddate as date)
	set @adtype_out = @adtype
	set @mode_out = @mode
	set @businessid_out = @businessid
	set @UserPid_out = @UserPid
	set @campaignid_out = @campaignid
	set @customerid_out= @customerid
	set @cityid_out = @cityid
	set @cityname_out = @cityname
end
else if @status = 1
begin
	set @hasduplicate =0                                        
	set @duplicatelistingids='' 
	set @IsSuccess = 1
	set @InsertedAdid = @adid
	set @adstatus = 'Live'
	set @redirecturl = '/'+@adtitleurl+'-' + convert(varchar,@adid) + '-ad'
	set @actionstatus = 'Inserted' 
	set @comments = 'Your ad/Offer posted successfully'
	set @startdate_out = cast(@startdate as date)
	set @expirydate = cast(@enddate as date)
	set @adtype_out = @adtype
	set @mode_out = @mode
	set @businessid_out = @businessid
	set @UserPid_out = @UserPid
	set @campaignid_out = @campaignid
	set @customerid_out= @customerid
	set @cityid_out = @cityid
	set @cityname_out = @cityname
end
else
begin
	set @hasduplicate =0                                        
	set @duplicatelistingids='' 
	set @IsSuccess = iif(@isfuturedate=0,0,1)
	set @InsertedAdid = @adid
	set @adstatus = iif(@isfuturedate=0,'Disabled','Live')
	set @redirecturl = '/'+@adtitleurl+'-' + convert(varchar,@adid) + '-ad'
	set @actionstatus = 'Disabled'
	set @comments = iif(@isfuturedate=0,'Ad/Offer has been Disabled','Ad/Offer Will be Live on this date') 
	set @startdate_out = cast(@startdate as date)
	set @expirydate = cast(@enddate as date)
	set @adtype_out = @adtype
	set @mode_out = @mode
	set @businessid_out = @businessid
	set @UserPid_out = @UserPid
	set @campaignid_out = @campaignid
	set @customerid_out= @customerid
	set @cityid_out = @cityid
	set @cityname_out = @cityname
end

end


commit transaction

end try

begin catch

rollback transaction

	exec dbo.prc_insert_errorinfo

	set @hasduplicate =0                                        
	set @duplicatelistingids='' 
	set @IsSuccess = 0
	set @InsertedAdid = 0
	set @adstatus = 'DB Exception'
	set @redirecturl = '' 
	set @actionstatus = 'DB Exception'
	set @comments = 'DB Exception'
	set @startdate_out = cast(@startdate as date)
	set @expirydate = cast(@enddate as date)
	set @adtype_out = @adtype
	set @mode_out = @mode
	set @businessid_out = @businessid
	set @UserPid_out = @UserPid
	set @campaignid_out = @campaignid
	set @customerid_out= @customerid
	set @cityid_out = @cityid
	set @cityname_out = @cityname

end catch

set nocount off;

end
GO
