ALTER PROCEDURE [dbo].[prc_multicity_adsprofile]                                                 
@adid		BIGINT,                                                                        
@adtitle	VARCHAR(128) = '',                                                                        
@advpid	INT=0,
@Internaluserpid	INT = 0,
@adurl		VARCHAR(256)=''                                                                        
AS                                                                        
BEGIN                                                                        
	SET	NOCOUNT	ON

DECLARE @isAccessDenied int = 0
                                                  
IF EXISTS (SELECT TOP 1 1 FROM adsmaster (NOLOCK) 
				WHERE advpid = @advpid and adid = @adid) OR @Internaluserpid > 0
	SET @isAccessDenied = 0 
ELSE IF @adid > 0 AND @advpid = 0 AND @Internaluserpid = 0
	SET @isAccessDenied = 0 
ELSE
	SET @isAccessDenied = 1

IF @isAccessDenied = 1
BEGIN
	SELECT 'Access Denied' [DisplayMessage]
	RETURN;
END


DROP TABLE IF EXISTS #adsmaster

CREATE TABLE #adsmaster(
[adid] [bigint] NULL,[projectid] [int] NULL
,[businessid] [int] NULL,[cityname] [varchar](64) NULL,[altcityname] [varchar](64) NULL
,[areaname] [varchar](64) NULL,[altareaname] [varchar](64) NULL,[admode] [smallint] NULL
,[adtitle] [varchar](256) NULL,[adurl] [varchar](256) NULL,[shortdesc] [varchar](4096) NULL
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
FROM	dbo.adsmaster (NOLOCK)
WHERE adid = @adid

	--ADS DETAIL
	SELECT	am.adid,am.adtitle,am.adurl,am.shortdesc [ShortDescription],am.admode,
			ISNULL(am.businessid,0)businessid,am.customerid,am.campaignid,am.categoryid,
			am.subcategoryid,an.addefid,an.needid,an.minprice [price],
			ISNULL(am.modifieddate,am.createddate) PostedDate,am.listdate,am.closedate,
			am.custominfo,an.adclassification,am.status adstatus
	FROM	#adsmaster am 
		JOIN dbo.adsneedmapping an (NOLOCK) on am.adid = an.adid
	WHERE	am.adid		=	@adid

	--ADS ADDRESS
	SELECT	adid,buildingno,buildingname,streetname,subarea,areaname,landmark,address,cityname,zipcode,
			latitude,longitude,cityid,areaid
	FROM	#adsmaster
	WHERE	adid		=	@adid

	--ADS CONTACT
	SELECT	adid,contactname,mobileno DisplayContactNo,phoneno DisplayPhoneNo,emailid,
	countrycode StdCode,0 as 'IsVisible', 0 as 'IsPrimary'
	FROM	#adsmaster
	WHERE	adid		=	@adid

	--ADS MEDIA
	SELECT	m.adid,m.mediatypeid,m.mediaurl,m.mediacaption TagName,m.createddate,m.attributeid
	FROM	dbo.adsmedia m(NOLOCK)
	WHERE	m.adid		=	@adid

	--ADS ATTRIBUTE
	SELECT	asam.adid,asam.attributeid,asam.attributevalueid
	FROM	dbo.adssubcatattributemapping asam(NOLOCK)
	WHERE	asam.adid		=	@adid

	--ADS OTHER INFO
	SELECT adid,advpid userpid,posteduserpid,posteduseremailid posteduseremail,
	landingurl,currenturl,sourceurl,sourcekeyword,ip,useragent userdevice,devicetype,
	clienttype,pagesource,listdate,closedate,netsalevalue
	FROM	#adsmaster
	WHERE	adid		=	@adid 

    DROP	TABLE #adsmaster
	                                                                                  
	SET NOCOUNT OFF                                                                        
END 