CREATE PROCEDURE prc_get_admatching_leaddistribution
@cityid INT,                                                        
@areaid INT,                                                        
@subcatid INT,                                                        
@addefid INT=0,                                                        
@needid INT=0,                                                        
@needidattributes VARCHAR(256),                                                        
@sortby VARCHAR(16)='',/*relevance ,recent ,low ,high ,ratesqftlow ,ratesqfthigh, img ,offers*/
@fromprice money=0,
@toprice money =0,
@fromarea int =0,
@toarea int =0,
@areaunit varchar(32)='',
@RowsToFetch INT=10,                                                        
@PageNo INT=1 ,                                                        
@LocalityFilter VARCHAR(128) = '',
@NearbyLocalityFilter VARCHAR(128) = '',                                                        
@CityFilter VARCHAR(64) = '',                                                        
@BrandFilter VARCHAR(512)='',                                                        
@ExcludeAdIds VARCHAR(1024) = '',
@IncludeSurroundingAreas BIT = 0,
@radius INT = 3,
@nearbyareacount tinyint =5,
@excludearea varchar(256)='',
@advpid int = 0,
@customerid int = 0,
@status int = -2,
@businessid int = 0,
@campaignid int = 0,
@adclassification int = 0,
@adid bigint = 0,  
@projectid bigint = 0,
@admode varchar(32)=''
AS                                                        
BEGIN                                                        
SET NOCOUNT ON    

BEGIN TRY

DECLARE @needidattribute split_needidattribute -- table(attributeid INT, attributevalueid INT)                                          
DECLARE @Adssorttable table(adid INT,needid INT,price money,row INT)                                          
DECLARE @Localityfiltertable split_localityfilter--table(areaid INT)                                          
DECLARE @NearbyLocalityfiltertable split_localityfilter--table(areaid INT)                                          
DECLARE @attributevalueidcount INT = 0                                          
DECLARE @excludeadidtable split_adsid                          
DECLARE @cnt TINYINT=0,@customeradscount INT = 0     
DECLARE @advertisermobile VARCHAR(16)=''
DECLARE @isdashboard INT = 0
DECLARE @lv_fromarea int = dbo.fn_tosqft(@fromarea,@areaunit)
DECLARE @lv_toarea int = dbo.fn_tosqft(@toarea,@areaunit)
DECLARE @lv_LocalityFilter VARCHAR(100) = @LocalityFilter

SET @IncludeSurroundingAreas = 0

IF @admode = '20' and @subcatid = 9600
	SET @NeedidAttributes = '286500:1035802' + ',' + isnull(@needidattributes,'')
ELSE IF @admode = '30' and @subcatid = 9600 
	SET @NeedidAttributes = '286500:1036200' + ',' + isnull(@needidattributes,'')
ELSE IF @admode = '40' and @subcatid = 9600
	SET @NeedidAttributes = '286500:1036002;1036102' + ',' + isnull(@needidattributes,'')
ELSE IF @admode = '20' and @subcatid = 9000
	SET @NeedidAttributes = '275101:1008503' + ',' + isnull(@needidattributes,'')
ELSE IF @admode = '20' and @subcatid = 951
	SET @NeedidAttributes = '254711:967932' + ',' + isnull(@needidattributes,'')



IF @subcatid = 9600 
	set @adclassification = 6
ELSE IF @subcatid = 9000 
	set @adclassification = 5
ELSE IF @subcatid = 951
	set @adclassification = 3


IF @needid in (67300,67200) /*Exclude Resale Need*/
	set @needid = 0

IF @areaid > 0
BEGIN
	set @lv_LocalityFilter= @lv_LocalityFilter + ',' + convert(varchar,@areaid)
	set @areaid = 0
END

                     
IF @needidattributes<>''                                
BEGIN        
	INSERT INTO @needidattribute(attributeid,attributevalueid)                                          
	SELECT case when attributeid = 53188 then 6802 else attributeid end attributeid, attributevalueid 
	FROM dbo.SplitAttributes(@needidattributes,',',':',';' )   
	WHERE attributeid > 0       
END        
	
IF @needidattributes<>'' 
BEGIN              
	SELECT @cnt=COUNT(1) FROM @needidattribute                                             
	SELECT @attributevalueidcount=COUNT( DISTINCT attributevalueid) FROM @needidattribute           
END   
          
set @LocalityFilter = ''

select @LocalityFilter = convert(varchar,X.areaid) + ',' + @LocalityFilter from (
select agm.areaid
	from Areagroupmaster agm (nolock)
		join string_split(@lv_LocalityFilter,',')ss on agm.Prominentroad_areaid = ss.value
union
select value from string_split(@lv_LocalityFilter,',')ss
)X		  
		     

IF @LocalityFilter!=''                                          
BEGIN                                 
	INSERT INTO @Localityfiltertable    
	SELECT value FROM STRING_SPLIT(@LocalityFilter,',')   WHERE value > ''                                       
	DELETE FROM @Localityfiltertable WHERE areaid=0    
END
                       


DROP TABLE IF EXISTS #adid
DROP TABLE IF EXISTS #TEMP

CREATE TABLE #adid
(adid BIGINT PRIMARY KEY WITH(IGNORE_DUP_KEY=ON),rowid INT
,score DECIMAL(5,1),mode INT,isnearby INT,netsalevalue SMALLINT,listingsection INT)   

CREATE TABLE #TEMP(
rowid [int] NULL,[adid] [bigint] PRIMARY KEY WITH(IGNORE_DUP_KEY=ON),[projectid] [bigint] NULL
,[businessid] [int] NULL,[cityname] [varchar](64) NULL,[areaname] [varchar](64) NULL,[admode] [smallint] NULL
,[adtitle] [varchar](256) NULL,[adurl] [varchar](256) NULL,[shortdesc] [nvarchar](4000) NULL
,[price] [money] NULL,[campaignid] [int] NULL,[customerid] [int] NULL
,[latitude] [float] NULL,[longitude] [float] NULL,[streetname] [varchar](512) NULL,[zipcode] [varchar](64) NULL
,[contactname] [varchar](128) NULL,[emailid] [varchar](128) NULL,[mobileno] [varchar](16) NULL
,[phoneno] [varchar](16) NULL,[ctcphone] [varchar](16) NULL,[landmark] [varchar](256) NULL
,[createddate] [datetime] NULL,[categoryid] [int] NULL
,[subcategoryid] [int] NULL,[areaid] [int] NULL,[subarea] [varchar](128) NULL,[buildingname] [varchar](128) NULL
,[buildingno] [varchar](64) NULL,[custominfo] [nvarchar](max) NULL,[netsalevalue] [smallint] NULL
,[status] [int] NULL,[isnearby] [int] NULL,[cityid] [int] NULL,[listdate] [datetime] NULL
,[closedate] [datetime] NULL,[businessname] [varchar](128) NULL,[countrycode] [int] NULL
) 


IF isnull(nullif(@cityid,''),0) > 0 and @lv_LocalityFilter > '' and isnull(nullif(@subcatid,''),0) > 0
begin
		EXEC dbo.prc_list_adslistings_relevance_alchemy @cityid =@cityid,@areaid =@areaid,                                  
		@Localityfiltertable=@Localityfiltertable,@NearbyLocalityfiltertable=@NearbyLocalityfiltertable,
		@subcatid =@subcatid,@addefid=@addefid,
		@needid=@needid,@needidattribute =@needidattribute,@sortby =@sortby,
		@fromprice=@fromprice,@toprice=@toprice,@fromarea=@lv_fromarea,@toarea=@lv_toarea,
		@RowsToFetch = 50,@PageNo = 1,@excludeadidtable=@excludeadidtable,
		@IncludeSurroundingAreas=@IncludeSurroundingAreas,@radius=@radius,
		@nearbyareacount=@nearbyareacount,@excludearea=@excludearea,@adclassification=@adclassification                               
end
	                               


INSERT INTO #TEMP
(
rowid,adid,projectid,businessid,cityname,areaname,admode,adtitle,adurl
,shortdesc,price,campaignid,customerid,latitude,longitude,streetname,zipcode,contactname
,emailid,mobileno,phoneno,ctcphone,landmark,createddate,categoryid,subcategoryid
,areaid,subarea,buildingname,buildingno,custominfo,netsalevalue,status,isnearby,cityid
,listdate,closedate,businessname,countrycode 
)
SELECT
ai.rowid,am.adid,am.projectid,am.businessid,am.cityname,am.areaname
,case when isnull(@lv_LocalityFilter,'') > '0' and dbo.fn_calc_runtime_admode(am.adid) > 0 then dbo.fn_calc_runtime_admode(am.adid) else am.admode end
,am.adtitle,am.adurl
,am.shortdesc,am.price,am.campaignid,am.customerid,am.latitude,am.longitude,am.streetname,am.zipcode,am.contactname
,am.emailid,am.mobileno,am.phoneno,am.ctcphone,am.landmark,am.createddate,am.categoryid,am.subcategoryid
,am.areaid,am.subarea,am.buildingname,am.buildingno,am.custominfo,am.netsalevalue,am.status
,isnull(ai.isnearby,0),am.cityid,am.listdate,am.closedate,am.businessname,am.countrycode
FROM	dbo.adsmaster am (NOLOCK) INNER JOIN	#adid ai
ON		am.adid	=	ai.adid


IF @RowsToFetch > 25
	set @RowsToFetch = 25

--Ads Listing
SELECT top(@RowsToFetch) adid,projectid,businessid,needid,adtitle,projectname,businessname,admode,areaid,areaname,
cityid,cityname,campaignid,customerid,contactname name,emailid email,mobileno mobile,countrycode,
adtitle title,adurl url,projecturl,closedate expirydate,
subcategoryid,runrate,displayattributes 
from (
SELECT	
		row_number() over (partition by t.businessid order by t.rowid) dupeid,t.rowid,
		t.adid adid,t.projectid,t.businessid,an.needid,t.adtitle,t.buildingname projectname,t.businessname,
		t.admode,t.areaid,t.areaname,t.cityid,t.cityname,t.campaignid,t.customerid,t.contactname,
		t.emailid,t.mobileno,t.countrycode,t.adurl,
		case when t.projectid > 0 then dbo.fn_get_projecturl('','','',t.projectid,t.businessid) end projecturl,
		t.closedate,dbo.fn_get_runrate(0,t.cityid,0,t.campaignid) runrate,t.subcategoryid,
		dbo.fn_get_displayattributes(t.adtitle,t.buildingname,t.price,t.areaname,t.cityname)displayattributes
FROM	#TEMP t
	INNER JOIN	dbo.adsneedmapping an (NOLOCK) ON T.adid	=	an.adid
WHERE (an.adclassification = @adclassification or @adclassification = 0)
)X WHERE dupeid = 1 and runrate > 0
ORDER	BY rowid	ASC




DROP TABLE IF EXISTS #adid
DROP TABLE IF EXISTS #TEMP 

END TRY
BEGIN CATCH

	EXEC dbo.prc_insert_errorinfo

END CATCH
                                              
SET NOCOUNT OFF           
END