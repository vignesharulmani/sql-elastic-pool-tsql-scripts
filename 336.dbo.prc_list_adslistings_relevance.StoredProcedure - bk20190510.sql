/****** Object:  StoredProcedure [dbo].[prc_list_adslistings_relevance]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_list_adslistings_relevance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_list_adslistings_relevance] AS'
END
GO
ALTER procedure [dbo].[prc_list_adslistings_relevance]
@cityid int,                              
@areaid int=0,                              
@subcatid int, 
@addefid INT=0,                             
@needid int=0,                              
@needidattribute split_needidattribute readonly, 
@Localityfiltertable   split_localityfilter readonly,                            
@NearbyLocalityfiltertable   split_localityfilter readonly,                            
@sortby varchar(16)='score',                              
@fromprice money=0,
@toprice money =0,
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
@lv_fromprice money= @fromprice,
@lv_toprice money = @toprice,
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
			adid,cityid,mode,netsalevalue,campaignid,crdate,price,oapc             
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then a.campaignid else 1 end 
								order by 
									case when isnull(a.campaignid,0) > 0 then 1 else 2 end,
								a.mode desc, a.minprice) oapc,
			a.adid,a.cityid,a.mode,a.campaignid,a.netsalevalue,a.crdate,a.minprice price
		from dbo.adsNeedMapping(nolock)  a                     
		where a.adid > 0
		and (a.cityid=@lv_cityid) and (a.subcategoryid=@lv_subcatid) 
		and (a.adclassification=@lv_adclassification or @lv_adclassification = 0)                           
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and a.status = 1
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)
		) a where dup=1                              
		) 
		,Ads_need_attribute                              
		as                              
		(                              
		select 
			RowID,adid,cityid,mode,netsalevalue              
		from (                              
		select 
			row_number() over (partition by an.adid order by an.adid) as dup,
			row_number() over (order by 
					case when isnull(an.campaignid,0) > 0 then 1 else 2 end,
					oapc,an.mode desc,dbo.fn_get_runrate(0,an.cityid,0,an.campaignid) desc
					) as RowID,
			an.adid,an.cityid,an.mode,an.campaignid
			,count(a.attributevalueid) over (partition by an.adid) attributevaluecount
			,count(a.attributeid) over (partition by an.adid) attributecount
			,an.netsalevalue
		from dbo.adsSubcatAttributemapping(nolock) a 
			join Ads_need an on an.adid = a.adid                             
		where a.rowid > 0
		and exists (select top 1 1 from @needidattribute na where na.attributeid=a.attributeid 
														and a.attributevalueid=na.attributevalueid)            
		) a where a.dup=1 and a.attributecount = @attributecount
		)
		Insert into #adid(adid,rowid,score,mode,netsalevalue)    
		select top(( @RowsToFetch) + @morerecords)  
			b.adid,RowID,0 score,b.mode,b.netsalevalue 
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
			adid,cityid,mode,netsalevalue,campaignid,crdate,price,oapc             
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then a.campaignid else 1 end 
								order by 
									case when isnull(a.campaignid,0) > 0 then 1 else 2 end,
								a.mode desc, a.minprice) oapc,
			a.adid,a.cityid,a.mode,a.campaignid,a.netsalevalue,a.crdate,a.minprice price
		from dbo.adsNeedMapping(nolock)  a                     
			inner join @tblarea ta on a.areaid = ta.areaid
		where a.adid > 0
		and (a.cityid=@lv_cityid) and (a.subcategoryid=@lv_subcatid) 
		and (a.adclassification=@lv_adclassification or @lv_adclassification = 0)                           
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and a.status = 1
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)
		) a where dup=1                              
		) 
		,Ads_need_attribute                              
		as                              
		(                              
		select --top(( @RowsToFetch * @pageno )+ @morerecords)
			RowID,adid,cityid,mode,netsalevalue              
		from (                              
		select 
			row_number() over (partition by an.adid order by an.adid) as dup,
			row_number() over (order by 
					case when dbo.fn_get_topslot(an.adid) > 0 then dbo.fn_get_topslot(an.adid) else 6 end,
					case when isnull(an.campaignid,0) > 0 then 1 else 2 end,
					oapc,an.mode desc,dbo.fn_get_runrate(0,an.cityid,0,an.campaignid) desc
					) as RowID,
			an.adid,an.cityid,an.mode,an.campaignid
			,count(a.attributevalueid) over (partition by an.adid) attributevaluecount
			,count(a.attributeid) over (partition by an.adid) attributecount
			,an.netsalevalue
		from dbo.adsSubcatAttributemapping(nolock) a 
			join Ads_need an on an.adid = a.adid                             
		where a.rowid > 0
		and exists (select top 1 1 from @needidattribute na where na.attributeid=a.attributeid 
														and a.attributevalueid=na.attributevalueid)                                                            
		) a where a.dup=1 and a.attributecount = @attributecount
		)
		Insert into #adid(adid,rowid,score,mode,netsalevalue)    
		select top(( @RowsToFetch) + @morerecords)  
			b.adid,RowID,0 score,b.mode,b.netsalevalue 
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
		select top(( @RowsToFetch * @pageno )+ @morerecords)
			row_number() over (order by 
								case when isnull(campaignid,0) > 0 then 1 else 2 end,oapc,
								mode desc,dbo.fn_get_runrate(0,cityid,0,campaignid) desc) as RowID,
			adid,cityid,mode,netsalevalue,crdate,price             
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then campaignid else 1 end 
								order by a.minprice) oapc,
			a.adid,a.cityid,a.mode,a.campaignid,a.netsalevalue,a.crdate,a.minprice price
		from dbo.adsNeedMapping(nolock)  a                
		where a.adid > 0
		and (a.cityid=@lv_cityid) and (a.subcategoryid=@lv_subcatid)                
		and (a.adclassification=@lv_adclassification or @lv_adclassification = 0)                           
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and a.status = 1
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)
		) a where dup=1                              
		)                         
                         
		Insert into #adid(adid,rowid,score,mode,netsalevalue)                                     
		select top(( @RowsToFetch)+ @morerecords)  
			b.adid,RowID,0 score,b.mode,b.netsalevalue
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
		select top(( @RowsToFetch * @pageno )+ @morerecords)
			row_number() over (order by 
								case when dbo.fn_get_topslot(adid) > 0 then dbo.fn_get_topslot(adid) else 6 end,
								case when isnull(campaignid,0) > 0 then 1 else 2 end,oapc,
								isnearby,mode desc,dbo.fn_get_runrate(0,cityid,0,campaignid) desc) as RowID,
			adid,cityid,mode,netsalevalue,crdate,price,isnearby  
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then campaignid else 1 end 
								order by a.minprice) oapc,
			a.adid,a.cityid,a.mode,a.campaignid,a.netsalevalue,a.crdate,a.minprice price,ta.isnearby
		from dbo.adsNeedMapping(nolock) a               
			inner join @tblarea ta on a.areaid = ta.areaid
		where a.adid > 0
		and (a.cityid=@lv_cityid) and (a.subcategoryid=@lv_subcatid) 
		and (a.adclassification=@lv_adclassification or @lv_adclassification = 0)                           
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and a.status = 1
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)
		) a where dup=1                              
		)                              
		Insert into #adid(adid,rowid,score,mode,isnearby,netsalevalue)                              
		select top(( @RowsToFetch)+ @morerecords)  
			b.adid,RowID,0 score,b.mode ,b.isnearby,b.netsalevalue
		from Ads_Need b              
		where RowID > ((@PageNo - 1) * @RowsToFetch)  
		order by RowID
end

if (select count(1) from #adid) < 10 and exists (select top 1 1 from @tblarea)
begin
	exec dbo.prc_list_adslistings_relevance_nearby @cityid=@cityid,@areaid=@areaid,@subcatid=@subcatid
	,@addefid=@addefid,@needid=@needid,@needidattribute=@needidattribute,@Localityfiltertable=@Localityfiltertable
	,@NearbyLocalityfiltertable=@NearbyLocalityfiltertable,@sortby=@sortby,@fromprice=@fromprice
	,@toprice=@toprice,@RowsToFetch=@RowsToFetch,@PageNo=@PageNo,@excludeadidtable=@excludeadidtable
	,@IncludeSurroundingAreas=@IncludeSurroundingAreas,@radius=@radius,@nearbyareacount=@nearbyareacount
	,@excludearea=@excludearea,@adclassification=@adclassification
end

set nocount off

end
GO