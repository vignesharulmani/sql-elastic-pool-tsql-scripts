/****** Object:  StoredProcedure [dbo].[prc_get_customer_otherads]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[prc_get_customer_otherads]                                  
@adid bigint = 0 ,
@ExcludeAdIds VARCHAR(1024) = ''
AS                                                        
BEGIN                                                        
SET NOCOUNT ON    

BEGIN TRY

DECLARE
@cityid INT,                                                        
@areaid INT=0,                                                        
@subcatid INT,                                                        
@needid INT=0,                                                        
@needidattributes VARCHAR(256)='',                                                        
@sortby VARCHAR(16)='',/*relevance ,recent ,low ,high ,ratesqftlow ,ratesqfthigh, img ,offers */
@price money=0,
@fromprice money=0,
@toprice money =0,
@RowsToFetch INT=10,                                                        
@PageNo INT=1 ,                                                        
@LocalityFilter VARCHAR(128) = '',                                                        
@CityFilter VARCHAR(64) = '',                                                        
@BrandFilter VARCHAR(512)='',                                                        
@IncludeSurroundingAreas BIT = 1,
@radius INT = 3,
@nearbyareacount tinyint =5,
@excludearea varchar(256)='',
@lat float = null,
@long float = null,
@customerid int                 


DECLARE @needidattribute split_needidattribute -- table(attributeid INT, attributevalueid INT)                                          
DECLARE @Adssorttable table(adid INT,needid INT,price money,row INT)                                          
DECLARE @Localityfiltertable split_localityfilter--table(areaid INT)                                          
DECLARE @attributevalueidcount INT = 0                                          
DECLARE @excludeadidtable split_adsid                          
DECLARE @includeadidtable split_adsid                          
DECLARE @cnt TINYINT=0     
DECLARE @advertisermobile VARCHAR(16)=''                                     


                        
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

IF @adid > 0
BEGIN
	select top 1 @cityid = cityid,@areaid = 0,@subcatid= subcategoryid,
	@customerid = customerid
	from dbo.adsmaster am (nolock) 
	where adid = @adid

	insert into @includeadidtable(adid)
	select adid
	from dbo.adsmaster am (nolock) where customerid = @customerid and adid <> @adid and @customerid > 0

	set @sortby = 'otherads'
	set @RowsToFetch= 6
END

DROP TABLE IF EXISTS #adid
DROP TABLE IF EXISTS #TEMP

CREATE TABLE #adid
(adid BIGINT,rowid INT,score DECIMAL(5,1),mode INT
,isnearby INT,netsalevalue SMALLINT)        

CREATE TABLE #TEMP(
rowid [int] NULL,[adid] [bigint] PRIMARY KEY WITH(IGNORE_DUP_KEY=ON),[projectid] [int] NULL
,[businessid] [int] NULL,[cityname] [varchar](64) NULL,[areaname] [varchar](64) NULL,[admode] [smallint] NULL
,[adtitle] [varchar](256) NULL,[adurl] [varchar](256) NULL,[price] [money] NULL,[campaignid] [int] NULL
,[customerid] [int] NULL,[latitude] [float] NULL,[longitude] [float] NULL,[zipcode] [varchar](64) NULL
,[landmark] [varchar](256) NULL,[createddate] [datetime] NULL,[offer] [varchar](256) NULL
,[custominfo] [nvarchar](max) NULL,[isnearby] [int] NULL
)                                      
 
                                 
IF @sortby='otherads' or @sortby=''
		EXEC dbo.prc_list_customer_otherads @cityid =@cityid,@areaid =@areaid,                                          
		@Localityfiltertable=@Localityfiltertable,@subcatid =@subcatid,@needid=@needid,
		@needidattribute =@needidattribute,@sortby =@sortby,
		@fromprice=@fromprice,@toprice=@toprice,
		@RowsToFetch = @RowsToFetch,@PageNo = @PageNo,@excludeadidtable=@excludeadidtable,
		@IncludeSurroundingAreas=@IncludeSurroundingAreas,@radius=@radius,
		@nearbyareacount=@nearbyareacount,@excludearea=@excludearea,
		@lat=@lat,@long=@long,@includeadidtable=@includeadidtable
   

INSERT INTO #TEMP
(
rowid,adid,projectid,businessid,cityname
,areaname,admode,adtitle,adurl
,price,campaignid,customerid
,latitude,longitude,zipcode,landmark
,createddate,offer,custominfo,isnearby
)
SELECT  ai.rowid,ad.adid,ad.projectid,ad.businessid,ad.cityname
		,ad.areaname,ad.admode,ad.adtitle,ad.adurl
		,ad.price,ad.campaignid,ad.customerid
		,ad.latitude,ad.longitude,ad.zipcode,ad.landmark
		,ad.createddate,ad.offer,ad.custominfo,ai.isnearby   
FROM	dbo.adsmaster ad (NOLOCK) INNER JOIN	#adid ai
ON		ad.adid	=	ai.adid


--Ads Listing
SELECT	t.adid,t.projectid,t.businessid,t.admode,t.adtitle,t.price,
		t.campaignid,t.customerid,t.isnearby,t.custominfo,
		t.createddate posteddate,
		t.adurl adurl,
		t.areaname,t.cityname,
		t.zipcode,t.landmark,t.latitude,t.longitude,
		dbo.fn_get_ad_singleimage_bytag(t.adid,'elevation') [imageurl],
		anm.addefid
FROM	#TEMP t
	INNER JOIN dbo.adsneedmapping anm (NOLOCK) ON t.adid = anm.adid
ORDER	BY t.rowid	ASC


--Ads Attributes & Values
SELECT	a.adid,a.attributeid,a.attributevalueid
FROM	#adid T 
	INNER JOIN	dbo.adssubcatattributemapping a (NOLOCK) ON		T.adid	=	a.adid
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
