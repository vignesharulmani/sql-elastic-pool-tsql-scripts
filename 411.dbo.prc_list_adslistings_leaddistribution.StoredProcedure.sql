/****** Object:  StoredProcedure [dbo].[prc_list_adslistings_leaddistribution]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_list_adslistings_leaddistribution]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_list_adslistings_leaddistribution] AS'
END
GO
Alter procedure [dbo].[prc_list_adslistings_leaddistribution]
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

declare @tblads table (adid bigint primary key with(ignore_dup_key = on),cityid int,mode int,
						campaignid int,attributecount int,attributevaluecount int);

declare @tblads_leaddistribution table (adid bigint primary key with(ignore_dup_key = on),cityid int,areaid int);
                                    
declare @tblarea table (rowid int identity,cityid int,areaid int primary key with(ignore_dup_key = on)
							,isnearby int,radius real);

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
	insert into @tblarea(cityid,areaid,isnearby,radius)
		select @lv_cityid,@lv_areaid,0,0

if exists (select top 1 1 from @Localityfiltertable)
	insert into @tblarea(cityid,areaid,isnearby,radius)
		select @lv_cityid,areaid,0,0 from @Localityfiltertable
     
 
/*Locality Page with attributes*/
if exists (select top 1 1 from @tblarea) and exists (select top 1 1 from @needidattribute)
begin
print 'here only 123...'
select @attributevaluecount = count(distinct attributevalueid) from @needidattribute
select @attributecount = count(distinct attributeid) from @needidattribute



insert into @tblads_leaddistribution(adid,cityid,areaid)
	select ld.adid,ld.cityid,ld.areaid from @tblarea ta 
			cross apply dbo.fn_get_ads_leaddistribution_v2(@lv_cityid,ta.areaid) ld


/*Broker Lead Management*/
insert into @tblads(adid,mode,campaignid,attributevaluecount,attributecount,cityid)
	select adid,mode,campaignid,attributevaluecount,attributecount,cityid
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			a.adid,a.mode,a.campaignid,a.cityid,
			count(asam.attributevalueid) over (partition by asam.adid) attributevaluecount,
			count(asam.attributeid) over (partition by asam.adid) attributecount
		from dbo.adsNeedMapping(nolock)  a
			join dbo.adssubcatattributemapping (nolock) asam on a.adid = asam.adid 
			inner join @tblarea ta on a.areaid = ta.areaid
		where a.campaignid > 0 and a.mode = 20 and a.minprice > 0
		and a.adid > 0
		and (a.subcategoryid=@lv_subcatid)
		and (a.needid=@lv_needid or @lv_needid = 0) 
		and (a.adclassification=@lv_adclassification or @lv_adclassification = 0)                           
		and a.status = 1
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		and not exists (select top 1 1 from @excludecampaignidtable ect where a.campaignid=ect.adid)
		and exists (select top 1 1 from @needidattribute na 
						where na.attributeid=asam.attributeid 
							and asam.attributevalueid=na.attributevalueid)
		) a where dup=1 and attributecount =  @attributecount 


/*Ads Lead Distribution*/
insert into @tblads(adid,mode,campaignid,attributevaluecount,attributecount,cityid)
	select adid,mode,campaignid,attributevaluecount,attributecount,cityid
		from (
		select 
			row_number() over (partition by a.adid order by a.adid) as dup,
			a.adid,a.mode,a.campaignid,a.cityid,
			count(asam.attributevalueid) over (partition by asam.adid) attributevaluecount,
			count(asam.attributeid) over (partition by asam.adid) attributecount
		from dbo.adsNeedMapping(nolock)  a
			join dbo.adssubcatattributemapping (nolock) asam on a.adid = asam.adid 
			inner join @tblads_leaddistribution ld on a.adid = ld.adid
			inner join @tblarea ta on ld.cityid = ta.cityid and (ld.areaid = ta.areaid or ld.areaid = 0)
		where a.campaignid > 0 and a.mode > 0 and a.minprice > 0
		and a.adid > 0
		and (a.subcategoryid=@lv_subcatid)
		and (a.needid=@lv_needid or @lv_needid = 0) 
		and (a.adclassification=@lv_adclassification or @lv_adclassification = 0)                           
		and a.status = 1
		and (a.minprice >= @lv_fromprice or @lv_fromprice = 0)
		and (a.minprice <= @lv_toprice or @lv_toprice = 0)
		and (a.areavalue >= @lv_fromarea or @lv_fromarea = 0)
		and (a.areavalue <= @lv_toarea or @lv_toarea = 0)
		and not exists (select top 1 1 from @excludecampaignidtable ect where a.campaignid=ect.adid)
		and exists (select top 1 1 from @needidattribute na 
						where na.attributeid=asam.attributeid and asam.attributevalueid=na.attributevalueid)
		) a where dup=1 and attributecount =  @attributecount 



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
								a.mode desc,dbo.fn_get_runrate(0,a.cityid,0,a.campaignid) desc,a.minprice) oapc,
			a.adid,a.mode,a.campaignid,a.cityid,
			t.attributevaluecount,
			t.attributecount
		from dbo.adsNeedMapping(nolock)  a
			inner join @tblads t on a.adid = t.adid 
		) a where dup=1   
		) 
		,Ads_need_attribute                              
		as                              
		(                              
		select 
			row_number() over (order by 
					oapc,mode desc,dbo.fn_get_runrate(0,cityid,0,campaignid) desc
					) as RowID,adid
		from (                              
		select 
			row_number() over (partition by an.adid order by an.adid) as dup,
			an.adid,an.oapc,an.mode,an.campaignid,an.attributevaluecount,an.attributecount,an.cityid
		from Ads_need an 
		) a where a.dup=1 
		)
		Insert into #adid(adid,rowid,listingsection)    
		select top(( @RowsToFetch) + @morerecords)  
			b.adid,RowID,3
		from Ads_need_attribute b              
		where RowID > ((@PageNo - 1) * @RowsToFetch) 
		order by RowID
		


end

set nocount off

end
GO
