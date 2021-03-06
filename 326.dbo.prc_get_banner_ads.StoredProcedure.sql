/****** Object:  StoredProcedure [dbo].[prc_get_banner_ads]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[prc_get_banner_ads]
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
@bannertype varchar(64)                                                         
AS                                                        
BEGIN                                                        
SET NOCOUNT ON    

BEGIN TRY

declare @bannerads table (bannerid int primary key with(ignore_dup_key = on),adid bigint)

set @LocalityFilter = isnull(@LocalityFilter,'')

if @areaid > 0
	set @LocalityFilter += ',' + convert(varchar,@areaid)

insert into @bannerads(bannerid,adid)
	select bd.bannerid,bd.adid
	from bannerdetail bd (nolock) 
		join adsmaster am (nolock) on bd.adid = am.adid
	where bd.enddate > getdate() 
	and bd.cityid = @cityid
	and bd.isactive = 1
	and bd.bannertype = @bannertype
	and (exists (select top 1 1 from string_split(bd.areaids,',') ss 
						join string_split(@LocalityFilter,',') lf on ss.value = lf.value) or @LocalityFilter = '')

select  
bd.AdId,0 ProjectId,bd.BusinessId,bd.CustomerId,bd.CampaignId,am.AdTitle,am.AdURL,am.subcategoryid,am.Price,am.ContactName,
am.BuildingName,am.AreaName,am.CityName,am.ZipCode,
dbo.fn_get_ad_singleimage_bytag(bd.Adid,'elevation') ImageURL,
5 TotalRooms,bd.BannerType,am.createddate PostedDate 
from bannerdetail bd (nolock) 
	join adsmaster am (nolock) on bd.adid = am.adid
where exists (select top 1 1 from @bannerads ba where ba.bannerid = bd.bannerid)

select asam.adid,asam.attributeid,asam.attributevalueid 
from adssubcatattributemapping asam (nolock)
where exists (select top 1 1 from @bannerads ba where ba.adid = asam.adid)

END TRY
BEGIN CATCH

	EXEC dbo.prc_insert_errorinfo

END CATCH
                                              
SET NOCOUNT OFF                                                   
END
GO
