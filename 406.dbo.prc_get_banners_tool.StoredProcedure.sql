/****** Object:  StoredProcedure [dbo].[prc_get_banners_tool]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_banners_tool]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_banners_tool] AS'
END
GO
Alter PROCEDURE prc_get_banners_tool                                                                                                             
@needidattributes VARCHAR(256),                                                     
@businessid int
AS                                                        
BEGIN                                                        
SET NOCOUNT ON    

BEGIN TRY

DECLARE @needidattribute split_needidattribute -- table(attributeid INT, attributevalueid INT)                                                                             
DECLARE @lv_needidattributes varchar(256) = @needidattributes
DECLARE @lv_businessid int = @businessid

    
                     
IF @lv_needidattributes<>''                                          
BEGIN                                          
	INSERT INTO @needidattribute(attributeid,attributevalueid)                                          
	SELECT attributeid, attributevalueid FROM dbo.SplitAttributes(@lv_needidattributes,',',':',';' )                                          
END                         
	

  

	;with cte_banners
	as
	(
	select 
	row_number() over (partition by anm.adid order by anm.adid) dupid,
	anm.adid,anm.areaid,anm.areaname,asm.campaignid,asm.businessid,bm.adid referenceid 
	from dbo.adsneedmapping anm (nolock)
		join dbo.adssubcatmapping asm (nolock) on anm.adid = asm.adid
		join dbo.bannermapping bm (nolock) on asm.adid = bm.bannerid
		join @needidattribute na on bm.bannertypeattributevalueid = na.attributevalueid
	where  anm.adclassification = 4
	and (asm.businessid = @lv_businessid)
	and anm.status = 1
	)
	select 
		c.adid bannerid,c.referenceid,
		dbo.fn_get_adtitle(c.referenceid) referencetitle,
		c.areaid,c.areaname,c.campaignid,c.businessid 
		from cte_banners c 
	where c.dupid = 1


END TRY
BEGIN CATCH

	EXEC dbo.prc_insert_errorinfo

END CATCH
                                              
SET NOCOUNT OFF           
END
GO
