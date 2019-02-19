Alter procedure [dbo].[prc_list_ads_sortby_nocity]
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
@RowsToFetch int=10,                              
@PageNo int=1 ,                              
@excludeadidtable split_adsid  readonly,
@IncludeSurroundingAreas BIT = 1,
@radius INT = 3,
@nearbyareacount tinyint =5,
@excludearea varchar(256)=''                    
as                     
begin                    
                    
set nocount on
                                    
declare @tblarea table (rowid int identity,areaid int primary key with(ignore_dup_key = on)
							,isnearby int,radius real)

declare @attributevaluecount int = 1
declare @attributecount int = 1
declare @morerecords int = 1
 
if @areaid > 0
	insert into @tblarea(areaid,isnearby,radius)
		select @areaid,0,0

if exists (select top 1 1 from @Localityfiltertable)
	insert into @tblarea(areaid,isnearby,radius)
		select areaid,0,0 from @Localityfiltertable

/*
if @includesurroundingareas = 1
insert into @tblarea(areaid,isnearby,radius)	      
	select top 10 
		f.areaid,1,f.radius                                                                                   
	from @tblarea tl                                                                                
	cross apply dbo.fn_get_nearby_latlong(tl.areaid,@cityid,@radius,@nearbyareacount) f                                                                    
	left join string_split(@excludearea,',')c on dbo.fn_get_titleurl(f.area,'-')=c.value                                                                                  
	where c.value is null                                                      
	order by radius  
*/	     
 
/*City Page with attributes*/
if not exists (select top 1 1 from @tblarea) and exists (select top 1 1 from @needidattribute)
begin

select @attributevaluecount = count(distinct attributevalueid) from @needidattribute
select @attributecount = count(distinct attributeid) from @needidattribute

		;With Ads_need_attribute                              
		as                              
		(                              
		select top(( @RowsToFetch * @pageno )+ @morerecords)
			row_number() over (order by oapc,mode desc,netsalevalue desc) as RowID,
			adid,cityid,mode,score,netsalevalue              
		from (                              
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then campaignid else 999999999 end 
								order by adid desc) oapc,
			a.adid,a.cityid,a.mode,0 score,a.campaignid
			,count(a.attributevalueid) over (partition by a.adid) attributevaluecount
			,count(a.attributeid) over (partition by a.adid) attributecount
			,a.netsalevalue
		from dbo.adsSubcatAttributemapping(nolock) a                              
		where a.rowid > 0
		and cityid > 0 and a.subcategoryid = @subcatid
		and exists (select top 1 1 from @needidattribute na where na.attributeid=a.attributeid 
														and a.attributevalueid=na.attributevalueid)
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)                                                            
		and (a.price >= @fromprice or @fromprice = 0)
		and (a.price <= @toprice or @toprice = 0)
		and a.status = 1
		) a where dup=1 
		and attributecount = @attributecount
		)                        
                          
		Insert into #adid(adid,rowid,score,mode,netsalevalue)                              
		select top(( @RowsToFetch * @pageno) + @morerecords)  
			b.adid,RowID,b.score,b.mode,b.netsalevalue 
		from Ads_need_attribute b              
		where RowID > ((@PageNo - 1) * @RowsToFetch) 
		order by RowID

end

/*Locality Page with attributes*/
else if exists (select top 1 1 from @tblarea) and exists (select top 1 1 from @needidattribute)
begin

select @attributevaluecount = count(distinct attributevalueid) from @needidattribute
select @attributecount = count(distinct attributeid) from @needidattribute
		
		;With Ads_need_attribute                              
		as     
		(               
		select top(( @RowsToFetch * @pageno )+ @morerecords)
			row_number() over (order by 
									/*
									case 
										when dbo.fn_get_topslot_ad(adid,subcategoryid,cityid,areaid) > 0 
										then dbo.fn_get_topslot_ad(adid,subcategoryid,cityid,areaid)
										else dbo.fn_generate_randomnumber(5,100) end,
										*/
										isnearby,oapc,mode desc,netsalevalue desc) as RowID,
			adid,cityid,areaid,subcategoryid,mode,score,isnearby,netsalevalue              
		from ( 
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then campaignid else 999999999 end 
								order by adid desc) oapc,
			a.adid,a.cityid,a.areaid,a.subcategoryid,a.mode,0 score,ta.isnearby  
			,count(a.attributevalueid) over (partition by a.adid) attributevaluecount
			,count(a.attributeid) over (partition by a.adid) attributecount
			,a.campaignid,a.netsalevalue
		from dbo.adsSubcatAttributemapping(nolock) a                              
		inner join @tblarea ta on a.areaid = ta.areaid
		where a.rowid > 0
		and cityid > 0 and a.subcategoryid = @subcatid
		and exists (select top 1 1 from @needidattribute na where na.attributeid=a.attributeid 
												and a.attributevalueid=na.attributevalueid)
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)                              
		and (a.price >= @fromprice or @fromprice = 0)
		and (a.price <= @toprice or @toprice = 0)
		and a.status = 1
		) a where dup=1 
		and attributecount = @attributecount
		)                        
                          
		Insert into #adid(adid,rowid,score,mode,isnearby,netsalevalue)                              
		select top(( @RowsToFetch * @pageno)+ @morerecords)  
			b.adid,RowID,b.score,b.mode,isnearby,b.netsalevalue 
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
			row_number() over (order by  oapc,mode desc,netsalevalue desc) as RowID,
			adid,cityid,mode,score,netsalevalue             
		from (
		select 
			1 as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then campaignid else 999999999 end 
								order by adid desc) oapc,
			a.adid,a.cityid,a.mode,0 score ,a.campaignid,a.netsalevalue
		from dbo.adsNeedMapping(nolock)  a                     
		where a.adid > 0
		and (cityid > 0)  and (subcategoryid=@subcatid) 
		and (a.addefid=@addefid or @addefid = 0)
		and (a.needid=@needid or @needid = 0)               
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)                           
		and (a.minprice >= @fromprice or @fromprice = 0)
		and (a.minprice <= @toprice or @toprice = 0)
		and a.status = 1
		) a where dup=1                              
		)                         
                         
		Insert into #adid(adid,rowid,score,mode,netsalevalue)                                     
		select top(( @RowsToFetch * @pageno)+ @morerecords) 
			b.adid,RowID,b.score,b.mode,b.netsalevalue
		from Ads_need b               
		where RowID > ((@PageNo - 1) * @RowsToFetch)    
		order by RowID
end

/*Locality Page without attributes*/
else if exists (select top 1 1 from @tblarea) and not exists (select top 1 1 from @needidattribute)
begin
		;With Ads     
		as      
		(                              
		select top(( @RowsToFetch * @pageno )+ @morerecords)
			row_number() over (order by 
									/*
									case 
										when dbo.fn_get_topslot_ad(adid,subcategoryid,cityid,areaid) > 0 
										then dbo.fn_get_topslot_ad(adid,subcategoryid,cityid,areaid)
										else dbo.fn_generate_randomnumber(5,100) end,
										*/
										isnearby,oapc, mode desc,netsalevalue desc) as RowID,
			adid,cityid,areaid,subcategoryid,mode,score,isnearby,netsalevalue                           
		from (
		select 
			1 as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then campaignid else 999999999 end 
								order by adid desc) oapc,
			a.adid,a.cityid,a.areaid,a.subcategoryid,a.mode,0 score,ta.isnearby	,a.campaignid,
			a.netsalevalue
		from dbo.adsNeedMapping(nolock) a               
			inner join @tblarea ta on a.areaid = ta.areaid
		where a.adid > 0
		and (cityid > 0) and (subcategoryid=@subcatid) 
		and (a.addefid=@addefid or @addefid = 0)
		and (a.needid=@needid or @needid = 0)            
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)                              
		and (a.minprice >= @fromprice or @fromprice = 0)
		and (a.minprice <= @toprice or @toprice = 0)
		and a.status = 1
		) a where dup=1                              
		)                              
		Insert into #adid(adid,rowid,score,mode,isnearby,netsalevalue)                              
		select top(( @RowsToFetch * @pageno)+ @morerecords)  
			b.adid,RowID,b.score,b.mode ,b.isnearby,b.netsalevalue
		from Ads b              
		where RowID > ((@PageNo - 1) * @RowsToFetch)  
		order by RowID
end

set nocount off

end
