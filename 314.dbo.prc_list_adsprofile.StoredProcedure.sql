/****** Object:  StoredProcedure [dbo].[prc_list_adsprofile]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter PROCEDURE [dbo].[prc_list_adsprofile]
@adid		BIGINT,                                                                        
@adtitle	VARCHAR(128) = '',                                                                        
@advpid	INT=0,
@Internaluserpid	INT = 0,
@adurl		VARCHAR(256)='',
@isproject int = 0,
@businessurl varchar(128)=''
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
[adid] [bigint] NULL,[projectid] [bigint] NULL
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
,[businessname] [varchar](128) NULL,[businessurl] [varchar](128) NULL
)

INSERT INTO #adsmaster
(
adid,projectid,businessid,cityname,altcityname,areaname,altareaname,admode,adtitle,adurl
,shortdesc,price,displayarea,campaignid,customerid,latitude,longitude,streetname,zipcode,contactname
,emailid,mobileno,phoneno,ctcphone,landmark,createddate,modifieddate,cityid,categoryid,subcategoryid
,areaid,remarks,countrycode,subarea,buildingname,buildingno,address,paymentmode,offer,custominfo
,advpid,posteduserpid,completionscore,landingurl,currenturl,sourceurl,sourcekeyword,ip
,useragent,devicetype,clienttype,pagesource,listdate,closedate,netsalevalue,status,posteduseremailid
,businessname,businessurl
)
SELECT  
adid,projectid,businessid,cityname,altcityname,areaname,altareaname,admode,adtitle,adurl
,shortdesc,price,displayarea,campaignid,customerid,latitude,longitude,streetname,zipcode,contactname
,emailid,mobileno,phoneno,ctcphone,landmark,createddate,modifieddate,cityid,categoryid,subcategoryid
,areaid,remarks,countrycode,subarea,buildingname,buildingno,address,paymentmode,offer,custominfo
,advpid,posteduserpid,completionscore,landingurl,currenturl,sourceurl,sourcekeyword,ip
,useragent,devicetype,clienttype,pagesource,listdate,closedate,netsalevalue,status,posteduseremailid
,businessname,businessurl
FROM	dbo.adsmaster (NOLOCK)
WHERE adid = @adid



	--ADS DETAIL
	IF @isproject = 0
	BEGIN
		SELECT	am.adid,am.adtitle,am.adurl,am.shortdesc [ShortDescription],am.admode,
				ISNULL(am.businessid,0)businessid,am.customerid,am.campaignid,am.categoryid,
				am.subcategoryid,an.addefid,an.needid,an.minprice [price],
				ISNULL(am.modifieddate,am.createddate) PostedDate,am.listdate,am.closedate,
				am.custominfo,an.adclassification,am.status adstatus,
				am.businessname,am.businessurl,dbo.fn_calc_runtime_adtype(am.admode) adtype,
				pbm.minprice,pbm.maxprice,pbm.minarea,pbm.maxarea,pbm.displaybedroom,
				am.projectid,pbm.projecturl,
				dbo.fn_get_adoffer(iif(am.projectid > 0 ,am.projectid,am.adid)) offer,
				dbo.fn_get_projectlogourl(iif(am.projectid > 0 ,am.projectid,am.adid)) projectlogourl
		FROM	#adsmaster am 
			JOIN dbo.adsneedmapping an (NOLOCK) on am.adid = an.adid 
			OUTER APPLY dbo.fn_get_projectbusinessmapping(am.projectid,am.businessid) pbm
		WHERE	am.adid		=	@adid 
	END
	ELSE 
	BEGIN
		SELECT	am.adid,am.adtitle,pbm.projecturl adurl,am.shortdesc [ShortDescription],pbm.mode admode,
				pbm.businessid,pbm.customerid,pbm.campaignid,am.categoryid,
				am.subcategoryid,an.addefid,an.needid,an.minprice [price],
				ISNULL(am.modifieddate,am.createddate) PostedDate,am.listdate,am.closedate,
				am.custominfo,an.adclassification,am.status adstatus,
				pbm.businessname,pbm.businessurl,dbo.fn_calc_runtime_adtype(isnull(nullif(pbm.mode,0),am.admode)) adtype,
				dbo.fn_get_adhighlights(am.adid) highlights,
				dbo.fn_get_adlocalityhighlights(am.adid) localityhighlights,
				dbo.fn_get_adlongdesc(am.adid) LongDescription,
				pbm.minprice,pbm.maxprice,pbm.minarea,pbm.maxarea,pbm.displaybedroom,
				pbm.customertypevalueid [advertisertype],
				dbo.fn_get_adoffer(am.adid) offer,
				dbo.fn_get_projectlogourl(am.adid) projectlogourl
		FROM	#adsmaster am 
			JOIN dbo.adsneedmapping an (NOLOCK) on am.adid = an.adid
			CROSS APPLY dbo.fn_get_projectbusinessmapping_businesstitleurl(@adid,@businessurl) pbm
		WHERE	am.adid		=	@adid 
	END

	--ADS ADDRESS
	SELECT	adid,buildingno,buildingname,address streetname,subarea,areaname,landmark,address,
			cityname,zipcode,latitude,longitude,cityid,areaid
	FROM	#adsmaster
	WHERE	adid		=	@adid

	--ADS CONTACT
	IF @isproject = 0
	BEGIN
		SELECT	adid,contactname,mobileno DisplayContactNo,phoneno DisplayPhoneNo,emailid,
		countrycode StdCode,0 as 'IsVisible', 0 as 'IsPrimary'
		FROM	#adsmaster
		WHERE	adid		=	@adid
	END
	ELSE
	BEGIN
		SELECT	am.adid,pbm.contactname,pbm.mobileno DisplayContactNo,pbm.mobileno DisplayPhoneNo,pbm.emailid,
		am.countrycode StdCode,0 as 'IsVisible', 0 as 'IsPrimary'
		FROM	#adsmaster am
			CROSS APPLY dbo.fn_get_projectbusinessmapping_businesstitleurl(@adid,@businessurl) pbm
		WHERE	adid		=	@adid
	END

	--ADS MEDIA
	/*
	SELECT	m.adid,m.mediatypeid,m.mediaurl,m.mediacaption TagName,m.createddate,m.attributeid
	FROM	dbo.adsmedia m(NOLOCK)
	WHERE	m.adid		=	@adid
	*/

	SELECT adid,mediatypeid,mediaurl,TagName,createddate,attributeid FROM (
	SELECT a.adid adid, 1 mediatypeid,
		replace(m.mediaurl,'http://','https://') mediaurl,
		m.mediacaption 'TagName',m.createddate,
		m.attributeid attributeid
	FROM	#adsmaster a
	LEFT OUTER JOIN dbo.adsmedia m (NOLOCK) ON a.adid =	m.adid
	WHERE a.adid = @adid
	UNION ALL
	SELECT a.adid adid, 1 mediatypeid,
		replace(f.mediaurl,'http://','https://') mediaurl,
		f.mediacaption 'TagName',null createddate,
		f.attributeid attributeid
	FROM	#adsmaster a
	OUTER APPLY dbo.fn_get_project_images(a.projectid) f
	WHERE a.adid = @adid
	)X
	WHERE X.mediaurl > ''



	--ADS ATTRIBUTE
	SELECT	asam.adid,asam.attributeid,asam.attributevalueid
	FROM	dbo.adssubcatattributemapping asam(NOLOCK)
	WHERE	asam.adid		=	@adid

	--ADS Redirect
	select newadid,newadurl from dbo.fn_get_adredirect(@adid)

    DROP TABLE IF EXISTS #adsmaster
	                                                                                  
	SET NOCOUNT OFF                                                          
END
GO
