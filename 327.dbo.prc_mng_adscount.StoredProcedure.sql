/****** Object:  StoredProcedure [dbo].[prc_mng_adscount]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[prc_mng_adscount]
AS
BEGIN
SET	NOCOUNT	ON
BEGIN TRY


--- city

TRUNCATE TABLE citysubcatadscount

insert into citysubcatadscount(cityid,subcategoryid,adscount)
select cityid,subcategoryid,COUNT(1) counts
from dbo.adssubcatmapping(nolock)
where status = 1
group by cityid,subcategoryid



--- area

TRUNCATE TABLE citysubcatareaadscount

insert into citysubcatareaadscount
(cityid,areaid,subcategoryid,adscount)
select cityid,areaid,subcategoryid,COUNT(1) counts
from dbo.adssubcatmapping(nolock)
where areaid > 0
and status = 1
group by cityid,subcategoryid,areaid


--city

TRUNCATE TABLE citysubcatneedadscount

insert into citysubcatneedadscount
(cityid,subcategoryid,needid,addefid,adscount)
select cityid,subcategoryid,needid,addefid,COUNT(1) counts  
from dbo.adsneedmapping (nolock)
where status = 1
group by cityid,subcategoryid,needid,addefid


--- area

TRUNCATE TABLE citysubcatneedareaadscount

insert into citysubcatneedareaadscount
(cityid,areaid,subcategoryid,needid,addefid,adscount)
select cityid,areaid,subcategoryid,needid,addefid,COUNT(1) counts  
from dbo.adsneedmapping (nolock)
where areaid > 0
and status = 1
group by cityid,subcategoryid,needid,addefid,areaid



---city

TRUNCATE TABLE citysubcatattributeadscount

insert into citysubcatattributeadscount
(cityid,subcategoryid,attributeid,attributevalueid,adscount )
select cityid,subcategoryid,attributeid,attributevalueid,COUNT(1) counts    
from dbo.adssubcatattributemapping(nolock)
where attributeid >0 and attributeid is not null 
and status = 1
group by 
cityid,subcategoryid,attributeid,attributevalueid


---area

TRUNCATE TABLE citysubcatareaattributeadscount

insert into citysubcatareaattributeadscount
(cityid,areaid,subcategoryid,attributeid,attributevalueid,adscount)
select cityid,areaid,subcategoryid,attributeid,attributevalueid,COUNT(1) counts    
from dbo.adssubcatattributemapping(nolock)
where areaid > 0 and attributeid >0 and attributeid is not null 
and status = 1
group by cityid,subcategoryid,attributeid,attributevalueid,areaid

--customeradscount

TRUNCATE TABLE customeradscount

insert into customeradscount(businessid,customerid,campaignid,cityid,status,adscount)
select am.businessid,am.customerid,am.campaignid,am.cityid,am.status,count(1) adscount
from dbo.adsmaster am (nolock)
where am.contentid > 0 and am.businessid > 0 and am.customerid > 0 and am.campaignid > 0
group by am.businessid,am.customerid,am.campaignid,am.cityid,am.status


--campaignadscount

TRUNCATE TABLE campaignadscount

insert into campaignadscount(campaignid,cityid,subcategoryid,adclassification,status,adscount)
select anm.campaignid,anm.cityid,anm.subcategoryid,anm.adclassification,anm.status,count(1) adscount
from adsneedmapping anm (nolock)
where anm.campaignid > 0
and anm.adid > 0 and anm.cityid > 0 and anm.subcategoryid > 0 
and anm.needid > 0 and anm.addefid > 0 and anm.adclassification > 0
group by anm.campaignid,anm.cityid,anm.subcategoryid,anm.adclassification,anm.status


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
