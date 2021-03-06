/****** Object:  StoredProcedure [dbo].[prc_get_recent_ads]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter PROCEDURE [dbo].[prc_get_recent_ads]
@cityid INT,                                                        
@areaid INT=0,                                                        
@subcatid INT,  
@addefid INT=0,                                                      
@needid INT=0,                                                        
@needidattributes VARCHAR(256)='',                                                        
@sortby VARCHAR(16)='recent',
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
@adclassification int = 0                                                          
AS                                                        
BEGIN                                                        
SET NOCOUNT ON    

BEGIN TRY

DECLARE @needidattribute split_needidattribute -- table(attributeid INT, attributevalueid INT)                                          
DECLARE @geo GEOMETRY,
		@areacount INT =0                                          
DECLARE @Adssorttable table(adid INT,needid INT,price money,row INT)                                          
DECLARE @Localityfiltertable split_localityfilter--table(areaid INT)                                          
DECLARE @cityfiltertable split_cityfilter                                         
DECLARE @listingtypeid TINYINT                                          
DECLARE @istotcsubcat BIT = 0                                          
DECLARE @attributevalueidcount INT = 0                                          
DECLARE @excludeadidtable split_adsid                          
DECLARE @cnt TINYINT=0                                          


SET @addefid = 0
SET @needid = 0
SET @listingtypeid=5--dbo.fn_getlistingtype(@cityid,@subcatid) 
                        
IF @areaid IS NULL                                            
	SET @areaid=0                                             
IF @needidattributes IS NULL                                          
	SET @needidattributes=''                                          
IF @CityFilter IS NULL                                          
	SET @cityfilter=''                                          
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
PRINT @cnt                  

IF @LocalityFilter!=''                                          
BEGIN                                          
	INSERT INTO @Localityfiltertable                                          
	SELECT value FROM STRING_SPLIT(@LocalityFilter,',')   WHERE value > ''                                       
	DELETE FROM @Localityfiltertable WHERE areaid=0                                          
	SELECT @areacount=COUNT(DISTINCT areaid) FROM @Localityfiltertable                
END    

IF @cityfilter!=''      
	INSERT INTO @cityfiltertable             
	SELECT value FROM STRING_SPLIT(@CityFilter,',')   WHERE value > ''                                                                                 
ELSE IF @cityfilter='' AND @cityid>0                                          
	INSERT INTO @cityfiltertable                                          
	SELECT @cityid                               
ELSE IF @cityfilter='' AND @cityid=0                                          
	INSERT INTO @cityfiltertable                                          
	SELECT 0                                        
	
IF @cityid=0 AND @cityfilter!=''                            
	SELECT @cityid=CAST(cityid AS INT) FROM @cityfiltertable
                            
IF @ExcludeAdIds!=''                        
	INSERT INTO @excludeadidtable(adid)                        
	SELECT value FROM STRING_SPLIT(@ExcludeAdIds,',')   WHERE value > ''  
	
DROP TABLE IF EXISTS #adid
DROP TABLE IF EXISTS #TEMP 	                        

CREATE TABLE #adid
(adid BIGINT,rowid INT,score DECIMAL(5,1),mode INT
,isnearby INT,netsalevalue SMALLINT)   

CREATE TABLE #TEMP(
rowid [int] NULL,[adid] [bigint] PRIMARY KEY WITH(IGNORE_DUP_KEY=ON),[projectid] [bigint] NULL,[businessid] [int] NULL
,[cityname] [varchar](64) NULL,[areaname] [varchar](64) NULL,[adtitle] [varchar](256) NULL,[adurl] [varchar](256) NULL
,[price] [money] NULL,[campaignid] [int] NULL,[customerid] [int] NULL,[zipcode] [varchar](64) NULL
,[contactname] [varchar](128) NULL,[emailid] [varchar](128) NULL,[mobileno] [varchar](16) NULL,[createddate] [datetime] NULL
,[subcategoryid] [int] NULL,[countrycode] [int] NULL,[buildingname] [varchar](128) NULL,[custominfo] [nvarchar](max) NULL
)                                          
 

		EXEC dbo.prc_list_adslistings_recent   @cityid =@cityid,@areaid =@areaid,                                          
		@Localityfiltertable=@Localityfiltertable,@subcatid =@subcatid,
		@addefid=@addefid,@needid=@needid,
		@needidattribute =@needidattribute,@sortby =@sortby,
		@fromprice=@fromprice,@toprice=@toprice,
		@RowsToFetch = @RowsToFetch,@PageNo = @PageNo,@excludeadidtable=@excludeadidtable,
		@IncludeSurroundingAreas=@IncludeSurroundingAreas,@radius=@radius,
		@nearbyareacount=@nearbyareacount,@excludearea=@excludearea,@adclassification=@adclassification                               
                              
  


INSERT INTO #TEMP
(
rowid,adid,projectid,businessid,cityname,areaname,adtitle,adurl
,price,campaignid,customerid,zipcode,contactname,emailid,mobileno
,createddate,subcategoryid,countrycode,buildingname,custominfo
)
SELECT  ai.rowid,ad.adid,ad.projectid,ad.businessid,ad.cityname,ad.areaname,ad.adtitle,ad.adurl
		,ad.price,ad.campaignid,ad.customerid,ad.zipcode,ad.contactname,ad.emailid,ad.mobileno
		,ad.createddate,ad.subcategoryid,ad.countrycode,ad.buildingname,ad.custominfo
FROM	dbo.adsmaster ad (NOLOCK) INNER JOIN	#adid ai
ON		ad.adid	=	ai.adid


--Ads Listing
SELECT	
	t.AdId,t.ProjectId,t.BusinessId,t.CustomerId,t.CampaignId,t.AdTitle,t.AdURL,t.subcategoryid,t.Price
	,t.ContactName,t.BuildingName,t.AreaName,t.CityName,t.ZipCode
	,dbo.fn_get_ad_singleimage_bytag(t.Adid,'elevation') ImageURL
	,t.custominfo,anm.addefid
FROM	#TEMP t 
	INNER JOIN adsneedmapping anm (nolock) on t.adid = anm.adid
ORDER	BY t.rowid	ASC

--Ads Attributes & Values
SELECT	DISTINCT t.rowid,a.adid,a.attributeid,a.attributevalueid
FROM	#adid T INNER JOIN	dbo.adssubcatattributemapping a (NOLOCK)
ON		T.adid	=	a.adid
ORDER BY t.rowid	ASC,a.attributeid,a.attributevalueid



DROP TABLE IF EXISTS #adid
DROP TABLE IF EXISTS #TEMP 

END TRY
BEGIN CATCH

	EXEC dbo.prc_insert_errorinfo

END CATCH
                                              
SET NOCOUNT OFF                                                   
END
GO
