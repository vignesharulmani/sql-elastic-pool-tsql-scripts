/****** Object:  StoredProcedure [dbo].[prc_get_projectunitgroups_projectlistings]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_projectunitgroups_projectlistings]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_projectunitgroups_projectlistings] AS'
END
GO
Alter procedure prc_get_projectunitgroups_projectlistings
@projectids varchar(1024),
@rowstofetch int = 4
as
begin

begin try

declare @lv_projectids varchar(1024)=@projectids
declare @lv_rowstofetch int=@rowstofetch

drop table if exists #prjads
drop table if exists #output

create table #prjads(adid bigint,projectid bigint)

create table #output(projectid bigint,propertytypevalueid int,bedroomsvalueid int
						,minarea int,maxarea int,areaunit varchar(64)
						,minprice money,maxprice money)


insert into #prjads(adid,projectid)
select am.adid,am.projectid 
	from dbo.adsmaster am (nolock) 
		join string_split(@lv_projectids,',')ss on am.projectid = ss.value
		cross apply dbo.fn_get_projectbusinessmapping(am.projectid,am.businessid) pbm
where am.contentid > 0 and am.projectid > 0 and am.status = 1 
and pbm.customertypevalueid = 1036002 /*Builder Only*/


;with cte_flats
as
(
select asam.adid,pa.projectid,attributevalueid propertytypevalueid 
from dbo.adssubcatattributemapping asam (nolock) 
	join #prjads pa on pa.adid = asam.adid
where asam.attributevalueid = 1027500 /*propertytype : flats*/
)
insert into #output(projectid,propertytypevalueid,bedroomsvalueid
					,minarea,maxarea,areaunit,minprice,maxprice)
select c.projectid,c.propertytypevalueid,asam.attributevalueid bedroomsvalueid,
				min(areavalue),max(areavalue),min(areavalueunit),min(minprice),max(minprice)
from dbo.adsneedmapping anm (nolock)
	join dbo.adssubcatattributemapping asam (nolock) on anm.adid = asam.adid
	join cte_flats c on c.adid = anm.adid
where anm.areavalue > 0
and asam.attributeid = 281501 /*filter bedroom attribute alone for grouping*/
group by c.projectid,c.propertytypevalueid,asam.attributevalueid 


;with cte_villas
as
(
select asam.adid,pa.projectid,attributevalueid propertytypevalueid 
from dbo.adssubcatattributemapping asam (nolock) 
	join #prjads pa on pa.adid = asam.adid
where asam.attributevalueid = 1027600 /*propertytype : villas*/
)
insert into #output(projectid,propertytypevalueid,bedroomsvalueid
					,minarea,maxarea,areaunit,minprice,maxprice)
select c.projectid,c.propertytypevalueid,asam.attributevalueid bedroomsvalueid,
				min(areavalue),max(areavalue),min(areavalueunit),min(minprice),max(minprice)
from dbo.adsneedmapping anm (nolock)
	join dbo.adssubcatattributemapping asam (nolock) on anm.adid = asam.adid
	join cte_villas c on c.adid = anm.adid
where anm.areavalue > 0
and asam.attributeid = 281501 /*filter bedroom attribute alone for grouping*/
group by c.projectid,c.propertytypevalueid,asam.attributevalueid 


;with cte_rowhouse
as
(
select asam.adid,pa.projectid,attributevalueid propertytypevalueid 
from dbo.adssubcatattributemapping asam (nolock) 
	join #prjads pa on pa.adid = asam.adid
where asam.attributevalueid = 1027601 /*propertytype : rowhouse*/
)
insert into #output(projectid,propertytypevalueid,bedroomsvalueid
					,minarea,maxarea,areaunit,minprice,maxprice)
select c.projectid,c.propertytypevalueid,asam.attributevalueid bedroomsvalueid,
				min(areavalue),max(areavalue),min(areavalueunit),min(minprice),max(minprice)
from dbo.adsneedmapping anm (nolock)
	join dbo.adssubcatattributemapping asam (nolock) on anm.adid = asam.adid
	join cte_rowhouse c on c.adid = anm.adid
where anm.areavalue > 0
and asam.attributeid = 281501 /*filter bedroom attribute alone for grouping*/
group by c.projectid,c.propertytypevalueid,asam.attributevalueid 


;with cte_plotsnland
as
(
select asam.adid,pa.projectid,attributevalueid propertytypevalueid 
from dbo.adssubcatattributemapping asam (nolock) 
	join #prjads pa on pa.adid = asam.adid
where asam.attributevalueid = 1027700 /*propertytype : plotsnland*/
)
insert into #output(projectid,propertytypevalueid,bedroomsvalueid
					,minarea,maxarea,areaunit,minprice,maxprice)
select c.projectid,c.propertytypevalueid,0 bedroomsvalueid,
				min(areavalue),max(areavalue),min(areavalueunit),min(minprice),max(minprice)
from dbo.adsneedmapping anm (nolock)
	join cte_plotsnland c on c.adid = anm.adid
where anm.areavalue > 0
group by c.projectid,c.propertytypevalueid


;with cte_commercialofficespace
as
(
select asam.adid,pa.projectid,attributevalueid propertytypevalueid 
from dbo.adssubcatattributemapping asam (nolock) 
	join #prjads pa on pa.adid = asam.adid
where asam.attributevalueid = 1028102 /*propertytype : Commercial Office Space/IT park*/
)
insert into #output(projectid,propertytypevalueid,bedroomsvalueid
					,minarea,maxarea,areaunit,minprice,maxprice)
select c.projectid,c.propertytypevalueid,0 bedroomsvalueid,
				min(areavalue),max(areavalue),min(areavalueunit),min(minprice),max(minprice)
from dbo.adsneedmapping anm (nolock)
	join cte_commercialofficespace c on c.adid = anm.adid
where anm.areavalue > 0
group by c.projectid,c.propertytypevalueid


;with cte_commercialshops
as
(
select asam.adid,pa.projectid,attributevalueid propertytypevalueid 
from dbo.adssubcatattributemapping asam (nolock) 
	join #prjads pa on pa.adid = asam.adid
where asam.attributevalueid = 1028200 /*propertytype : Commercial Showrooms/Shops*/
)
insert into #output(projectid,propertytypevalueid,bedroomsvalueid
					,minarea,maxarea,areaunit,minprice,maxprice)
select c.projectid,c.propertytypevalueid,0 bedroomsvalueid,
				min(areavalue),max(areavalue),min(areavalueunit),min(minprice),max(minprice)
from dbo.adsneedmapping anm (nolock)
	join cte_commercialshops c on c.adid = anm.adid
where anm.areavalue > 0
group by c.projectid,c.propertytypevalueid


;with getlist
as
(
select 
	row_number() over (partition by projectid order by projectid) rowid
	,projectid,propertytypevalueid,bedroomsvalueid
	,dbo.fn_fromsqft(minarea,areaunit) minarea,dbo.fn_fromsqft(maxarea,areaunit)maxarea,areaunit
	,minprice,maxprice
from #output
)
select projectid,propertytypevalueid,bedroomsvalueid,minarea,maxarea,isnull(nullif(areaunit,''),'Sq feet') areaunit,
minprice,maxprice
from getlist
where rowid <=@rowstofetch
--order by projectid

end try
begin catch

select top(0) projectid,propertytypevalueid,bedroomsvalueid
	,minarea,maxarea,areaunit,minprice,maxprice
from #output

exec dbo.prc_insert_errorinfo

end catch

drop table if exists #prjads
drop table if exists #output

end
GO
