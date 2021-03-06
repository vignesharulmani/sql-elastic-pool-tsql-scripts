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
@projectids varchar(1024)
as
begin

declare @lv_projectids varchar(1024)=@projectids

;with cte_am
as
(
select am.adid,am.projectid 
	from dbo.adsmaster am (nolock) 
		join string_split(@lv_projectids,',')ss on am.projectid = ss.value
where am.status = 1
and exists (select top 1 1 from dbo.projectbusinessmapping pbm (nolock) 
					where pbm.projectid = am.projectid 
					and am.businessid = pbm.businessid
					and pbm.customertype = 1036002 /*Builder Only*/)
),
cte_before_pivot
as
(
select am.projectid,
--dbo.fn_get_attributename_attributeid(asam.attributeid) attribute,
--dbo.fn_get_attributevaluename_attributevalueid(asam.attributevalueid) attributevalue,
asam.attributeid,asam.attributevalueid,
min(anm.areavalue) minarea,max(anm.areavalue) maxarea,min(anm.areavalueunit) areaunit,
min(anm.minprice) minprice,max(anm.minprice) maxprice
from dbo.adsneedmapping anm (nolock)
	join dbo.adssubcatattributemapping asam (nolock) on anm.adid = asam.adid
	join cte_am am on am.adid = anm.adid
where asam.attributeid in (281501,281500) /*Bedroom & propertytype wise grouping*/
group by am.projectid,asam.attributeid,asam.attributevalueid
)
SELECT projectid, [281500] propertytypevalueid,
[281501] bedroomsvalueid,minarea,maxarea,areaunit,minprice,maxprice FROM   
(SELECT projectid,attributeid,attributevalueid,minarea,maxarea,areaunit,minprice,maxprice 
	FROM cte_before_pivot )t1  
PIVOT  
(  
min(attributevalueid) FOR attributeid IN ([281500],[281501])) AS t2  
order by projectid

end 
GO
