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
Alter procedure [dbo].[prc_add_adsmaster]    
@adid bigint     
,@projectid bigint    
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
,@tvp_areanames split_areaname readonly    
,@mode tinyint /*[0-99]-Response,[4,110]-Premium,[3,105]-Priority,[1,100]-Free*/    
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
,@adtitleurl varchar(256)=''    
,@shortdesc nvarchar(4000)=''    
,@longdesc varchar(max)=''    
,@price money = 0    
,@netsalevalue smallint    
,@status int = 1/*0-Disabled,1-Live,2-Deleted,3-Expired,4-Futuredate*/    
,@completionscore int = 0    
,@adtype varchar(32)=''    
,@AdClassification int = 0    
,@pagesource varchar(64)=''    
,@startdate datetime = null     
,@enddate datetime = null     
,@remarks varchar(512) = null    
,@businessname varchar(128) = null  
,@businessurl varchar(128) = null
,@oldadid bigint = 0    
,@bannertypeid int = 0
,@areavalue int = null
,@areavalueunit varchar(64) = null 
,@customertype int = 0
,@projectminprice money = 0
,@projectmaxprice money = 0
,@projectminareavalue int = 0
,@projectmaxareavalue int = 0
,@displayprice varchar(128)=''    
,@displayarea varchar(64)=''
,@displaybedroom varchar(64)=''
,@displaypropertytype varchar(512)=''
,@highlights varchar(max)=''
,@localityhighlights varchar(max)=''
,@buildingname varchar(128)=''
,@subarea varchar(128)=''  
,@offer varchar(512)=''      
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
,@AdClassification_out int = 0 output    
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
,tvp_needidattribute,tvp_images,tvp_areanames
,customertype,projectminprice,projectmaxprice
,projectminareavalue,projectmaxareavalue
,displaybedroom,displaypropertytype,highlights
,localityhighlights,longdesc 
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
,(select * from @tvp_areanames for json path)
,@customertype,@projectminprice,@projectmaxprice
,@projectminareavalue,@projectmaxareavalue
,@displaybedroom,@displaypropertytype,@highlights
,@localityhighlights,@longdesc        
    
    
    
declare @crdate datetime = getdate()    
,@modifieddate datetime = getdate()    
,@contactname varchar(128) = @UserName    
,@emailid varchar(128) = @UserEmail    
,@mobileno varchar(16) = @UserMobileNo    
,@phoneno varchar(16)     
,@ctcphone varchar(16)    
,@areaid int = isnull(@localityid,0)    
,@areaname varchar(128) = @localityname    
,@areaurl varchar(128)     
,@cityurl varchar(64)     
,@address varchar(256) = @formatted_address    
,@buildingno varchar(64)    
,@streetname varchar(512)    
,@zipcode varchar(8) = @postal_code    
,@needid int = @parentneedid    
,@addefid int = @NeedDefinitionId    
,@advpid int = @UserPid    
,@useragent varchar(512) = @UserDevice    
,@latitude float = @lat    
,@longitude float = @lng    
,@landmark varchar(256)    
,@paymentmode varchar(1024)    
,@clienttype varchar(128)    
,@mediatypeid int = 1    
,@ishidden int = 0    
,@isfeatured int = 0    
,@isverified int = 0    
,@tvp_adids as split_adsid    
,@modifiedpid int = 0    
,@adddays int = 60    
,@isfuturedate int = 0    
,@action varchar(32)=''    
,@isfreeadeligible int = 1    
,@scopeidentity int = 0    
,@adcitycode varchar(4)=''    
,@adareaid int = 0    
,@adareaname varchar(64)=''   
,@isvalidationpassed int = 1 
,@istestuser int = 0 
,@lv_areavalue int = null
,@lv_areavalueunit varchar(64) = null
,@lv_projectid bigint = 0
,@adcampaignid int = 0
,@lv_adstatus int = 0
    
if isnull(@areavalue,0) > 0
begin
	set @lv_areavalue = @areavalue
	set @lv_areavalueunit =  @areavalueunit
end
  
if exists (select top 1 1 from @tvp_areanames where localityid > 0) and @areaid = 0  
 select top 1 @areaid = localityid,@areaname = localityname from @tvp_areanames where localityid > 0  
    
set @hasduplicate = 0    
set @cityurl = dbo.fn_Get_TitleUrl(@cityname,'-')    
set @areaurl = dbo.fn_Get_TitleUrl(@areaname,'-')    
    
if @offer = '0'
	set @offer = ''
    
if @adtitle > '' and isnull(@adtitleurl,'') = ''    
 set @adtitleurl = dbo.fn_Get_TitleUrl(@adtitle,'-')    
    
set @adddays = dbo.fn_get_duration(@subcategoryid,@needid,@addefid,@mode)    
    
if @startdate is null or @startdate = '1900-01-01'    
 set @startdate = @crdate    
    
if @enddate is null or @enddate = '1900-01-01'    
 set @enddate = @startdate + @adddays    
    
if @status = 1 and cast(@startdate as date) > cast(@crdate as date) and @AdClassification = 2    
 select @status = 4,@isfuturedate = 1    
    
if @cityid > 0    
 set @adcitycode = dbo.fn_get_adcitycode(@cityid)    
     
if (@categoryid = 201) and (@cityid = 0 or @categoryid = 0 or @subcategoryid = 0 or @needid = 0     
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
 set @adtype_out = ''    
 set @mode_out = @mode    
 set @businessid_out = @businessid    
 set @UserPid_out = @UserPid    
 set @campaignid_out = @campaignid    
 set @customerid_out= @customerid    
 set @cityid_out = @cityid    
 set @cityname_out = @cityname    
 set @AdClassification_out = @AdClassification    
    
 commit transaction    
 return;     
end    
    
    
if (@categoryid <> 201) and (@cityid = 0 or @categoryid = 0 or @subcategoryid = 0 or @needid = 0     
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
set @adtype_out = ''    
 set @mode_out = @mode    
 set @businessid_out = @businessid    
 set @UserPid_out = @UserPid    
 set @campaignid_out = @campaignid    
 set @customerid_out= @customerid    
 set @cityid_out = @cityid    
 set @cityname_out = @cityname    
 set @AdClassification_out = @AdClassification    
    
 commit transaction    
 return;     
end   
  
if  @AdClassification = 4  and isnull(@oldadid,0) > 0  
begin  
 set @isvalidationpassed = dbo.fn_validatead_bannermapping_v2(@cityid,@areaid,@businessid  
     ,@oldadid,@needid,@addefid,@oldadid,@tvp_needidattribute)  
end  
  
  
/*Banner - Ad mapping Failed*/    
if @isvalidationpassed = 0  
begin    
    
 /*assign output param values*/                                  
 set @hasduplicate = 0                                            
 set @duplicatelistingids = ''  
 set @IsSuccess = 0    
 set @InsertedAdid = 0    
 set @adstatus = 'Mapping Failed'    
 set @redirecturl = ''     
 set @actionstatus = 'Mapping Failed'    
 set @comments = 'Banner Ad Mapping Failed due to Customer/Locality/Propertytype mismatch'    
 set @startdate_out = cast(@startdate as date)    
 set @expirydate = cast(@enddate as date)    
 set @adtype_out = ''    
 set @mode_out = @mode    
 set @businessid_out = @businessid    
 set @UserPid_out = @UserPid    
 set @campaignid_out = @campaignid    
 set @customerid_out= @customerid    
 set @cityid_out = @cityid    
 set @cityname_out = @cityname    
 set @AdClassification_out = @AdClassification    
    
 commit transaction    
 return;    
    
end   
  
    
if @AdClassification in (3,5,6) /* and isnull(@oldadid,0) = 0 */   
 set @duplicatelistingids = dbo.fn_get_samerequirement_ads_v2(@cityid,@areaid,@UserMobileNo    
          ,@customerid,@businessid,@price,@tvp_needidattribute,@adid,@projectid)    
else if @AdClassification = 2  
 set @duplicatelistingids = dbo.fn_get_samerequirement_offers(@cityid,@areaid,@UserMobileNo  
    ,@customerid,@businessid,@price,@subcategoryid,@needid,@addefid,@adid,@tvp_needidattribute)
else if @AdClassification = 4    
 set @duplicatelistingids = dbo.fn_get_samerequirement_banners_v2(@cityid,@tvp_areanames,@businessid  
 ,@bannertypeid,@subcategoryid,@needid,@addefid,@adid,@startdate)  
    
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
set @adtype_out = ''    
 set @mode_out = @mode    
 set @businessid_out = @businessid    
 set @UserPid_out = @UserPid    
 set @campaignid_out = @campaignid    
 set @customerid_out= @customerid    
 set @cityid_out = @cityid    
 set @cityname_out = @cityname    
 set @AdClassification_out = @AdClassification    
    
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
 set @adtype_out = ''    
 set @mode_out = @mode    
 set @businessid_out = @businessid    
 set @UserPid_out = @UserPid    
 set @campaignid_out = @campaignid    
 set @customerid_out= @customerid    
 set @cityid_out = @cityid    
 set @cityname_out = @cityname    
 set @AdClassification_out = @AdClassification    
    
 commit transaction    
 return;    
end    
    
if @businessid = 0 and @customerid = 0 and @campaignid = 0 and @categoryid = 201 and @status = 1  
 set @isfreeadeligible = dbo.fn_check_freead_eligibility_v2(@cityid,@UserMobileNo,@adid)    
  
if isnull(@emailid,'') > '' or isnull(@UserMobileNo,'') > ''
 set @istestuser = dbo.fn_check_istestuser(@emailid,@UserMobileNo)

if @istestuser = 1
	set @isfreeadeligible = 1

if isnull(@isfreeadeligible,0)=0
	set @isfreeadeligible = 0
    
if @businessid = 0 and @customerid = 0 and @campaignid = 0 and @isfreeadeligible = 0 and @categoryid = 201    
  and isnull(@mode,0) not in (3,4,105,110) and isnull(@adid,0)=0 /* Exclude Priority & Premium */    
begin    
 set @status = 0 /*Post Ad/Offer in Disabled status*/    
end    
else if @businessid = 0 and @customerid = 0 and @campaignid = 0 and @categoryid <> 201 and @adclassification <> 1   
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
    
select top 1 @mode = admode,@crdate = createddate,@adareaid = areaid,@adareaname=areaname,
@adcampaignid=campaignid,@lv_adstatus = status    
from adsmaster am (nolock)    
where adid = @adid    

set @adtitleurl = replace(@adtitleurl,N'{ADID}',convert(varchar,@adid))    
    
/*update adsmaster*/    
update top(1) am    
 set mobileno = iif(@adclassification = 7,isnull(nullif(@mobileno,''),mobileno),mobileno)
  ,shortdesc = isnull(@shortdesc,shortdesc)    
  ,price = isnull(@price,price)    
  ,landmark = isnull(@landmark,landmark)    
  ,modifieddate = @modifieddate    
  ,remarks = isnull(@remarks,remarks)    
  ,subarea = isnull(nullif(@subarea,''),subarea)    
  ,buildingname = isnull(nullif(@buildingname,''),buildingname)    
  ,buildingno = isnull(@buildingno,buildingno)    
  ,address = isnull(@address,address)    
  ,paymentmode = isnull(@paymentmode,paymentmode)    
  ,offer = isnull(nullif(@offer,''),offer)    
  ,custominfo = isnull(@custominfo,custominfo)    
  --,referenceid = isnull(@oldadid,referenceid)  
  --,status = isnull(@status,status)    
  ,listdate=iif(@categoryid <> 201,isnull(@startdate,listdate),listdate)    
  ,closedate=iif(@categoryid <> 201,isnull(@enddate,closedate),closedate)    
 ,adtitle = isnull(@adtitle,adtitle)    
  ,adurl = isnull(@adtitleurl,adurl)    
  ,latitude = isnull(@latitude,latitude)    
  ,longitude = isnull(@longitude,longitude)    
  ,areaname = iif(@posteduserpid > 0,isnull(@areaname,areaname),areaname)    
  ,altareaname = iif(@posteduserpid > 0,isnull(@areaurl,altareaname),altareaname)     
  ,areaid = iif(@posteduserpid > 0,isnull(@areaid,areaid),areaid)     
  ,businessname = isnull(nullif(@businessname,''),businessname)    
from adsmaster am (nolock)    
where adid = @adid    
    
/*    
/*update adsneedmapping*/    
update anm    
 set minprice = isnull(@price,minprice)    
  ,modifieddate = @modifieddate    
,status = isnull(@status,status)    
  ,areaid = iif(@posteduserpid > 0,isnull(@areaid,areaid),areaid)    
from adsneedmapping anm (nolock)    
where adid = @adid    
and (adclassification = @AdClassification or @AdClassification = 0)    
*/    
    
/*update - reload adsneedmapping*/    
delete adsneedmapping where adid = @adid    
    
insert into adsneedmapping    
(adid,subcategoryid,addefid,needid,cityid,areaid,areaname    
,minprice,crdate,mode,modifieddate,campaignid,netsalevalue,status
,adclassification,areavalue,areavalueunit)    
select     
@adid,@subcategoryid,@addefid,@needid,@cityid,iif(@posteduserpid > 0,@areaid,@adareaid),iif(@posteduserpid > 0,@areaname,@adareaname)   
,@price,@crdate,@mode mode,@modifieddate,@adcampaignid,@netsalevalue,@lv_adstatus
,@AdClassification,@lv_areavalue,@lv_areavalueunit     
    
    
/*update adssubcatmapping*/    
update top(1) ascm    
 set price = isnull(@price,price)    
  ,modifieddate = @modifieddate    
  --,status = isnull(@status,status)    
  ,areaid = iif(@posteduserpid > 0,isnull(@areaid,areaid),areaid)    
from adssubcatmapping ascm    
where adid = @adid    
    
    
/*update - reload adsmedia*/    
delete adsmedia where adid = @adid    
    
insert into adsmedia(adid,medianame,mediatypeid,mediaurl,mediacaption,tag,createddate,ishidden    
   ,isfeatured,isverified,modifieddate,mediatagid,subcatattributemediatagid,attributeid,status)    
select @adid adid,'' medianame,@mediatypeid mediatypeid,imageurl mediaurl    
,tag mediacaption,dbo.fn_get_titleurl(tag,'-') tag,@crdate,@ishidden     
,@isfeatured,@isverified,@modifieddate,dbo.fn_get_mediatagid(tag)    
,0 subcatattributemediatagid,attributeid,@lv_adstatus     
from @tvp_images where len(imageurl) > 3    
    
/*update - reload adssubcatattributemapping*/    
delete adssubcatattributemapping where adid = @adid    
    
insert into adssubcatattributemapping(    
adid,subcategoryid,cityid,areaid,price,mode,createddate,modifieddate,isautomapped    
,campaignid,isexclude,adattributemapid,attributeid,attributevalueid,netsalevalue,status)    
select @adid,@subcategoryid,@cityid,@areaid,@price,@mode mode    
,@crdate,@modifieddate,0 isautomapped    
,@adcampaignid,0 isexclude    
,0 attributemapid,na.attributeid,na.attributevalueid,@netsalevalue,@lv_adstatus    
from @tvp_needidattribute na    
where na.attributeid > 0    
    
if @adid > 0 and @bannertypeid > 0   
 exec dbo.prc_add_bannermapping @bannerid = @adid,@adid=@oldadid,@bannertypeattributevalueid=@bannertypeid  
 ,@isactive=1,@startdate=@startdate,@enddate=@enddate  
    
if @adid > 0 and exists (select top 1 1 from @tvp_areanames)  
 exec dbo.prc_mng_adsneedmapping @adid = @adid,@tvp_areanames = @tvp_areanames ,@adclassification = @adclassification   
    
if @adclassification = 7 or (@projectid > 0 and @businessid > 0)
begin

if @projectid > 0 /*Project Ad posting*/
	set @lv_projectid = @projectid
else /*Project posting*/
	set @lv_projectid = @adid

exec dbo.prc_mng_projectbusinessmapping @projectid=@lv_projectid ,@businessid=@businessid,@customerid=@customerid
	,@campaignid=@adcampaignid,@customertype=@customertype,@projectminprice=@projectminprice
	,@projectmaxprice=@projectmaxprice,@projectminareavalue=@projectminareavalue
	,@projectmaxareavalue=@projectmaxareavalue,@displayprice=@displayprice,@displayarea=@displayarea
	,@displaybedroom=@displaybedroom,@displaypropertytype=@displaypropertytype,@contactname=@contactname
	,@emailid=@emailid,@mobileno=@mobileno,@status=@status,@businessname=@businessname,@businessurl=@businessurl
	,@postedby=@PostedUserEmail,@adclassification=@adclassification

exec dbo.prc_autoupdate_projectbusinessmapping @projectid = @lv_projectid,@businessid = @businessid

	if @adclassification = 7
	begin
		exec dbo.prc_mng_adsfeature @adid = @lv_projectid,@highlights = @highlights,
							@localityhighlights = @localityhighlights,@longdesc=@longdesc

		if @areaid > 0 and @lv_projectid > 0 and @businessid > 0
		begin
			exec dbo.prc_mng_projectads @projectid = @lv_projectid,@businessid=@businessid,@customerid=0,
							@campaignid=0,@mode=0,@customertype=0,@contactname='',@emailid='',
							@mobileno=@mobileno,@status = @status,@landingurl='prc_add_adsmaster',
							@currenturl='prc_add_adsmaster',@sourceurl='prc_add_adsmaster',
							@UserPid=@modifiedpid,@comments='',@areaid = @areaid,
							@areaname =@areaname,@latitude = @latitude,@longitude = @longitude,
							@streetname = @streetname,@zipcode = @zipcode,@landmark = @landmark,
							@buildingname = @buildingname,@buildingno = @buildingno,@address = @address 
		end

	end

end
    
/*assign output param values*/    
if @status = 1    
begin    
 set @hasduplicate =0                                            
set @duplicatelistingids=''     
 set @IsSuccess = 1    
 set @InsertedAdid = @adid  
 set @adstatus = 'Live'    
 set @redirecturl = @adtitleurl    
 set @actionstatus = 'Updated'    
 set @comments = 'Your ad/offer updated successfully'    
 set @startdate_out = cast(@startdate as date)   
 set @expirydate = cast(@enddate as date)    
 set @adtype_out = ''    
 set @mode_out = @mode    
 set @businessid_out = @businessid    
 set @UserPid_out = @UserPid    
 set @campaignid_out = @campaignid    
 set @customerid_out= @customerid    
 set @cityid_out = @cityid    
 set @cityname_out = @cityname    
set @AdClassification_out = @AdClassification    
end    
else    
begin    
 set @hasduplicate =0                                     
 set @duplicatelistingids=''     
 set @IsSuccess = iif(@isfuturedate=0,0,1)    
 set @InsertedAdid = @adid    
 set @adstatus = iif(@isfuturedate=0,'Disabled','Live')    
 set @redirecturl =  @adtitleurl    
 set @actionstatus = 'Disabled'    
 set @comments = iif(@isfuturedate=0,'Ad/Offer has been Disabled','Ad/Offer Will be Live on this date')    
 set @startdate_out = cast(@startdate as date)    
 set @expirydate = cast(@enddate as date)    
 set @adtype_out = ''    
 set @mode_out = @mode    
 set @businessid_out = @businessid    
 set @UserPid_out = @UserPid    
 set @campaignid_out = @campaignid    
 set @customerid_out= @customerid    
 set @cityid_out = @cityid    
 set @cityname_out = @cityname    
 set @AdClassification_out = @AdClassification    
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
,offer,custominfo,advpid,posteduserpid,completionscore,landingurl,currenturl,sourceurl    
,sourcekeyword,ip,useragent,devicetype,pagesource,listdate,closedate,netsalevalue    
,status,referenceid,posteduseremailid,businessname,businessurl)    
select @projectid,@businessid,@cityname,@cityurl,@areaname,@areaurl,@mode,@adtitle,''    
,@shortdesc,@price,@areaname,@campaignid,@customerid,@latitude,@longitude,@streetname,@zipcode,@contactname    
,@emailid,@mobileno,@phoneno,@ctcphone,@landmark,@crdate,null,@cityid,@categoryid    
,@subcategoryid,@areaid,@remarks,@countrycode,@subarea,@buildingname,@buildingno,@address,@paymentmode    
,@offer,@custominfo,@advpid,@posteduserpid,@completionscore,@landingurl,@currenturl,@sourceurl    
,@sourcekeyword,@ip,@useragent,@devicetype,@pagesource,@startdate,@enddate,@netsalevalue    
,@status,@oldadid,@PostedUserEmail,@businessname,@businessurl    
  
set @scopeidentity = scope_identity()    
set @adid = @adcitycode + convert(varchar,@scopeidentity)    
set @adtitleurl = replace(@adtitleurl,N'{ADID}',convert(varchar,@adid))    
    
update top(1) adsmaster    
 set adid = @adid,    
  adurl = @adtitleurl    
where contentid = @scopeidentity    
    
    
/*insert adsneedmapping*/    
insert into adsneedmapping    
(adid,subcategoryid,addefid,needid,cityid,areaid,areaname,minprice    
,crdate,mode,modifieddate,campaignid,netsalevalue,status
,adclassification,areavalue,areavalueunit)    
select  
@adid,@subcategoryid,@addefid,@needid,@cityid,@areaid,@areaname,@price    
,@crdate,@mode mode,null,@campaignid,@netsalevalue,@status
,@AdClassification,@lv_areavalue,@lv_areavalueunit     
    
    
    
/*insert adssubcatmapping*/    
insert into adssubcatmapping(adid,categoryid,subcategoryid,cityid,areaid    
,mode,price,createddate,modifieddate,campaignid,spcategoryid,netsalevalue,businessid,status)    
select @adid,@categoryid,@subcategoryid,@cityid,@areaid,@mode mode,@price,@crdate   
,null,@campaignid,null spcategoryid,@netsalevalue,@businessid,@status    
    
    
/*insert adsmedia*/    
insert into adsmedia    
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
    
if @adid > 0 and @bannertypeid > 0   
 exec dbo.prc_add_bannermapping @bannerid = @adid,@adid=@oldadid,@bannertypeattributevalueid=@bannertypeid  
 ,@isactive=1,@startdate=@startdate,@enddate=@enddate  
    
if @adid > 0 and exists (select top 1 1 from @tvp_areanames)  
 exec dbo.prc_mng_adsneedmapping @adid = @adid,@tvp_areanames = @tvp_areanames,@adclassification = @adclassification     

if @adclassification = 7 or (@projectid > 0 and @businessid > 0)
begin

if @projectid > 0 /*Project Ad posting*/
	set @lv_projectid = @projectid
else /*Project posting*/
	set @lv_projectid = @adid

exec dbo.prc_mng_projectbusinessmapping @projectid=@lv_projectid ,@businessid=@businessid,@customerid=@customerid
	,@campaignid=@campaignid,@customertype=@customertype,@projectminprice=@projectminprice
	,@projectmaxprice=@projectmaxprice,@projectminareavalue=@projectminareavalue
	,@projectmaxareavalue=@projectmaxareavalue,@displayprice=@displayprice,@displayarea=@displayarea
	,@displaybedroom=@displaybedroom,@displaypropertytype=@displaypropertytype,@contactname=@contactname
	,@emailid=@emailid,@mobileno=@mobileno,@status=@status,@businessname=@businessname,@businessurl=@businessurl
	,@postedby=@PostedUserEmail

exec dbo.prc_autoupdate_projectbusinessmapping @projectid = @lv_projectid,@businessid = @businessid

	if @adclassification = 7
	begin
		exec dbo.prc_mng_adsfeature @adid = @lv_projectid,@highlights = @highlights,
							@localityhighlights = @localityhighlights,@longdesc=@longdesc
	end

end
    
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
 set @adtype_out = ''    
 set @mode_out = @mode    
 set @businessid_out = @businessid    
 set @UserPid_out = @UserPid    
 set @campaignid_out = @campaignid    
 set @customerid_out= @customerid    
 set @cityid_out = @cityid    
 set @cityname_out = @cityname    
 set @AdClassification_out = @AdClassification 
end    
else if @status = 1    
begin    
 set @hasduplicate =0    
 set @duplicatelistingids=''  
 set @IsSuccess = 1    
 set @InsertedAdid = @adid    
 set @adstatus = 'Live'    
 set @redirecturl = @adtitleurl    
 set @actionstatus = 'Inserted'     
 set @comments = 'Your ad/Offer posted successfully'    
 set @startdate_out = cast(@startdate as date)    
 set @expirydate = cast(@enddate as date)    
 set @adtype_out = ''    
 set @mode_out = @mode    
 set @businessid_out = @businessid    
 set @UserPid_out = @UserPid    
 set @campaignid_out = @campaignid    
 set @customerid_out= @customerid    
 set @cityid_out = @cityid    
 set @cityname_out = @cityname    
 set @AdClassification_out = @AdClassification    
end    
else    
begin    
 set @hasduplicate =0 
 set @duplicatelistingids=''     
 set @IsSuccess = iif(@isfuturedate=0,0,1)   
 set @InsertedAdid = @adid    
 set @adstatus = iif(@isfuturedate=0,'Disabled','Live')    
 set @redirecturl = @adtitleurl    
 set @actionstatus = 'Disabled'    
 set @comments = iif(@isfuturedate=0,'Ad/Offer has been Disabled','Ad/Offer Will be Live on this date')     
 set @startdate_out = cast(@startdate as date)    
 set @expirydate = cast(@enddate as date)    
 set @adtype_out = '' 
 set @mode_out = @mode    
 set @businessid_out = @businessid    
 set @UserPid_out = @UserPid    
 set @campaignid_out = @campaignid    
 set @customerid_out= @customerid    
 set @cityid_out = @cityid    
 set @cityname_out = @cityname    
 set @AdClassification_out = @AdClassification    
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
 set @adtype_out = ''    
 set @mode_out = @mode    
 set @businessid_out = @businessid    
 set @UserPid_out = @UserPid    
 set @campaignid_out = @campaignid    
 set @customerid_out= @customerid    
 set @cityid_out = @cityid    
 set @cityname_out = @cityname    
 set @AdClassification_out = @AdClassification    
    
end catch    
    
set nocount off;    
    
end
GO
