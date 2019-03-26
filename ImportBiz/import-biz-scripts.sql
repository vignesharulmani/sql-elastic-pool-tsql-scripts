prc_get_importbiz @rowstofetch = 10
create table importbiz(rowid int identity
,businessid int
,isprocessed int
)

create procedure prc_get_importbiz
@rowstofetch int = 10
as
begin

select top(@rowstofetch) * from importbiz where isprocessed = 0

end


create procedure prc_upd_importbiz
@rowid int
as
begin

update importbiz 
	set isprocessed = 1
where rowid = @rowid

end





CREATE TYPE [dbo].[tvp_businessmaster] AS TABLE(
	[BusinessId] [int] NOT NULL,
	[BusinessName] [varchar](128) NULL,
	[AreaName] [varchar](40) NULL,
	[AltareaName] [varchar](40) NULL,
	[CityName] [varchar](50) NULL,
	[AltCityName] [varchar](50) NULL,
	[Businessmode] [smallint] NULL,
	[Businessverifeid] [bit] NULL,
	[BusinessURL] [varchar](128) NULL,
	[Campaignid] [int] NULL,
	[StdCode] [varchar](8) NULL,
	[Latitude] [varchar](24) NULL,
	[Longitude] [varchar](32) NULL,
	[StreetName] [varchar](500) NULL,
	[Zipcode] [varchar](50) NULL,
	[ContactPerson] [varchar](120) NULL,
	[EstablishedYear] [int] NULL,
	[LogoUrl] [varchar](500) NULL,
	[FacebookUrl] [varchar](500) NULL,
	[GplusUrl] [varchar](500) NULL,
	[TwitterUrl] [varchar](500) NULL,
	[YoutubeUrl] [varchar](500) NULL,
	[LinkedinUrl] [varchar](500) NULL,
	[emailid] [varchar](100) NULL,
	[Landmarkprefix] [varchar](10) NULL,
	[Landmark] [varchar](140) NULL,
	[ctcphone] [varchar](15) NULL,
	[Netsales] [int] NULL,
	[Avgrating] [int] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[CityId] [int] NULL,
	[Categoryid] [int] NULL,
	[Subcategoryid] [int] NULL,
	[Areaid] [int] NULL,
	[ListingId] [int] NULL,
	[ListingStatusId] [int] NULL,
	[ClaimedBy] [varchar](128) NULL,
	[ClaimedStatusID] [int] NULL,
	[CurrentlyHandledBy] [varchar](128) NULL,
	[DataSourceID] [int] NULL,
	[OriginSourceID] [int] NULL,
	[AlsoOtherBusinessHandledBy] [varchar](255) NULL,
	[CurrentlyHandlyingProcessNames] [int] NULL,
	[Remarks] [varchar](255) NULL,
	[PromotionalText] [varchar](max) NULL,
	[CommentsByDataCollector] [varchar](255) NULL,
	[PhoneNo] [varchar](15) NULL,
	[PhoneNo1] [varchar](15) NULL,
	[PhoneNo2] [varchar](15) NULL,
	[MobileNo] [varchar](15) NULL,
	[MobileNo1] [varchar](15) NULL,
	[subarea] [varchar](120) NULL,
	[buildingname] [varchar](128) NULL,
	[buildingno] [varchar](40) NULL,
	[Holidays] [varchar](15) NULL,
	[About] [varchar](max) NULL,
	[Extra] [varchar](500) NULL,
	[TollFreeNumber] [varchar](25) NULL,
	[Fax1] [varchar](24) NULL,
	[Fax2] [varchar](24) NULL,
	[paymentmode] [varchar](1000) NULL,
	[WebsiteUrl] [varchar](500) NULL,
	[customerid] [int] NULL,
	[BizListingID] [varchar](32) NULL,
	[ListingSubStatusId] [tinyint] NULL,
	[Medium] [varchar](64) NULL,
	[Campaign] [varchar](64) NULL,
	[ClientType] [varchar](64) NULL,
	[DeviceID] [varchar](64) NULL,
	[modifiedbyuserpid] [varchar](64) NULL,
	[VisitorID] [varchar](64) NULL,
	[modifiedbyuserguid] [varchar](64) NULL,
	[outletname] [varchar](200) NULL,
	[outlettypeid] [tinyint] NULL,
	[outleturl] [varchar](200) NULL,
	[istotc_active] [bit] NULL,
	[altbusinessname] [varchar](256) NULL,
	[workflowstatusid] [int] NULL,
	[source] [varchar](64) NULL,
	[subsource] [varchar](64) NULL,
	[ModifiedByuserroleid] [varchar](64) NULL,
	[versionnumber] [int] NULL,
	[businessstate] [int] NULL,
	[instagramurl] [varchar](500) NULL,
	[ModeBeforePaid] [int] NULL,
	[AadharNo] [varchar](20) NULL,
	[GstInNo] [varchar](20) NULL,
	[sourcebusinessid] [int] NULL,
	[LeadNotificationToggle] [tinyint] NULL,
	[isdisplaycontactno] [bit] NULL,
	[BusinessidShortURL] [varchar](50) NULL
)


CREATE TYPE [dbo].[tvp_businesscontact] AS TABLE(
	[Rowid] [int] IDENTITY(1,1) NOT NULL,
	[BusinessId] [int] NULL,
	[ContactNumber] [varchar](200) NULL,
	[ContacTypeId] [tinyint] NULL,
	[contacttype] [varchar](20) NULL,
	[contactreasonid] [tinyint] NULL,
	[ContactReason] [varchar](100) NULL,
	[CityId] [int] NULL,
	[SubCategoryId] [int] NULL,
	[198needid] [int] NULL,
	[198Attributeid] [int] NULL,
	[198Attributevalueid] [int] NULL,
	[NeedId] [int] NULL,
	[Attributeid] [int] NULL,
	[Attributevalueid] [int] NULL,
	[StdCode] [varchar](25) NULL,
	[IsVisible] [bit] NULL,
	[isprimary] [bit] NULL,
	[createddate] [datetime] NULL,
	[UserPid] [int] NULL,
	[LastLeadSentDate] [datetime] NULL
)


CREATE TYPE [dbo].[tvp_bizsubcatmapping] AS TABLE(
	[Businessid] [int] NOT NULL,
	[Subcategoryid] [smallint] NOT NULL,
	[Cityid] [smallint] NOT NULL,
	[Areaid] [int] NOT NULL,
	[Mode] [int] NULL,
	[createddate] [datetime] NULL,
	[modifieddate] [datetime] NULL,
	[campaignid] [int] NULL,
	[netsalevalue] [smallint] NULL,
	[confidencescore] [int] NULL
)


CREATE TYPE [dbo].[tvp_bizneedmapping] AS TABLE(
	[businessid] [int] NOT NULL,
	[subcategoryid] [smallint] NOT NULL,
	[needid] [int] NOT NULL,
	[cityid] [int] NOT NULL,
	[areaid] [int] NOT NULL,
	[minprice] [decimal](7, 3) NULL,
	[crdate] [date] NOT NULL,
	[Mode] [tinyint] NULL,
	[modifieddate] [datetime] NULL,
	[campaignid] [int] NULL,
	[netsalevalue] [smallint] NULL,
	[confidencescore] [int] NULL
)
GO


CREATE TYPE [dbo].[tvp_bizsubcatattributemapping] AS TABLE(
	[Businessid] [int] NOT NULL,
	[SubcateAttributeMapid] [int] NOT NULL,
	[AttributeValueid] [int] NOT NULL,
	[Cityid] [smallint] NOT NULL,
	[Areaid] [int] NOT NULL,
	[Mode] [tinyint] NOT NULL,
	[price] [money] NULL,
	[createddate] [datetime] NULL,
	[modifieddate] [datetime] NULL,
	[isautomapped] [bit] NULL,
	[confidencescore] [int] NULL,
	[isfilterattribute] [bit] NULL,
	[campaignid] [int] NULL,
	[netsalevalue] [smallint] NULL
)


CREATE TYPE [dbo].[tvp_bizsubcatneedattributemapping] AS TABLE(
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[Businessid] [int] NOT NULL,
	[Subcategoryid] [smallint] NOT NULL,
	[NeedAttributeMapid] [int] NOT NULL,
	[Attributevalueid] [int] NOT NULL,
	[Cityid] [smallint] NOT NULL,
	[Areaid] [int] NOT NULL,
	[Mode] [tinyint] NOT NULL,
	[createddate] [datetime] NULL,
	[modifieddate] [datetime] NULL,
	[isautomapped] [bit] NULL,
	[confidencescore] [int] NULL,
	[campaignid] [int] NULL,
	[netsalevalue] [smallint] NULL,
	[isexclude] [bit] NULL
)



CREATE TYPE [dbo].[tvp_businessmedia] AS TABLE(
	[mediaid] [int] IDENTITY(1,1) NOT NULL,
	[businessid] [int] NOT NULL,
	[medianame] [varchar](256) NULL,
	[mediatypeid] [smallint] NOT NULL,
	[mediaurl] [varchar](256) NOT NULL,
	[mediacaption] [varchar](256) NULL,
	[tag] [varchar](128) NULL,
	[createddate] [datetime] NULL,
	[ishidden] [bit] NULL,
	[isfeatured] [bit] NULL,
	[isverified] [bit] NULL,
	[modifieddate] [datetime] NULL,
	[KYCVerifiedStatus] [tinyint] NULL,
	[mediatagid] [int] NULL,
	[subcatattributemediatagid] [int] NULL,
	[mediacover] [varchar](256) NULL,
	[IsResized] [tinyint] NULL
)


select top 10 * from sys.objects order by 8 desc


create procedure prc_reload_biz
@tbl_businessmaster as tvp_businessmaster readonly,
@tbl_businesscontact as tvp_businesscontact readonly,
@tbl_bizsubcatmapping as tvp_bizsubcatmapping readonly,
@tbl_bizneedmapping as tvp_bizneedmapping readonly,
@tbl_bizsubcatattributemapping as tvp_bizsubcatattributemapping readonly,
@tbl_bizsubcatneedattributemapping as tvp_bizsubcatneedattributemapping readonly,
@tbl_businessmedia as tvp_businessmedia readonly
as
begin

declare @bizid int = 0

select top 1 @bizid = businessid from @tbl_bizsubcatmapping

/*
delete from businessmedia where businessid = @bizid
delete from bizsubcatneedattributemapping where businessid = @bizid
delete from bizsubcatattributemapping where businessid = @bizid
delete from bizneedmapping where businessid = @bizid
delete from bizsubcatmapping where businessid = @bizid
delete from businesscontact where businessid = @bizid
delete from businessmaster where businessid = @bizid
*/

insert into businessmaster(BusinessId,BusinessName,AreaName,AltareaName
,CityName,AltCityName,Businessmode,Businessverifeid,BusinessURL
,Campaignid,StdCode,Latitude,Longitude,StreetName,Zipcode,ContactPerson
,EstablishedYear,LogoUrl,FacebookUrl,GplusUrl,TwitterUrl,YoutubeUrl
,LinkedinUrl,emailid,Landmarkprefix,Landmark,ctcphone,Netsales
,Avgrating,CreatedDate,ModifiedDate,CityId,Categoryid,Subcategoryid
,Areaid,ListingId,ListingStatusId,ClaimedBy,ClaimedStatusID
,CurrentlyHandledBy,DataSourceID,OriginSourceID,AlsoOtherBusinessHandledBy
,CurrentlyHandlyingProcessNames,Remarks,PromotionalText,CommentsByDataCollector
,PhoneNo,PhoneNo1,PhoneNo2,MobileNo,MobileNo1,subarea,buildingname,buildingno
,Holidays,About,Extra,TollFreeNumber,Fax1,Fax2,paymentmode,WebsiteUrl
,customerid,BizListingID,ListingSubStatusId,Medium,Campaign,ClientType,DeviceID
,modifiedbyuserpid,VisitorID,modifiedbyuserguid,outletname,outlettypeid,outleturl
,istotc_active,altbusinessname,workflowstatusid,source,subsource,ModifiedByuserroleid
,versionnumber,businessstate,instagramurl,ModeBeforePaid,AadharNo,GstInNo,sourcebusinessid
,LeadNotificationToggle,isdisplaycontactno,BusinessidShortURL)
select BusinessId,BusinessName,AreaName,AltareaName
,CityName,AltCityName,Businessmode,Businessverifeid,BusinessURL
,Campaignid,StdCode,Latitude,Longitude,StreetName,Zipcode,ContactPerson
,EstablishedYear,LogoUrl,FacebookUrl,GplusUrl,TwitterUrl,YoutubeUrl
,LinkedinUrl,emailid,Landmarkprefix,Landmark,ctcphone,Netsales
,Avgrating,CreatedDate,ModifiedDate,CityId,Categoryid,Subcategoryid
,Areaid,ListingId,ListingStatusId,ClaimedBy,ClaimedStatusID
,CurrentlyHandledBy,DataSourceID,OriginSourceID,AlsoOtherBusinessHandledBy
,CurrentlyHandlyingProcessNames,Remarks,PromotionalText,CommentsByDataCollector
,PhoneNo,PhoneNo1,PhoneNo2,MobileNo,MobileNo1,subarea,buildingname,buildingno
,Holidays,About,Extra,TollFreeNumber,Fax1,Fax2,paymentmode,WebsiteUrl
,customerid,BizListingID,ListingSubStatusId,Medium,Campaign,ClientType,DeviceID
,modifiedbyuserpid,VisitorID,modifiedbyuserguid,outletname,outlettypeid,outleturl
,istotc_active,altbusinessname,workflowstatusid,source,subsource,ModifiedByuserroleid
,versionnumber,businessstate,instagramurl,ModeBeforePaid,AadharNo,GstInNo,sourcebusinessid
,LeadNotificationToggle,isdisplaycontactno,BusinessidShortURL
from @tbl_businessmaster


insert into businesscontact(BusinessId,ContactNumber,ContacTypeId,contacttype,contactreasonid
,ContactReason,CityId,SubCategoryId,[198needid],[198Attributeid],[198Attributevalueid],NeedId
,Attributeid,Attributevalueid,StdCode,IsVisible,isprimary,createddate,UserPid,LastLeadSentDate)
select BusinessId,ContactNumber,ContacTypeId,contacttype,contactreasonid
,ContactReason,CityId,SubCategoryId,[198needid],[198Attributeid],[198Attributevalueid],NeedId
,Attributeid,Attributevalueid,StdCode,IsVisible,isprimary,createddate,UserPid,LastLeadSentDate
from @tbl_businesscontact


insert into bizsubcatmapping(Businessid,Subcategoryid,Cityid,Areaid,Mode,createddate
,modifieddate,campaignid,netsalevalue,confidencescore)
select Businessid,Subcategoryid,Cityid,Areaid,Mode,createddate
,modifieddate,campaignid,netsalevalue,confidencescore
from @tbl_bizsubcatmapping

insert into bizneedmapping(businessid,subcategoryid,needid,cityid,areaid,minprice
,crdate,Mode,modifieddate,campaignid,netsalevalue,confidencescore)
select businessid,subcategoryid,needid,cityid,areaid,minprice
,crdate,Mode,modifieddate,campaignid,netsalevalue,confidencescore
from @tbl_bizneedmapping

insert into bizsubcatattributemapping(Businessid,SubcateAttributeMapid,AttributeValueid
,Cityid,Areaid,Mode,price,createddate,modifieddate,isautomapped,confidencescore
,isfilterattribute,campaignid,netsalevalue)
select Businessid,SubcateAttributeMapid,AttributeValueid
,Cityid,Areaid,Mode,price,createddate,modifieddate,isautomapped,confidencescore
,isfilterattribute,campaignid,netsalevalue
from @tbl_bizsubcatattributemapping


insert into bizsubcatneedattributemapping(Businessid,Subcategoryid,NeedAttributeMapid
,Attributevalueid,Cityid,Areaid,Mode,createddate,modifieddate,isautomapped
,confidencescore,campaignid,netsalevalue,isexclude)
select Businessid,Subcategoryid,NeedAttributeMapid
,Attributevalueid,Cityid,Areaid,Mode,createddate,modifieddate,isautomapped
,confidencescore,campaignid,netsalevalue,isexclude
from @tbl_bizsubcatneedattributemapping


insert into businessmedia(businessid,medianame,mediatypeid,mediaurl,mediacaption
,tag,createddate,ishidden,isfeatured,isverified,modifieddate,KYCVerifiedStatus
,mediatagid,subcatattributemediatagid,mediacover)
select businessid,medianame,mediatypeid,mediaurl,mediacaption
,tag,createddate,ishidden,isfeatured,isverified,modifieddate,KYCVerifiedStatus
,mediatagid,subcatattributemediatagid,mediacover
from @tbl_businessmedia

end


