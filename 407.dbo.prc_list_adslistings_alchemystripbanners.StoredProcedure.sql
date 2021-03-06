/****** Object:  StoredProcedure [dbo].[prc_list_adslistings_alchemystripbanners]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_list_adslistings_alchemystripbanners]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_list_adslistings_alchemystripbanners] AS'
END
GO
Alter procedure [dbo].[prc_list_adslistings_alchemystripbanners]
@cityid int,                              
@areaid int=0,                              
@subcatid int, 
@addefid INT=0,                             
@needid int=0,                              
@needidattribute split_needidattribute readonly, 
@Localityfiltertable   split_localityfilter readonly,                            
@sortby varchar(16)='score',                              
@fromprice money=0,
@toprice money =0,
@fromarea int = 0,
@toarea int = 0,
@RowsToFetch int=10,                              
@PageNo int=1 ,                              
@excludeadidtable split_adsid  readonly,
@IncludeSurroundingAreas BIT = 1,
@radius INT = 3,
@nearbyareacount tinyint =5,
@excludearea varchar(256)='',
@adclassification int = 0                    
as                     
begin                    
                    
set nocount on

                                    
declare @tblarea table (rowid int identity,areaid int primary key with(ignore_dup_key = on)
							,isnearby int,radius real)

declare @attributevaluecount int = 1
declare @attributecount int = 1
declare @morerecords int = 1

declare
@lv_fromprice money= @fromprice,
@lv_toprice money = @toprice,
@lv_fromarea int= @fromarea,
@lv_toarea int = @toarea
 
if @areaid > 0
	insert into @tblarea(areaid,isnearby,radius)
		select @areaid,0,0

if exists (select top 1 1 from @Localityfiltertable)
	insert into @tblarea(areaid,isnearby,radius)
		select areaid,0,0 from @Localityfiltertable
     

/*City Page with attributes*/
if not exists (select top 1 1 from @tblarea) and exists (select top 1 1 from @needidattribute)
begin
print 'city page'

		
		;With cte_CustomerBanners
		as
		(
		select a.adid,a.businessid,bm.adid projectid
		from dbo.adssubcatmapping(nolock)  a
			join dbo.adsneedmapping (nolock)anm on a.adid = anm.adid
			join bannermapping bm (nolock) on bm.bannerid = a.adid                      
		where a.adid > 0 and a.businessid > 0
		and (a.cityid=@cityid) and (a.subcategoryid=@subcatid) 
		and a.status = 1 and bm.isactive = 1
		and exists (select top 1 1 from @needidattribute na 
						where bm.bannertypeattributevalueid=na.attributevalueid)
		),Ads_need   
		as                              
		(                              
		select top(( @RowsToFetch * @pageno )+ @morerecords)
			row_number() over (order by  oapc,mode desc) as RowID,
			adid,cityid,mode,bannerbusinessid             
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then a.campaignid else 999999999 end 
								order by a.minprice) oapc,
			a.adid,a.cityid,a.mode,c.businessid bannerbusinessid
		from dbo.adsNeedMapping(nolock)  a
			join cte_CustomerBanners c on c.projectid=a.adid
		where a.adid > 0
		and (a.subcategoryid=@subcatid) 
		and (a.addefid=@addefid or @addefid = 0)
		and (a.needid=@needid or @needid = 0)               
		and (a.adclassification=@adclassification or @adclassification = 0)                           
		and a.status = 1
		--and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		--and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		--and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		--and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		--and exists (select top 1 1 from cte_CustomerBanners c where c.projectid=a.adid)
		) a where dup = 1
		)                 
		Insert into #alchemystripbanners(adid,rowid,businessid,listingsection)    
		select top(( @RowsToFetch * @pageno) + @morerecords)  
			am.adid,b.RowID,b.bannerbusinessid,1
		from Ads_need b  
			join dbo.adsmaster am (nolock) on b.adid = am.adid
		where b.RowID > ((@PageNo - 1) * @RowsToFetch) 
		order by b.RowID

end

/*Locality Page with attributes*/
else if exists (select top 1 1 from @tblarea) and exists (select top 1 1 from @needidattribute)
begin

print 'loc page'
		;With cte_CustomerBanners
		as
		(
		select a.adid,a.businessid,bm.adid projectid
		from dbo.adssubcatmapping(nolock)  a
			join dbo.adsneedmapping (nolock)anm on a.adid = anm.adid
			inner join @tblarea ta on anm.areaid = ta.areaid
			join bannermapping bm (nolock) on bm.bannerid = a.adid                      
		where a.adid > 0 and a.businessid > 0
		and (a.cityid=@cityid) and (a.subcategoryid=@subcatid) 
		and a.status = 1 and bm.isactive = 1
		and exists (select top 1 1 from @needidattribute na 
						where bm.bannertypeattributevalueid=na.attributevalueid)
		),Ads_need   
		as                              
		(                              
		select top(( @RowsToFetch * @pageno )+ @morerecords)
			row_number() over (order by  oapc,mode desc) as RowID,
			adid,cityid,mode,bannerbusinessid             
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then a.campaignid else 999999999 end 
								order by a.minprice) oapc,
			a.adid,a.cityid,a.mode,c.businessid bannerbusinessid
		from dbo.adsNeedMapping(nolock)  a
			join cte_CustomerBanners c on c.projectid=a.adid
		where a.adid > 0
		and (a.subcategoryid=@subcatid) 
		and (a.addefid=@addefid or @addefid = 0)
		and (a.needid=@needid or @needid = 0)               
		and (a.adclassification=@adclassification or @adclassification = 0)                           
		and a.status = 1
		--and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		--and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		--and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		--and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		--and exists (select top 1 1 from cte_CustomerBanners c where c.projectid=a.adid)
		) a where dup = 1
		)                 
		Insert into #alchemystripbanners(adid,rowid,businessid,listingsection)    
		select top(( @RowsToFetch * @pageno) + @morerecords)  
			am.adid,b.RowID,b.bannerbusinessid,1
		from Ads_need b  
			join dbo.adsmaster am (nolock) on b.adid = am.adid
		where b.RowID > ((@PageNo - 1) * @RowsToFetch) 
		order by b.RowID

end


select @attributevaluecount = count(distinct attributevalueid) from @needidattribute  
where attributeid <> 304300

select @attributecount = count(distinct attributeid) from @needidattribute 
where attributeid <> 304300

	
		;with cte_alchemystripbanners_ads
		as
		(
		select 
		am.adid,am.projectid,am.businessid,am.price,asb.rowid,asb.listingsection 
			from dbo.adsmaster am (nolock)
				join #alchemystripbanners asb on am.projectid = asb.adid and am.businessid = asb.businessid
				join dbo.adsneedmapping anm (nolock) on am.adid = anm.adid
		where am.contentid > 0
		and am.projectid > 0
		and am.status = 1
		and exists (select top 1 1 from dbo.projectbusinessmapping pbm (nolock) 
						where am.projectid = pbm.projectid 
						and pbm.businessid = am.businessid
						and pbm.status = 1)
		and anm.adclassification = 6
		and (anm.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		and (anm.areavalue <= @lv_toarea or @lv_toarea = 0) 
		),
		cte_alchemystripbanners_ads_attributes
		as
		(
		select 
		row_number() over (partition by c.projectid order by c.price,c.rowid) dupid,
		c.adid,c.projectid,c.rowid,c.businessid,c.listingsection,
		count(asam.attributevalueid) over (partition by asam.adid) attributevaluecount,  
		count(asam.attributeid) over (partition by asam.adid) attributecount 
		from dbo.adssubcatattributemapping asam (nolock)
			join cte_alchemystripbanners_ads c on asam.adid = c.adid
		where exists (select top 1 1 from @needidattribute na where na.attributeid=asam.attributeid   
              and asam.attributevalueid=na.attributevalueid)  
		and (asam.price <= @lv_toprice or @lv_toprice = 0)
		)
		Insert into #adid(adid,rowid,businessid,projectid,listingsection)
		select c.adid,c.rowid,c.businessid,c.projectid,c.listingsection
		from cte_alchemystripbanners_ads_attributes c  
		where c.dupid=1 and c.attributecount = @attributecount 



set nocount off

end
GO
