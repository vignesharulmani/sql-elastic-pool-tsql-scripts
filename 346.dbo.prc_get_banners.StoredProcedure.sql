/****** Object:  StoredProcedure [dbo].[prc_get_banners]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_banners]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_banners] AS'
END
GO
Alter PROCEDURE prc_get_banners
@cityid INT,                                                        
@areaid INT=0,                                                        
@subcatid INT,                                                        
@addefid INT=0,                                                        
@needid INT=0,                                                        
@needidattributes VARCHAR(256)='',                                                        
@sortby VARCHAR(16)='',/*relevance ,recent ,low ,high ,ratesqftlow ,ratesqfthigh, img ,offers*/
@fromprice money=0,
@toprice money =0,
@RowsToFetch INT=10,                                                        
@PageNo INT=1 ,                                                        
@LocalityFilter VARCHAR(128) = '',                                                        
@CityFilter VARCHAR(64) = '',                                                        
@BrandFilter VARCHAR(512)='',                                                        
@ExcludeAdIds VARCHAR(1024) = '',
@IncludeSurroundingAreas BIT = 1,
@radius INT = 3,
@nearbyareacount tinyint =5,
@excludearea varchar(256)='',
@advpid int = 0,
@customerid int = 0,
@status int = -2,
@businessid int = 0,
@campaignid int = 0,
@adclassification int = 0  
AS                                                        
BEGIN                                                        
SET NOCOUNT ON    

BEGIN TRY

DECLARE @needidattribute split_needidattribute -- table(attributeid INT, attributevalueid INT)                                          
DECLARE @Adssorttable table(adid INT,needid INT,price money,row INT)                                          
DECLARE @Localityfiltertable split_localityfilter--table(areaid INT)                                          
DECLARE @attributevalueidcount INT = 0                                          
DECLARE @excludeadidtable split_adsid                          
DECLARE @cnt TINYINT=0,@customeradscount INT = 0     
DECLARE @advertisermobile VARCHAR(16)=''
DECLARE @isdashboard INT = 0

SET @RowsToFetch = 50

IF @status = -1
	set @status = -2

IF @advpid > 0 or @customerid > 0 or @businessid > 0 or @campaignid > 0
BEGIN
	SET @isdashboard = 1                                     
	SET @customeradscount = dbo.fn_get_customeradscount(@businessid,@customerid,@campaignid,@cityid,@status)
END

IF @isdashboard = 0 and @adclassification <> 4
BEGIN
	SET @addefid = 0
	SET @needid = 0
END

IF ISNULL(@LocalityFilter,'') > '' AND @areaid > 0
	SET @areaid = 0 
                        
IF @areaid IS NULL                                            
	SET @areaid=0                                             
IF @needidattributes IS NULL                                          
	SET @needidattributes=''                                          
IF @ExcludeAdIds IS NULL                        
	SET @ExcludeAdIds=''    
                     
IF @needidattributes<>''                                          
BEGIN                                          
	INSERT INTO @needidattribute(attributeid,attributevalueid)                                          
	SELECT attributeid, attributevalueid FROM dbo.SplitAttributes(@needidattributes,',',':',';' )                                          
END                         
	
IF @needidattributes<>'' 
BEGIN              
	SELECT @cnt=COUNT(1) FROM @needidattribute                                             
	SELECT @attributevalueidcount=COUNT( DISTINCT attributevalueid) FROM @needidattribute               
END   
             

IF @LocalityFilter!=''                                          
BEGIN                                          
	INSERT INTO @Localityfiltertable                                          
	SELECT value FROM STRING_SPLIT(@LocalityFilter,',')   WHERE value > ''                                       
	DELETE FROM @Localityfiltertable WHERE areaid=0    
END    

 
IF @ExcludeAdIds!=''                        
	INSERT INTO @excludeadidtable(adid)                        
	SELECT value FROM STRING_SPLIT(@ExcludeAdIds,',')   WHERE value > ''                          


DROP TABLE IF EXISTS #adid
DROP TABLE IF EXISTS #TEMP

CREATE TABLE #adid
(adid BIGINT PRIMARY KEY WITH(IGNORE_DUP_KEY=ON),rowid INT
,score DECIMAL(5,1),mode INT,isnearby INT,netsalevalue SMALLINT,businessid int)   

CREATE TABLE #TEMP(
rowid [int] NULL,[adid] [bigint] PRIMARY KEY WITH(IGNORE_DUP_KEY=ON)
,[businessid] [int] NULL,[cityname] [varchar](64) NULL,[areaname] [varchar](64) NULL,[admode] [smallint] NULL
,[adtitle] [varchar](256) NULL,[adurl] [varchar](256) NULL,[shortdesc] [varchar](4096) NULL
,[price] [money] NULL,[campaignid] [int] NULL,[customerid] [int] NULL
,[latitude] [float] NULL,[longitude] [float] NULL,[streetname] [varchar](512) NULL,[zipcode] [varchar](64) NULL
,[contactname] [varchar](128) NULL,[emailid] [varchar](128) NULL,[mobileno] [varchar](16) NULL
,[phoneno] [varchar](16) NULL,[ctcphone] [varchar](16) NULL,[landmark] [varchar](256) NULL
,[createddate] [datetime] NULL,[categoryid] [int] NULL
,[subcategoryid] [int] NULL,[areaid] [int] NULL,[subarea] [varchar](128) NULL,[buildingname] [varchar](128) NULL
,[buildingno] [varchar](64) NULL,[custominfo] [nvarchar](max) NULL,[netsalevalue] [smallint] NULL
,[status] [int] NULL,[isnearby] [int] NULL,[businessname] [varchar](128) NULL
) 
        
IF @adclassification = 4 and @subcatid = 9600 and exists (select top 1 1 from @needidattribute 
															where attributevalueid = 1091600)/*Builder Gallery*/
		EXEC dbo.prc_list_adslistings_buildergallery @cityid =@cityid,@areaid =@areaid,                                  
		@Localityfiltertable=@Localityfiltertable,@subcatid =@subcatid,@addefid=@addefid,
		@needid=@needid,@needidattribute =@needidattribute,@sortby =@sortby,
		@fromprice=@fromprice,@toprice=@toprice,
		@RowsToFetch = @RowsToFetch,@PageNo = @PageNo,@excludeadidtable=@excludeadidtable,
		@IncludeSurroundingAreas=@IncludeSurroundingAreas,@radius=@radius,
		@nearbyareacount=@nearbyareacount,@excludearea=@excludearea,@adclassification=7
ELSE IF @adclassification = 4 and @subcatid = 9600
		EXEC dbo.prc_list_adslistings_projectgallery @cityid =@cityid,@areaid =@areaid,                                  
		@Localityfiltertable=@Localityfiltertable,@subcatid =@subcatid,@addefid=@addefid,
		@needid=@needid,@needidattribute =@needidattribute,@sortby =@sortby,
		@fromprice=@fromprice,@toprice=@toprice,
		@RowsToFetch = @RowsToFetch,@PageNo = @PageNo,@excludeadidtable=@excludeadidtable,
		@IncludeSurroundingAreas=@IncludeSurroundingAreas,@radius=@radius,
		@nearbyareacount=@nearbyareacount,@excludearea=@excludearea,@adclassification=7
ELSE IF @adclassification = 4 and @subcatid <> 9600
		EXEC dbo.prc_list_adslistings_premiumgallery @cityid =@cityid,@areaid =@areaid,                                  
		@Localityfiltertable=@Localityfiltertable,@subcatid =@subcatid,@addefid=@addefid,
		@needid=@needid,@needidattribute =@needidattribute,@sortby =@sortby,
		@fromprice=@fromprice,@toprice=@toprice,
		@RowsToFetch = @RowsToFetch,@PageNo = @PageNo,@excludeadidtable=@excludeadidtable,
		@IncludeSurroundingAreas=@IncludeSurroundingAreas,@radius=@radius,
		@nearbyareacount=@nearbyareacount,@excludearea=@excludearea,@adclassification=@adclassification
	                               


INSERT INTO #TEMP
(
rowid,adid,businessid,cityname,areaname,admode,adtitle,adurl
,shortdesc,price,campaignid,customerid,latitude,longitude,streetname,zipcode,contactname
,emailid,mobileno,phoneno,ctcphone,landmark,createddate,categoryid,subcategoryid
,areaid,subarea,buildingname,buildingno,custominfo,netsalevalue,status,isnearby
)
SELECT
ai.rowid,am.adid,ai.businessid,am.cityname,am.areaname
,case when dbo.fn_calc_runtime_admode(am.adid) > 0 then dbo.fn_calc_runtime_admode(am.adid) else am.admode end
,am.adtitle,am.adurl
,am.shortdesc,am.price,am.campaignid,am.customerid,am.latitude,am.longitude,am.streetname,am.zipcode,am.contactname
,am.emailid,am.mobileno,am.phoneno,am.ctcphone,am.landmark,am.createddate,am.categoryid,am.subcategoryid
,am.areaid,am.subarea,am.buildingname,am.buildingno,am.custominfo,am.netsalevalue,am.status,ai.isnearby
FROM	dbo.adsmaster am (NOLOCK) INNER JOIN	#adid ai
ON		am.adid	=	ai.adid


--Ads Listing
if @subcatid = 9600
begin
;WITH cte_adlisting
AS
(
SELECT	
		ROW_NUMBER() OVER (PARTITION BY t.adid ORDER BY t.rowid	ASC) dup,t.rowid,
		t.adid adid,t.businessid,t.admode,t.adtitle,t.shortdesc shortdescription,t.price,
		t.campaignid,t.customerid,t.categoryid,t.subcategoryid,t.isnearby,t.custominfo,
		'' bookingspot,
		t.createddate posteddate,
		dbo.fn_get_projecturl('','','',t.adid,t.businessid) adurl,
		--t.adurl adurl,
		t.netsalevalue,an.addefid,an.adclassification,t.status,
		t.areaid,t.areaname,t.cityname,an.cityid,t.businessname
FROM	#TEMP t
	INNER JOIN	dbo.adsneedmapping an (NOLOCK) ON T.adid	=	an.adid
/*
WHERE 
(exists (SELECT TOP 1 1 FROM @Localityfiltertable l WHERE l.areaid = an.areaid) or ISNULL(@LocalityFilter,'0')='0')
and (an.areaid = @areaid or ISNULL(@areaid,0)=0)
*/
)
SELECT 
		t.adid adid,0 projectid,t.businessid,t.admode,t.adtitle,t.shortdescription,t.price,
		t.campaignid,t.customerid,t.categoryid,t.subcategoryid,t.isnearby,t.custominfo,
		'' bookingspot,
		t.posteddate,
		t.adurl adurl,
		t.netsalevalue,t.addefid,t.adclassification,t.status,
		dbo.fn_get_ad_singleimage_bytag(t.Adid,'elevation') bannerimage,
		t.areaid,t.areaname,t.cityname,
		dbo.fn_get_campaignadscount(t.businessid,0,0,t.cityid,0,1,0) adscount,
		pbm.businessname,dbo.fn_get_adlocalities(t.adid) bannerlocalities,
		pbm.minprice,pbm.maxprice,pbm.minarea,pbm.maxarea,pbm.displaybedroom,
		pbm.businessurl
FROM cte_adlisting t
	outer apply dbo.fn_get_projectbusinessmapping(t.adid,t.businessid) pbm
WHERE dup = 1
ORDER	BY t.rowid	ASC
end
else if @subcatid <> 9600
begin
;WITH cte_adlisting
AS
(
SELECT	
		ROW_NUMBER() OVER (PARTITION BY t.adid ORDER BY t.rowid	ASC) dup,t.rowid,
		t.adid adid,t.businessid,t.admode,t.adtitle,t.shortdesc shortdescription,t.price,
		t.campaignid,t.customerid,t.categoryid,t.subcategoryid,t.isnearby,t.custominfo,
		'' bookingspot,
		t.createddate posteddate,
		t.adurl adurl,
		t.netsalevalue,an.addefid,an.adclassification,t.status,
		t.areaid,t.areaname,t.cityname,an.cityid,t.businessname
FROM	#TEMP t
	INNER JOIN	dbo.adsneedmapping an (NOLOCK) ON T.adid	=	an.adid
WHERE ((an.adclassification = @adclassification or @adclassification = 0))
and (exists (SELECT TOP 1 1 FROM @Localityfiltertable l WHERE l.areaid = an.areaid) or ISNULL(@LocalityFilter,'0')='0')
and (an.areaid = @areaid or ISNULL(@areaid,0)=0)
)
SELECT 
		t.adid adid,0 projectid,t.businessid,t.admode,t.adtitle,t.shortdescription,t.price,
		t.campaignid,t.customerid,t.categoryid,t.subcategoryid,t.isnearby,t.custominfo,
		'' bookingspot,
		t.posteddate,
		t.adurl adurl,
		t.netsalevalue,t.addefid,t.adclassification,t.status,
		dbo.fn_get_ad_singleimage_bytag(t.Adid,'main-photo') bannerimage,
		t.areaid,t.areaname,t.cityname,
		dbo.fn_get_campaignadscount(t.businessid,0,0,t.cityid,0,1,0) adscount,
		t.businessname,dbo.fn_get_adlocalities(t.adid) bannerlocalities
FROM cte_adlisting t
WHERE dup = 1
ORDER	BY t.rowid	ASC
end


--Ads Attributes & Values
SELECT	a.adid adid,a.attributeid,a.attributevalueid
FROM	#adid T INNER JOIN	dbo.adssubcatattributemapping a (NOLOCK)
ON		T.adid	=	a.adid
ORDER BY T.rowid ASC


DROP TABLE IF EXISTS #adid
DROP TABLE IF EXISTS #TEMP 

END TRY
BEGIN CATCH

	EXEC dbo.prc_insert_errorinfo

END CATCH
                                              
SET NOCOUNT OFF           
END
GO
