/****** Object:  StoredProcedure [dbo].[prc_mng_adscount]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter PROCEDURE [dbo].[prc_mng_adscount]
AS
BEGIN
SET	NOCOUNT	ON
BEGIN TRY



--- area

TRUNCATE TABLE citysubcatneedareaadscount

/*Other than Projects*/
insert into citysubcatneedareaadscount
(cityid,areaid,subcategoryid,needid,addefid,adscount)
select cityid,isnull(areaid,0) areaid,subcategoryid,needid,addefid,COUNT(1) counts  
from dbo.adsneedmapping (nolock)
where subcategoryid > 0 and addefid <> 66600 and addefid > 0
and status = 1
group by cityid,isnull(areaid,0),subcategoryid,needid,addefid


/*Only Projects*/
insert into citysubcatneedareaadscount
(cityid,areaid,subcategoryid,needid,addefid,adscount)
select anm.cityid,isnull(anm.areaid,0) areaid,anm.subcategoryid,anm.needid,anm.addefid,COUNT(1) counts  
from dbo.adsneedmapping anm(nolock)
where subcategoryid > 0 and anm.addefid = 66600
and exists (select top 1 1 from dbo.projectbusinessmapping pbm (nolock) 
				where pbm.projectid = anm.adid and pbm.status = 1 and pbm.minprice > 0)
and anm.status = 1
group by anm.cityid,isnull(anm.areaid,0),anm.subcategoryid,anm.needid,anm.addefid



--city

TRUNCATE TABLE citysubcatneedadscount


insert into citysubcatneedadscount
(cityid,subcategoryid,needid,addefid,adscount)
select cityid,subcategoryid,needid,addefid,sum(adscount) adscount from citysubcatneedareaadscount (nolock)
group by cityid,subcategoryid,needid,addefid


-- citysubcatneedareaadscount : build stats for group locality
insert into citysubcatneedareaadscount(cityid,areaid,subcategoryid,needid,addefid,adscount)
select csac.cityid,agm.Prominentroad_areaid areaid,csac.subcategoryid
,csac.needid,csac.addefid,sum(csac.adscount)
from citysubcatneedareaadscount csac (nolock)
	join areagroupmaster agm (nolock) on csac.areaid = agm.areaid
where csac.subcategoryid in (951,9000,9600)
group by csac.cityid,agm.Prominentroad_areaid,csac.subcategoryid
,csac.needid,csac.addefid


--- area

TRUNCATE TABLE citysubcatareaadscount

insert into citysubcatareaadscount
(cityid,areaid,subcategoryid,adscount)
select cityid,areaid,subcategoryid,sum(adscount)adscount from citysubcatneedareaadscount (nolock)
where addefid not in (56900,67700,59900,66600) /*Exclude Banners & Projects*/
group by cityid,areaid,subcategoryid

--- city

TRUNCATE TABLE citysubcatadscount

insert into citysubcatadscount(cityid,subcategoryid,adscount)
select cityid,subcategoryid,sum(adscount) adscount from citysubcatareaadscount (nolock)
group by cityid,subcategoryid



-- citysubcatareaadscount : build stats for group locality
insert into citysubcatareaadscount(cityid,areaid,subcategoryid,adscount)
select csac.cityid,agm.Prominentroad_areaid areaid,csac.subcategoryid,sum(adscount)
from citysubcatareaadscount csac (nolock)
	join areagroupmaster agm (nolock) on csac.areaid = agm.areaid
where csac.subcategoryid in (951,9000,9600)
 group by csac.cityid,agm.Prominentroad_areaid ,csac.subcategoryid


---area

TRUNCATE TABLE citysubcatareaattributeadscount

insert into citysubcatareaattributeadscount
(cityid,areaid,subcategoryid,attributeid,attributevalueid,adscount)
select cityid,isnull(areaid,0) areaid,subcategoryid,attributeid,attributevalueid,COUNT(1) counts    
from dbo.adssubcatattributemapping(nolock)
where subcategoryid > 0 and attributeid >0 and attributeid is not null and attributevalueid > 0
and status = 1
group by cityid,isnull(areaid,0),subcategoryid,attributeid,attributevalueid



---city

TRUNCATE TABLE citysubcatattributeadscount

insert into citysubcatattributeadscount
(cityid,subcategoryid,attributeid,attributevalueid,adscount )
select cityid,subcategoryid,attributeid,attributevalueid,sum(adscount) adscount 
from citysubcatareaattributeadscount (nolock)
group by cityid,subcategoryid,attributeid,attributevalueid


-- citysubcatareaattributeadscount : build stats for group locality
 insert into citysubcatareaattributeadscount(cityid,areaid,subcategoryid,subcatattributemapid,attributeid,attributevalueid,adscount)
 select
 csac.cityid,agm.Prominentroad_areaid,csac.subcategoryid,csac.subcatattributemapid,
 csac.attributeid,csac.attributevalueid,sum(csac.adscount) adscount
 from citysubcatareaattributeadscount csac (nolock)
 join areagroupmaster agm (nolock) on csac.areaid = agm.areaid
 where csac.subcategoryid in (951,9000,9600)
 group by csac.cityid,agm.Prominentroad_areaid,csac.subcategoryid,csac.subcatattributemapid,
 csac.attributeid,csac.attributevalueid



--customeradscount

TRUNCATE TABLE customeradscount

insert into customeradscount(businessid,customerid,campaignid,cityid,status,adscount)
select am.businessid,am.customerid,am.campaignid,am.cityid,am.status,count(1) adscount
from dbo.adsmaster am (nolock)
where am.contentid > 0 and am.businessid > 0 and am.customerid > 0 and am.campaignid > 0
group by am.businessid,am.customerid,am.campaignid,am.cityid,am.status



--campaignmodeadscount

TRUNCATE TABLE campaignmodeadscount

insert into campaignmodeadscount(campaignid,mode,cityid,subcategoryid,adclassification,status,adscount)
select anm.campaignid,isnull(anm.mode,0) mode,anm.cityid,anm.subcategoryid,anm.adclassification,anm.status,count(1) adscount
from adsneedmapping anm (nolock)
where anm.campaignid > 0
and anm.adid > 0 and anm.cityid > 0 and anm.subcategoryid > 0 
and anm.needid > 0 and anm.addefid > 0 and anm.adclassification > 0 and anm.adclassification <> 7
group by anm.campaignid,isnull(anm.mode,0),anm.cityid,anm.subcategoryid,anm.adclassification,anm.status


insert into campaignmodeadscount(campaignid,mode,cityid,subcategoryid,adclassification,status,adscount)
select distinct pbm.campaignid,isnull(pbm.mode,0) mode,left(pbm.projectid,4)-1000 cityid, 9600 subcategoryid, 7 adclassification,pbm.status,count(distinct pbm.projectid) 
from dbo.projectbusinessmapping pbm (nolock)
where pbm.campaignid > 0
group by pbm.campaignid,isnull(pbm.mode,0),left(pbm.projectid,4),pbm.status


--campaignadscount

TRUNCATE TABLE campaignadscount

insert into campaignadscount(campaignid,cityid,subcategoryid,adclassification,status,adscount)
select cmac.campaignid,cmac.cityid,cmac.subcategoryid,cmac.adclassification,cmac.status,sum(cmac.adscount) adscount 
from campaignmodeadscount cmac (nolock)
group by cmac.campaignid,cmac.cityid,cmac.subcategoryid,cmac.adclassification,cmac.status



--useradscount

TRUNCATE TABLE useradscount

insert into useradscount(advpid,cityid,status,adscount)
select am.advpid,am.cityid,am.status,count(1) adscount
from dbo.adsmaster am (nolock)
where am.contentid > 0 and am.advpid > 0 and am.businessid = 0 
and am.customerid = 0 and am.campaignid = 0
group by am.advpid,am.cityid,am.status

END TRY

BEGIN CATCH

exec dbo.PRC_INSERT_ERRORINFO

END CATCH

END
GO
