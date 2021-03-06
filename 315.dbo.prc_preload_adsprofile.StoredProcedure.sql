/****** Object:  StoredProcedure [dbo].[prc_preload_adsprofile]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_preload_adsprofile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_preload_adsprofile] AS'
END
GO
Alter PROCEDURE [dbo].[prc_preload_adsprofile]   
@adid  BIGINT,                                                                          
@adtitle VARCHAR(128) = '',                                                                          
@advpid INT=0,  
@Internaluserpid INT = 0,/*Internal User PId*/  
@PostedUserEmail varchar(128)='', /*Internal User EmailId*/  
@adurl  VARCHAR(256)='',  
@AdvMobile VARCHAR(16)=''                                                                   
AS                                                                          
BEGIN                                                                          
 SET NOCOUNT ON  
  
DECLARE @isAccessDenied int = 0  
  
                                                    
IF EXISTS (SELECT TOP 1 1 FROM dbo.adsmaster (NOLOCK)   
    WHERE advpid = @advpid and adid = @adid) OR @Internaluserpid > 0 OR @PostedUserEmail > ''  
 SET @isAccessDenied = 0   
ELSE IF @adid > 0 AND @advpid = 0 AND @Internaluserpid = 0 AND @PostedUserEmail = ''  
 SET @isAccessDenied = 1   
ELSE  
 SET @isAccessDenied = 1  
  
IF @isAccessDenied = 1 AND EXISTS (SELECT TOP 1 1 FROM dbo.adsmaster (NOLOCK)   
    WHERE mobileno = @AdvMobile and adid = @adid)  
 SET @isAccessDenied = 0  
  
IF @isAccessDenied = 1  
BEGIN  
 SELECT 'Access Denied' [DisplayMessage]  
 RETURN;  
END  
  
DROP TABLE IF EXISTS #adsmaster  
  
CREATE TABLE #adsmaster(  
[adid] [bigint] NULL,[projectid] [bigint] NULL  
,[businessid] [int] NULL,[cityname] [varchar](64) NULL,[altcityname] [varchar](64) NULL  
,[areaname] [varchar](64) NULL,[altareaname] [varchar](64) NULL,[admode] [smallint] NULL  
,[adtitle] [varchar](256) NULL,[adurl] [varchar](256) NULL,[shortdesc] [nvarchar](4000) NULL  
,[price] [money] NULL,[displayarea] [varchar](64) NULL,[campaignid] [int] NULL,[customerid] [int] NULL  
,[latitude] [float] NULL,[longitude] [float] NULL,[streetname] [varchar](512) NULL,[zipcode] [varchar](64) NULL  
,[contactname] [varchar](128) NULL,[emailid] [varchar](128) NULL,[mobileno] [varchar](16) NULL  
,[phoneno] [varchar](16) NULL,[ctcphone] [varchar](16) NULL,[landmark] [varchar](256) NULL  
,[createddate] [datetime] NULL,[modifieddate] [datetime] NULL,[cityid] [int] NULL,[categoryid] [int] NULL  
,[subcategoryid] [int] NULL,[areaid] [int] NULL,[remarks] [varchar](256) NULL,[countrycode] [int] NULL  
,[subarea] [varchar](128) NULL,[buildingname] [varchar](128) NULL,[buildingno] [varchar](64) NULL  
,[address] [varchar](256) NULL,[paymentmode] [varchar](1024) NULL,[offer] [varchar](256) NULL  
,[custominfo] [nvarchar](max) NULL,[advpid] [int] NULL,[posteduserpid] [int] NULL  
,[completionscore] [float] NULL,[landingurl] [varchar](512) NULL,[currenturl] [varchar](512) NULL  
,[sourceurl] [varchar](512) NULL,[sourcekeyword] [varchar](128) NULL,[ip] [varchar](16) NULL  
,[useragent] [varchar](512) NULL,[devicetype] [varchar](128) NULL,[clienttype] [varchar](128) NULL  
,[pagesource] [varchar](64) NULL,[listdate] [datetime] NULL,[closedate] [datetime] NULL  
,[netsalevalue] [smallint] NULL,[status] [int] NULL,[posteduseremailid] [varchar](128) NULL  
)  
  
INSERT INTO #adsmaster  
(  
adid,projectid,businessid,cityname,altcityname,areaname,altareaname,admode,adtitle,adurl  
,shortdesc,price,displayarea,campaignid,customerid,latitude,longitude,streetname,zipcode,contactname  
,emailid,mobileno,phoneno,ctcphone,landmark,createddate,modifieddate,cityid,categoryid,subcategoryid  
,areaid,remarks,countrycode,subarea,buildingname,buildingno,address,paymentmode,offer,custominfo  
,advpid,posteduserpid,completionscore,landingurl,currenturl,sourceurl,sourcekeyword,ip  
,useragent,devicetype,clienttype,pagesource,listdate,closedate,netsalevalue,status,posteduseremailid  
)  
SELECT    
adid,projectid,businessid,cityname,altcityname,areaname,altareaname,admode,adtitle,adurl  
,shortdesc,price,displayarea,campaignid,customerid,latitude,longitude,streetname,zipcode,contactname  
,emailid,mobileno,phoneno,ctcphone,landmark,createddate,modifieddate,cityid,categoryid,subcategoryid  
,areaid,remarks,countrycode,subarea,buildingname,buildingno,address,paymentmode,offer,custominfo  
,advpid,posteduserpid,completionscore,landingurl,currenturl,sourceurl,sourcekeyword,ip  
,useragent,devicetype,clienttype,pagesource,listdate,closedate,netsalevalue,status,posteduseremailid  
FROM dbo.adsmaster (NOLOCK)  
WHERE adid = @adid  
  
  
 --ADS DETAIL  
 ;with cte_anm  
 as  
 (  
 SELECT TOP 1  
 anm.adid,anm.adclassification,anm.addefid,anm.needid,anm.minprice  
 FROM dbo.adsneedmapping anm (NOLOCK)   
 WHERE anm.adid = @adid  
 and anm.cityid > 0  
 and anm.subcategoryid > 0  
 and anm.needid > 0  
 and anm.addefid > 0  
 and anm.adclassification > 0  
 )  
 SELECT am.adid,am.adtitle,am.adurl,ISNULL(am.shortdesc,'') [ShortDescription],ISNULL(am.admode,0)admode,  
   am.businessid,ISNULL(am.customerid,0) customerid,ISNULL(am.campaignid,0) campaignid,  
   am.categoryid,am.subcategoryid,an.addefid,  
   an.needid,ISNULL(an.minprice,0) [price],am.custominfo,  
   ISNULL(am.buildingno,'') buildingno,ISNULL(am.buildingname,'') buildingname,  
   ISNULL(am.streetname,'') streetname,ISNULL(am.subarea,'') subarea,  
   am.areaname,ISNULL(am.landmark,'') landmark,ISNULL(am.address,'') address,  
   trim(am.cityname) cityname,am.zipcode,am.latitude,am.longitude,am.cityid,am.areaid,  
   am.advpid userpid,am.contactname username,am.mobileno DisplayContactNo,  
   ISNULL(am.phoneno,'') DisplayPhoneNo,ISNULL(am.emailid,'') emailid,  
   am.countrycode StdCode,0 as 'IsVisible', 0 as 'IsPrimary',  
   am.listdate Startdate,am.closedate Enddate,  
   dbo.fn_get_pagetype(am.categoryid) pagetype,  
   am.status,an.adclassification,pbm.minprice projectminprice,pbm.maxprice projectmaxprice,  
   pbm.minarea projectminareavalue,pbm.maxarea projectmaxareavalue,  
   pbm.displaybedroom,pbm.customertypevalueid,am.projectid,  
   dbo.fn_get_adhighlights(am.adid) ProjectHighlights,  
   dbo.fn_get_adlocalityhighlights(am.adid) LocalityHighlights,  
   dbo.fn_get_adlongdesc(am.adid) LongDesc,am.offer  
 FROM #adsmaster am   
  JOIN cte_anm an (NOLOCK) on am.adid = an.adid  
  OUTER APPLY dbo.fn_get_projectbusinessmapping(am.projectid,am.businessid) pbm  
 WHERE am.adid = @adid  
  
  
 --ADS MEDIA  
 SELECT m.adid,m.mediatypeid,m.mediaurl imageurl,ISNULL(m.mediacaption,'') TagName,m.createddate,m.attributeid  
 FROM dbo.adsmedia m(NOLOCK)  
 WHERE m.adid = @adid  
  
 --ADS ATTRIBUTE  
 SELECT asam.adid,asam.attributeid,asam.attributevalueid  
 FROM dbo.adssubcatattributemapping asam(NOLOCK)  
 WHERE asam.adid = @adid  
  
 --ADS LOCALITIES  
 SELECT anm.adid,anm.cityid,anm.areaid,anm.areaname  
 FROM dbo.adsNeedmapping anm(NOLOCK)  
 WHERE anm.adid = @adid   
 and anm.cityid > 0  
 and anm.subcategoryid > 0  
 and anm.needid > 0  
 and anm.addefid > 0  
 and anm.adclassification > 0  
  
    DROP TABLE #adsmaster  
                                                                                     
 SET NOCOUNT OFF                                                                          
END 
GO
