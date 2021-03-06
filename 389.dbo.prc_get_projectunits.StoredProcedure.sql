/****** Object:  StoredProcedure [dbo].[prc_get_projectunits]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_projectunits]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_projectunits] AS'
END
GO
Alter PROCEDURE prc_get_projectunits
@projectid bigint,
@businessid int 
AS                                                        
BEGIN                                                        
SET NOCOUNT ON    

BEGIN TRY

declare @lv_projectid bigint = @projectid,
@lv_businessid int = @businessid


DROP TABLE IF EXISTS #adid
DROP TABLE IF EXISTS #TEMP

CREATE TABLE #adid
(adid BIGINT PRIMARY KEY WITH(IGNORE_DUP_KEY=ON),rowid INT
,score DECIMAL(5,1),mode INT,isnearby INT,netsalevalue SMALLINT)   

CREATE TABLE #TEMP(
rowid [int] NULL,[adid] [bigint] PRIMARY KEY WITH(IGNORE_DUP_KEY=ON),[projectid] [bigint] NULL
,[businessid] [int] NULL,[price] [money] NULL,[custominfo] [nvarchar](max) NULL
) 
        
IF @projectid > 0 and @businessid > 0
		EXEC dbo.prc_list_adslistings_projectads @projectid=@lv_projectid,@businessid=@lv_businessid,@status=1

INSERT INTO #TEMP
(
rowid,adid,projectid,businessid,price,custominfo
)
SELECT
ai.rowid,am.adid,am.projectid,am.businessid,am.price,am.custominfo
FROM	dbo.adsmaster am (NOLOCK) INNER JOIN	#adid ai
ON		am.adid	=	ai.adid


--Ads Listing
SELECT	t.adid adid,t.projectid,t.businessid,t.price,t.custominfo,
		an.areavalue,an.areavalueunit,an.addefid,an.adclassification,an.mode admode
FROM	#TEMP t
	INNER JOIN	dbo.adsneedmapping an (NOLOCK) ON T.adid	=	an.adid
WHERE (an.adclassification = 6)
ORDER	BY t.rowid	ASC



--Ads Media		--BusinessId ,Description,BusinessMediaType
SELECT  m.adid adid,replace(m.mediaurl,'http://','https://') mediaurl,m.mediacaption 'TagName'
FROM	#adid	T INNER JOIN dbo.adsmedia m (NOLOCK)
ON		T.adid	=	m.adid
WHERE m.mediaid > 0 and m.attributeid = 300300 /*Only Floor Plan*/
ORDER	BY T.rowid	ASC



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
