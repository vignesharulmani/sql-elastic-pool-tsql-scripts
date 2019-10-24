CREATE procedure [dbo].[prc_list_adslistings_relevance_alchemy]
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
@fromarea int = 0,
@toarea int = 0,
@RowsToFetch int=10,                              
@PageNo int=1 ,                              
@excludeadidtable split_adsid  readonly,
@excludecampaignidtable split_adsid  readonly,
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
@lv_fromarea int= @fromarea,
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


if @lv_fromprice = 0 and @lv_toprice = 0 and @lv_fromarea= 0 and @lv_toarea = 0
begin
		;With Ads_need                              
		as                              
		(                              
		select top(10000)
			adid,mode,campaignid,oapc,attributevaluecount,attributecount,cityid             
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then a.campaignid else 1 end 
								order by 
									case when isnull(a.campaignid,0) > 0 then 1 else 2 end,
								a.mode desc,a.minprice) oapc,
			a.adid,a.mode,a.campaignid,a.cityid,
			count(asam.attributevalueid) over (partition by asam.adid) attributevaluecount,
			count(asam.attributeid) over (partition by asam.adid) attributecount
		from dbo.adsNeedMapping(nolock)  a
			join dbo.adssubcatattributemapping (nolock) asam on a.adid = asam.adid                     
			join dbo.citygroupmaster cgm (nolock) on cgm.cityid = a.cityid
		where a.campaignid > 0 and a.mode > 0 and a.minprice > 0
		and a.adid > 0
		and cgm.groupcityid = @lv_cityid and cgm.isactive = 1
		and (a.subcategoryid=@lv_subcatid) 
		and (a.adclassification=@lv_adclassification or @lv_adclassification = 0)                           
		and a.status = 1
		and not exists (select top 1 1 from @excludecampaignidtable ect where a.campaignid=ect.adid)
		and exists (select top 1 1 from @needidattribute na where na.attributeid=asam.attributeid 
														and asam.attributevalueid=na.attributevalueid)
		--and exists (select top 1 1 from dbo.citygroupmaster cgm (nolock) where cgm.cityid = a.cityid and cgm.groupcityid = @lv_cityid and cgm.isactive = 1)
		) a where dup=1   
		--order by 
		--case when isnull(a.campaignid,0) > 0 then 1 else 2 end                      
		) 
		,Ads_need_attribute                              
		as                              
		(                              
		select 
			row_number() over (order by 
					case when isnull(campaignid,0) > 0 then 1 else 2 end,
					oapc,mode desc,dbo.fn_get_runrate(0,cityid,0,campaignid) desc
					) as RowID,adid
		from (                              
		select 
			row_number() over (partition by an.adid order by an.adid) as dup,
			an.adid,an.oapc,an.mode,an.campaignid,an.attributevaluecount,an.attributecount,an.cityid
		from Ads_need an 
		) a where a.dup=1 and a.attributecount = @attributecount
		)
		Insert into #adid(adid,rowid,listingsection)    
		select top(( @RowsToFetch) + @morerecords)  
			b.adid,RowID,3
		from Ads_need_attribute b              
		where RowID > ((@PageNo - 1) * @RowsToFetch) 
		order by RowID



end
else
begin
		;With Ads_need                              
		as                              
		(                              
		select top(10000)
			adid,mode,campaignid,oapc,attributevaluecount,attributecount,cityid             
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then a.campaignid else 1 end 
								order by 
									case when isnull(a.campaignid,0) > 0 then 1 else 2 end,
								a.mode desc,a.minprice) oapc,
			a.adid,a.mode,a.campaignid,a.cityid,
			count(asam.attributevalueid) over (partition by asam.adid) attributevaluecount,
			count(asam.attributeid) over (partition by asam.adid) attributecount
		from dbo.adsNeedMapping(nolock)  a
			join dbo.adssubcatattributemapping (nolock) asam on a.adid = asam.adid                     
			join dbo.citygroupmaster cgm (nolock) on cgm.cityid = a.cityid
		where a.campaignid > 0 and a.mode > 0 and a.minprice > 0
		and a.adid > 0
		and cgm.groupcityid = @lv_cityid and cgm.isactive = 1
		and (a.subcategoryid=@lv_subcatid) 
		and (a.adclassification=@lv_adclassification or @lv_adclassification = 0)                           
		and a.status = 1
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		and not exists (select top 1 1 from @excludecampaignidtable ect where a.campaignid=ect.adid)
		and exists (select top 1 1 from @needidattribute na where na.attributeid=asam.attributeid 
														and asam.attributevalueid=na.attributevalueid)
		--and exists (select top 1 1 from dbo.citygroupmaster cgm (nolock) where cgm.cityid = a.cityid and cgm.groupcityid = @lv_cityid and cgm.isactive = 1)
		) a where dup=1   
		--order by case when isnull(a.campaignid,0) > 0 then 1 else 2 end
		) 
		,Ads_need_attribute                              
		as                              
		(                              
		select 
			row_number() over (order by 
					case when isnull(campaignid,0) > 0 then 1 else 2 end,
					oapc,mode desc,dbo.fn_get_runrate(0,cityid,0,campaignid) desc
					) as RowID,adid
		from (                              
		select 
			row_number() over (partition by an.adid order by an.adid) as dup,
			an.adid,an.oapc,an.mode,an.campaignid,an.attributevaluecount,an.attributecount,an.cityid
		from Ads_need an 
		) a where a.dup=1 and a.attributecount = @attributecount
		)
		Insert into #adid(adid,rowid,listingsection)    
		select top(( @RowsToFetch) + @morerecords)  
			b.adid,RowID,3
		from Ads_need_attribute b              
		where RowID > ((@PageNo - 1) * @RowsToFetch) 
		order by RowID
end
		
end

/*Locality Page with attributes*/
else if exists (select top 1 1 from @tblarea) and exists (select top 1 1 from @needidattribute)
begin
print 'here only 123...'
select @attributevaluecount = count(distinct attributevalueid) from @needidattribute
select @attributecount = count(distinct attributeid) from @needidattribute


;With Ads_need                              
		as               
		(                              
		select 
			adid,mode,campaignid,oapc,attributevaluecount,attributecount,cityid             
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then a.campaignid else 1 end 
								order by 
									case when isnull(a.campaignid,0) > 0 then 1 else 2 end,
								a.mode desc,a.minprice) oapc,
			a.adid,a.mode,a.campaignid,a.cityid,
			count(asam.attributevalueid) over (partition by asam.adid) attributevaluecount,
			count(asam.attributeid) over (partition by asam.adid) attributecount
		from dbo.adsNeedMapping(nolock)  a
			join dbo.adssubcatattributemapping (nolock) asam on a.adid = asam.adid                     
			inner join @tblarea ta on a.areaid = ta.areaid
		where a.campaignid > 0 and a.mode > 0 and a.minprice > 0
		and a.adid > 0
		and (a.subcategoryid=@lv_subcatid) 
		and (a.adclassification=@lv_adclassification or @lv_adclassification = 0)                           
		and a.status = 1
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		and not exists (select top 1 1 from @excludecampaignidtable ect where a.campaignid=ect.adid)
		and exists (select top 1 1 from @needidattribute na where na.attributeid=asam.attributeid 
														and asam.attributevalueid=na.attributevalueid)            
		) a where dup=1   
		) 
		,Ads_need_attribute                              
		as                              
		(                              
		select 
			row_number() over (order by 
					--case when dbo.fn_get_topslot(adid) > 0 then dbo.fn_get_topslot(adid) else 6 end,
					case when isnull(campaignid,0) > 0 then 1 else 2 end,
					oapc,mode desc,dbo.fn_get_runrate(0,cityid,0,campaignid) desc
					) as RowID,adid
		from (                              
		select 
			row_number() over (partition by an.adid order by an.adid) as dup,
			an.adid,an.oapc,an.mode,an.campaignid,an.attributevaluecount,an.attributecount,an.cityid
		from Ads_need an 
		) a where a.dup=1 and a.attributecount = @attributecount
		)
		Insert into #adid(adid,rowid,listingsection)    
		select top(( @RowsToFetch) + @morerecords)  
			b.adid,RowID,3
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
								case when isnull(campaignid,0) > 0 then 1 else 2 end,oapc,mode desc,
								dbo.fn_get_runrate(0,cityid,0,campaignid) desc) as RowID,
			adid
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then campaignid else 1 end 
								order by a.mode desc,a.minprice) oapc,
			a.adid,a.cityid,a.mode,a.campaignid
		from dbo.adsNeedMapping(nolock)  a                
			join dbo.citygroupmaster cgm (nolock) on cgm.cityid = a.cityid
		where a.campaignid > 0 and a.mode > 0 and a.minprice > 0
		and a.adid > 0
		and cgm.groupcityid = @lv_cityid and cgm.isactive = 1
		and (a.subcategoryid=@lv_subcatid)                
		and (a.adclassification=@lv_adclassification or @lv_adclassification = 0)         
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		and a.status = 1
		and not exists (select top 1 1 from @excludecampaignidtable ect where a.campaignid=ect.adid)
		--and exists (select top 1 1 from dbo.citygroupmaster cgm (nolock) where cgm.cityid = a.cityid and cgm.groupcityid = @lv_cityid and cgm.isactive = 1)
		) a where dup=1          
		)                         
                         
		Insert into #adid(adid,rowid,listingsection)                                     
		select top(( @RowsToFetch)+ @morerecords)  
			b.adid,RowID,3
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
								--case when dbo.fn_get_topslot(adid) > 0 then dbo.fn_get_topslot(adid) else 6 end,
								case when isnull(campaignid,0) > 0 then 1 else 2 end,
								isnearby,mode desc,oapc,dbo.fn_get_runrate(0,cityid,0,campaignid) desc) as RowID,
			adid,isnearby  
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then campaignid else 1 end 
								order by a.mode desc,a.minprice) oapc,
			a.adid,a.cityid,a.mode,a.campaignid,ta.isnearby
		from dbo.adsNeedMapping(nolock) a               
			inner join @tblarea ta on a.areaid = ta.areaid
		where a.campaignid > 0 and a.mode > 0 and a.minprice > 0
		and a.adid > 0
		and (a.subcategoryid=@lv_subcatid) 
		and (a.adclassification=@lv_adclassification or @lv_adclassification = 0)                           
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		and a.status = 1
		and not exists (select top 1 1 from @excludecampaignidtable ect where a.campaignid=ect.adid)
		) a where dup=1                              
		)                              
		Insert into #adid(adid,rowid,isnearby,listingsection)                              
		select top(( @RowsToFetch)+ @morerecords)  
			b.adid,RowID,b.isnearby,3
		from Ads_Need b              
		where RowID > ((@PageNo - 1) * @RowsToFetch)  
		order by RowID
end

if (select count(1) from #adid) < 10 and exists (select top 1 1 from @tblarea) 
begin


	exec dbo.prc_list_adslistings_relevance_nearby_alchemy @cityid=@cityid,@areaid=@areaid,@subcatid=@subcatid
	,@addefid=@addefid,@needid=@needid,@needidattribute=@needidattribute,@Localityfiltertable=@Localityfiltertable
	,@NearbyLocalityfiltertable=@NearbyLocalityfiltertable,@sortby=@sortby,@fromprice=@fromprice
	,@toprice=@toprice,@fromarea=@fromarea,@toarea=@toarea,@RowsToFetch=@RowsToFetch,@PageNo=@PageNo
	,@excludeadidtable=@excludeadidtable,@excludecampaignidtable=@excludecampaignidtable	
	,@IncludeSurroundingAreas=@IncludeSurroundingAreas,@radius=@radius
	,@nearbyareacount=@nearbyareacount,@excludearea=@excludearea,@adclassification=@adclassification
end

set nocount off

end