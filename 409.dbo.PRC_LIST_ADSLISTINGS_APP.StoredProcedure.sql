/****** Object:  StoredProcedure [dbo].[PRC_LIST_ADSLISTINGS_APP]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRC_LIST_ADSLISTINGS_APP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PRC_LIST_ADSLISTINGS_APP] AS'
END
GO
Alter PROCEDURE PRC_LIST_ADSLISTINGS_APP
@cityid INT,                                                        
@areaid INT=0,                                                        
@subcatid INT,                                                        
@addefid INT=0,                                                        
@needid INT=0,                                                        
@needidattributes VARCHAR(256)='',                                                        
@sortby VARCHAR(16)='',/*relevance ,recent ,low ,high ,ratesqftlow ,ratesqfthigh, img ,offers*/
@fromprice money=0,
@toprice money =0,
@fromarea int =0,
@toarea int =0,
@areaunit varchar(32)='',
@RowsToFetch INT=50,                                                        
@PageNo INT=1 ,                                                        
@LocalityFilter VARCHAR(128) = '',
@NearbyLocalityFilter VARCHAR(128) = '',                                                        
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
@adclassification int = 0,
@adid bigint = 0,  
@projectid bigint = 0,
@adidlists varchar(2048)=''
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


IF @NeedidAttributes='281500:1027500;1027600;1027601;1027700' and @subcatid = 9600
BEGIN
	set @NeedidAttributes = ''
	set @needid = 62300
END	
ELSE IF @NeedidAttributes='281500:1028002;1028102;1028103;1028200;1028201' and @subcatid = 9600
BEGIN
	set @NeedidAttributes = ''
	set @needid = 62400
END	

IF @businessid > 0 and isnull(@adidlists,'')='' 
select @adidlists = string_agg(asm.adid ,',') within group (order by asm.adid asc) 
	from dbo.adssubcatmapping asm(nolock) 
		join dbo.adsneedmapping anm (nolock) on asm.adid = anm.adid
where anm.adclassification = 2 and anm.status = 1
and asm.businessid = @businessid
and asm.cityid = @cityid

IF @advpid > 0 and isnull(@adidlists,'')=''
	set @adidlists = dbo.fn_get_offersforyou(@advpid)

IF @status = -1
	set @status = -2

IF ISNULL(@adclassification,0)=0
	set @adclassification = 0

IF @advpid > 0 or @customerid > 0 or @businessid > 0 or @campaignid > 0
BEGIN
	SET @isdashboard = 1 
	
	IF @customerid > 0 or @businessid > 0 or @campaignid > 0                                    
		SET @customeradscount = dbo.fn_get_customeradscount(@businessid,@customerid,@campaignid,@cityid,@status)
	ELSE IF @advpid > 0
		SET @customeradscount = dbo.fn_get_useradscount(@advpid,@cityid,@status)
END

IF @isdashboard = 0 and @adclassification <> 4
BEGIN
	SET @addefid = 0
	SET @needid = 0
END

IF @areaid > 0
BEGIN
	set @lv_LocalityFilter= @lv_LocalityFilter + ',' + convert(varchar,@areaid)
	set @areaid = 0
END

IF ISNULL(@lv_LocalityFilter,'') > '' AND @areaid > 0
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
	SELECT case when attributeid = 53188 then 6802 else attributeid end attributeid, attributevalueid 
	FROM dbo.SplitAttributes(@needidattributes,',',':',';' )          
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

IF @NearbyLocalityFilter!=''                                          
BEGIN                                 
	INSERT INTO @NearbyLocalityfiltertable    
	SELECT value FROM STRING_SPLIT(@NearbyLocalityFilter,',')   WHERE value > ''                                       
	DELETE FROM @NearbyLocalityfiltertable WHERE areaid=0    
END    

                            
IF @ExcludeAdIds!=''                        
	INSERT INTO @excludeadidtable(adid)                        
	SELECT value FROM STRING_SPLIT(@ExcludeAdIds,',')   WHERE value > ''                          


DROP TABLE IF EXISTS #adid
DROP TABLE IF EXISTS #TEMP

CREATE TABLE #adid
(adid BIGINT PRIMARY KEY WITH(IGNORE_DUP_KEY=ON),rowid INT
,score DECIMAL(5,1),mode INT,isnearby INT,netsalevalue SMALLINT)   

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
,[closedate] [datetime] NULL,[offer] [varchar](256) NULL,[price2] [money] NULL
) 
        

		IF isnull(@adid,0)=0 and isnull(@adidlists,'')='' and isnull(@advpid,0)=0
			EXEC dbo.prc_list_adslistings_relevance @cityid =@cityid,@areaid =@areaid,                                  
			@Localityfiltertable=@Localityfiltertable,@NearbyLocalityfiltertable=@NearbyLocalityfiltertable,
			@subcatid =@subcatid,@addefid=@addefid,
			@needid=@needid,@needidattribute =@needidattribute,@sortby =@sortby,
			@fromprice=@fromprice,@toprice=@toprice,@fromarea=@lv_fromarea,@toarea=@lv_toarea,
			@RowsToFetch = @RowsToFetch,@PageNo = @PageNo,@excludeadidtable=@excludeadidtable,
			@IncludeSurroundingAreas=@IncludeSurroundingAreas,@radius=@radius,
			@nearbyareacount=@nearbyareacount,@excludearea=@excludearea,@adclassification=@adclassification                       
		ELSE IF @adid > 0 or isnull(@adidlists,'')>''
			EXEC dbo.prc_list_adslistings_adid @adid = @adid,@adidlists=@adidlists
	                       


INSERT INTO #TEMP
(
rowid,adid,projectid,businessid,cityname,areaname,admode,adtitle,adurl
,shortdesc,price,campaignid,customerid,latitude,longitude,streetname,zipcode,contactname
,emailid,mobileno,phoneno,ctcphone,landmark,createddate,categoryid,subcategoryid
,areaid,subarea,buildingname,buildingno,custominfo,netsalevalue,status,isnearby,cityid
,listdate,closedate,offer,price2 
)
SELECT
ai.rowid,am.adid,am.projectid,am.businessid,am.cityname,am.areaname
,case when isnull(@lv_LocalityFilter,'') > '0' and dbo.fn_calc_runtime_admode(am.adid) > 0 then dbo.fn_calc_runtime_admode(am.adid) else am.admode end
,am.adtitle,am.businessurl adurl
,am.shortdesc,am.price,am.campaignid,am.customerid,am.latitude,am.longitude,am.streetname,am.zipcode,am.contactname
,am.emailid,am.mobileno,am.phoneno,am.ctcphone,am.landmark,am.createddate,am.categoryid,am.subcategoryid
,am.areaid,am.subarea,am.buildingname,am.buildingno,am.custominfo,am.netsalevalue,am.status
,isnull(ai.isnearby,0),am.cityid,am.listdate,am.closedate,am.offer,am.price2
FROM	dbo.adsmaster am (NOLOCK) INNER JOIN	#adid ai
ON		am.adid	=	ai.adid


--Ads Listing
SELECT	t.adid adid,t.businessid,t.adtitle,t.shortdesc shortdescription,
		convert(bigint,t.price) price,t.custominfo,t.createddate posteddate,
		t.adurl adurl,dbo.fn_get_ad_singleimage_bytag(t.adid,'')imageurl,
		format(t.listdate,'dd MMM yyyy')listdate,format(t.closedate,'dd MMM yyyy')closedate,
		isnull(dbo.fn_calc_discount(convert(money,dbo.fn_extract_custominfo(t.custominfo,'Actual Price')),t.price),'') discount,
		t.admode mode,t.subcategoryid,anm.needid,isnull(t.offer,'')offer,
		dbo.fn_check_isfeatured_ad(t.adid) isfeatured,t.price2 actualprice,
		dbo.fn_calc_discount2(t.price2,t.price) formatdiscount
FROM	#TEMP t
	JOIN dbo.adsneedmapping anm (nolock) on t.adid = anm.adid
ORDER	BY t.rowid	ASC



DROP TABLE IF EXISTS #adid
DROP TABLE IF EXISTS #TEMP 

END TRY
BEGIN CATCH

	EXEC dbo.prc_insert_errorinfo

END CATCH
                                              
SET NOCOUNT OFF  
END
GO
