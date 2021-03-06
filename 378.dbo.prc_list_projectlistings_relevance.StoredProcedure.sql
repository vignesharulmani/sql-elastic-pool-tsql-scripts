/****** Object:  StoredProcedure [dbo].[prc_list_projectlistings_relevance]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_list_projectlistings_relevance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_list_projectlistings_relevance] AS'
END
GO
Alter procedure [dbo].[prc_list_projectlistings_relevance]
@cityid int,                              
@areaid int=0,                              
@subcatid int, 
@addefid INT=0,                             
@needid int=0,                              
@needidattribute split_needidattribute readonly, 
@Localityfiltertable split_localityfilter readonly,                            
@NearbyLocalityfiltertable split_localityfilter readonly,                            
@sortby varchar(16)='score',                              
@fromprice money=0,
@toprice money =0,
@fromarea int=0,
@toarea int =0,
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
@lv_cityid int = @cityid, 
@lv_areaid int= @areaid,                              
@lv_subcatid int = @subcatid, 
@lv_addefid INT= @addefid,                             
@lv_needid int= @needid,  
@lv_fromprice money = @fromprice,
@lv_toprice money = @toprice,
@lv_fromarea int = @fromarea,
@lv_toarea int = @toarea,
@lv_adclassification int = @adclassification
 
if @lv_areaid > 0
	insert into @tblarea(areaid,isnearby,radius)
		select @lv_areaid,0,0

if exists (select top 1 1 from @Localityfiltertable)
	insert into @tblarea(areaid,isnearby,radius)
		select areaid,0,0 from @Localityfiltertable
     
 
/*City Page with attributes*/
if not exists (select top 1 1 from @tblarea) and exists (select top 1 1 from @needidattribute)
begin

print 'City Page with attributes';


select @attributevaluecount = count(distinct attributevalueid) from @needidattribute
select @attributecount = count(distinct attributeid) from @needidattribute


		;With Ads_need                              
		as                              
		(                              
		select 
			adid,cityid,mode,campaignid,oapc,projectid             
		from (
		select 
			row_number() over (partition by am.projectid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then a.campaignid else 1 end 
								order by 
									case when isnull(a.campaignid,0) > 0 then 1 else 2 end,
								a.mode desc, a.minprice) oapc,
			a.adid,a.cityid,a.mode,a.campaignid,am.projectid
		from dbo.adsNeedMapping(nolock)  a						
			inner join dbo.adsmaster (nolock) am on a.adid = am.adid
			cross apply dbo.fn_get_projectbusinessmapping(am.projectid,am.businessid) pbm
		where a.adid > 0
		and (a.subcategoryid=@lv_subcatid) 
		and (a.adclassification=6)                           
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		and a.status = 1
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)
		and exists (select top 1 1 from dbo.citygroupmaster cgm (nolock) where cgm.cityid = a.cityid and cgm.groupcityid = @lv_cityid and cgm.isactive = 1)
		and pbm.customertypevalueid = 1036002 /*Builder Only*/
		and am.contentid > 0 and am.projectid > 0
		) a where dup=1                              
		) 
		,Ads_need_attribute                              
		as                              
		(                              
		select 
			row_number() over (order by 
					case when isnull(campaignid,0) > 0 then 1 else 2 end,
					oapc,mode desc,dbo.fn_get_runrate(0,cityid,0,campaignid) desc
					) as RowID,adid,projectid
		from (               
		select 
			row_number() over (partition by an.adid order by an.adid) as dup,
			an.adid,an.cityid,an.oapc,an.mode,an.campaignid,an.projectid
			,count(a.attributevalueid) over (partition by an.adid) attributevaluecount
			,count(a.attributeid) over (partition by an.adid) attributecount
		from dbo.adsSubcatAttributemapping(nolock) a 
			join Ads_need an on an.adid = a.adid 
		where a.rowid > 0
		and exists (select top 1 1 from @needidattribute na where na.attributeid=a.attributeid 
														and a.attributevalueid=na.attributevalueid)            
		) a where a.dup=1 
		and (a.attributecount = @attributecount or @lv_fromprice > 0 or @lv_toprice > 0 
						or @lv_fromarea > 0 or @lv_toarea > 0)
		)
		Insert into #adid(adid,rowid)    
		select top(( @RowsToFetch) + @morerecords)  
			projectid,RowID
		from Ads_need_attribute b              
		where RowID > ((@PageNo - 1) * @RowsToFetch) 
		order by RowID
		
end

/*Locality Page with attributes*/
else if exists (select top 1 1 from @tblarea) and exists (select top 1 1 from @needidattribute)
begin

select @attributevaluecount = count(distinct attributevalueid) from @needidattribute
select @attributecount = count(distinct attributeid) from @needidattribute
		
		;With Ads_need                              
		as                              
		(                              
		select --top(( @RowsToFetch * @pageno )+ @morerecords)
			adid,cityid,mode,campaignid,oapc,projectid             
		from (
		select 
			row_number() over (partition by am.projectid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then a.campaignid else 1 end 
								order by 
									case when isnull(a.campaignid,0) > 0 then 1 else 2 end,
								a.mode desc, a.minprice) oapc,
			a.adid,a.cityid,a.mode,a.campaignid,am.projectid
		from dbo.adsNeedMapping(nolock)  a                     
			inner join dbo.adsmaster (nolock) am on a.adid = am.adid
			inner join @tblarea ta on a.areaid = ta.areaid
			cross apply dbo.fn_get_projectbusinessmapping(am.projectid,am.businessid) pbm
		where a.adid > 0
		and (a.subcategoryid=@lv_subcatid) 
		and (a.adclassification=6)                           
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		and a.status = 1
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)
		and pbm.customertypevalueid = 1036002 /*Builder Only*/
		) a where dup=1                              
		) 
		,Ads_need_attribute                              
		as                              
		(                              
		select --top(( @RowsToFetch * @pageno )+ @morerecords)
			row_number() over (order by 
					case when dbo.fn_get_topslot(adid) > 0 then dbo.fn_get_topslot(adid) else 6 end,
					case when isnull(campaignid,0) > 0 then 1 else 2 end,
					oapc,mode desc,dbo.fn_get_runrate(0,cityid,0,campaignid) desc
					) as RowID,adid,projectid
		from (                              
		select 
			row_number() over (partition by an.adid order by an.adid) as dup,
			an.adid,an.cityid,an.oapc,an.mode,an.campaignid,an.projectid
			,count(a.attributevalueid) over (partition by an.adid) attributevaluecount
			,count(a.attributeid) over (partition by an.adid) attributecount
		from dbo.adsSubcatAttributemapping(nolock) a 
			join Ads_need an on an.adid = a.adid                             
		where a.rowid > 0
		and exists (select top 1 1 from @needidattribute na where na.attributeid=a.attributeid 
														and a.attributevalueid=na.attributevalueid)                                                            
		) a where a.dup=1 
		and (a.attributecount = @attributecount or @lv_fromprice > 0 or @lv_toprice > 0 
						or @lv_fromarea > 0 or @lv_toarea > 0)
		)
		Insert into #adid(adid,rowid)    
		select top(( @RowsToFetch) + @morerecords)  
			projectid,RowID
		from Ads_need_attribute b              
		where RowID > ((@PageNo - 1) * @RowsToFetch) 
		order by RowID

end

/*City Page without attributes*/
else if not exists (select top 1 1 from @tblarea) and not exists (select top 1 1 from @needidattribute)
begin
		;With Ads_need                              
		as                              
		(     
		select --top(( @RowsToFetch * @pageno )+ @morerecords)
			row_number() over (order by 
								case when isnull(campaignid,0) > 0 then 1 else 2 end,oapc,
								mode desc,dbo.fn_get_runrate(0,cityid,0,campaignid) desc) as RowID,
			adid,projectid
		from (
		select 
			row_number() over (partition by am.projectid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then a.campaignid else 1 end 
								order by a.minprice) oapc,
			a.adid,a.cityid,a.mode,a.campaignid,am.projectid
		from dbo.adsNeedMapping(nolock)  a						
			inner join dbo.adsmaster (nolock) am on a.adid = am.adid
			cross apply dbo.fn_get_projectbusinessmapping(am.projectid,am.businessid) pbm             
		where a.adid > 0
		and (a.subcategoryid=@lv_subcatid)                
		and (a.adclassification=6)                           
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		and a.status = 1
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)
		and pbm.customertypevalueid = 1036002 /*Builder Only*/
		and exists (select top 1 1 from dbo.citygroupmaster cgm (nolock) where cgm.cityid = a.cityid and cgm.groupcityid = @lv_cityid and cgm.isactive = 1)
		) a where dup=1                              
		)                         
                         
		Insert into #adid(adid,rowid)                                     
		select top(( @RowsToFetch)+ @morerecords)  
			projectid,RowID
		from Ads_need b               
		where RowID > ((@PageNo - 1) * @RowsToFetch)    
		order by RowID
end

/*Locality Page without attributes*/
else if exists (select top 1 1 from @tblarea) and not exists (select top 1 1 from @needidattribute)
begin
		;With Ads_Need     
		as      
		(                              
		select --top(( @RowsToFetch * @pageno )+ @morerecords)
			row_number() over (order by 
								case when dbo.fn_get_topslot(adid) > 0 then dbo.fn_get_topslot(adid) else 6 end,
								case when isnull(campaignid,0) > 0 then 1 else 2 end,oapc,
								isnearby,mode desc,dbo.fn_get_runrate(0,cityid,0,campaignid) desc) as RowID,
			adid,isnearby,projectid  
		from (
		select 
			row_number() over (partition by am.projectid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then a.campaignid else 1 end 
								order by a.minprice) oapc,
			a.adid,a.cityid,a.mode,a.campaignid,ta.isnearby,am.projectid
		from dbo.adsNeedMapping(nolock)  a                     
			inner join dbo.adsmaster (nolock) am on a.adid = am.adid
			inner join @tblarea ta on a.areaid = ta.areaid
			cross apply dbo.fn_get_projectbusinessmapping(am.projectid,am.businessid) pbm
		where a.adid > 0
		and (a.subcategoryid=@lv_subcatid) 
		and (a.adclassification=6)                           
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		and a.status = 1
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)
		and pbm.customertypevalueid = 1036002 /*Builder Only*/
		) a where dup=1                              
		)                              
		Insert into #adid(adid,rowid,isnearby)                              
		select top(( @RowsToFetch)+ @morerecords)  
			b.projectid,RowID,b.isnearby
		from Ads_Need b              
		where RowID > ((@PageNo - 1) * @RowsToFetch)  
		order by RowID
end


set nocount off

end
GO
