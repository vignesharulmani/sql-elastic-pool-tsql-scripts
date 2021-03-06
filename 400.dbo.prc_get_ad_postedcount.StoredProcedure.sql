/****** Object:  StoredProcedure [dbo].[prc_get_ad_postedcount]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_ad_postedcount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_ad_postedcount] AS'
END
GO
Alter procedure prc_get_ad_postedcount
@noofdays int = 3,
@subcategoryid int
as
begin

set nocount on;

declare @adclassification int = 0
declare @attributeid int = 0 

if @subcategoryid= 9600
	select @adclassification = 6,@attributeid=281500
else if @subcategoryid= 9000
	select @adclassification = 5,@attributeid=256203
else if @subcategoryid= 951
	select @adclassification = 3,@attributeid = 6802

select a.subcategoryid,a.cityname,b.needid,e.attributevalueid,a.pagesource,count(1) counts
    From adsmaster(nolock)a
join adsneedmapping(nolock)b on a.adid = b.adid 
join adssubcatattributemapping (nolock) e on a.adid = e.adid 
where (e.attributeid = @attributeid)
and a.subcategoryid = @subcategoryid
and b.adclassification = @adclassification
and a.createddate >=cast(getdate()-@noofdays as date)
group by a.subcategoryid,a.cityname,b.needid,e.attributevalueid,a.pagesource
order by cityname

set nocount off;

end
GO
